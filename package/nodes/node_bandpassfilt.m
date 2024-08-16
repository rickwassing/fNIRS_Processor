% -------------------------------------------------------------------------
% Apply bandpass filter
cfg = struct();
cfg.source = 'dod'; % apply bandpass filter to 'dod'
cfg.hpf = 1/60; % Hz
cfg.lpf = 1/2; % Hz
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('bandpassfilt', cfg);
pipe = [pipe; node];