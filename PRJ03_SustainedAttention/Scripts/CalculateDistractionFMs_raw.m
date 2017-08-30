function [fwdModel,AzLoo,Az,LRstats] = CalculateDistractionFMs_raw(data,stats,question,tc,fracTcVarToKeep,fracFcVarToKeep,label1,label0)

% [fwdModel,AzLoo,Az,LRstats] = CalculateDistractionFMs_raw(data,stats,question,tc,fracTcVarToKeep,fracFcVarToKeep,label1,label0)
%
% INPUTS:
%
% OUTPUTS:
%
% Created 5/26/16 by DJ.

% declare LR params
params.regularize=1;
params.lambda=1e-6;
params.lambdasearch=true;
params.eigvalratio=1e-4;
% params.vinit=zeros(size(feats,1)+1,1);
params.show=0;
params.LOO=true; % false; %
params.demean=false;
params.LTO=false;%true;
% declare other params
fcWinLength = 10;
tcWinLength = 8;
TR = 2;
nFirstRemoved = 3;
roiNames = {};


% normalize TC
for i=1:size(tc,1)
    tc(i,:) = (tc(i,:)-nanmean(tc(i,:)))/nanstd(tc(i,:));
end

% Run PCA on tcs
isNotCensoredSample = ~any(isnan(tc));
[U,S,V] = svd(tc(:,isNotCensoredSample)');
fracVar = cumsum(diag(S).^2)/sum(diag(S).^2);

% Perform dimensionality reduction on mag features
if fracTcVarToKeep<=0    
    fracTcVarToKeep = fracVar(getelbow(fracVar'));
    lastToKeep = find(fracVar<=fracTcVarToKeep,1,'last');
    fprintf('Found elbow at %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep*100)
else
    lastToKeep = find(fracVar<=fracTcVarToKeep,1,'last');
    fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep*100)
end
tc2 = V(:,1:lastToKeep)'*tc; % multiply each weight vec by each FC vec


%% Get feature matrix
[feats, featNames, labels, labelNames, times, timeNames, iTcEventSample, iFcEventSample,Vf] = ConstructComboFeatMatrix(data, stats, question, tc2, roiNames, fcWinLength, tcWinLength, TR, nFirstRemoved,fracFcVarToKeep);
fprintf('Done!\n');

%% Do classification
% remove nans
newFeats = feats;
for i=1:size(newFeats,1)
    newFeats(i,isnan(newFeats(i,:))) = nanmean(newFeats(i,:));
end
% normalize
normfeats = zeros(size(newFeats));
for i=1:size(newFeats,1)
    normfeats(i,:) = (newFeats(i,:)-nanmean(newFeats(i,:)))/nanstd(newFeats(i,:));
end
% Break down feats
isBoldFeat = strncmp('BOLD',featNames,4);
isFcFeat = strncmp('FC',featNames,2);
isEyeFeat = strncmp('EYE',featNames,3);
fprintf('%d BOLD, %d FC, %d EYE feats\n',sum(isBoldFeat),sum(isFcFeat),sum(isEyeFeat))

% Get Truth Labels
nTrials = size(labels,2);
truth = nan(1,size(labels,2));
iLabel1 = find(strcmp(labelNames,label1));
truth(labels(iLabel1,:)) = 1;
if strcmp(label0,'other')
    truth(~labels(iLabel1,:)) = 0;
else
    iLabel0 = find(strcmp(labelNames,label0));
    truth(labels(iLabel0,:)) = 0;
end
isOkTrial = ~isnan(truth) & ~isnan(iFcEventSample);
newFeats = permute(normfeats(isFcFeat,isOkTrial),[1 3 2]);
newTruth = truth(isOkTrial);
nTrials = numel(newTruth);

%% Classify
nFeats = sum(isFcFeat);
% Check for features            
if nFeats==0
    fprintf('No FC features... classifier can''t run!\n')    
    AzLoo = 0;
    Az = 0;
    y = nan(1,nTrials);
    return;
end
% CLASSIFY
fprintf('Classifying for %d trials',nTrials)
params.vinit=zeros(nFeats+1,1);

[Az,AzLoo,LRstats,AzLto] = RunSingleLR(newFeats,newTruth,params);
fprintf('tcVar=%.2f, fcVar=%.2f: FC LOO Az = %.3f\n',fracTcVarToKeep,fracFcVarToKeep,AzLoo);
isOkTrial = ~isnan(truth) & ~isnan(iFcEventSample);
y = [normfeats(isFcFeat,isOkTrial); ones(1,sum(isOkTrial))]'*LRstats.wts;

%% Get FC and normalize
% FC = GetFcMatrices(tc,'sw',fcWinLength);
% FC_norm = nan(size(FC));
% for i=1:size(FC,1)
%     for j=1:size(FC,2)
%         FC_norm(i,j,:) = (FC(i,j,:)-nanmean(FC(i,j,:),3))/nanstd(FC(i,j,:),[],3);
%     end
% end
% % set nans to zero
% FC_norm(isnan(FC_norm)) = 0;
% % Crop to trials
% FC_okTrials = FC_norm(:,:,iFcEventSample(isOkTrial));
% nTrials = sum(isOkTrial);
% nROI = size(FC,1);
% X = reshape(FC_okTrials,[nROI*nROI,nTrials])';

%% Get FC and normalize
FC = GetFcMatrices(tc2,'sw',fcWinLength);
% demean
FC_norm = nan(size(FC));
for i=1:size(FC,1)
    for j=1:size(FC,2)
        FC_norm(i,j,:) = (FC(i,j,:)-nanmean(FC(i,j,:),3));%/nanstd(FC(i,j,:),[],3);
    end
end
% Reduce dimensionality
FC_vec = VectorizeFc(FC_norm);
nFcDimsToKeep = sum(isFcFeat);
FC_vec_dimred = Vf(:,1:nFcDimsToKeep)*Vf(:,1:nFcDimsToKeep)'*FC_vec;
FC_dimred = UnvectorizeFc(FC_vec_dimred);

% Crop to trials
FC_okTrials = FC_dimred(:,:,iFcEventSample(isOkTrial));

% set nans to zero
FC_okTrials(isnan(FC_okTrials)) = 0;
% set diagonals to zero
FC_okTrials(FC_okTrials==1) = 0;

% Reshape to X matrix
nTrials = sum(isOkTrial);
nROI = size(FC,1);
X = reshape(FC_okTrials,[nROI*nROI,nTrials])';

%% Get FM
fprintf('Getting forward models...\n');
fwdModel_2d = y \ X;
fwdModel = reshape(fwdModel_2d,[nROI,nROI]);
% Clean up
fprintf('Done!\n');
        
