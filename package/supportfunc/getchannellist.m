% GETCHANNELLIST
% Generates a list of all source-detector pairs
%
% Usage:
%   >> [chanlist, chanindex] = getchannellist(measlist);
%
% Inputs:
%   'measurementlist' - [MeasListClass] Homer3 measurement list class
%
% Outputs:
%   'chanlist' - [cell] channel list
%   'chanindex' - [integer] <n x 2> channel indices list

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

function [chanlist, chanindex] = getchannellist(measlist)
% =========================================================================
chanlist = unique(arrayfun(@(ml) sprintf('%i %i', ml.sourceIndex, ml.detectorIndex), ...
    measlist, ...
    'UniformOutput', false), 'stable');
chanindex = cellfun(@(str) str2double(strsplit(str, ' ')), chanlist, 'UniformOutput', false);
chanindex = cat(1, chanindex{:});
chanlist = unique(arrayfun(@(ml) sprintf('s%i-d%i', ml.sourceIndex, ml.detectorIndex), ...
    measlist, ...
    'UniformOutput', false), 'stable')';
end