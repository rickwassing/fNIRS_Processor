% -------------------------------------------------------------------------
% Import FNIRS data
cfg = struct();
cfg.datasetname = 'NeuroVosa';
cfg.manufacturer = 'Artenis'; % 'Artenis' or 'Cortivision'
cfg.manufacturersmodelname = 'PortaLight MKII'; % 'PortaLight MKII' or 'Photon cap'
cfg.sourcefile = '/Volumes/sleep/Sleep/3. ACTIVE STUDIES/NeuroVOSA/07. Data/sourcedata/sub-nv01/ses-bl/fnirs/sub-nv01_ses-bl_task-psg_fnirs.edf';
cfg.sub = 'nv01'; % subject id
cfg.ses = 'bl'; % session label
cfg.task = 'psg'; % task name
cfg.participants.age = 21;
cfg.participants.sex = 'm';
cfg.bidsroot = [bidsroot, '/rawdata'];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('import', cfg);
pipe = [pipe; node];