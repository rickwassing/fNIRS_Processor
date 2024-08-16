% GETFILENAMEDATETIMESTAMP
% Use RegExp to extract date time stamp from filename
%
% Usage:
%   >> [date] = getfilenamedatetimestamp(filename, pattern);
%
% Inputs:
%   'filename' - [char] filename
%   'pattern' - [char] regular expression pattern
%
% Outputs:
%   'date' - [char] ISO formatted date time stamp 'uuuu-MM-ddTHH:mm:ss'

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-08-17, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [date] = getfilenamedatetimestamp(filename, pattern, format)
% =========================================================================
idx = regexp(filename, pattern);
date = filename(idx:idx+length(format)-1);
date = char(datetime(date, 'InputFormat', format), 'uuuu-MM-dd''T''HH:mm:ss');
end