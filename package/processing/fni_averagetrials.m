% FNI_AVERAGETRIALS
% Calculate the avergage across all trials of a given label over a window
% specified in seconds. The pre-stimulus baseline is set to zero by
% subtracting the mean of the average.
%
% Usage:
%   >> [data, log] = fni_averagetrials(data, cfg);
%
% Inputs:
%   'data.(field)' - [DataClass] Homer3 data class
%   'cfg' - [struct] configuration with the fields
%       'source' - [char] the data class to apply the trial average to 
%       'window' - [double] window length in seconds
%
% Outputs:
%   'data.([field, '_avgtrial'])' - [struct] with the fieldsHomer3 data class
%       'trialtype' - [char] Name of the trials used for averaging
%       'avg' - [DataClass] Homer3 data class for the average across trials
%       'std' - [DataClass] Homer3 data class with the standard deviation across trials
%       'numtrials' - [integer] number of trials
%   'log' - [cell] errors and warnings

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-09-15, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data, log] = fni_averagetrials(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% -------------------------------------------------------------------------
% init output
data.([cfg.source, '_avgtrial']) = struct();
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: averaging across trials on ''%s'' using a peri-stimulus window of %.3f to %.3f seconds, and subtracting the mean across the pre-stimulus baseline.\n', cfg.source, cfg.window(1), cfg.window(2));
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Do the trial averaging for each of the requested event labels:
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
for i = 1:length(cfg.eventlabels)
    % Extract the labels for this averaging request
    labels = cfg.eventlabels{i};
    stim = StimClass(); % Init an empty stim class
    % For each of the requested labels, append these stims to the stim class
    for j = 1:length(labels)
        % Find index
        idx = strcmpi({data.raw.stim.name}, labels{j});
        if ~any(idx)
            continue % nothing found
        end
        % Append:
        stim.name = [stim.name, labels{j}]; 
        stim.data = [stim.data; data.raw.stim(idx).data];
        stim.states = [stim.states; data.raw.stim(idx).states];
    end
    % Call Homer3 function to do the averaging
    [avg, std, numtrials] = fni_blockavg(data.(cfg.source), stim, cfg.window);
    % Store output
    data.([cfg.source, '_avgtrial'])(i).trialtype = stim.name;
    data.([cfg.source, '_avgtrial'])(i).avg = avg;
    data.([cfg.source, '_avgtrial'])(i).std = std;
    data.([cfg.source, '_avgtrial'])(i).numtrials = numtrials{1};
end
% =========================================================================
% History
data = fni_history(data, cfg);

end