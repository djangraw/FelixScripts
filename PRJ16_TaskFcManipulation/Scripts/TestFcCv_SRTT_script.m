% TestFcCv_SRTT_script.m
%
% Created 8/15/17 by DJ.

nFirstHalf = floor(size(FC_struct,3)/2);
figure(101);
PlotFc_SRTT(FC_struct(:,:,1:nFirstHalf),FC_unstruct(:,:,1:nFirstHalf),FC_base(:,:,1:nFirstHalf),[],[-1 1]*.05)
MakeFigureTitle('First Half');
figure(102);
PlotFc_SRTT(FC_struct(:,:,nFirstHalf+1:end),FC_unstruct(:,:,nFirstHalf+1:end),FC_base(:,:,nFirstHalf+1:end),[],[-1 1]*.05)
MakeFigureTitle('Second Half');


%% See if the significance tests agree across data halves
thresh = 0.05;
[FC_struct_base_thresh1,FC_unstruct_base_thresh1,FC_struct_unstruct_thresh1] = ...
    GetFcDiffs_SRTT(FC_struct_fisher(:,:,1:nFirstHalf),FC_unstruct_fisher(:,:,1:nFirstHalf),FC_base_fisher(:,:,1:nFirstHalf),thresh);
[FC_struct_base_thresh2,FC_unstruct_base_thresh2,FC_struct_unstruct_thresh2] = ...
    GetFcDiffs_SRTT(FC_struct_fisher(:,:,nFirstHalf+1:end),FC_unstruct_fisher(:,:,nFirstHalf+1:end),FC_base_fisher(:,:,nFirstHalf+1:end),thresh);

overlap = sum(VectorizeFc(FC_struct_unstruct_thresh1>0 & FC_struct_unstruct_thresh2>0));
total = sum(VectorizeFc(FC_struct_unstruct_thresh1>0)) + sum(VectorizeFc(FC_struct_unstruct_thresh2>0));       
PosDice = 2*overlap./total;

overlap = sum(VectorizeFc(FC_struct_unstruct_thresh1<0 & FC_struct_unstruct_thresh2<0));
total = sum(VectorizeFc(FC_struct_unstruct_thresh1<0)) + sum(VectorizeFc(FC_struct_unstruct_thresh2<0));       
NegDice = 2*overlap./total;

fprintf('PosDice: %.3g, NegDice:%.3g\n',PosDice,NegDice);

%% See if the FC difference matrices agree across data halves
FC_struct_unstruct1 = mean(FC_struct_fisher(:,:,1:nFirstHalf)-FC_unstruct_fisher(:,:,1:nFirstHalf),3);
FC_struct_unstruct2 = mean(FC_struct_fisher(:,:,nFirstHalf+1:end)-FC_unstruct_fisher(:,:,nFirstHalf+1:end),3);
[r,p] = corr(VectorizeFc(FC_struct_unstruct1),VectorizeFc(FC_struct_unstruct2));
fprintf('r=%.3f, p=%.3g\n',r,p);

%% Try some cross-validated classification
nSubj = size(FC_struct,3);
nFolds = 5;
indices = crossvalind('Kfold', nSubj, nFolds);
nEdges = size(VectorizeFc(FC_struct_fisher),1);

% Set up logistic regression params
params.regularize=1;
params.lambda=1e1;
params.lambdasearch=0;
params.eigvalratio=1e-4;
params.vinit=zeros(nEdges+1,1);
params.show = 0;
params.LOO = 0;  

testLabels = nan(nSubj,2);
trueLabels = [zeros(nSubj,1); ones(nSubj,1)];
for i=1:nFolds
    fprintf('Fold %d/%d...\n',i,nFolds);
    tic;
    % Get train/test split
    isTest = indices==i;
    isTrain = ~isTest;
    trainData = [VectorizeFc(FC_unstruct_fisher(:,:,isTrain)), VectorizeFc(FC_struct_fisher(:,:,isTrain))]';
    trainLabels = [zeros(1,sum(isTrain)), ones(1,sum(isTrain))]';
    testData = [VectorizeFc(FC_unstruct_fisher(:,:,isTest)), VectorizeFc(FC_struct_fisher(:,:,isTest))]';
    % Train classifier
    [~,~,stats] = RunSingleLR(permute(trainData,[2,3,1]),trainLabels,params);
    class = testData*stats.wts(1:end-1)+stats.wts(end);
    % Test classifier
    testLabels(isTest,1) = class(1:sum(isTest));
    testLabels(isTest,2) = class(sum(isTest)+1:end);
    fprintf('Done! took %.1f seconds.\n',toc);
end
AUC = rocarea(trueLabels,testLabels(:));
fprintf('AUC = %.3f\n',AUC);

%% RUN PERM TESTS
nPerms = 500;
AUC_perm = nan(1,nPerms);
for iPerm = 1:nPerms
    fprintf('===Perm %d/%d...\n',iPerm,nPerms);
    testLabels = nan(nSubj,2);
    trueLabels = [zeros(nSubj,1); ones(nSubj,1)];
    % PERMUTE!
    trueLabels = trueLabels(randperm(size(trueLabels,1)));
    for i=1:nFolds
        fprintf('Fold %d/%d...\n',i,nFolds);
        tic;
        % Get train/test split
        isTest = indices==i;
        isTrain = ~isTest;
        trainData = [VectorizeFc(FC_unstruct_fisher(:,:,isTrain)), VectorizeFc(FC_struct_fisher(:,:,isTrain))]';
        trainLabels = [zeros(1,sum(isTrain)), ones(1,sum(isTrain))]';
        testData = [VectorizeFc(FC_unstruct_fisher(:,:,isTest)), VectorizeFc(FC_struct_fisher(:,:,isTest))]';
        % Train classifier
        [~,~,stats] = RunSingleLR(permute(trainData,[2,3,1]),trainLabels,params);
        class = testData*stats.wts(1:end-1)+stats.wts(end);
        % Test classifier
        testLabels(isTest,1) = class(1:sum(isTest));
        testLabels(isTest,2) = class(sum(isTest)+1:end);
        fprintf('Done! took %.1f seconds.\n',toc);
    end
    AUC_perm(iPerm) = rocarea(trueLabels,testLabels(:));
    fprintf('AUC = %.3f\n',AUC_perm(iPerm));
end