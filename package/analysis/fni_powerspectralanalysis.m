% FNI_POWERSPECTRALANALYSIS
% Calculates the powerspectral analysis using P-Welch's method
%
% Usage:
%   >> [data, log] = fni_powerspectralanalysis(data, cfg);
%
% Inputs:
%   'data.(field)' - [DataClass] Homer3 data class
%   'cfg' - [struct] configuration with the fields
%       'source' - [char] the data class to apply the power-spectral analysis to 
%       'windowlength' - [double] window length in seconds
%       'overlap' - [double] overlap of the window in percent
%
% Outputs:
%   'data.([field, '_psa'])' - [DataClass] Homer3 data class
%   'log' - [cell] errors and warnings

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Adapted 2023-09-01, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data, log] = fni_powerspectralanalysis(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: calculating power-spectrum using a sliding window of %i seconds and %i %% overlap.\n', cfg.windowlength, cfg.overlap);
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
pnts = size(data.dc.time, 1); % number of data points
fs = round(1/mean(diff(data.(cfg.source).time))); % sampling rate
win = cfg.windowlength*fs; % window size in samples
winstep = floor(win * (cfg.overlap/100)); % window step in samples
if win > pnts
    error('>> FNI: window size must be smaller than the length of the data.')
end
% -------------------------------------------------------------------------
[data.([cfg.source, '_psa']).pow, data.([cfg.source, '_psa']).freq] = ...
    pwelch(data.(cfg.source).dataTimeSeries, win, winstep, max([256, 2^nextpow2(win)]), fs);
% =========================================================================
% History
data = fni_history(data, cfg);

end