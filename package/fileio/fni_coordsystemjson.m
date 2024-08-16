% FNI_COORDSYSTEMJSON
% Creates the coordinate system JSON structure
%
% Usage:
%   >> [coordsystem] = fni_coordsystemjson(hdr);
%
% Inputs:
%   'hdr' - [struct] Fieldtrip header information with 'opto' field
%
% Outputs:
%   'coordsystem' - [struct] BIDS complient coordinate system information

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-08-24, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [coordsystem] = fni_coordsystemjson(hdr)
% =========================================================================
% Get required fields
coordsystem = struct();
coordsystem.NIRSCoordinateSystem = 'RAS';
coordsystem.NIRSCoordinateUnits = hdr.opto.unit;
coordsystem.NIRSCoordinateProcessingDescription = 'n/a';
coordsystem.NIRSCoordinateSystemDescription = 'RAS orientation: positive x-axis towards right, positive y-axis orthogonal to x-axis towards nasion, z-axis orthogonal to xy-plane in superior direction.';

end
