% -------------------------------------------------------------------------
% Graph individual trial quality figures
cfg = struct();
cfg.eventlabels = {'x1', 'x2'};
cfg.window = [-12, 30];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('graphtrialquality', []);
pipe = [pipe; node];