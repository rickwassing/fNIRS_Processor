% FNI_IMPORT
% Imports data into SNIRF structure and saves it into 'rawdata' BIDS directory.
%
% Usage:
%   >> [data, log] = fni_import(data, cfg);
%
% Inputs:
%   'data.(field)' - [<empty> | SnirfClass | DataClass] Empty or Homer3 data class
%   'cfg' - [struct] configuration with the fields
%       'sourcefile' - [char] full path to source file
%       'bidsroot' - [char] top level directory for the BIDS output
%       'sub' - [char] subject ID
%       'ses' - [char] session label (optional)
%       'task' - [char] task name (required for functional data)
%       'run' - [integer] run number (optional)
%       'datatype' - [char] must be 'nirs' for this FNI function
%       'participants.age' - [integer] age of participant
%       'participants.sex - [char] 'm' or 'f'
%
% Outputs:
%   'data.raw' - [SnirfClass] Homer3 data class
%   'data.info' - [struct] meta data
%   'log' - [cell] errors and warnings

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

function [data, log] = fni_import(data, cfg)
% =========================================================================
% INITIALIZE
log = {};
% -------------------------------------------------------------------------
% Check the config
cfg = fni_defaultcfg(cfg, data);
% -------------------------------------------------------------------------
% Read the extenstion of the source file, this will determine the import function
[~, ~, extension] = fileparts(cfg.sourcefile);
% =========================================================================
% COMMAND WINDOW
fprintf('>> FNI: import sourcefile: ''%s''\n', cfg.sourcefile);
% =========================================================================
% IMPORT AND SAVE TO RAW DATA
% -------------------------------------------------------------------------
% Check what filetype it is and call the appropriate import function
switch extension
    case {'edf', '.edf'}
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Check from which manufacturer we need to import the EDF
        switch lower(cfg.manufacturer)
            case 'artenis'
                data.raw = fni_importartenisedf(cfg.sourcefile);
            otherwise
                error('>> FNI: Cannot import EDF files from the manufacturer ''%s''.', cfg.manufacturer)
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    case {'snirf', '.snirf'}
        ft_cfg = struct();
        ft_cfg.dataset = cfg.sourcefile;
        data.raw = ft_preprocessing(ft_cfg); % Use fieldtrip to import the data
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    otherwise
        error('>> FNI: Cannot import files with the extension ''%s''.', extension)
end
% -------------------------------------------------------------------------
% Setup the BIDS sidecar file information
cfg.method = 'convert';
cfg.scans.acq_time = getfilenamedatetimestamp(cfg.sourcefile, '[0-9]{8}-[0-9]{6}', 'uuuuMMdd-HHmmss');
cfg.sessions.acq_time = getfilenamedatetimestamp(cfg.sourcefile, '[0-9]{8}-[0-9]{6}', 'uuuuMMdd-HHmmss');
if strcmpi(cfg.scans.acq_time, 'NaT')
    cfg.scans.acq_time = '1900-01-01T00:00:00';
    cfg.sessions.acq_time = '1900-01-01T00:00:00';
end
cfg.sessions.pathology = [];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cfg.nirs.NIRSPlacementScheme = '10-20';
cfg.nirs.ACCELChannelCount = sum(contains(data.raw.hdr.label, 'accel'));
cfg.nirs.GYROChannelCount = sum(contains(data.raw.hdr.label, 'gyro'));
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cfg.events = fni_eventread(cfg.sourcefile);
cfg.channels = fni_channelstsv(data.raw.hdr);
cfg.coordsystem = fni_coordsystemjson(data.raw.hdr);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Weirly, Fieldtrip also expects the events to be part of the data.cfg structure
data.raw.cfg.event = cfg.events;
% -------------------------------------------------------------------------
% Save the data as a BIDS dataset
cfg = data2bids(cfg, data.raw);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Store the BIDS config
data.info = cfg;
data.info.nirs = ft_read_json(strrep(data.info.outputfile, '.snirf', '.json')); % weirly, this step is not done within 'data2bids';
data.info.channels = ft_read_tsv(strrep(data.info.outputfile, '_nirs.snirf', '_channels.tsv'));
data.info.optodes = ft_read_tsv(strrep(data.info.outputfile, '_nirs.snirf', '_optodes.tsv'));
data.info.events = ft_read_tsv(strrep(data.info.outputfile, '_nirs.snirf', '_events.tsv'));
% -------------------------------------------------------------------------
% Convert to Homer3 SNIRF format
data.raw = SnirfClass(cfg.outputfile);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Store the events as a StimClass
data.raw.stim = fni_events2stimclass(cfg.events, data.info.nirs.SamplingFrequency);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Make sure the Aux channels are named correctly (Homer3 does not do this)
auxchans = find(strcmpi(cfg.channels.type, 'aux'));
for i = 1:length(auxchans)
    data.raw.aux(i).name = cfg.channels.name{auxchans(i)};
end
% =========================================================================
% History
data = fni_history(data, cfg);
end