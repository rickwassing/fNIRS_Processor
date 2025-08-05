% =========================================================================
% INITIALIZE
cd(fileparts(matlab.desktop.editor.getActiveFilename))
pipe = fni_init();

% -------------------------------------------------------------------------
% Root directory of your BIDS dataset (Windows path)
bidsroot = 'Y:\\Sleep\\3. ACTIVE STUDIES\\Brain Cleaning in OSA\\07.Data';

if ~isfolder(bidsroot)
    error('The folder %s does not exist. Please check the path.', bidsroot);
end
cd(bidsroot);

% =========================================================================
% CREATE PIPELINE

% -------------------------------------------------------------------------
% Import FNIRS data
cfg = struct();
cfg.datasetname = 'BrainCleaning';
cfg.manufacturer = 'Artenis'; % 'Artenis' or 'Cortivision'
cfg.manufacturersmodelname = 'PortaLight MKII'; % 'PortaLight MKII' or 'Photon cap'
cfg.sourcefile = fullfile(bidsroot, 'sourcedata', 'sub-r02', 'ses-cpapon', 'nirs', 'bcosa_fnirs_r002_rs.edf');
cfg.sub = 'r02';
cfg.ses = 'cpapon';
cfg.task = 'rs';
cfg.participants.age = 21;
cfg.participants.sex = 'm';
cfg.bidsroot = fullfile(bidsroot, 'rawdata');
node = fni_node('import', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Import synced EXG channels
cfg = struct();
cfg.sourcefile = fullfile(bidsroot, 'sourcedata', 'sub-r02', 'ses-cpapon', 'psg', 'sub-r02_ses-cpapon_task-rs_eeg.edf');
cfg.nirssyncchan = 'sync';
cfg.exgsyncchan = 'sync';
cfg.selchans = {'ECG_old'};
node = fni_node('importsyncedexgchannels', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Calculate instantaneous heart-rate
cfg = struct();
cfg.source = 'ECG_old';
node = fni_node('calcinstantaneousheartrate', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Convert intensity to optical density
node = fni_node('raw2dod', []);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Correct motion artefacts within each channel
cfg = struct();
cfg.source = 'dod';
cfg.iqr = 1.5;
node = fni_node('correctmotionwithwavelet', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Detect remaining motion artefacts within each channel
cfg = struct();
cfg.source = 'dod_mc';
cfg.ampthres = 0.20;
cfg.stdthres = 40;
cfg.tmotion = 0.5;
cfg.tmask = 1;
node = fni_node('detectmotionartefactbychannel', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply bandpass filter to delta-optical density timeseries
cfg = struct();
cfg.source = 'dod_mc';
cfg.hpf = 1/60;
cfg.lpf = 5;
node = fni_node('bandpassfilt', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply bandpass filter to auxiliary channels
cfg = struct();
cfg.source = 'aux';
cfg.hpf = 1/60;
cfg.lpf = 5;
node = fni_node('bandpassfilt', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Convert optical density to concentration changes
cfg = struct();
cfg.source = 'dod_mc_bpfilt';
cfg.age = 21; % from earlier config
node = fni_node('dod2dc', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Calculate signal quality index
cfg = struct();
cfg.source = 'dod_mc_bpfilt';
cfg.windowlength = 30;
cfg.overlap = 75;
node = fni_node('signalqualityindex', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Calculate power-spectrum
cfg = struct();
cfg.source = 'dod_mc';
cfg.windowlength = 60;
cfg.overlap = 50;
node = fni_node('powerspectralanalysis', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply General Linear Model
cfg = struct();
cfg.stimlabel = {'qrs'};
cfg.contrast = 1;
cfg.window = [-3, 6];
cfg.auxchans = {'gyro', 'accel'};
cfg.baselinewindow = [0, 60];
node = fni_node('glmtimeseries', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph channel quality figures
node = fni_node('graphchannelquality', []);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph GLM nuisance regression
node = fni_node('graphglmtimeseries', []);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph individual trial quality figures across channels
cfg = struct();
cfg.source = 'dc';
cfg.window = [-3, 6];
cfg.sschandist = 15;
node = fni_node('graphtrialsacrosschans', cfg);
pipe = [pipe; node];

cfg = struct();
cfg.source = 'glm';
cfg.window = [-3, 6];
cfg.sschandist = 15;
node = fni_node('graphtrialsacrosschans', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Save processed data to derivatives
cfg = struct();
cfg.derivative = 'preproc';
node = fni_node('savederivative', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph trial quality figures within each channel
cfg = struct();
cfg.source = 'dc';
cfg.window = [-3, 6];
node = fni_node('graphtrialswithinchan', cfg);
pipe = [pipe; node];

cfg = struct();
cfg.source = 'glm';
cfg.window = [-3, 6];
cfg.sschandist = 15;
node = fni_node('graphtrialswithinchan', cfg);
pipe = [pipe; node];

% =========================================================================
% RUN
[data, log] = fni_run(pipe);
