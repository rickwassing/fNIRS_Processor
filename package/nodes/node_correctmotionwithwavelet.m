% -------------------------------------------------------------------------
% Correct motion artefacts within each channel
cfg = struct();
cfg.iqr = 1.5; % used to detect outliers
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
node = fni_node('correctmotionwithwavelet', cfg);
pipe = [pipe; node];