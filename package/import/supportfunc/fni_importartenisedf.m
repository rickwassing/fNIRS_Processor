% FNI_IMPORTARTENISEDF
% Imports an EDF into a SnirfClass. It is recommended to use the
% 'fni_import' function instead of this function directly. The function
% 'fni_import' will adhere to BIDS, this function does not.
%
% Usage:
%   >> [data, log] = fni_importartenisedf([], cfg);
%
% Inputs:
%   'sourcefile' - [char] full path to source file
%
% Outputs:
%   'data' - [struct] Fieldtrip data structure
%   'log' - [cell] errors and warnings

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

function [data, log] = fni_importartenisedf(sourcefile)
% =========================================================================
% INITIALIZE
log = {};
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
% Read data and header
ft_data = ft_read_data(sourcefile);
hdr = ft_read_header(sourcefile);
% -------------------------------------------------------------------------
% Set channel type
hdr.chantype(contains(hdr.label, 'Rx')) = {'nirs'};
hdr.chantype(~contains(hdr.label, 'Rx')) = {'aux'};
% -------------------------------------------------------------------------
% Relabel
hdr.label = strrep(hdr.label, 'Rx', 'D');
hdr.label = strrep(hdr.label, 'Tx', 'S');
hdr.label = strrep(hdr.label, ' - ', '-');
hdr.label = strrep(hdr.label, 'nm', 'nm]');
hdr.label(contains(hdr.label, 'S1_IMU_GYR_-2')) = {'gyro_z_s1'};
hdr.label(contains(hdr.label, 'S1_IMU_GYR_-1')) = {'gyro_y_s1'};
hdr.label(contains(hdr.label, 'S1_IMU_GYR')) = {'gyro_x_s1'};
hdr.label(contains(hdr.label, 'S2_IMU_GYR_-2')) = {'gyro_z_s2'};
hdr.label(contains(hdr.label, 'S2_IMU_GYR_-1')) = {'gyro_y_s2'};
hdr.label(contains(hdr.label, 'S2_IMU_GYR')) = {'gyro_x_s2'};
hdr.label(contains(hdr.label, 'S1_IMU_ACC_-2')) = {'accel_z_s1'};
hdr.label(contains(hdr.label, 'S1_IMU_ACC_-1')) = {'accel_y_s1'};
hdr.label(contains(hdr.label, 'S1_IMU_ACC')) = {'accel_x_s1'};
hdr.label(contains(hdr.label, 'S2_IMU_ACC_-2')) = {'accel_z_s2'};
hdr.label(contains(hdr.label, 'S2_IMU_ACC_-1')) = {'accel_y_s2'};
hdr.label(contains(hdr.label, 'S2_IMU_ACC')) = {'accel_x_s2'};
hdr.label(contains(hdr.label, 'S1_TSI')) = {'tsi_s1'};
hdr.label(contains(hdr.label, 'S2_TSI')) = {'tsi_s2'};
hdr.label(contains(hdr.label, 'S1_TEMPER')) = {'temperature_s1'};
hdr.label(contains(hdr.label, 'S2_TEMPER')) = {'temperature_s2'};
hdr.label(contains(hdr.label, 'Battery')) = {'battery'};
hdr.label(contains(hdr.label, 'PortAd_Button')) = {'buttons'};
hdr.label(contains(hdr.label, 'PortAd_Input')) = {'sync'};
% -------------------------------------------------------------------------
% Remove some unimportant channels
rmidx = find(contains(hdr.label, '8027_'));
hdr.label(rmidx) = [];
hdr.chantype(rmidx) = [];
hdr.chanunit(rmidx) = [];
hdr.nChans = length(hdr.label);
ft_data(rmidx, :) = [];
% -------------------------------------------------------------------------
% Create the 'opto' structure
hdr.opto = struct();
hdr.opto.chanpos = zeros(0);
hdr.opto.label = {};
hdr.opto.optolabel = {};
hdr.opto.optopos = zeros(0);
hdr.opto.optotype = {};
hdr.opto.tra = zeros(0);
hdr.opto.type = 'nirs';
hdr.opto.unit = 'mm';
hdr.opto.wavelength = zeros(0);
% -------------------------------------------------------------------------
% Extract the detector for each channel
detector = cellfun(@(lbl) strsplit(lbl, '-'), hdr.label(strcmpi(hdr.chantype, 'nirs')), 'UniformOutput', false);
detector = cellfun(@(lbl) lbl{1}, detector, 'UniformOutput', false);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Extract the source for each channel
source = cellfun(@(lbl) strsplit(lbl, '-'), hdr.label(strcmpi(hdr.chantype, 'nirs')), 'UniformOutput', false);
source = cellfun(@(lbl) strsplit(lbl{2}, ' ['), source, 'UniformOutput', false);
source = cellfun(@(lbl) lbl{1}, source, 'UniformOutput', false);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Extract the wavelength for each channel
wavelength = cellfun(@(lbl) strsplit(lbl, '['), hdr.label(strcmpi(hdr.chantype, 'nirs')), 'UniformOutput', false);
wavelength = cellfun(@(lbl) str2double(strrep(lbl{2}, 'nm]', '')), wavelength, 'UniformOutput', true);
hdr.opto.wavelength = [758, 844];
% -------------------------------------------------------------------------
% Set the optode locations
hdr.opto.optolabel = [unique(source); unique(detector)];
hdr.opto.optotype = [repmat({'transmitter'}, length(unique(source)), 1); repmat({'receiver'}, length(unique(detector)), 1)];
hdr.opto.optopos = [...
    -35.7, 74.6, -3; ...
    -30.0, 71.0, -3; ...
    -24.3, 74.6, -3; ...
    35.7, 74.6, -3; ...
    30.0, 71.0, -3; ...
    24.3, 74.6, -3; ...
    -64.7, 74.6, -3; ...
    -30.0, 79.0, -3; ...
    64.7, 74.6, -3; ...
    30.0, 79.0, -3; ...
    ]; % all positions given a two sensor layout
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% If there are only 5 optodes, then only take one half of the positions
if length(hdr.opto.label) == 5
    hdr.opto.optopos = hdr.opto.optopos(1:5, :);
end
% -------------------------------------------------------------------------
% Define the channel structure (which source-detector pairs make up each channel
hdr.opto.tra = zeros(sum(strcmpi(hdr.chantype, 'nirs')), length(hdr.opto.optolabel)); % <chan x optodes>
for i = 1:length(detector)
    idxdetector = strcmpi(hdr.opto.optolabel, detector{i});
    idxsource = strcmpi(hdr.opto.optolabel, source{i});
    [~, idxwavelength] = min(abs(hdr.opto.wavelength - wavelength(i)));
    hdr.opto.tra(i, idxdetector) = -1*idxwavelength;
    hdr.opto.tra(i, idxsource) = idxwavelength;
end
% -------------------------------------------------------------------------
% Calculate the channel positions
hdr.opto.label = hdr.label(strcmpi(hdr.chantype, 'nirs'));
for i = 1:length(hdr.opto.label)
    idxdetector = strcmpi(hdr.opto.optolabel, detector{i});
    idxsource = strcmpi(hdr.opto.optolabel, source{i});
    hdr.opto.chanpos(i, :) = mean(hdr.opto.optopos(idxdetector | idxsource, :));
end
% -------------------------------------------------------------------------
% Store all data into Fieltrip structure
data = struct();
data.hdr = hdr;
data.label = hdr.label;
data.time = {0:1/hdr.Fs:(hdr.nSamples-1)/hdr.Fs};
data.trial = {ft_data};
data.fsample = hdr.Fs;
data.sampleinfo = [1, hdr.nSamples];
data.opto = hdr.opto;
data.cfg = struct();

end