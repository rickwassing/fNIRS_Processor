% FNI_SCALPCOUPLINGINDEX
% Calculates scalp coupling index.
%
% Usage:
%   >> [data, log] = fni_scalpcouplingindex(data, cfg);
%
% Inputs:
%   'data.dod' - [DataClass] Homer3 data class
%   'cfg' - [struct] configuration with the fields
%       'source' - [char] the data class to compute the SCI for
%       'windowlength' - [double] window length in seconds
%       'overlap' - [double] window overlap in percent, user 100 to slide window sample-by-sample
%
% Outputs:
%   'data.quality' - [struct] quality assessments with the fields
%       'sci' - [double] <m x n> scalp coupling index for each segment m and channel n
%   'log' - [cell] errors and warnings

% Authors:
%   Sofia Sappia (sofia@artinis.com)
%   Naser Hakimi (naser@artinis.com) 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2020-08-24, Sofia Sappia and Naser Hakimi
%   Adapted 2023-09-01, Rick Wassing

% (C) 2023 by Artinis Medical Systems, licensed under
% This work is licensed under a Creative Commons Attribution-NonCommercial-
% ShareAlike 4.0 International License. Based on a work at 
% https://github.com/Artinis-Medical-Systems-B-V/SignalQualityIndex.
% Permissions beyond the scope of this license may be available upon 
% request at science@artinis.com.

function [data, log] = fni_scalpcouplingindex(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: calculating scalp coupling index on source ''%s'' using a sliding window of %i seconds and %i %% overlap.\n', cfg.source, cfg.windowlength, cfg.overlap);
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Get the channel list and their indices
[chanlist, chanindex] = getchannellist(data.(cfg.source).measurementList);
% -------------------------------------------------------------------------
pnts = size(data.(cfg.source).time, 1); % number of data points
fs = round(1/mean(diff(data.(cfg.source).time))); % sampling rate
win = cfg.windowlength*fs; % window size in samples
% Make sure the window is odd
if mod(win, 2) == 0
    win = win+1;
end
if cfg.overlap == 100
    step = 1;
else
    step = floor((cfg.overlap/100).*win); % step size
end
if step < 1
    step = 1;
end
% -------------------------------------------------------------------------
% Init output
data.quality.sci = nan(pnts, length(chanlist));
previ = [];
% -------------------------------------------------------------------------
% For each window...
for i = 1:step:pnts
    % ... set the indices of the sliding window
    slidewin = [i, i+win-1] - ceil(win/2);
    if slidewin(1) < 1
        slidewin(1) = 1; % Crop window at the start of the data trace
    end
    if slidewin(2) > pnts
        slidewin(2) = pnts; % Crop window at the end of the data trace
    end
    % ---------------------------------------------------------------------
    % For each channel...
    for j = 1:length(chanlist)
        % ... extract the data
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Optical density of wavelength 1
        cidx = ...
            [data.(cfg.source).measurementList.sourceIndex] == chanindex(j, 1) & ...
            [data.(cfg.source).measurementList.detectorIndex] == chanindex(j, 2) & ...
            [data.(cfg.source).measurementList.wavelengthIndex] == 1;
        if ~any(cidx) || sum(cidx) > 1 % we should find one and only one channel
            error('>> FNI: Found no channel or more than one channel for wavelength 1.')
        end
        dod_lambda1 = asrow(data.(cfg.source).dataTimeSeries(slidewin(1):slidewin(2), cidx));
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Optical density of wavelength 2
        cidx = ...
            [data.(cfg.source).measurementList.sourceIndex] == chanindex(j, 1) & ...
            [data.(cfg.source).measurementList.detectorIndex] == chanindex(j, 2) & ...
            [data.(cfg.source).measurementList.wavelengthIndex] == 2;
        if ~any(cidx) || sum(cidx) > 1 % we should find one and only one channel
            error('>> FNI: Found no channel or more than one channel for wavelength 2.')
        end
        dod_lambda2 = asrow(data.(cfg.source).dataTimeSeries(slidewin(1):slidewin(2), cidx));
        % -----------------------------------------------------------------
        % Calculate SCI
        if isempty(previ) || step == 1
            data.quality.sci(i, j) = scalpcouplingindex(dod_lambda1, dod_lambda2, fs);
        else
            tmp = scalpcouplingindex(dod_lambda1, dod_lambda2, fs);
            data.quality.sci(previ+1:i, j) = linspace(data.quality.sci(previ, j), tmp, step);
        end   
    end
    previ = i;
end
keyboard
% =========================================================================
% History
data = fni_history(data, cfg);

end