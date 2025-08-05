% =========================================================================
% NOTES
% -------------------------------------------------------------------------
% This pipeline is used to preprocess and analyse subject-level FNIRS data
% from the NeuroVOSA study. The following tasks were performed:
% - Fingertapping: 
%       padding = 210 s, stimulus = 12 s, ISI = 17 s
% - N-Back:
%       padding = 210 s, stimulus = 24 s, ISI = 39 s
% - Stroop (text and colour): 
%       padding = 60 s, stimulus = 18 s, ISI = 32 s
% - Breath-hold: 
%       padding = 60 s, stimulus = variable, ISI = minimum 60 s

% =========================================================================
% INITIALIZE
cd(fileparts(matlab.desktop.editor.getActiveFilename))
pipe = fni_init();
% -------------------------------------------------------------------------
% Root directory of your BIDS dataset
bidsroot = '/Volumes/sleep/Sleep/3. ACTIVE STUDIES/NeuroVOSA/07. Data';
cd(bidsroot);

% -------------------------------------------------------------------------
% Add Patient demographics 
age = 31;

% =========================================================================
% CREATE PIPELINE

% -------------------------------------------------------------------------
% Import FNIRS data
cfg = struct();
cfg.datasetname = 'NeuroVosa';
cfg.manufacturer = 'Cortivision'; % 'Artenis' or 'Cortivision'
cfg.manufacturersmodelname = 'Photon cap'; % 'PortaLight MKII' or 'Photon cap'
cfg.sourcefile = '/Volumes/sleep/Sleep/3. ACTIVE STUDIES/NeuroVOSA/07. Data/sourcedata/sub-nv10/ses-fu/fnirs/sub-nv10_ses-1_task-2back_run-1_fnirs_20240712-114046.snirf';
cfg.sub = 'nv10'; % subject id
cfg.ses = 'fu'; % session label
cfg.task = '2back'; % 'psg', 'rspm', 'rsam', '2back', 'breathhold', 'fingertap', 'stroopcolor', or 'strooptext'
cfg.participants.age = age;
cfg.participants.sex = 'm';
cfg.bidsroot = [bidsroot, '/rawdata']; % Don't change
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
cfg.lpf = 1/2; % Hz
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('bandpassfilt', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Apply bandpass filter to auxiliary channels
cfg = struct();
cfg.source = 'aux'; % apply bandpass filter to 'dod_mc'
cfg.hpf = 1/60; % Hz. Note, must be equal to bandpass filter applied to 'dod'
cfg.lpf = 1/2; % Hz. Note, must be equal to bandpass filter applied to 'dod'
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
cfg.stimlabel = {'x1'}; % label(s) of the stimulus to model
cfg.contrast = 1;
cfg.window = [-9, 24];
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
% Graph trial quality figures within each channel
cfg = struct();
cfg.source = 'dc';
cfg.window = [-9, 24];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphtrialswithinchan', cfg);
pipe = [pipe; node];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% The same, but now after short-separated channel regression
cfg = struct();
cfg.source = 'glm';
cfg.window = [-9, 24];
cfg.sschandist = 15;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphtrialswithinchan', cfg);
pipe = [pipe; node];

% -------------------------------------------------------------------------
% Graph individual trial quality figures across channels
cfg = struct();
cfg.source = 'dc';
cfg.window = [-9, 24];
cfg.sschandist = 15;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphtrialsacrosschans', cfg);
pipe = [pipe; node];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cfg = struct();
cfg.source = 'glm';
cfg.window = [-9, 24];
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

% =========================================================================
% RUN
data = fni_run(pipe, 'bidsroot', bidsroot);
