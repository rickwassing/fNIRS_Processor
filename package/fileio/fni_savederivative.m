% FNI_SAVEDERIVATIVE
% Saves data to a derivative's folder
%
% Usage:
%   >> [data, log] = fni_savederivative(data, cfg);
%
% Inputs:
%   'data' - [struct] all data
%   'cfg' - [struct] configuration with the fields
%       'derivative' - [char] FNI output step e.g., 'preproc'
%
% Outputs:
%   none - no changes to the dataset

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-09-15, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data, log] = fni_savederivative(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: saving data to ''%s''.\n', cfg.outputfile);
% =========================================================================
% History
data = fni_history(data, cfg);
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
folder = fileparts(cfg.outputfile);
if exist(folder, 'dir') == 0
    mkdir(folder);
end
% -------------------------------------------------------------------------
save(cfg.outputfile, 'data', '-mat', '-v7.3')
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
methodsfile = strrep(data.info.outputfile, '_nirs.snirf', '_methods.txt');
methodsfile = strrep(methodsfile, '/nirs/', '/');
writelines(strjoin({data.history.methods}, ' '), methodsfile);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
citationsfile = strrep(data.info.outputfile, '_nirs.snirf', '_cites.txt');
citationsfile = strrep(citationsfile, '/nirs/', '/');
writelines(strjoin([data.history.cite], ', '), citationsfile);

end