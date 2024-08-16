% FNI_INIT
% Initializes the Matlab path
%
% Usage:
%   >> fni_init(apppath);
%
% Inputs:
%   none
%
% Outputs:
%   'pipe' - [cell] empty cell array to store the pipeline in

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-10-18, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function pipe = fni_init()
% =========================================================================
% Check if Wavelet, Signal Processing, and Statistics and Machine Learning Toolboxes are installed
if exist('exportgraphics', 'file') == 0
    error('FNI: Your Matlab version ''%s'' is too old. This toolbox requires version R2020a or later.', version());
end
if exist('wavelet', 'file') == 0
    error('FNI: Please install the Wavelet Toolbox (Home > Environment > Add-Ons > Get Add-Ons)');
end
if exist('cconv', 'file') == 0
    error('FNI: Please install the Signal Processing Toolbox (Home > Environment > Add-Ons > Get Add-Ons)');
end
if exist('mad', 'file') == 0
    error('FNI: Please install the Statistics and Machine Learning Toolbox (Home > Environment > Add-Ons > Get Add-Ons)');
end
% =========================================================================
% Initialize the pipeline as an empty cell array
pipe = {};
% -------------------------------------------------------------------------
apppath = fileparts(which('fni_pipeline'));
cd(apppath)
% -------------------------------------------------------------------------
% Add path of the fNIRS analysis software
if exist('fni_run', 'file') ~= 2
    addpath(genpath('.'));
end
% -------------------------------------------------------------------------
% Assume that Fieldtrip and Homer3 are located on directory up
cd('..')
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% EEGLAB
if exist('eeglab', 'file') ~= 2
    addpath('./eeglab/latest'); eeglab; close all
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Fieldtrip
if exist('ft_defaults', 'file') ~= 2
    addpath('./fieldtrip/latest'); ft_defaults;
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Homer3
if exist('Homer3', 'file') ~= 2
    addpath(genpath('./Homer3'));
end
% -------------------------------------------------------------------------
cd(apppath)
% -------------------------------------------------------------------------
fprintf('>> FNI: initialized\n');
end