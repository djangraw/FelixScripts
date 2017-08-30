function [AzLoo,Az_accuracy,AzLoo_perm,Az_accuracy_perm] = GetLrAccuracyPredictions(allData,trainlabels,qPages_cell,isCorrect,params,nPerms)

% [AzLoo,Az_accuracy,AzLoo_perm,Az_accuracy_perm] = GetLrAccuracyPredictions(allData,trainlabels,qPages_cell,isCorrect,params,nPerms)
%
% Created 8/13/15 by DJ.


% declare defaults
if ~exist('nPerms','var')
    nPerms = 0;
end

% remove nans
for i=1:size(allData,1);
    allData(i,isnan(allData(i,:))) = nanmean(allData(i,:));
end

% crop training data
isForTraining = ~isnan(trainlabels);
yTrain = trainlabels(isForTraining);
training = allData(:,isForTraining)';

% run LR
[Az,AzLoo,LRstats] = RunSingleLR(permute(training,[2 3 1]),yTrain,params);
% Get resulting y values for each trial
wtsLoo = mean(LRstats.wtsLoo,2);
%     wts = LRstats(iClassifier).wts;
yAll = allData'*wtsLoo(1:end-1) + wtsLoo(end);

% Get output
yTest = nan(1,numel(qPages_cell));
qPages_cell = reshape(qPages_cell',size(isCorrect));
for i=1:numel(qPages_cell)
    if any(~isnan(qPages_cell{i}))
        yTest(i) = mean(yAll(qPages_cell{i}(~isnan(qPages_cell{i}))));
    end
end
Az_accuracy = rocarea(yTest,isCorrect);
fprintf('LOO Classifier predicts training with AzLoo = %.3f, accuracy with Az = %.3f\n',AzLoo, Az_accuracy);

% plot
xHist = (-20:1:20)*4;
if nPerms==0
    nPlots = 2;
else
    nPlots = 3;
end
% plot training histogram
nHist = zeros(numel(xHist),3);
nHist(:,1) = hist(yAll(trainlabels<=0),xHist);
nHist(:,2) = hist(yAll(trainlabels>0),xHist);
nHist(:,3) = hist(yAll(isnan(trainlabels)),xHist);
subplot(1,nPlots,1); cla;
plot(xHist,nHist)
xlabel('y (A.U.)')
ylabel('# trials')
legend('training = 0','training = 1','training = NaN');
title(sprintf('Histogram of mean-LOO results by training condition\nAz=%.3f',AzLoo))

% plot testing (accuracy) histogram
subplot(1,nPlots,2); cla;
nHist = zeros(numel(xHist),2);
nHist(:,1) = hist(yTest(~isCorrect),xHist);
nHist(:,2) = hist(yTest(isCorrect),xHist);
plot(xHist,nHist)
xlabel('y (A.U.)')
ylabel('# questions')
legend('incorrect','correct');
title(sprintf('Histogram of mean-LOO results by accuracy\nAz=%.3f',Az_accuracy))

% get for permutations
if nPerms>0
    [Az_perm, AzLoo_perm, wts_perm, wtsLoo_perm] = RunLrPermutationTests(training,yTrain,nPerms,params);
    yAll = allData'*wtsLoo_perm(1:end-1,:) + repmat(wtsLoo_perm(end,:),size(allData,2),1);

    %% Get output
    yTest_perm = nan(numel(qPages_cell),nPerms);
    for i=1:numel(qPages_cell)
        yTest_perm(i,:) = mean(yAll(qPages_cell{i}(~isnan(qPages_cell{i})),:),1);
    end
    Az_accuracy_perm = nan(nPerms,1);
    for i=1:nPerms
        Az_accuracy_perm(i) = rocarea(yTest_perm(:,i),isCorrect);
    end    
    fprintf('Classifier outperforms %d/%d = %.1f%% of permutations\n',sum(Az_accuracy>Az_accuracy_perm),nPerms,mean(Az_accuracy>Az_accuracy_perm)*100);    
    
    % plot cumulative histogram
    subplot(1,nPlots,3);
    cla; hold on;
    xHist = (.05:.05:.95)-.025;
    yHist = hist(Az_accuracy_perm,xHist);
    plot(xHist,cumsum(yHist)/sum(yHist)*100);
    PlotVerticalLines(Az_accuracy,'r');    
    xlabel('LOO Az');
    ylabel('% permutations')
    title(sprintf('Accuracy results:\nAzLoo=%.3f > %.1f%% of %d permutations',Az_accuracy,mean(Az_accuracy>Az_accuracy_perm)*100,nPerms));
else
    AzLoo_perm = [];
    Az_accuracy_perm = [];
end
