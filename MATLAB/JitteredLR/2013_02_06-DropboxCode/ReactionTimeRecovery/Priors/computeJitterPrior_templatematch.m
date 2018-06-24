function [pdf,extended_t] = computeJitterPrior_templatematch(t, params)

% This function returns the prior matrix using a gaussian distribution with
% the given parameters.
%
% pdf = computeJitterPrior_templatematch(t, params)
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
% Created 11/27/12 by DJ based on computeJitterPrior_gaussian.m.

% Extract info
data = params.data; % raw eeg data to compare to template
tRaw = params.times; % indices correspond to data
template = params.template; % template to use for matchStrength
tWin = params.tWin; % min and max times of template window
useMax = params.useMax; % use the maximum point instead of a distribution

%% Set up
% offset times
times = tRaw-mean(tWin); % time of each data point relative to template window center


%% Calculate pdf
windowSize = size(template,2);
matchStrength = UpdateTemplateMatchStrength(data, template); % Get strength of match between data and template at each offset
tMatch = times(1:end-windowSize)+round(windowSize/2); % indices correspond to matchStrength
iMatch = interp1(tMatch,1:length(tMatch),t,'nearest','extrap'); % for each value in t, find index of the closest value in tMatch
pdf = matchStrength(:,iMatch); % crop matchStrength to values in t

%% Correct
pdf = pdf./repmat(sum(pdf,2),1,size(pdf,2)); % normalize each row to sum to 1
if useMax
    [~,iMax] = max(pdf,[],2);
    pdf = full(sparse(1:length(iMax),iMax,1,size(pdf,1),size(pdf,2)));   
end
extended_t = t; % return t as is