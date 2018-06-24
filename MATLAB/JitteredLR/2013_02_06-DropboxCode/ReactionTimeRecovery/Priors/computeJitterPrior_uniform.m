function [pdf,extended_t] = computeJitterPrior_uniform(t, params)

% This function returns the prior matrix using a uniform distribution with
% the given parameters.
%
% [pdf,extended_t] = computeJitterPrior_uniform(t, params)
%
% INPUTS:
% - t is a T-element vector indicating the times of EEG data available
%   (i.e the acceptable jitter times).
% - params is a struct (currently created in run_logisticregression_jittered_EM_oddball.m)
%   with fields:
%    > range, a 2-element vector indicating the min and max values of the
%    uniform distribution.
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

% Extract info
range = params.range;
nTrials = params.nTrials;
if isfield(params,'tInit');
    tInit = params.tInit;
else
    tInit = NaN;
end
max_t = max(t);

% create extended pdf matrix
if length(t)>1
    diff_t = t(2)-t(1); % assume constant sampling rate
else
    diff_t = 1; % assume sampling rate of 1000 Hz
end
extended_t = [t, (max_t+diff_t):diff_t:range(2)];
% pdf = zeros(length(reactionTimes),length(extended_t)); % make it big - we'll crop it down at the end

% Model RT distribution as a Gaussian
onepdf = zeros(1,length(extended_t));
onepdf(extended_t>=range(1) & extended_t<=range(2)) = 1;
if ~isnan(tInit)
    iTime = find(extended_t>=tInit,1);
    if isempty(iTime) 
        iTime=length(extended_t); 
    end
    onepdf(iTime) = 1+1e-10;
end
onepdf = onepdf/sum(onepdf);
pdf = repmat(onepdf,nTrials,1);

% crop pdf back down as much as possible
pdf = pdf(:,1:find(sum(pdf,1)>0,1,'last')); % delete all columns after last non-zero column
extended_t = extended_t(1:size(pdf,2)); % crop to fit size of pdf
