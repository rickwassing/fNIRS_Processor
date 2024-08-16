% -------------------------------------------------------------------------
% Calculate power-spectrum
cfg = struct();
cfg.source = 'dod'; % apply powerspectral analysis to 'dod'
cfg.windowlength = 60; % seconds
cfg.overlap = 50; % percent
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('powerspectralanalysis', cfg);
pipe = [pipe; node];