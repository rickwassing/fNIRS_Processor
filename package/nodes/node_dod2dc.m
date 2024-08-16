% -------------------------------------------------------------------------
% Convert optical density to concentration changes
cfg = struct();
cfg.source = 'dod_bpfilt'; % use 'dod_bpfilt' to calculate Hb changes
cfg.age = 21; % age of participant used to calculate partial path length factor
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('dod2dc', cfg);
pipe = [pipe; node];