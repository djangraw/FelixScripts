function [FCtop,FCbottom] = GetFcInGoodAndBadPerformers(FC,fracCorrect)

% [FCtop,FCbottom] = VisualizeFcInGoodAndBadPerformers(FC,fracCorrect)
%
% Created 2/22/17 by DJ.

% Separate into thirds
nSubj = numel(fracCorrect);
nInThird = ceil(nSubj/3);
[~,order] = sort(fracCorrect,'descend');
topThird = order(1:nInThird);
bottomThird = order((end-nInThird+1):end);

% Get mean FC in top third and bottom third
FCtop = mean(FC(:,:,topThird),3);
FCbottom = mean(FC(:,:,bottomThird),3);
