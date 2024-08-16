% FNI_CORRECTMOTIONWITHWAVELET
% Perform a wavelet transformation of the dod data and computes the
% distribution of the wavelet coefficients. It sets the coefficient
% exceeding iqr times the interquartile range to zero, because these are 
% probably due to motion artifacts. set iqr<0 to skip this function.
% The algorithm follows in part the procedure described by
% Molavi et al.,Physiol Meas, 33, 259-270 (2012).
%
% Usage:
%   >> [data, log] = fni_correctmotionwithwavelet(data, cfg);
%
% Inputs:
%   'data.dod' - [DataClass] Homer3 data class
%   'cfg' - [struct] configuration with the fields
%       'source' - [double] used to detect outliers in the wavelet decomposition
%       'iqr' - [double] used to detect outliers in the wavelet decomposition
%
% Outputs:
%   'data.dod' - [DataClass] Homer3 data class
%   'log' - [cell] errors and warnings

% Authors:
%   Behnam Molavi, University of British Columbia, Vancouver, Canada
%   Sabrina Brigadoi, University College London, WC1E 6BT, United Kingdom
%   Jay Dubb, Athinoula Martinos Center for Biomedical Imaging, Charlestown (MA), United States
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created unkown, Behnam Molavi
%   Adapted 2012-10-17, Sabrina Brigadoi
%   Adapted 2019-03-27, Jay Dubb
%   Adapted 2023-09-07, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data, log] = fni_correctmotionwithwavelet(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: correcting motion artefacts by removing wavelett coefficients exceeding %.1f times the inter-quartile range\n', cfg.iqr);
% =========================================================================
% EXECUTE
data.([cfg.source, '_mc']) = hmrR_MotionCorrectWavelet(data.(cfg.source), [], [], cfg.iqr, 1);
% =========================================================================
% History
data = fni_history(data, cfg);
end