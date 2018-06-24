function [pdf,extended_t] = computeJitterPrior_exgaussian(t, params)

% This function returns the prior matrix using a gaussian distribution with
% the given parameters.
%
% pdf = computeJitterPrior_exgaussian(t, params)
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
% Created 9/26/12 by DJ based on computeJitterPrior_gaussian.m.
% Updated 12/4/12 by DJ - fixed bug for t ranges that don't sum to zero

% Extract info
mu = params.mu;
sigma = params.sigma;
tau = params.tau;

% Model RT distribution as a Gaussian
if params.mirror
    pdf = exgausspdf(mu,sigma,tau,-t);
else
    pdf = exgausspdf(mu,sigma,tau,t);
end
% if params.mirror
%     pdf = fliplr(pdf);
% end
extended_t = t;