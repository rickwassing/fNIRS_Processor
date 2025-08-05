function [data, log] = fni_importsyncedexgchannels(data, cfg)
% =========================================================================
% Syncs EXG recording to fNIRS using respective sync channels and
% adds selected EXG channels to data.exg
% =========================================================================

fprintf('>> ======================================================\n');
fprintf('>> FNI: Running ''importsyncedexgchannels'' (%s)\n', datestr(now, 'dd-mm-yyyy HH:MM:SS'));
log = {};

% Check config
cfg = fni_defaultcfg(cfg, data);

fprintf('>> FNI: syncing and importing %i channels from EXG recording ''%s''.\n', length(cfg.selchans), cfg.sourcefile);

% Load EXG
exg = edf2fieldtrip(cfg.sourcefile);
fprintf('>> FNI: loaded EXG from %s\n', cfg.sourcefile);

% Extract sync channels
s = struct();

% --- NIRS sync ---
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
        error('>> FNI: Unsupported NIRS sync channel type: ''%s''.', type);
end

% Rogue sync override
if contains(data.info.sourcefile, 'sub-nv01_ses-bl_task-psg_fnirs.edf')
    s.nirs.trial{1}(1:20000) = min(s.nirs.trial{1}(1:20000));
end

% --- EXG sync and selected channels ---
idxsync = find(strcmpi(exg.label, cfg.exgsyncchan));
idxselchan = find(ismember(exg.label, cfg.selchans));
if isempty(idxsync)
    error('>> FNI: Could not find sync-channel ''%s'' in the EXG recording.', cfg.exgsyncchan);
end
if length(idxselchan) ~= length(cfg.selchans)
    error('>> FNI: Not all requested EXG channels found.');
end

s.exg.label = [{cfg.exgsyncchan}, cfg.selchans];
s.exg.time = exg.time;
s.exg.trial = {exg.trial{1}([idxsync, idxselchan], :)};
s.exg.fsample = exg.fsample;
s.exg.sampleinfo = [1, length(exg.time{1})];

% --- Resample to match frequency ---
resamplecfg = struct('detrend','no','sampleindex','yes');
if s.exg.fsample > s.nirs.fsample
    resamplecfg.resamplefs = s.exg.fsample;
    s.nirs = ft_resampledata(resamplecfg, s.nirs);
elseif s.nirs.fsample > s.exg.fsample
    resamplecfg.resamplefs = s.nirs.fsample;
    s.exg = ft_resampledata(resamplecfg, s.exg);
end

s.nirs.trial = s.nirs.trial{1};
s.exg.trial = s.exg.trial{1};

% --- Filtering EXG sync channel ---
if ~strcmpi(cfg.nirssyncchan, 'buttons')
    s.exg.trial(1,:) = ft_preproc_bandstopfilter(abs(s.exg.trial(1,:)), s.exg.fsample, [40 60]);
    s.exg.trial(1,:) = ft_preproc_lowpassfilter(abs(s.exg.trial(1,:)), s.exg.fsample, 50);
end

% --- Save original before thresholding ---
s.nirs.trial = [s.nirs.trial; s.nirs.trial(1,:)];
s.exg.trial = [s.exg.trial; s.exg.trial(1,:)];
s.nirs.label = [s.nirs.label, {'sync_orig'}];
s.exg.label = [s.exg.label, {'sync_orig'}];

% --- Z-score + threshold ---
s.exg.trial(1,:) = 0.98 .* (zscore(s.exg.trial(1,:)) > 1);
s.nirs.trial(1,:) = 0.98 .* (zscore(s.nirs.trial(1,:)) > 1);

% --- Find peaks ---
[~, s.exg.peaks] = findpeaks(s.exg.trial(1,:), 'MinPeakDistance', round(1.25 * s.exg.fsample));
[~, s.nirs.peaks] = findpeaks(s.nirs.trial(1,:), 'MinPeakDistance', round(1.25 * s.nirs.fsample));

% --- Assign blocks ---
for fld = {'nirs','exg'}
    delay = diff(s.(fld{:}).peaks);
    block = zscore(delay) < 0;
    s.(fld{:}).block = [1, nan(size(block))];
    cnt = 1;
    for i = 1:length(block)
        if block(i)==0, cnt=cnt+1; end
        s.(fld{:}).block(i+1) = cnt;
    end
end

nblocks = min([max(s.nirs.block), max(s.exg.block)]);
idxnirs = [0, 0];
idxexg = [0, 0];

fprintf('>> FNI: syncing %d blocks...\n', nblocks);

for b = 1:nblocks
    idxnirs = [idxnirs(2)+1, s.nirs.peaks(find(s.nirs.block==b,1,'last'))];
    idxexg = [idxexg(2)+1, s.exg.peaks(find(s.exg.block==b,1,'last'))];
    idx = [min([idxnirs(1), idxexg(1)]), max([idxnirs(2), idxexg(2)])];

    if any(idx > length(s.nirs.time{1}) | idx > length(s.exg.time{1}))
        error('>> FNI: Sync pulses were too close to end of EXG or NIRS recording');
    end

    trialnirs = s.nirs.trial(end, idx(1):idx(2));
    trialexg = s.exg.trial(end, idx(1):idx(2));
    [r, lags] = xcorr(trialnirs, trialexg);
    [~, idxshift] = max(r);
    shift = lags(idxshift);

    if b == 1
        if shift > 0
            s.exg.trial = [nan(size(s.exg.trial,1), shift), s.exg.trial];
        elseif shift < 0
            s.exg.trial = s.exg.trial(:, abs(shift)+1:end);
        end
    elseif abs(shift/s.nirs.fsample) > 1
        s.exg.trial(2:end-1, idx(1):idx(2)) = zeros(size(s.exg.trial,1)-2, length(idx(1):idx(2)));
        if shift > 0
            s.exg.trial = [s.exg.trial(:, 1:idx(1)), zeros(size(s.exg.trial,1), shift), s.exg.trial(:, idx(2)+1:end)];
        elseif shift < 0
            s.exg.trial(:, idx(1):idx(1)+abs(shift)-1) = [];
        end
        fprintf('>> FNI: warning! desync %.3f sec (%d samples) in block %d\n', shift/s.exg.fsample, shift, b);
    else
        idxrsmp = round(linspace(idx(1), idx(2), abs(shift)+2));
        idxrsmp = idxrsmp(2:end-1);
        if shift > 0
            for i = 1:length(idxrsmp)
                s.exg.trial = [s.exg.trial(:,1:idxrsmp(i)), nan(size(s.exg.trial,1),1), s.exg.trial(:,idxrsmp(i)+1:end)];
                for c = 1:size(s.exg.trial,1)
                    tmp = linspace(s.exg.trial(c,idxrsmp(i)), s.exg.trial(c,idxrsmp(i)+2), 3);
                    s.exg.trial(c,idxrsmp(i)+1) = tmp(2);
                end
                idxrsmp = idxrsmp + 1;
            end
            fprintf('>> FNI: interpolated %.3f ms (%d samples) in block %d\n', 1000*abs(shift)/s.exg.fsample, abs(shift), b);
        elseif shift < 0
            s.exg.trial(:, idxrsmp) = [];
            fprintf('>> FNI: removed %.3f ms (%d samples) in block %d\n', 1000*abs(shift)/s.exg.fsample, abs(shift), b);
        end
    end

    s.exg.time{1} = 0:1/s.exg.fsample:(size(s.exg.trial,2)-1)/s.exg.fsample;
    s.exg.peaks(s.exg.peaks > idx(1)) = s.exg.peaks(s.exg.peaks > idx(1)) + shift;
    idxexg = idxexg + shift;
end

% --- Crop EXG if longer than NIRS
s.nirs.xmax = data.raw.data.time(end);
s.exg.xmax = s.exg.time{1}(end);
if s.exg.xmax > s.nirs.xmax
    idx = find(s.exg.time{1} > s.nirs.xmax, 1, 'first');
    s.exg.trial = s.exg.trial(:, 1:idx);
    s.exg.time{1} = s.exg.time{1}(1:idx);
end

% --- Save figure (Windows-safe)
fig = figure('Visible','off'); fig.Position(3:4) = [500 250];
ax = axes(fig); hold(ax,'on');
for i = 1:length(s.nirs.peaks)
    X = -0.5:1/s.nirs.fsample:1;
    Y1 = s.exg.trial(end, X*s.nirs.fsample + s.nirs.peaks(i));
    Y2 = s.nirs.trial(end, X*s.nirs.fsample + s.nirs.peaks(i));
    patch(ax, 'XData', X, 'YData', zscore(Y1), 'EdgeColor', [0.6 0.07 0.18], 'FaceColor', 'none', 'EdgeAlpha', 1/nblocks);
    patch(ax, 'XData', X, 'YData', zscore(Y2), 'EdgeColor', [0.07 0.18 0.63], 'FaceColor', 'none', 'EdgeAlpha', 1/nblocks);
end
xlabel('Time (s)'); ylabel('Z-scored sync'); legend('EXG','NIRS'); box on;

[figfolder, figfile] = fileparts(data.info.outputfile);
figfolder = strrep(figfolder, [filesep 'nirs'], [filesep 'qc']);
figfile = strrep(figfile, '_nirs', '_sync.png');
if ~exist(figfolder, 'dir'), mkdir(figfolder); end
outpath = fullfile(figfolder, figfile);
exportgraphics(fig, outpath, 'Resolution', 144);
fprintf('>> FNI: wrote sync figure to ''%s''\n', outpath);
close(fig);

% --- Add to output
data.exg = struct();
for i = 2:size(s.exg.trial, 1)-1
    data.exg(i-1).label = s.exg.label{i};
    data.exg(i-1).y = s.exg.trial(i,:);
    data.exg(i-1).fs = s.exg.fsample;
    data.exg(i-1).xmin = s.exg.time{1}(1);
    data.exg(i-1).xmax = s.exg.time{1}(end);
    data.exg(i-1).chanlocs = struct();
end

% --- Log
data = fni_history(data, cfg);
fprintf('>> FNI: Completed in %.0f seconds\n', toc);
fprintf('>> ======================================================\n');

end
