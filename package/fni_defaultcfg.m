% FNI_DEFAULTCFG
% Checks the config and sets default values
%
% Usage:
%   >> [cfg] = fni_defaultcfg(cfg, data);
%
% Inputs:
%   'cfg' - [struct] configuration
%   'data.(field)' - [<empty> | SnirfClass | DataClass] Empty or Homer3 data class
%
% Outputs:
%   'cfg' - [struct] configuration

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

function [cfg] = fni_defaultcfg(cfg, data)

switch cfg.fcn
    % =====================================================================
    case 'import'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'sourcefile', 'bidsroot', 'sub', 'task', 'datasetname', 'manufacturer', 'manufacturersmodelname'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        if ~isfield(cfg, 'participants')
            cfg.participants.age = 999;
            cfg.participants.sex = 'unknown';
        else
            if ~isfield(cfg.participants, 'age')
                cfg.participants.age = 999;
            end
            if ~isfield(cfg.participants, 'sex')
                cfg.participants.sex = 'unknown';
            end
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        cfg.nirs.CapManufacturer = cfg.manufacturer;
        cfg.nirs.CapManufacturersModelName = cfg.manufacturersmodelname;
        cfg.nirs.NIRSPlacementScheme = '10-20';
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        cfg.TaskName = cfg.task;
        cfg.datatype = 'nirs';
        cfg.InstitutionName = 'Woolcock Institute of Medical Research';
        cfg.InstitutionAddress = '431 Glebe Point Road, Sydney, Australia';
        cfg.InstitutionalDepartmentName = 'Sleep and Circadian Research';
        cfg.DeviceSerialNumber = 'unknown';
        cfg.SoftwareVersions = 'unknown';
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        cfg.dataset_description.writesidecar = 'yes';
        cfg.dataset_description.Name = cfg.datasetname;
        cfg.dataset_description.BIDSVersion = 'v1.8.0';
        cfg.dataset_description.License = 'unspecified';
        cfg.dataset_description.Authors = 'unspecified';
        cfg.dataset_description.Acknowledgements = 'unspecified';
        cfg.dataset_description.HowToAcknowledge = 'unspecified';
        cfg.dataset_description.Funding = 'unspecified';
        cfg.dataset_description.ReferencesAndLinks = 'unspecified';
        cfg.dataset_description.DatasetDOI = 'unspecified';
        % =================================================================
    case 'importsyncedexgchannels'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'sourcefile', 'nirssyncchan', 'exgsyncchan', 'selchans'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % =================================================================
    case 'bandpassfilt'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'source'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        if ~isfield(cfg, 'hpf')
            cfg.hpf = 0;
        end
        if ~isfield(cfg, 'lpf')
            cfg.lpf = 0.5;
        end
        % =================================================================
    case 'detectmotionartefactbychannel'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'source'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        if ~isfield(cfg, 'ampthres')
            cfg.ampthres = 5;
        end
        if ~isfield(cfg, 'stdthres')
            cfg.stdthres = 50;
        end
        if ~isfield(cfg, 'tmotion')
            cfg.tmotion = 0.5;
        end
        if ~isfield(cfg, 'tmask')
            cfg.tmask = 1;
        end
        % =================================================================
    case 'correctmotion'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'source'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        if ~isfield(cfg, 'method')
            cfg.method = 'wavelet';
        end
        if ~isfield(cfg, 'iqr')
            cfg.iqr = 1.5;
        end
        % =================================================================
    case 'correctmotionwithwavelet'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'source'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        if ~isfield(cfg, 'iqr')
            cfg.iqr = 1.5;
        end
    case 'dod2dc'
        % -----------------------------------------------------------------
        % Checks
        if ~isfield(cfg, 'dpf')
            requiredfields = {'source', 'age'};
        else
            requiredfields = {'source', 'dpf'};
        end
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % =================================================================
    case 'signalqualityindex'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'source'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        if ~isfield(cfg, 'windowlength')
            cfg.windowlength = 10;
        end
        if ~isfield(cfg, 'overlap')
            cfg.overlap = 50;
        end
        % =================================================================
    case 'calcinstantaneousheartrate'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'source'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        if ~isfield(cfg, 'dosaveraw')
            cfg.dosaveraw = true;
        end
        % =================================================================
    case 'powerspectralanalysis'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'source'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        if ~isfield(cfg, 'windowlength')
            cfg.windowlength = 60;
        end
        if ~isfield(cfg, 'overlap')
            cfg.overlap = 50;
        end
        % =================================================================
    case 'averagetrials'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'source', 'window'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % =================================================================
    case 'savederivative'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'derivative'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        cfg.outputfile = ['./derivatives/fni_', cfg.derivative, '/'];
        for key = {'sub', 'ses'}
            if isempty(data.info.(key{:}))
                continue
            end
            cfg.outputfile = [cfg.outputfile, key{:}, '-', data.info.(key{:}), '/'];
        end
        for key = {'sub', 'ses', 'task', 'run'}
            if isempty(data.info.(key{:}))
                continue
            end
            cfg.outputfile = [cfg.outputfile, key{:}, '-', data.info.(key{:}), '_'];
        end
        cfg.outputfile = [cfg.outputfile, 'desc-', cfg.derivative, '_nirs.mat'];
        % =================================================================
    case 'glmtimeseries'
        % -----------------------------------------------------------------
        % Checks
        requiredfields = {'stimlabel', 'window', 'baselinewindow', 'auxchans'};
        for i = 1:length(requiredfields)
            if ~isfield(cfg, requiredfields{i})
                error('>> FNI: Configuration must contain the field ''%s''.', requiredfields{i})
            end
        end
        % -----------------------------------------------------------------
        % Default values
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Parameters derived from 
        % https://github.com/BUNPC/Homer3/blob/master/FuncRegistry/UserFunctions/tcca_glm/docu.pdf
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        if ~isfield(cfg, 'trainingfile')
            [filepath, cfg.trainingfile] = fileparts(data.info.outputfile);
            cfg.trainingfile = fullfile(filepath, strrep(cfg.trainingfile, '_nirs', '_tccafilter.txt'));
        end
        if ~isfield(cfg, 'rejchans'); cfg.rejchans = ''; end
        if ~isfield(cfg, 'contrast'); cfg.contrast = 0; end
        if ~isfield(cfg, 'method'); cfg.method = 'ordinary'; end %  use 'ordinary' or 'weighted' least squares
        if ~isfield(cfg, 'basisfcn'); cfg.basisfcn = 1; end % use consecutive sequence of gausians
        if ~isfield(cfg, 'basiscfg'); cfg.basiscfg = [0.5, 0.5]; end % standard deviation and time-step
        if ~isfield(cfg, 'driftorder'); cfg.driftorder = 0; end
        if ~isfield(cfg, 'timelag'); cfg.timelag = 3; end
        if ~isfield(cfg, 'stepsize'); cfg.stepsize = 0.8; end
        if ~isfield(cfg, 'corrthresh'); cfg.corrthresh = 0.3; end
        if ~isfield(cfg, 'sstrhesh'); cfg.sstrhesh = 15; end
        % -----------------------------------------------------------------
        % Hard-coded parameters
        cfg.motionflag = 0; % already done
        cfg.ssflag = 0; % already included in the nuisance regressors
        % =================================================================
    otherwise
        error('>> FNI: Function ''%s'' is not supported', cfg.fcn)
end
end