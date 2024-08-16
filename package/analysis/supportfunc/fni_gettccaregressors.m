% FNI_GETTCCAREGRESSORS
% Generates regressors using the regularized temporally embedded
% Canonical Correlation Anlaysis. Please use the following citation:
% von Lühmann, et al., NeuroImage, 208, 116472 (2020).
%
% Usage:
%   >> [aux, rcmap] = fni_gettccaregressors(data, cfg);
%
% Inputs:
%   'dc' - [DataClass] Homer3 data class
%   'aux' - [AuxClass] Homer3 aux class
%   'probe' - [ProbeClass] Homer3 probe class
%   'cfg' - [struct] configuration with the fields
%       'timelag' - [double] timespan in seconds for temporal embedding 
%           (Default: 3)
%       'stepsize' - [double] step size (Δt) in seconds for each time shift 
%           of auxiliary signals in the temporal embedding step
%       'corrthresh' - [double] correlation threshold to keep only those 
%           tCCA regressors for the GLM nuisance removal that have a 
%           canonical correlation with fNIRS signals in the CCA space that 
%           is greater than 'corrThresh'
%       'auxchans' - [cell] channel names of the auxiliary channels to
%           include.
%       'sstrhesh' - [double] distance in mm to detect short separation 
%           channels
%       'baselinewindow' - [double] window in seconds to be used as a resting
%           state measurement for tCCA training. By default, the first 3.5
%           minutes should be resting-state
%       'trainingfile' - [char] path and filename containing the tCCA filter coefficients
%
% Outputs:
%   'regressors' - A matrix of auxilliary regressors (#time points x #Aux regressors)
%
% Authors:
%   Alexander von Lühmann, Neurophotonics Center, Biomedical Engineering, Boston University, Boston, MA 02215, USA
%   Meryem Ayşe Yücel, Neurophotonics Center, Biomedical Engineering, Boston University, Boston, MA 02215, USA
%   Rick Wassing, Woocock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2020-05-206, Alexander von Lühmann and Meryem Ayşe Yücel
%   Adapted 2023-09-29, Rick Wassing

% (C) 2023 by Homer3 is BSD licensed under the 3-Clause BSD License
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [regressors, rcmap] = fni_gettccaregressors(dc, aux, probe, cfg)
% =========================================================================
% EXECUTE
% -------------------------------------------------------------------------
mlActMan = [];
mlActAuto = [];
flagtCCA = true;
tCCAparams = [cfg.timelag, cfg.stepsize, cfg.corrthresh];
tCCAaux_inx = contains({aux.name}, cfg.auxchans);
ss_ch_on = 1;
runIdxResting = 1;
% Training
if exist(cfg.trainingfile, 'file') == 0
    fprintf('>> FNI: Training file for tCCA ''%s'' does not exist yet, creating now.\n', cfg.trainingfile)
    hmrR_tCCA(dc, aux, probe, 1, 1, mlActMan, mlActAuto, flagtCCA, tCCAparams, tCCAaux_inx, cfg.sstrhesh, ss_ch_on, runIdxResting, cfg.baselinewindow, cfg.trainingfile);
else
    fprintf('>> FNI: Using training file ''%s'' for tCCA.\n', cfg.trainingfile)
end
% Apply
[regressors, rcmap] = hmrR_tCCA(dc, aux, probe, 2, 1, mlActMan, mlActAuto, flagtCCA, tCCAparams, tCCAaux_inx, cfg.sstrhesh, ss_ch_on, runIdxResting, cfg.baselinewindow, cfg.trainingfile);

end