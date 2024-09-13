% FNI_RUN
% Runs a cell array of processing steps.
%
% Usage:
%   >> [data, log] = fni_run(pipe);
%
% Inputs:
%   'pipe' - [cell] pipeline steps
%
% Outputs:
%   'data.(field)' - [SnirfClass | DataClass] Homer3 data class
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

function [data, log] = fni_run(pipe, varargin)
try % wrapper to catch any errors
    % =========================================================================
    % CHECKS
    % -------------------------------------------------------------------------
    % Check if the toolboxes are available
    if exist('ft_test.m', 'file') == 0
        error('>> FNI: Fieldtrip is not on the Matlab path.')
    end
    if exist('Homer3.m', 'file') == 0
        error('>> FNI: Homer3 is not on the Matlab path.')
    end
    % =========================================================================
    % INITIALIZE
    hasWarnings = false;
    log = {};
    data = struct();
    bidsroot = pwd;
    dowebsite = true;
    if nargin > 1
        for i = 1:2:length(varargin)
            switch lower(varargin{i})
                case 'data'
                    data = varargin{i+1};
                case 'log'
                    log = varargin{i+1};
                case 'bidsroot'
                    bidsroot = varargin{i+1};
                case 'dowebsite'
                    dowebsite = varargin{i+1};
            end
        end
    end
    % =========================================================================
    % RUN EACH NODE
    for i = 1:length(pipe)
        % ---------------------------------------------------------------------
        node = pipe{i};
        t = datetime('now');
        l = [];
        log = [log; {'-------------------------------------------------'}]; %#ok<AGROW>
        log = [log; {node.fcn}]; %#ok<AGROW>
        % ---------------------------------------------------------------------
        fprintf('>> ======================================================\n');
        fprintf('>> FNI: Running ''%s'' (%s)\n', node.fcn, char(t, 'dd-MM-yyyy HH:mm:ss'));
        switch node.fcn
            case 'import'
                [data, l] = fni_import(data, node.cfg);
            case 'importsyncedexgchannels'
                [data, l] = fni_importsyncedexgchannels(data, node.cfg);
            case 'raw2dod'
                [data, l] = fni_raw2dod(data);
            case 'detectmotionartefactbychannel'
                [data, l] = fni_detectmotionartefactbychannel(data, node.cfg);
            case 'correctmotion'
                [data, l] = fni_correctmotion(data, node.cfg);
            case 'correctmotionwithwavelet'
                [data, l] = fni_correctmotionwithwavelet(data, node.cfg);
            case 'bandpassfilt'
                [data, l] = fni_bandpassfilt(data, node.cfg);
            case 'dod2dc'
                [data, l] = fni_dod2dc(data, node.cfg);
            case 'signalqualityindex'
                [data, l] = fni_signalqualityindex(data, node.cfg);
            case 'calcinstantaneousheartrate'
                [data, l] = fni_calcinstantaneousheartrate(data, node.cfg);
            case 'powerspectralanalysis'
                [data, l] = fni_powerspectralanalysis(data, node.cfg);
            case 'averagetrials'
                [data, l] = fni_averagetrials(data, node.cfg);
            case 'glmtimeseries'
                [data, l] = fni_glmtimeseries(data, node.cfg);
            case 'savederivative'
                fni_savederivative(data, node.cfg);
            case 'graphchannels'
                fni_graphchannels(data);
            case 'graphchannelquality'
                fni_graphchannelquality(data);
            case 'graphtrialswithinchan'
                fni_graphtrialswithinchan(data, node.cfg);
            case 'graphtrialsacrosschans'
                fni_graphtrialsacrosschans(data, node.cfg);
            case 'graphglmtimeseries'
                fni_graphglmtimeseries(data);
            otherwise
                l = {sprintf('FNI_RUN: function ''%s'' is not supported.', node.fcn)};
        end
        if ~isempty(l)
            hasWarnings = true;
            log = [log; l]; %#ok<AGROW>
        end
        fprintf('>> FNI: Completed in %.0f seconds\n', seconds(datetime('now') - t));
    end
    % =========================================================================
    % PRINT TO COMMAND WINDOW
    if hasWarnings
        fprintf('>> ======================================================\n');
        fprintf('>> FNI: These warnings and comments were logged\n');
        for i = 1:length(log)
            fprintf('>> FNI: %s\n', log{i});
        end
    end
    % =========================================================================
    % UPDATE WEBSITE
    if dowebsite
        bids_website(bidsroot)
    end
    % =========================================================================
    % CATCH ANY ERRORS
catch ME
    printerrormessage(ME, 'Send this error message to rick.wassing@woolcock.org.au')
end

end