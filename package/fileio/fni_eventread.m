% FNI_EVENTREAD
% Reads events from the input file
%
% Usage:
%   >> [events] = fni_eventread(FullFileName);
%
% Inputs:
%   'FullFileName' - [char] Full filepath to events
%
% Outputs:
%   'events' - [struct] Fieldtrip events structure

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-08-31, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [events] = fni_eventread(FullFileName)
% =========================================================================
events = ft_read_event(FullFileName);
if ~isfield(events, 'type')
    error('Did not find event type in file ''%s''.', FullFileName)
end
% Make the event type a valid Matlab variable name
for i = 1:length(events)
    events(i).type = matlab.lang.makeValidName(events(i).type);
end
% Sanitize: remove events labeled as 'annotation'
rmidx = strcmpi({events.type}, 'annotation');
events(rmidx) = [];
if isempty(events)
    events(1).type = 'start';
    events(1).value = 1;
    events(1).sample = 1;
    events(1).duration = 0;
    events(1).timestamp = 0;
    events(1).offset = 0;
end