% -------------------------------------------------------------------------
% Import synced EXG channels
cfg.sourcefile = '/Users/rickwassing/Local/NeuroVosa/sourcedata/sub-nv01/ses-bl/eeg/sub-nv01_ses-bl_task-psg_eeg.edf';
cfg.nirssyncchan = 'buttons';
cfg.exgsyncchan = 'sync';
cfg.selchans = {'ECG'};
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('importsyncedexgchannels', cfg);
pipe = [pipe; node];