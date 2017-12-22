function [icTcs_accepted,betas_accepted,iAccepted] = Get100RunsAcceptedCompTcs(subject,session,task)

% [icTcs_accepted,betas_accepted,iAccepted] = Get100RunsAcceptedCompTcs(subject,session,task)
%
% Created 12/20/17 by DJ.

% cd /data/jangrawdc/PRJ15_FmriToSound/TestData/100RUNS_3Tmultiecho
% Load component timecourses
icTcs = Read_1D(sprintf('SBJ%02d_S%02d_Task%02d_meica_mix.1D',subject,session,task));
% Scale by variance explained
varex = dlmread(sprintf('SBJ%02d_S%02d_Task%02d_varex.txt',subject,session,task));
icTcs_scaled = icTcs.*repmat(sqrt(varex'),size(icTcs,1),1);

% Crop to accepted components
iAccepted = 1 + dlmread(sprintf('SBJ%02d_S%02d_Task%02d_accepted.txt',subject,session,task));
icTcs_accepted = icTcs_scaled(:,iAccepted);
% Load betas of accepted components
betasFilename = sprintf('SBJ%02d_S%02d_Task%02d_betas_OC.nii',subject,session,task);
betas_accepted = load_nii(betasFilename,iAccepted);
