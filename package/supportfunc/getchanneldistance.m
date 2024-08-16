% GETCHANNELDISTANCE
% Calculates the distance between source-detector channel pairs
%
% Usage:
%   >> [chandist] = getchanneldistance(measlist);
%
% Inputs:
%   'probe' - [MeasListClass] Homer3 measurement list class
%   'data' - [DataClass] Indices of source-detector channel pairs
%
% Outputs:
%   'chandist' - [float] channel distance in mm

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-05-31, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [chandist] = getchanneldistance(probe, data)
% =========================================================================
SrcPos  = probe.GetSrcPos();
DetPos  = probe.GetDetPos();
MeasList = data.GetMeasListSrcDetPairs('reshape');
chandist = nan(size(MeasList, 1), 1);
for i = 1:size(MeasList, 1)
    chandist(i) = sqrt(...
        (SrcPos(MeasList(i, 1), 1) - DetPos(MeasList(i, 2), 1)).^2 + ...
        (SrcPos(MeasList(i, 1), 2) - DetPos(MeasList(i, 2), 2)).^2 + ...
        (SrcPos(MeasList(i, 1), 3) - DetPos(MeasList(i, 2), 3)).^2);
end

end