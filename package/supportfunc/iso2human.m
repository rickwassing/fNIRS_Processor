% ISO2HUMAN
% Converts a string in the ISO format 'yyyy-mm-ddTHH:MM:SS.FFF' to a 
% human readable string.
%
% Optional inputs:
%   'OmitMilliseconds' - [boolean] include milliseconds or not

% Authors: 
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-03-17, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function dstr = iso2human(dstr, varargin)
% ---------------------------------------------------------------------
% Parse variable arguments in
DateOnly = false;
OmitMilliseconds = false;
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'dateonly'
            DateOnly = varargin{i+1};
        case 'omitmilliseconds'
            OmitMilliseconds = varargin{i+1};
    end
end
% ---------------------------------------------------------------------
% Secify output format
if DateOnly
    Format = 'eeee dd-MMM-uuuu';
elseif OmitMilliseconds
    Format = 'dd-MMM-uuuu HH:mm:ss';
else
    Format = 'dd-MMM-uuuu HH:mm:ss.SSS';
end
% ---------------------------------------------------------------------
% Run
if isdatetime(dstr)
    dstr = char(dstr, Format);
else
    dstr = char(datetime(dstr, 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSS'), Format);
end
end