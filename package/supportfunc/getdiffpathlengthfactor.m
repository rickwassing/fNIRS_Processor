% GETDIFFPATHLENGTHFACTOR
% Calculates the differential pathlength factor for a given wavelength and
% age. See Scholkmann and Wolf (2013) General equation for the differential 
% pathlength factor of the frontal human head depending on wavelength and 
% age. Journal of Biomedical Optics, 18(10):105004. 
% DOI: https://doi.org/10.1117/1.JBO.18.10.105004
%
% Usage:
%   >> [dpf] = getdiffpathlengthfactor(lambda, age);
%
% Inputs:
%   'lambda' - [integer] wavelength
%   'age' - [double] age
%
% Outputs:
%   'dpf' - [double] differential pathlength factor

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

function [dpf] = getdiffpathlengthfactor(lambda, age)
a = 223.3;
b = 0.05624;
c = 0.8493;
d = -5.723e-7;
e = 0.001245;
f = -0.9025;
dpf = a + b*age.^c + d*lambda.^3 + e*lambda.^2 + f*lambda;
end