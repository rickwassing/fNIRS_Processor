% FNI_EVENTS2STIMCLASS
% Converts a Fieldtrip events structure to Homer3 StimClass objects
%
% Usage:
%   >> [stim] = fni_events2stimclass(events);
%
% Inputs:
%   'events' - [struct] Fieldtrip events structure
%
% Outputs:
%   'stim' - [StimClass] Homer3 StimClass objects (one for each trial type)

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-0-15, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [stim] = fni_events2stimclass(events, fs)
% =========================================================================
if ~isfield(events, 'type')
    error('Did not find event type in file ''%s''.', FullFileName)
end
types = unique({events.type});
% Make the event type a valid Matlab variable name
stim = StimClass();
for i = 1:length(types)
    e = events(strcmpi({events.type}, types{i}));
    s = StimClass();
    s.name = types{i};
    s.data = [ascolumn([e.sample]-1)./fs, ascolumn([e.duration])./fs, ascolumn([e.value])];
    s.states = [ascolumn([e.sample]-1)./fs, ascolumn([e.value])];
    stim(i) = s;
end

end