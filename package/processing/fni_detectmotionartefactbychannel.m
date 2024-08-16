% FNI_DETECTMOTIONARTEFACTBYCHANNEL
% Identifies motion artifacts. Segments of data with a signal change 
% greater than ampthresh or stdthresh is marked as a motion artifact. 
%
% Usage:
%   >> [data, log] = fni_detectmotionartefactbychannel(data, cfg);
%
% Inputs:
%   'data.dod' - [DataClass] Homer3 data class
%   'data.raw.probe' - [ProbeClass] Homer3 probe class
%   'cfg' - [struct] configuration with the fields
%       'source' - [char] the data class used to detect motion artefacts
%       'ampthres' - [double] mark artefact if signal changes more than 'ampthres' over timeperiod 'tmotion'
%       'stdthres' - [double] mark artefact if signal changes more than 'stdthres' * std(data) over timeperiod 'tmotion'
%       'tmotion' - [double] seconds, timeperiod to check
%       'tmask' - [double] seconds, mask +/- 'tmask' seconds around identified motion as artefact
%
% Outputs:
%   'data.quality.isClean' - [boolean] <pnts x numchans> indicates good signal (true) or artefact (false)
%   'log' - [cell] errors and warnings

% Authors:
%   K. Perdue, kperdue@nmr.mgh.harvard.edu
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2010-09-23, K. Perdue 
%   Adapted 2023-09-07, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data, log] = fni_detectmotionartefactbychannel(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: detecting motion artefacts on source ''%s'' using amplitude threshold of %.1f, standard deviation treshold of %.1f, time segments of %.1f s, and a mask duration of %.1f seconds\n', cfg.source, cfg.ampthres, cfg.stdthres, cfg.tmotion, cfg.tmask);
% =========================================================================
% EXECUTE
[~, tmp] = hmrR_MotionArtifactByChannel(data.(cfg.source), data.raw.probe, [], [], [], cfg.tmotion, cfg.tmask, cfg.stdthres, cfg.ampthres);
data.quality.isclean = tmp{:};
data.quality.isclean = data.quality.isclean(1:end-4, :);
% =========================================================================
% History
data = fni_history(data, cfg);
end