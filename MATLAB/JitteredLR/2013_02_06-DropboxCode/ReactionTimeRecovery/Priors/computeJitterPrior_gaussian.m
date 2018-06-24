function [pdf,extended_t] = computeJitterPrior_gaussian(t, params)

% This function returns the prior matrix using a gaussian distribution with
% the given parameters.
%
% pdf = computeJitterPrior_gaussian(t, params)
%
% INPUTS:
% - t is a T-element vector indicating the times of EEG data available
%   (i.e the acceptable jitter times).
% - params is a struct (currently created in run_logisticregression_jittered_EM_oddball.m)
%   with fields:
%    > mu, a scalar indicating the mean of the gaussian
%    > sigma, a scalar indicating the standard deviation of the gaussian
%    > nTrials, a scalar indicating the number of trials.
%
% OUTPUTS:
% - pdf is an NxM matrix (where M>=T), in which pdf(i,j) is the prior 
% probability that the discriminating activity in trial i is locked to time 
% extended_t(j).  Each row of pdf will therefore sum to 1.
% - extended_t is an M-element vector that takes the t input vector and
% extends it just enough to include every 'first saccade after this range'
% as described above.
%
% Created 8/15/12 by DJ based on computeSaccadeJitterPrior.m.
% Updated 9/24/12 by DJ - nTrials=1, let pop_ make it bigger

% Extract info
mu = params.mu;
sigma = params.sigma;
% nTrials = params.nTrials;
nTrials = 1;

% Model RT distribution as a Gaussian
onepdf = normpdf(t,mu,sigma);
onepdf = onepdf/sum(onepdf);
pdf = repmat(onepdf,nTrials,1);

% crop pdf back down as much as possible
pdf = pdf(:,1:find(sum(pdf,1)>0,1,'last')); % delete all columns after last non-zero column
extended_t = t(1:size(pdf,2)); % crop to fit size of pdf