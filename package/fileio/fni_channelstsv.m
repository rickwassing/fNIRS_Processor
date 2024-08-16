% FNI_REA
% Creates the channels TSV structure
%
% Usage:
%   >> [channels] = fni_channelstsv(hdr);
%
% Inputs:
%   'hdr' - [struct] Fieldtrip header information with 'opto' field
%
% Outputs:
%   'channels' - [struct] BIDS complient channel information

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

function [channels] = fni_channelstsv(hdr)
% =========================================================================
% Get required fields
channels = struct();
channels.name = hdr.label;
channels.type = hdr.chantype;
channels.source = repmat({'n/a'}, hdr.nChans, 1);
channels.detector = repmat({'n/a'}, hdr.nChans, 1);
channels.wavelength_nominal = repmat({'n/a'}, hdr.nChans, 1);
% =========================================================================
% Extract source and detector label and the short distance channels
d = nan(size(hdr.opto.tra, 1), 1);
p = nan(2, 3);
for i = 1:size(hdr.opto.tra, 1)
    channels.source{i} = hdr.opto.optolabel{hdr.opto.tra(i, :) > 0};
    channels.detector{i} = hdr.opto.optolabel{hdr.opto.tra(i, :) < 0};
    channels.wavelength_nominal{i} = hdr.opto.wavelength(hdr.opto.tra(i, hdr.opto.tra(i, :) > 0));
    p(1, :) = hdr.opto.optopos(hdr.opto.tra(i, :) > 0, :);
    p(2, :) = hdr.opto.optopos(hdr.opto.tra(i, :) < 0, :);
    d(i) = sqrt((p(1, 1) - p(2, 1)).^2 + (p(1, 2) - p(2, 2)).^2 + (p(1, 3) - p(2, 3)).^2);
end
channels.units = hdr.chanunit;
channels.orientation_component = repmat({'n/a'}, hdr.nChans, 1);
channels.orientation_component(contains(channels.name, '_x')) = {'x'};
channels.orientation_component(contains(channels.name, '_y')) = {'y'};
channels.orientation_component(contains(channels.name, '_z')) = {'z'};
channels.short_channel = repmat({false}, hdr.nChans, 1);
channels.short_channel(d < 12) = {true};
channels.status = repmat({'good'}, hdr.nChans, 1);

end