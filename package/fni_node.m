% FNI_NODE
% Creates a node to run within a pipeline.
%
% Usage:
%   >> [node] = fni_run(fcn, cfg);
%
% Inputs:
%   'fcn' - [char] function name
%   'cfg' - [struct] configuration
%
% Outputs: 
%   'node' - [struct] node to run within a pipeline

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History: 
%   Created 2023-03-17, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under 
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any 
% medium or format, for noncommercial purposes only. If others modify or 
% adapt the material, they must license the modified material under 
% identical terms.

function node = fni_node(fcn, cfg)

if nargin < 2
    cfg = struct();
end

node = struct();
node.fcn = fcn;
node.cfg = cfg;
node.cfg.fcn = fcn;

end