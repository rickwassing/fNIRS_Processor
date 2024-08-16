% FNI_RAW2DOD
% Converts raw intensity data to optical density
%
% Usage:
%   >> [data, log] = fni_raw2dod(data);
%
% Inputs:
%   'data.raw' - [SnirfClass] Homer3 data class
%
% Outputs: 
%   'data.dod' - [DataClass] Homer3 data class
%   'log' - [cell] errors and warnings

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-03-31, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function [data, log] = fni_raw2dod(data)
% =========================================================================
% INITIALIZE
log = {};
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: converting optical intensity to density\n');
% =========================================================================
% EXECUTE
data.dod = hmrR_Intensity2OD(data.raw.data);
% =========================================================================
% History
cfg.fcn = 'raw2dod';
data = fni_history(data, cfg);
end