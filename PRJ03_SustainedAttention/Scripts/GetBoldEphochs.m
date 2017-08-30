function epochs = GetBoldEphochs(boldData,boldTimes,tEpochStart,tWindow)

% epochs = GetBoldEphochs(boldData,boldTimes,tEpochStart,tWindow)
%
% INPUTS:
% -boldData is an NxM matrix, where N is the number of time points and M is
% the number of features (e.g., activity in an ROI);
% -boldTimes is an M-element vector of the corresponding sample times.
% -tEpochStart is a P-element vector of the start times of each epoch.
% -tWindow is a Q-element vector of the times (relative to tEpochStart) to
% be included in the epoch. 
%
% OUTPUTS:
% -epochs is a QxMxP matrix in which epochs(i,j,k) is the bold data at time
% tWindow(i)+tEpochStart(k) for feature j.
%
% Created 3/16/16 by DJ.

if numel(boldTimes)==1
    TR = boldTimes;
    boldTimes = (1:size(boldData,2))*TR;
else
    TR = boldTimes(2)-boldTimes(1);
end
if numel(tWindow)==2
    tLimits = tWindow;
    tWindow = tLimits(1):TR:tLimits(2);
end

nEpochs = numel(tEpochStart);
nFeats = size(boldData,2);
nT = numel(tWindow);
epochs = nan(nT,nFeats,nEpochs);

for i=1:nEpochs
    epochTimes = tEpochStart(i)+tWindow;
    epochs(:,:,i) = interp1(boldTimes,boldData,epochTimes,'linear');
end