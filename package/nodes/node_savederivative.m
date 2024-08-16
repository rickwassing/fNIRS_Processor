% -------------------------------------------------------------------------
% Save processed data to derivatives
cfg = struct();
cfg.derivative = 'preproc';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('savederivative', cfg); % no configuration required
pipe = [pipe; node];