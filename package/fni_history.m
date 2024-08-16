% FNI_HISTORY
% Keeps track of all processing steps and configuration. And adds
% standardized methodology blurbs and citations.
%
% Usage:
%   >> [data] = fni_history(data, cfg);
%
% Inputs:
%   'data' - [struct] main structure containing all raw and processed data
%   'cfg' - [struct] configuration
%
% Outputs:
%   'data.history' - [struct] history steps with the fields
%       'cmd' - [char] line of matlab code
%       'cfg' - [char] JSON formatted configuration parameters
%       'methods' - [char] blurb of text to add in manuscripts
%       'cite' - [cell] DOIs of publications to cite

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2023-09-01, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function [data] = fni_history(data, cfg)

history = struct();
switch cfg.fcn
    case 'import'
        history.cmd = '[data, log] = fni_import(data, cfg);';
        history.cfg = struct2json(cfg);
        history.methods = 'Raw functional NIRS data was imported and saved to a SNIRF dataset according to the Brain Imaging Data Structure using Fieldtrip and Homer3.';
        history.cite = {'10.1038/sdata.2016.44', '10.1155/2011/156869', '10.1364/ao.48.00d280'};
        data.history = struct([]);
    case 'raw2dod'
        history.cmd = '[data, log] = fni_raw2dod(data);';
        history.cfg = '';
        history.methods = 'Raw intensity timeseries were converted to changes in optical density timeseries.';
        history.cite = {};
    case 'detectmotionartefactbychannel'
        history.cmd = '[data, log] = fni_detectmotionartefactbychannel(data, cfg);';
        history.cfg = struct2json(cfg);
        history.methods = sprintf('Any (remaining) motion artefacts were automatically detected on the optical density timeseries for each channel using a sliding window of %.3f s, an amplitude threshold of %.1f and a z-score threshold of %.1f. Time segments +/- %.3f s around identified windows were marked as artefacts.', cfg.tmotion, cfg.ampthres, cfg.stdthres, cfg.tmask);
        history.cite = {};
    case 'correctmotionwithwavelet'
        history.cmd = '[data, log] = fni_correctmotionwithwavelet(data, cfg);';
        history.cfg = struct2json(cfg);
        history.methods = sprintf('Motion artefacts were automatically corrected using wavelet decomposition and removing wavelet coefficients that exceeded %.1f the inter-quartile range.', cfg.iqr);
        history.cite = {'10.1088/0967-3334/33/2/259'};
    case 'bandpassfilt'
        history.cmd = '[data, log] = fni_bandpassfilt(data, cfg);';
        history.cfg = struct2json(cfg);
        if cfg.hpf == 0
            history.methods = sprintf('A third-order Butterworth lowpass filter was applied to ''%s'' at %.3f Hz (transition bandwith %.3f Hz).', cfg.source, cfg.lpf, cfg.lpf*2);
        else
            history.methods = sprintf('A third-order Butterworth lowpass filter was applied to ''%s'' at %.3f Hz (transition bandwith %.3f Hz), followed by a fifth-order Butterworth highpass filter at %.3f Hz (transition bandwith %.3f Hz).', cfg.source, cfg.lpf, cfg.lpf*2, cfg.hpf, cfg.hpf*2);
        end
        history.cite = {};
    case 'dod2dc'
        history.cmd = '[data, l] = fni_dod2dc(data, cfg);';
        history.cfg = struct2json(cfg);
        if isfield(cfg, 'age')
            history.methods = sprintf('Optical density timeseries were converted to hemoglobin concentration changes (HbO, HbR, and HbT) using age-dependent partial path length factors of %.3f for wavelength %.i nm and %.3f for %.i nm.', cfg.dpf(1), data.raw.probe.wavelengths(1), cfg.dpf(2), data.raw.probe.wavelengths(2));
        else
            history.methods = sprintf('Optical density timeseries were converted to hemoglobin concentration changes (HbO, HbR, and HbT) using partial path length factors of %.3f for wavelength %.i nm and %.3f for %.i nm.', cfg.dpf(1), data.raw.probe.wavelengths(1), cfg.dpf(2), data.raw.probe.wavelengths(2));
        end
        if isfield(cfg, 'age')
            history.cite = {'10.1117/1.JBO.18.10.105004'};
        else
            history.cite = {};
        end
    case 'signalqualityindex'
        history.cmd = '[data, log] = fni_signalqualityindex(data, cfg);';
        history.cfg = struct2json(cfg);
        history.methods = 'The scalp coupling index was calculated to determine of the quality of the connection between the optode and the scalp.';
        history.cite = {'10.1016/j.heares.2013.11.007.'};
    case 'averagetrials'
        history.cmd = '[data, log] = fni_averagetrials(data, cfg);';
        history.cfg = struct2json(cfg);
        history.methods = sprintf('The average response across trials was calculated on the ''%s'' data using a peri-stimulus window of %.3f to .3f s, and subtracting the mean across the pre-stimulus baseline.', cfg.source, cfg.window(1), cfg.window(2));
        history.cite = {};
    case 'powerspectralanalysis'
        history.cmd = '[data, log] = fni_powerspectralanalysis(data, cfg);';
        history.cfg = struct2json(cfg);
        history.methods = sprintf('Power-spectral analysis was applied to ''%s'' using Welch''s method with %.3f s windows and %.1f percent overlap.', cfg.source, cfg.windowlength, cfg.overlap);
        history.cite = {};
    case 'glmtimeseries'
        history.cmd = '[data, log] = fni_glmtimeseries(data, cfg);';
        history.cfg = struct2json(cfg);
        switch cfg.method
            case 'ordinary'
                glm_type = 'ordinary least squares';
            case 'weighted'
                glm_type = 'iterative weighted least squares';
        end
        if cfg.basisfcn == 1
            basisfcn = 'consecutive sequence of gaussian functions';
            basisparam = sprintf('sd = %.3f s, Δt = %.3f s', cfg.basiscfg(1), cfg.basiscfg(2));
        elseif cfg.basisfcn == 2
            basisfcn = 'a modified gamma function';
            basisparam = sprintf('tau = %.3f, sigma = %.3f, ', cfg.basiscfg);
            basisparam = basisparam(1:end-2);
        elseif cfg.basisfcn == 3
            basisfcn = 'a modified gamma function and its derivative';
            basisparam = sprintf('tau = %.3f, sigma = %.3f, ', cfg.basiscfg);
            basisparam = basisparam(1:end-2);
        elseif cfg.basisfcn == 4
            basisfcn = 'a GAM function from 3dDeconvolve (AFNI)';
            basisparam = sprintf('p = %.3f, q = %.3f, ', cfg.basiscfg);
            basisparam = basisparam(1:end-2);
        else
            basisfcn = '<UNKNOWN>';
            basisparam = 'n/a';
        end
        if cfg.corrthresh < 1
            corrthresh = sprintf('r > %.2f', cfg.corrthresh);
        else
            corrthresh = sprintf('n = %i', cfg.corrthresh);
        end
        history.methods = sprintf('An %s GLM was applied to estimate the HRF relative to the onset of the stimuli ''%s'', using %s (%s) within the time-window of %.3f and %.3f s, and included polynomial signal drift regressors (order = %i) and nuisance signal regressors calculated from auxiliary channels (%s) and short-separation channels (< %i mm) using temporally embedded canonical correlation analysis (tCCA; time-lag = %.3f s, step size = %.3f s, %s).', glm_type, strjoin(cfg.stimlabel, ''', '''), basisfcn, basisparam, cfg.window(1), cfg.window(2), cfg.driftorder, strjoin(cfg.auxchans, ', '), cfg.sstrhesh, cfg.timelag, cfg.stepsize, corrthresh);
        history.cite = {'10.1016/j.neuroimage.2019.116472'};
    case 'savederivative'
        history.cmd = '[data, log] = fni_savederivative(data, cfg);';
        history.cfg = struct2json(cfg);
        history.methods = sprintf('Data from the ''%s'' step were saved to ''%s''.', cfg.derivative, cfg.outputfile);
        history.cite = {};
    case 'importsyncedexgchannels'
        history.cmd = '[data, log] = fni_importsyncedexgchannels(data, cfg);';
        history.cfg = struct2json(cfg);
        history.methods = sprintf('EXG data was synced to the NIRS recording using the channels ''%s'' and ''%s'' respectively, and %i channels were imported from the EXG recording (''%s'').', cfg.exgsyncchan, cfg.nirssyncchan, length(cfg.selchans), strjoin(cfg.selchans, ', '));
        history.cite = {};
    otherwise
        error('>> FNI: Oh silly me, always shooting for the future, I forgot this history.')
end
data.history = [data.history; history];

end