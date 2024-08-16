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