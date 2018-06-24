function [newdata,truejitter] = JitterTrials_rawdata(data,epochrange,jitterrange)

% truejitter = JitterTrials_rawdata(data,jitterrange)
%
% INPUTS:
% - data is a 3D matrix.
% - epochrange is a 2-element vector (in samples).
% - jitterrange is a 2-element vector (in samples).
%
% OUTPUTS:
% - truejitter is a vector.
%
% Created 11/1/13 by DJ.

% Get constants
D = size(data,1); % # chans
T = size(data,2); % # samples in NEW epochs
N = size(data,3); % # of trials

if (jitterrange(1) + epochrange(1)) < 0 || (jitterrange(2) + epochrange(2)) > T
    error('Possible jitter out of range!')
end

% Set up
truejitter = floor(jitterrange(1) + diff(jitterrange)*rand(1,N));
newdata = nan(D,diff(epochrange)+1,N);

% Main loop
for i=1:N
    newsamples = truejitter(i) + (epochrange(1):epochrange(2));
    newdata(:,:,i) = data(:,newsamples,i);
end