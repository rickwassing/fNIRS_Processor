% FNI_IMPORTSYNCEDEXGCHANNELS
% Syncs an EXG recording to the fNIRS recording using their respective sync
% channels, and then adds selected channels to data.exg.
%
% Usage:
%   >> [data, log] = fni_importsyncedexgchannels(data, cfg);
%
% Inputs:
%   'data.raw' - [SnirfClass] raw fNIRS data
%   'cfg' - [struct] configuration with the fields
%       'sourcefile' - [char] full path to source file
%       'nirssyncchan' - [char] label of the sync-channel in fNIRS recording
%       'exgsyncchan' - [char] label of the sync-channel in EXG recording
%       'selchans' - [cell] labels of channels to import from the EXG recording
%
% Outputs:
%   'data.exg' - [struct] imported exg channels with the fields
%       'label' - [char] channel label
%       'y' - [double] <1 x n> data with n samples
%       'fs' - [integer] sampling frequency
%       'xmin' - [double] start latency in seconds
%       'xmax' - [double] end latency in seconds
%       'chanlocs' - [struct] channel locations

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-09-19, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data, log] = fni_importsyncedexgchannels(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: syncing and importing %i channels from EXG recording ''%s''.\n', length(cfg.selchans), cfg.sourcefile);
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Load EXG
exg = edf2fieldtrip(cfg.sourcefile);
% -------------------------------------------------------------------------
% Extract sync channels
s = struct();
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% For the NIRS
idx = strcmpi(data.info.channels.name, cfg.nirssyncchan);
if ~any(idx)
    error('>> FNI: Could not find sync-channel ''%s'' in the NIRS recording.', cfg.nirssyncchan);
end
type = data.info.channels.type{idx};
switch type
    case 'aux'
        idx = strcmpi({data.raw.aux.name}, cfg.nirssyncchan);
        s.nirs.label = {cfg.nirssyncchan};
        s.nirs.time = {asrow(data.raw.aux(idx).time)};
        s.nirs.trial = {asrow(data.raw.aux(idx).dataTimeSeries)};
        s.nirs.fsample = round(1/mean(diff(data.raw.aux(idx).time)));
        s.nirs.sampleinfo = [1, length(data.raw.aux(idx).time)];
    otherwise
        error('>> FNI: Sorry, I don''t support ''%s'' as a channel type to sync EXG timeseries yet. Contact ''rick.wassing@woolcock.org.au'' for more information.', type)
end
% -------------------------------------------------------------------------
% Implement exceptions for rogue sync markers
if contains(data.info.sourcefile, 'sub-nv01_ses-bl_task-psg_fnirs.edf')
    s.nirs.trial{1}(1:20000) = min(s.nirs.trial{1}(1:20000));
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% For the EXG (also extract the 'selchans')
idxsync = find(strcmpi(exg.label, cfg.exgsyncchan));
idxselchan = find(ismember(exg.label, cfg.selchans));
if isempty(idxsync)
    error('>> FNI: Could not find sync-channel ''%s'' in the EXG recording.', cfg.exgsyncchan);
end
if isempty(idxselchan) || length(idxselchan) ~= length(cfg.selchans)
    error('>> FNI: Could not find all requested channels in the EXG recording.');
end
s.exg.label = [{cfg.exgsyncchan}, cfg.selchans];
s.exg.time = exg.time;
s.exg.trial = {exg.trial{1}([idxsync, idxselchan], :)};
s.exg.fsample = exg.fsample;
s.exg.sampleinfo = [1, length(exg.time{1})];
% -------------------------------------------------------------------------
% Resample the data to the highest sampling frequency
resamplecfg = struct();
resamplecfg.detrend = 'no';
resamplecfg.sampleindex = 'yes';
if s.exg.fsample > s.nirs.fsample
    resamplecfg.resamplefs = s.exg.fsample;
    s.nirs = ft_resampledata(resamplecfg, s.nirs);
elseif s.nirs.fsample > s.exg.fsample
    resamplecfg.resamplefs = s.nirs.fsample;
    s.exg = ft_resampledata(resamplecfg, s.exg);
end
% -------------------------------------------------------------------------
% Extract for shorthand
s.nirs.trial = s.nirs.trial{1};
s.exg.trial = s.exg.trial{1};
% -------------------------------------------------------------------------
% Apply notch and low pass to EXG sync channel
if ~strcmpi(cfg.nirssyncchan, 'buttons')
    s.exg.trial(1, :) = ft_preproc_bandstopfilter(abs(s.exg.trial(1,:)), s.exg.fsample, [40 60]);
    s.exg.trial(1, :) = ft_preproc_lowpassfilter(abs(s.exg.trial(1, :)), s.exg.fsample, 50);
end
% -------------------------------------------------------------------------
% Store orig sync data before thresholding
s.nirs.trial = [s.nirs.trial; s.nirs.trial(1, :)];
s.exg.trial = [s.exg.trial; s.exg.trial(1, :)];
s.nirs.label = [s.nirs.label, {'sync_orig'}];
s.exg.label = [s.exg.label, {'sync_orig'}];
% -------------------------------------------------------------------------
% Z-score and threshold
s.exg.trial(1, :) = 0.98 .* (zscore(s.exg.trial(1, :)) > 1);
s.nirs.trial(1, :) = 0.98 .* (zscore(s.nirs.trial(1, :)) > 1);
% -------------------------------------------------------------------------
% Find peaks
[~, s.exg.peaks, s.exg.width] = findpeaks(s.exg.trial(1, :), 'MinPeakDistance', round(1.25 .* s.exg.fsample));
[~, s.nirs.peaks, s.nirs.width] = findpeaks(s.nirs.trial(1, :), 'MinPeakDistance', round(1.25 .* s.nirs.fsample));
% -------------------------------------------------------------------------
% Assign block numbers to each of the peaks
for fld = {'nirs', 'exg'}
    delay = diff(s.(fld{:}).peaks);
    block = zscore(delay) < 0;
    s.(fld{:}).block = [1, nan(size(block))];
    cnt = 1;
    for i = 1:length(block)
        if block(i) == 0
            cnt = cnt+1;
        end
        s.(fld{:}).block(i+1) = cnt;
    end
end
% -------------------------------------------------------------------------
% Initialize number of blocks and indices
nblocks = min([max(s.nirs.block), max(s.exg.block)]);
idxnirs = [0, 0];
idxexg = [0, 0];
% -------------------------------------------------------------------------
% Sync the signal iteratively for each block
for b = 1:nblocks
    % ---------------------------------------------------------------------
    % Get indices for this block
    idxnirs = [idxnirs(2)+1, s.nirs.peaks(find(s.nirs.block == b, 1, 'last'))];
    idxexg = [idxexg(2)+1, s.exg.peaks(find(s.exg.block == b, 1, 'last'))];
    idx = [min([idxnirs(1), idxexg(1)]), max([idxnirs(2), idxexg(2)])];
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Check if there is enough data
    if any(idx > length(s.nirs.time{1}) | idx > length(s.exg.time{1}))
        error('>> FNI: Sync pulses were probably too close to the end of the EXG or NIRS recording')
    end
    % ---------------------------------------------------------------------
    % Extract data for this block
    trialnirs = s.nirs.trial(end, (idx(1):idx(2))+1*s.nirs.fsample);
    trialexg = s.exg.trial(end, (idx(1):idx(2))+1*s.exg.fsample);
    % ---------------------------------------------------------------------
    % Cross correlate and get how many samples the exg signal should shift
    [r, lags] = xcorr(trialnirs, trialexg);
    [~, idxshift] = max(r);
    shift = lags(idxshift);
    % ---------------------------------------------------------------------
    % Syncing...
    if b == 1
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % if this is the first block, then either simply remove or prepend EXG data
        if shift > 0
            s.exg.trial = [nan(size(s.exg.trial, 1), shift), s.exg.trial];
        elseif shift < 0
            s.exg.trial = s.exg.trial(:, abs(shift)+1:end);
        end
    elseif abs(shift/s.nirs.fsample) > 1
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % More than 1 second desync, replace data with NaN's to prevent this data can be used
        s.exg.trial(2:end-1, idx(1):idx(2)) = zeros(size(s.exg.trial, 1)-2, length(idx(1):idx(2)));
        if shift > 0
            % we have to add n samples
            s.exg.trial = [s.exg.trial(:, 1:idx(1)), zeros(size(s.exg.trial, 1), shift), s.exg.trial(:, idx(2)+1:end)];
        elseif shift < 0
            % take away n samples
            s.exg.trial(:, idxrsmp) = [];
            str = 'removed';
        end
        fprintf('>> FNI: warning! desync was %.3f seconds (%i samples) in block %i. Data from the EXG recording between %s and %s was replaced by NaN''s.\n', ...
            shift/s.exg.fsample, ...
            shift, ...
            b, ...
            char(seconds(idx(1)/s.exg.fsample), 'hh:mm:ss.SSS'), ...
            char(seconds(idx(2)/s.exg.fsample), 'hh:mm:ss.SSS'));
    else
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % The data is already syncronized based on the first block, but the
        % data can get out of sync over time too, so here we account for that
        idxrsmp = round(linspace(idx(1), idx(2), abs(shift)+2));
        idxrsmp = idxrsmp(2:end-1);
        if shift > 0
            % we have to interpolate n samples
            for i = 1:length(idxrsmp)
                % insert nan's
                s.exg.trial = [s.exg.trial(:, 1:idxrsmp(i)), nan(size(s.exg.trial, 1), 1), s.exg.trial(:, idxrsmp(i)+1:end)];
                % for each channel, interpolate a data point
                for c = 1:size(s.exg.trial, 1)
                    tmp = linspace(s.exg.trial(c, idxrsmp(i)), s.exg.trial(c, idxrsmp(i)+2), 3);
                    s.exg.trial(c, idxrsmp(i)+1) = tmp(2);
                end
                idxrsmp = idxrsmp + 1; % to account for added sample
            end
            str = 'interpolated';
        elseif shift < 0
            % take away n samples
            s.exg.trial(:, idxrsmp) = [];
            str = 'removed';
        end
        fprintf('>> FNI: %s %.3f milliseconds (%i samples) of data from the EXG recording between %s and %s (block %i, shift %i).\n', ...
            str, ...
            1000*abs(shift)/s.exg.fsample, ...
            abs(shift), ...
            char(seconds(idx(1)/s.exg.fsample), 'hh:mm:ss.SSS'), ...
            char(seconds(idx(2)/s.exg.fsample), 'hh:mm:ss.SSS'), ...
            b, ...
            shift);
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Rescale time, peaks and index
    s.exg.time{1} = 0:1/s.exg.fsample:(size(s.exg.trial, 2)-1)/s.exg.fsample;
    s.exg.peaks(s.exg.peaks > idx(1)) = s.exg.peaks(s.exg.peaks > idx(1)) + shift;
    idxexg = idxexg + shift;
end
% -------------------------------------------------------------------------
% Crop to xmax if EXG signal is longer
s.nirs.xmax = data.raw.data.time(end);
s.exg.xmax = s.exg.time{1}(end);
if s.exg.xmax > s.nirs.xmax % crop
    idx = find(s.exg.time{1} > s.nirs.xmax, 1, 'first');
    s.exg.trial = s.exg.trial(:, 1:idx);
    s.exg.time{1} = s.exg.time{1}(1:idx);
    s.exg.xmax = s.exg.time{1}(end);
end
% -------------------------------------------------------------------------
% Create figure
close all;
fig = figure();
fig.Position(3:4) = [500 250];
ax = axes(fig);
ax.NextPlot = 'add';
clear h
for i = 1:length(s.nirs.peaks)
    XData = -0.5:1/s.nirs.fsample:1;
    YData = s.exg.trial(end, XData*s.nirs.fsample+s.nirs.peaks(i));
    h(1) = patch(ax, 'XData', [NaN, XData], 'YData', [NaN, zscore(YData)], 'FaceColor', 'none', 'EdgeColor', [0.6350, 0.0780, 0.1840], 'EdgeAlpha', 1/nblocks);
    YData = s.nirs.trial(end, XData*s.nirs.fsample+s.nirs.peaks(i));
    h(2) = patch(ax, 'XData', [NaN, XData], 'YData', [NaN, zscore(YData)], 'FaceColor', 'none', 'EdgeColor', [0.0780, 0.1840, 0.6350], 'EdgeAlpha', 1/nblocks);
end
ax.Box = 'on';
ax.XTick = -0.5:0.1:1;
ax.YTick = [];
ax.XLabel.String = 'time (s)';
ax.YLabel.String = 'sync signal (a.u.)';
legend(h, {'EXG', 'NIRS'}, 'EdgeColor', 'none')
% -------------------------------------------------------------------------
% Save figure
[figfolder, figfile] = fileparts(data.info.outputfile);
figfolder = strrep(figfolder, '/nirs', '/qc');
figfile = strrep(figfile, '_nirs', '_sync.png');
if exist(figfolder, 'dir') == 0
    mkdir(figfolder);
end
exportgraphics(fig, fullfile(figfolder, figfile), 'Resolution', 144);
fprintf('>> FNI: wrote sync figure to ''%s''.\n', fullfile(figfolder, figfile))
close all;
% =========================================================================
% Output
data.exg = struct();
for i = 2:size(s.exg.trial, 1)-1
    data.exg(i-1).label = s.exg.label{i};
    data.exg(i-1).y = s.exg.trial(i, :);
    data.exg(i-1).fs = s.exg.fsample;
    data.exg(i-1).xmin = s.exg.time{1}(1);
    data.exg(i-1).xmax = s.exg.time{1}(end);
    data.exg(i-1).chanlocs = struct();
end
% =========================================================================
% History
data = fni_history(data, cfg);
end