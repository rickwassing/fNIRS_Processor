% -------------------------------------------------------------------------
% Apply General Linear Model
cfg = struct();
cfg.stimlabel = {'x1'}; % label(s) of the stimulus to model
cfg.contrast = 1;
cfg.window = [-15, 60];
cfg.auxchans = {'gyro', 'accel'};
cfg.baselinewindow = [0, 60]; % seconds
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('glmtimeseries', cfg);
pipe = [pipe; node];