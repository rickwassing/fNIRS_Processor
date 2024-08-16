% FNI_BANDPASSFILT
% Perform a bandpass filter on time course data.
%
% Usage:
%   >> [data, log] = fni_bandpassfilt(data, cfg);
%
% Inputs:
%   'data.(field)' - [SnirfClass | DataClass] Homer3 data class
%   'cfg' - [struct] configuration with the fields
%       'source' - [char] the data class to apply filter to 
%       'hpf' - [double] high pass frequency
%       'lpf' - [double] low pass frequency
%
% Outputs:
%   'data.([field, '_bpfilt'])' - [SnirfClass | DataClass] Homer3 data class
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

function [data, log] = fni_bandpassfilt(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: applying bandpass filter to ''%s'' between %.3f and %.3f Hz\n', cfg.source, cfg.hpf, cfg.lpf);
% =========================================================================
% EXECUTE
switch cfg.source 
    case 'aux'
        data.raw.aux = hmrR_BandpassFilt(data.raw.aux, cfg.hpf, cfg.lpf);
    otherwise
        data.([cfg.source, '_bpfilt']) = hmrR_BandpassFilt(data.(cfg.source), cfg.hpf, cfg.lpf);
end
% =========================================================================
% History
data = fni_history(data, cfg);
end