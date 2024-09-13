% FNI_GLMTIMESERIES
% Applies a generalized linear model on the timeseries data of one run.
%
% Usage:
%   >> [data, log] = fni_glmtimeseries(data, cfg);
%
% Inputs:
%   'data.dc' - [DataClass] Homer3 data class
%   'cfg' - [struct] configuration with the fields
%
%       GLM settings:
%
%       'stimlabel' - [char] label of the stimulus to model
%       'contrast' - [double] contrast vector
%       'window' - [double] defines the range for the block average [tPre Post]
%       'baselinewindow' - [double] defines the range for training the CCA filters
%       'rejchans' - [cell] names of nirs channels to exclude
%       'auxchans' - [cell] names of auxiliary channels to include as nuisance regressors
%       'method' - [char] 'ordinary' or 'weighted' least squares
%       'basisfcn' - [double] default: 1 for using consequtive gausians
%       'basiscfg' - [double] default: [0.5 0.5] for standard deviation and time-step
%       'driftorder' - [double] polynomial drift correction
%
%       temporal CCA Regressor settings:
%
%       'timelag' - [double] timespan in seconds for temporal embedding 
%       'stepsize' - [double] step size (Δt) in seconds for each time shift 
%           of auxiliary signals in the temporal embedding step
%       'corrthresh' - [double] correlation threshold to keep only those 
%           tCCA regressors for the GLM nuisance removal that have a 
%           canonical correlation with fNIRS signals in the CCA space that 
%           is greater than 'corrThresh'
%       'sstrhesh' - [double] distance in mm to detect short separation 
%           channels
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

function [data, log] = fni_glmtimeseries(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% -------------------------------------------------------------------------
% Extract homer values
switch lower(cfg.method)
    case 'ordinary'
        method = 1;
    case 'weighted'
        method = 2;
end
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: applying a GLM on the stimuli ''%s'' using a peri-stimulus window of %.3f to %.3f seconds.\n', strjoin(cfg.stimlabel, ', '), cfg.window(1), cfg.window(2));
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Motion scrubbing is not supported yet in this FNI function
motionscrubbing = [];
% -------------------------------------------------------------------------
% Exclude channels
ml = manualrejectchannels(cfg.rejchans, data.dc.GetMeasListSrcDetPairs('reshape'));
% -------------------------------------------------------------------------
% Get the stims
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Convert to cell array
if ~iscell(cfg.stimlabel)    
    cfg.stimlabel = {cfg.stimlabel};
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
idx_stim = ismember({data.raw.stim.name}, cfg.stimlabel);
stim = data.raw.stim(idx_stim);
% Set all stim amplitudes to 1
for i = 1:length(stim)
    stim(i).data(:, 3) = ones(size(stim(i).data, 1), 1);
    stim(i).states(:, 2) = ones(size(stim(i).states, 1), 1);
end
% -------------------------------------------------------------------------
% Get nuisance regressors including short-separation channels
[nuisance_regressors, rcmap] = fni_gettccaregressors(data.dc, data.raw.aux, data.raw.probe, cfg);
% -------------------------------------------------------------------------
% Apply GLM
[data.glm.avg, data.glm.std, data.glm.ntrials, data.glm.dc, data.glm.resid, data.glm.sum2, data.glm.beta, data.glm.r, data.glm.stats] = ...
    hmrR_GLM(data.dc, stim, data.raw.probe, {ml(:, 3)}, nuisance_regressors, motionscrubbing, rcmap, ...
    cfg.window, method, cfg.basisfcn, cfg.basiscfg, 0, 3, cfg.driftorder, cfg.contrast);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Save config
data.glm.cfg = cfg;
% -------------------------------------------------------------------------
% Homer returns the DC class with 3 dimension <time-by-hbx-by-channels>,
% this should be <time-by-channels>.
dataTimeSeries = nan(size(data.glm.dc.dataTimeSeries, 1), size(data.glm.dc.dataTimeSeries, 2).*size(data.glm.dc.dataTimeSeries, 3));
for i = 1:size(data.glm.dc.dataTimeSeries, 1)
    tmp = squeeze(data.glm.dc.dataTimeSeries(i, :, :));
    dataTimeSeries(i, :) = tmp(:);
end
data.glm.dc.dataTimeSeries = dataTimeSeries;
% -------------------------------------------------------------------------
% Homer only returns the beta's of the HRF regressors, I also want those of
% the nuisance regressors, so here we do it again.
data.glm.origbeta = data.glm.beta;
data.glm.beta = nan(size(data.glm.stats.desmat, 2), length(data.dc.measurementList));
for i = 1:length(data.dc.measurementList)
    mdl = fitlm(data.glm.stats.desmat, data.dc.dataTimeSeries(:, i), 'Intercept', false);
    data.glm.beta(:, i) = mdl.Coefficients.Estimate;
end
% =========================================================================
% History
data = fni_history(data, cfg);

end