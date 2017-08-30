function [AzLoo_all,Az_all,LRstats_all,yLoo,newTruth] = PerformNestedCvOnDistractionData_Mag(data,stats,question,tc,fracTcVarToKeep,label1,label0)

% Created 3/17/16 by DJ.

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
fracFcVarToKeep = 1e-3; % keep no FC... don't need it!

% normalize TC
for i=1:size(tc,1)
    tc(i,:) = (tc(i,:)-nanmean(tc(i,:)))/nanstd(tc(i,:));
end

% Run PCA on tcs
isNotCensoredSample = ~any(isnan(tc));
[U,S,V] = svd(tc(:,isNotCensoredSample)');
fracVar = cumsum(diag(S).^2)/sum(diag(S).^2);

% AzLoo_all = nan(numel(fracTcVarToKeep),numel(fracFcVarToKeep),nTrials);
clear AzLoo_all Az_all LRstats_all yLoo

for iTcVar=1:numel(fracTcVarToKeep)
    
    % Perform dimensionality reduction on mag features
    if fracTcVarToKeep(iTcVar)<=0    
        fracTcVarToKeep(iTcVar) = fracVar(getelbow(fracVar'));
        lastToKeep = find(fracVar<=fracTcVarToKeep(iTcVar),1,'last');
        fprintf('Found elbow at %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep(iTcVar)*100)
    else
        lastToKeep = find(fracVar<=fracTcVarToKeep(iTcVar),1,'last');
        if isempty(lastToKeep)
            lastToKeep=1;
            fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracVar(lastToKeep)*100)
        else
            fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep(iTcVar)*100)
        end
    end
    tc2 = V(:,1:lastToKeep)'*tc; % multiply each weight vec by each FC vec

    %% Get feature matrix
    [feats, featNames, labels, labelNames, times, timeNames, iTcEventSample, iFcEventSample] = ConstructComboFeatMatrix(data, stats, question, tc2, roiNames, fcWinLength, tcWinLength, TR, nFirstRemoved,fracFcVarToKeep);
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
    isOkTrial = ~isnan(truth);
    params.vinit=zeros(size(feats,1)+1,1);

    % Check for features            
    if sum(isBoldFeat)==0
        fprintf('No FC features... classifier can''t run!\n')
        AzLoo_all(iTcVar,:) = 0;
        Az_all(iTcVar,:) = 0;
        yLoo(iTcVar,:) = 0;
        continue;
    end
    % CLASSIFY
    newFeats = permute(normfeats(isBoldFeat,isOkTrial),[1 3 2]);
    newTruth = truth(isOkTrial);
    nTrials = numel(newTruth);
    fprintf('Classifying for %d trials',nTrials)
    for iTrial = 1:nTrials
        fprintf('.')
        inTrials = [1:iTrial-1, iTrial+1:nTrials];
        [Az_bold,AzLoo_bold,LRstats_bold,AzLto_bold] = RunSingleLR(newFeats(:,:,inTrials),newTruth(inTrials),params);
%            fprintf('tcVar=%.2f, fcVar=%.2f: FC LOO Az = %.3f\n',fracTcVarToKeep,fracFcVarToKeep,AzLoo_fc);
        AzLoo_all(iTcVar,iTrial) = AzLoo_bold;
        Az_all(iTcVar,iTrial) = Az_bold;
        LRstats_all{iTcVar,iTrial} = LRstats_bold;
        yLoo(iTcVar,iTrial) = [newFeats(:,:,iTrial); 1]'*LRstats_bold.wts;
    end
    fprintf('Done!\n');
        
end