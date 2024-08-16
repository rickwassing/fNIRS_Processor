% FNI_DOD2DC
% Converts optical density to hemoglobin concentration changes.
%
% Usage:
%   >> [data, log] = fni_dod2dc(data);
%
% Inputs:
%   'data.dod[_bpfilt]' - [DataClass] Homer3 data class
%   'data.raw.probe' - [ProbeClass] Homer3 probe class
%   'cfg' - [struct] configuration with the fields
%       'source' - [char] the data class to apply the dc conversion to
%       'age' - [double] age of the participant
%          or
%       'dpf' - [double] differential pathlength factor
%
% Outputs: 
%   'data.dc' - [DataClass] Homer3 data class
%   'log' - [cell] errors and warnings

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-09-01, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function [data, log] = fni_dod2dc(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: converting optical intensity to density\n');
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Calculate differential path length factor (if not already provided)
if ~isfield(cfg, 'dpf')
    cfg.dpf = ones(1, length(data.raw.probe.wavelengths));
    for i = 1:length(data.raw.probe.wavelengths)
        cfg.dpf(i) = getdiffpathlengthfactor(data.raw.probe.wavelengths(i), cfg.age);
    end
end
% -------------------------------------------------------------------------
% Convert to concentration changes
data.dc = hmrR_OD2Conc(data.(cfg.source), data.raw.probe, cfg.dpf);
% =========================================================================
% History
data = fni_history(data, cfg);
end