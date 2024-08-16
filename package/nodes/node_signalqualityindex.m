% -------------------------------------------------------------------------
% Calculate signal quality index
cfg = struct();
cfg.windowlength = 30; % seconds
cfg.overlap = 75; % percent (use 100 to shift window sample-by-sample)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('signalqualityindex', cfg);
pipe = [pipe; node];