% =========================================================================
% INITIALIZE
cd(fileparts(matlab.desktop.editor.getActiveFilename))
pipe = fni_init();
% -------------------------------------------------------------------------
% Root directory of your BIDS dataset
bidsroot = '/Volumes/sleep/Sleep/3. ACTIVE STUDIES/Brain Cleaning in OSA/07.Data';
cd(bidsroot);

% =========================================================================
% CREATE PIPELINE

% -------------------------------------------------------------------------
% Import FNIRS data
cfg = struct();
cfg.datasetname = 'BrainCleaning';
cfg.manufacturer = 'Artenis'; % 'Artenis' or 'Cortivision'
cfg.manufacturersmodelname = 'PortaLight MKII'; % 'PortaLight MKII' or 'Photon cap'
cfg.sourcefile = '/Volumes/sleep/Sleep/3. ACTIVE STUDIES/Brain Cleaning in OSA/07.Data/sourcedata/sub-r02/ses-cpapon/nirs/bcosa_fnirs_r002_rs.edf';
cfg.sub = 'r02'; % subject id
cfg.ses = 'cpapon'; % session label
cfg.task = 'rs'; % task name
cfg.participants.age = 21;
cfg.participants.sex = 'm';
cfg.bidsroot = [bidsroot, '/rawdata'];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('import', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Import synced EXG channels
cfg = struct();
cfg.sourcefile = '/Volumes/sleep/Sleep/3. ACTIVE STUDIES/Brain Cleaning in OSA/07.Data/sourcedata/sub-r02/ses-cpapon/psg/sub-r02_ses-cpapon_task-rs_eeg.edf';
cfg.nirssyncchan = 'sync';
cfg.exgsyncchan = 'sync';
cfg.selchans = {'ECG_old'};
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('importsyncedexgchannels', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Calculate instantaneous heart-rate
cfg = struct();
cfg.source = 'ECG_old';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('calcinstantaneousheartrate', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Convert intensity to optical density
node = fni_node('raw2dod', []); % no configuration required
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Correct motion artefacts within each channel
cfg = struct();
cfg.source = 'dod';
cfg.iqr = 1.5; % used to detect outliers
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('correctmotionwithwavelet', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Detect remaining motion artefacts within each channel
cfg = struct();
cfg.source = 'dod_mc'; % Detect remaining motion artefacts in motion corrected channels
cfg.ampthres = 0.20; % mark artefact if signal changes more than 'ampthres' over timeperiod 'tmotion'
cfg.stdthres = 40; % mark artefact if signal changes more than 'stdthres' * std(data) over timeperiod 'tmotion'
cfg.tmotion = 0.5; % seconds, timeperiod to check
cfg.tmask = 1; % seconds, mask +/- 'tmask' seconds around identified motion as artefact
node = fni_node('detectmotionartefactbychannel', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply bandpass filter to delta-optical density timeseries
cfg = struct();
cfg.source = 'dod_mc'; % apply bandpass filter to 'dod_mc'
cfg.hpf = 1/60; % Hz
cfg.lpf = 5; % Hz
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('bandpassfilt', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply bandpass filter to auxiliary channels
cfg = struct();
cfg.source = 'aux'; % apply bandpass filter to 'dod_mc'
cfg.hpf = 1/60; % Hz. Note, must be equal to bandpass filter applied to 'dod'
cfg.lpf = 5; % Hz. Note, must be equal to bandpass filter applied to 'dod'
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('bandpassfilt', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Convert optical density to concentration changes
cfg = struct();
cfg.source = 'dod_mc_bpfilt'; % use 'dod_mc_bpfilt' to calculate Hb changes
cfg.age = age; % age of participant used to calculate partial path length factor
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('dod2dc', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Calculate signal quality index
cfg = struct();
cfg.source = 'dod_mc_bpfilt';
cfg.windowlength = 30; % seconds
cfg.overlap = 75; % percent (use 100 to shift window sample-by-sample)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('signalqualityindex', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Calculate power-spectrum
cfg = struct();
cfg.source = 'dod_mc'; % apply powerspectral analysis to 'dod_mc'
cfg.windowlength = 60; % seconds
cfg.overlap = 50; % percent
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('powerspectralanalysis', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply General Linear Model
cfg = struct();
cfg.stimlabel = {'qrs'}; % label(s) of the stimulus to model
cfg.contrast = 1;
cfg.window = [-3, 6];
cfg.auxchans = {'gyro', 'accel'};
cfg.baselinewindow = [0, 60]; % seconds
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('glmtimeseries', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph channel quality figures
node = fni_node('graphchannelquality', []); % no configuration required
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph GLM nuisance regression
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphglmtimeseries', []); % no configuration required
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph individual trial quality figures across channels
cfg = struct();
cfg.source = 'dc';
cfg.window = [-3, 6];
cfg.sschandist = 15;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphtrialsacrosschans', cfg);
pipe = [pipe; node];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cfg = struct();
cfg.source = 'glm';
cfg.window = [-3, 6];
cfg.sschandist = 15;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphtrialsacrosschans', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Save processed data to derivatives
cfg = struct();
cfg.derivative = 'preproc';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('savederivative', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph trial quality figures within each channel
cfg = struct();
cfg.source = 'dc';
cfg.window = [-3, 6];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphtrialswithinchan', cfg);
pipe = [pipe; node];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% The same, but now after short-separated channel regression
cfg = struct();
cfg.source = 'glm';
cfg.window = [-3, 6];
cfg.sschandist = 15;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphtrialswithinchan', cfg);
pipe = [pipe; node];

% =========================================================================
% RUN
[data, log] = fni_run(pipe);

