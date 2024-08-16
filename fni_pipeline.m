% =========================================================================
% INITIALIZE
cd(fileparts(matlab.desktop.editor.getActiveFilename))
pipe = fni_init();
% -------------------------------------------------------------------------
% Root directory of your BIDS dataset
bidsroot = '/Volumes/sleep/Sleep/3. ACTIVE STUDIES/Brain Cleaning in OSA/07.Data';
cd(bidsroot);

%% =========================================================================
% CREATE PIPELINE

% -------------------------------------------------------------------------
% Import FNIRS data
cfg = struct();
cfg.datasetname = 'NeuroVosa';
cfg.manufacturer = 'Cortivision'; % 'Artenis' or 'Cortivision'
cfg.manufacturersmodelname = 'Photon cap'; % 'PortaLight MKII' or 'Photon cap'
cfg.sourcefile = '/Volumes/NO NAME/sub-a-test_ses-1_task-stroopcolor_run-1_fnirs_20231206-145047.snirf';
cfg.sub = 'a'; % subject id
cfg.ses = 'bl'; % session label
cfg.task = 'stroop'; % task name
cfg.participants.age = 21;
cfg.participants.sex = 'm';
cfg.bidsroot = [bidsroot, '/rawdata']; % don't change
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('import', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Convert intensity to optical density
node = fni_node('raw2dod', []); % no configuration required
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Correct motion artefacts within each channel
cfg = struct();
cfg.iqr = 1.5; % used to detect outliers
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('correctmotionwithwavelet', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Detect remaining motion artefacts within each channel
% Parameters obtained from https://doi.org/10.1016/j.neuroimage.2019.116472
cfg = struct();
cfg.ampthres = 5; % mark artefact if signal changes more than 'ampthres' over timeperiod 'tmotion'
cfg.stdthres = 30; % mark artefact if signal changes more than 'stdthres' * std(data) over timeperiod 'tmotion'
cfg.tmotion = 0.5; % seconds, timeperiod to check
cfg.tmask = 1; % seconds, mask +/- 'tmask' seconds around identified motion as artefact
node = fni_node('detectmotionartefactbychannel', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply bandpass filter
cfg = struct();
cfg.source = 'dod'; % apply bandpass filter to 'dod'
cfg.hpf = 0.02; % Hz
cfg.lpf = 0.4; % Hz
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('bandpassfilt', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Convert optical density to concentration changes
cfg = struct();
cfg.source = 'dod_bpfilt'; % use 'dod_bpfilt' to calculate Hb changes
cfg.age = 21; % age of participant used to calculate partial path length factor
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('dod2dc', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Calculate signal quality index
cfg = struct();
cfg.windowlength = 30; % seconds
cfg.overlap = 75; % percent (use 100 to shift window sample-by-sample)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('signalqualityindex', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Calculate power-spectrum
cfg = struct();
cfg.source = 'dod'; % apply powerspectral analysis to 'dod'
cfg.windowlength = 60; % seconds
cfg.overlap = 50; % percent
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('powerspectralanalysis', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply General Linear Model
cfg = struct();
cfg.stimlabel = {'x1'}; % label(s) of the stimulus to model
cfg.window = [-12, 24];
cfg.auxchans = {'gyro', 'accel'};
cfg.baselinewindow = [0, 60]; % seconds
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('glmtimeseries', cfg);
pipe = [pipe; node];

% % -------------------------------------------------------------------------
% % Graph channel quality figures
% node = fni_node('graphchannelquality', []);
% pipe = [pipe; node];

% % -------------------------------------------------------------------------
% % Graph individual trial quality figures
% cfg = struct();
% cfg.eventlabels = {'x1', 'x2'};
% cfg.window = [-12, 30];
% % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% node = fni_node('graphtrialquality', []);
% pipe = [pipe; node];

% -------------------------------------------------------------------------
% Save processed data to derivatives
cfg = struct();
cfg.derivative = 'preproc';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('savederivative', cfg);
pipe = [pipe; node];

% =========================================================================
% RUN
[data, log] = fni_run(pipe);

bids_website(bidsroot)
