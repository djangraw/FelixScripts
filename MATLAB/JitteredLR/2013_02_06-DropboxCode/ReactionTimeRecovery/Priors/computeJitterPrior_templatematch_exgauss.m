function [pdf,extended_t] = computeJitterPrior_templatematch_exgauss(t, params)

% This function returns the prior matrix using a gaussian distribution with
% the given parameters.
%
% pdf = computeJitterPrior_templatematch_exgauss(t, params)
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
raweeg = params.data; % raw eeg data to compare to template
tRaw = params.times; % indices correspond to data
smoothwidth = params.smoothwidth; % size of sliding window to smooth the data
template = params.template; % template to use for matchStrength
tWin = params.tWin; % min and max times of template window


%% Set up
% offset times
times = tRaw-mean(tWin); % time of each data point relative to template window center
% Smooth data
smootheeg = nan(size(raweeg));
for i=1:size(raweeg,3)
     smootheeg(:,:,i) = conv2(raweeg(:,:,i),ones(1,smoothwidth)/smoothwidth,'same'); % same means output will be same size as input
end
data = smootheeg;


%% Calculate pdf
windowSize = size(template,2);
matchStrength = UpdateTemplateMatchStrength(data, template); % Get strength of match between data and template at each offset
tMatch = times(1:end-windowSize)+round(windowSize/2); % indices correspond to matchStrength
iMatch = interp1(tMatch,1:length(tMatch),t,'nearest','extrap'); % for each value in t, find index of the closest value in tMatch
pdf = matchStrength(:,iMatch); % crop matchStrength to values in t

pdf2 = computeJitterPrior_exgaussian(t,struct('mu',-100.1325, 'sigma',49.6453, 'tau',100.1325,'mirror',1));
pdf2 = repmat(pdf2,size(pdf,1),1);
pdf = pdf2.*pdf;

%% Correct
pdf = pdf./repmat(sum(pdf,2),1,size(pdf,2)); % normalize each row to sum to 1
extended_t = t; % return t as is