function [AzLoo_all,Az_all,LRstats_all,yLoo,newTruth] = PerformNestedCvOnDistractionData(data,stats,question,tc,fracTcVarToKeep,fracFcVarToKeep,label1,label0)

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
        fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep(iTcVar)*100)
    end
    tc2 = V(:,1:lastToKeep)'*tc; % multiply each weight vec by each FC vec

    for iFcVar=1:numel(fracFcVarToKeep)

        %% Get feature matrix
        [feats, featNames, labels, labelNames, times, timeNames, iTcEventSample, iFcEventSample] = ConstructComboFeatMatrix(data, stats, question, tc2, roiNames, fcWinLength, tcWinLength, TR, nFirstRemoved,fracFcVarToKeep(iFcVar));
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
        if sum(isFcFeat)==0
            fprintf('No FC features... classifier can''t run!\n')
            AzLoo_all(iTcVar,iFcVar,:) = 0;
            Az_all(iTcVar,iFcVar,:) = 0;
            yLoo(iTcVar,iFcVar,:) = 0;
            continue;
        end
        % CLASSIFY
        newFeats = permute(normfeats(isFcFeat,isOkTrial),[1 3 2]);
        newTruth = truth(isOkTrial);
        nTrials = numel(newTruth);
        fprintf('Classifying for %d trials',nTrials)
        for iTrial = 1:nTrials
            fprintf('.')
            inTrials = [1:iTrial-1, iTrial+1:nTrials];
            [Az_fc,AzLoo_fc,LRstats_fc,AzLto_fc] = RunSingleLR(newFeats(:,:,inTrials),newTruth(inTrials),params);
%            fprintf('tcVar=%.2f, fcVar=%.2f: FC LOO Az = %.3f\n',fracTcVarToKeep,fracFcVarToKeep,AzLoo_fc);
            AzLoo_all(iTcVar,iFcVar,iTrial) = AzLoo_fc;
            Az_all(iTcVar,iFcVar,iTrial) = Az_fc;
            LRstats_all{iTcVar,iFcVar,iTrial} = LRstats_fc;
            yLoo(iTcVar,iFcVar,iTrial) = [newFeats(:,:,iTrial); 1]'*LRstats_fc.wts;
        end
        fprintf('Done!\n');
        
    end
end