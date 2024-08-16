% SCALPCOUPLINGINDEX
% Calculates the scalp-coupling index.
%
% Usage:
%   >> [sci] = scalpcouplingindex(dod_lambda1, dod_lambda2);
%
% Inputs:
%   'dod_lambda1' - [double] optical density on wavelength 1
%   'dod_lambda2' - [double] optical density on wavelength 2
%
% Outputs:
%   'sci' - [double] <m x n> scalp coupling index for each segment m and channel n

% Authors:
%   Laura Pollonini (lpollonini@uh.edu)
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2020-11-28, Rick Wassing

% (C) 2023 by Rick Wassing, licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function sci = scalpcouplingindex(dod_lambda1, dod_lambda2, Fs)

% =========================================================================
% FILTER THE DATA IN THE CARDIAC FREQUENCY BAND
% -------------------------------------------------------------------------
% Zero padding
dod_lambda1 = [zeros(1,2*Fs) detrend(dod_lambda1) zeros(1,2*Fs)];
dod_lambda2 = [zeros(1,2*Fs) detrend(dod_lambda2) zeros(1,2*Fs)];
% -------------------------------------------------------------------------
% Use fieldtrip to filter the data
dod_lambda1_filt = ft_preproc_bandpassfilter((dod_lambda1), Fs, [0.5, min([Fs/2-0.001, 2.5])], [], 'firws', 'onepass-zerophase',[],[],[],[],[],[]);
dod_lambda2_filt = ft_preproc_bandpassfilter((dod_lambda2), Fs, [0.5, min([Fs/2-0.001, 2.5])], [], 'firws', 'onepass-zerophase',[],[],[],[],[],[]);
% -------------------------------------------------------------------------
% Deleting the padded data
dod_lambda1_filt = dod_lambda1_filt(2*Fs+1:end-2*Fs);
dod_lambda2_filt = dod_lambda2_filt(2*Fs+1:end-2*Fs);
% =========================================================================
% AMPLITUDE NORMALIZATION
dod_lambda1_filt = zscore(dod_lambda1_filt);
dod_lambda2_filt = zscore(dod_lambda2_filt);
[sci_xcor, sci_lags] = xcorr(dod_lambda1_filt, dod_lambda2_filt, 'coeff');
sci = sci_xcor(abs(sci_lags) == min(abs(sci_lags)));
end