% -------------------------------------------------------------------------
% Convert intensity to optical density
node = fni_node('raw2dod', []); % no configuration required
pipe = [pipe; node];