% FNI_CALCINSTANTANEOUSHEARTRATE
% Calculate instantaneous heart-rate from an ECG channel and inserts event
% markers (StimClass) for each detected QRS complex.
%
% Usage:
%   >> [data, log] = fni_calcinstantaneousheartrate(data, cfg);
%
% Inputs:
%   'data.exg' - [struct] external synchronized data with the fields
%       'label' - [char] channel label
%       'y' - [double | single] <1-by-pnts> channel data
%       'fs' - [integer] sampling frequency
%       'xmin' - [double] start time/latency
%       'xmax' - [double] end time/latency
%       'chanlocs' - [struct] channel location (TODO)
%   'cfg' - [struct] configuration with the fields
%       'source' - [double] label of the channel to apply function to
%       'dosaveraw' - [bool] indicator whether to re-save the rawdata or not
%
% Outputs:
%   'data.exg' - [struct] instantaneous heart-rate data
%   'data.raw.stim' - [StimClass] appended with QRS events
%   'log' - [cell] errors and warnings

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-07-05, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data, log] = fni_calcinstantaneousheartrate(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: detecting QRS events in ECG channel ''%s'' and calculating instantaneous heart rate\n', cfg.source);
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Extract ECG trace
idx_ecgchan = strcmpi({data.exg.label}, cfg.source);
if ~any(idx_ecgchan)
    error('Source channel ''%s'' not found', cfg.souce);
end
ecgtrace = data.exg(idx_ecgchan).y;
% -------------------------------------------------------------------------
% Checks and constants
if ~any(size(ecgtrace) == 1) || all(size(ecgtrace) == 1)
    error('ECG trace should be a vector')
end
% Transpose to row-vector if needed
if size(ecgtrace, 1) ~= 1
    ecgtrace = ecgtrace';
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pnts = length(ecgtrace);
fs = data.exg(idx_ecgchan).fs;
% -------------------------------------------------------------------------
% Find QRS complexes
[~, idx_qrs] = ecg2hr_pantompkin(ecgtrace, fs, 0); % 1 = do plot
% -------------------------------------------------------------------------
% Convert to BPM
bpm = 60 ./ (diff(idx_qrs) ./ fs);
% -------------------------------------------------------------------------
% Cleaning
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Remove -20 and +200 BPM
bpm(bpm < 20) = NaN;
bpm(bpm > 200) = NaN;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Calculate beat-to-beat changes in HR (percentage)
for iteration = 1:3
    db2b = 0;
    for i = 2:length(bpm)
        db2b(i) = (bpm(i) - bpm(i-1)) / bpm(i-1);
    end
    % Z-score, and find outliers (3 standard deviations)
    idx_rm = abs(nanzscore(db2b)) > 3;
    if ~any(idx_rm)
        break
    end
    % Remove beat-to-beat outliers
    bpm(idx_rm) = NaN;
    % Interpolate missing values
    idx_nan = find(isnan(bpm));
    idx_nan = [idx_nan(1), idx_nan(find(diff(idx_nan) ~= 1)+1)];
    for i = 1:length(idx_nan)
        % Find the next non-nan value
        n = find(~isnan(bpm(idx_nan(i):end)), 1, 'first') - 1;
        if isempty(n) % must be end of the signal
            bpm(idx_nan(i):end) = median(bpm, 'omitnan');
            continue
        end
        % Extract the last-known bpm
        if idx_nan(i) == 1
            x1 = median(bpm, 'omitnan');
        else
            x1 = bpm(idx_nan(i)-1);
        end
        % Extract the first-known bpm following the missing data
        if idx_nan(i) == length(bpm)
            x2 = median(bpm, 'omitnan');
        else
            x2 = bpm(idx_nan(i)+n);
        end
        x = linspace(x1, x2, n+2);
        x([1, end]) = [];
        bpm(idx_nan(i):idx_nan(i)+n-1) = x;
    end
end
% -------------------------------------------------------------------------
% Construct instantaneous HR timeseries
hr = nan(1, pnts, 'single');
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Assume the HR for the first detected QRS
hr(1:idx_qrs(1)) = bpm(1);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% For each detected QRS, create the instantaneous HR
for i = 1:length(idx_qrs)
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Start index
    x1 = idx_qrs(i);
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % End index
    if (i+1) > length(idx_qrs)
        x2 = pnts;
    else
        x2 = idx_qrs(i+1);
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Start value
    if i == 1
        y1 = bpm(1);
    else
        y1 = bpm(i-1);
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % End value
    if i > length(bpm)
        y2 = bpm(end);
    else
        y2 = bpm(i);
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Insert into timeseries vector
    if (x2 - x1 + 1) > 3*fs
        hr(x1:x2) = nan;
    else    
        hr(x1:x2) = linspace(y1, y2, x2-x1+1);
    end
end
% -------------------------------------------------------------------------
% Append instantaneous heart rate trace to the dataset
data.exg(end+1) = data.exg(idx_ecgchan);
data.exg(end).label = 'instant_hr';
data.exg(end).y = hr;
% -------------------------------------------------------------------------
% Append StimClass events
Sample = num2cell(ascolumn(idx_qrs));
Onset = num2cell(ascolumn(idx_qrs ./ data.exg(idx_ecgchan).fs));
Duration = repmat({1}, length(idx_qrs), 1);
Amplitude = repmat({1}, length(idx_qrs), 1);
Type = repmat({'qrs'}, length(idx_qrs), 1);
Tsv = [{'Onset', 'Duration', 'Amplitude', 'trial_type'}; Onset, Duration, Amplitude, Type];
data.raw.bids.stim = [data.raw.bids.stim; Onset, Duration, Sample, Type, Amplitude];
data.raw.stim(end+1) = StimClass(Tsv);
% -------------------------------------------------------------------------
% Save to raw data
if cfg.dosaveraw
    % Save data
    SnirfSave(data.info.outputfile, data.raw)
    % And save events
    Tsv = cell2table(data.raw.bids.stim(2:end, :));
    Tsv.Properties.VariableNames = data.raw.bids.stim(1, :);
    ft_write_tsv(strrep(data.info.outputfile, '_nirs.snirf', '_events.tsv'), Tsv);
end

end