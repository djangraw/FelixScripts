function [AzCv, fwdModelCv, statsCv, newParams, AzCvPerm, fwdModelCvPerm, statsCvPerm, yCv_allTrials] = ClassifySubject_Mag_LORO(subject,allParams)

% [AzCv, fwdModelCv, statsCv, newParams, AzCvPerm, fwdModelCvPerm, statsCvPerm, yCv_allTrials] = ClassifySubject_Mag_LORO(subject,allParams)
%
% Classify a single subject's data - with LORO CV - using BOLD magnitude
% features. 
%
% Created 6/15/16 by DJ based on ClassifyAcrossSubjects.
% Updated 6/18/16 by DJ - added permutation option and outputs
% Updated 6/21/16 by DJ - added yCv_allTrials output.
% Updated 8/26/16 by DJ - allow custom atlasType, switched to LORO CV

if ~exist('allParams','var')
    allParams = [];
end
% Declare defaults
defaultParams.homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
defaultParams.label0 = 'attendedSpeech';
defaultParams.label1 = 'ignoredSpeech';
defaultParams.atlasType = 'Craddock'; % Craddock, Craddock_e2, or Shen
defaultParams.tcNormOption = 'run'; % normalization of raw data: 'run' or 'subject'
defaultParams.TR = 2;
defaultParams.nFirstRemoved = 3;
defaultParams.HrfOffset = 6;
defaultParams.doMagPca = true;
defaultParams.fracMagVarToKeep = 1;
defaultParams.magNormOption = 'run'; % normalization after SVD: 'run' or 'subject'
defaultParams.nPerms = 0; % number of permutations
defaultParams.doPlot = true;
defaultParams.doRandTc = false;

LRparams.regularize=1;
LRparams.lambda=1e-6;
LRparams.lambdasearch=true;
LRparams.eigvalratio=1e-4;
LRparams.vinit=[];
LRparams.show=0;
LRparams.LOO=false; % true; % 
LRparams.demean=false;
LRparams.LTO=false;%true;
defaultParams.LRparams = LRparams;

% Apply defaults and unpack struct fields into this workspace
newParams = ApplyDefaultsToStruct(allParams,defaultParams);
UnpackStruct(newParams);

% Set up
cd(homedir)
fprintf('Loading files...\n');
% Get input data
cd(sprintf('%sSBJ%02d',homedir,subject));
% Load timecourses
if subject<9
    beh = load(sprintf('DistractionTask-%d-QuickRun.mat',subject));
    load(sprintf('SBJ%02d_FC_MultiEcho_2015-12-17_Craddock.mat',subject),'tc');
else
%     beh = load(sprintf('Distraction-%d-QuickRun.mat',subject));
    beh = load(sprintf('Distraction-SBJ%02d-Behavior.mat',subject));
    datadir = dir('AfniProc*');
    cd(datadir(1).name);
    switch atlasType
        case 'Craddock'
            [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
        case 'Craddock_e2'
            [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts_e2.1D',subject));
        case 'Shen'
            [~,tc] = Read_1D(sprintf('shen268_withSegTc_SBJ%02d_ROI_TS.1D',subject));
        otherwise
            tcFile = sprintf('%s_SBJ%02d_ROI_TS.1D',atlasType,subject);
            if exist(tcFile,'file')
                [~,tc] = Read_1D(tcFile);
            else
                error('Altas not recognized!');
            end
    end
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
end
if doRandTc
    fprintf('====RANDOMIZING TC!!!!!\n')
    tc = tc(:,randperm(size(tc,2)));
%     tc = randn(size(tc));
end

% Get trial times
nRuns = numel(beh.data);
nT = size(tc,2);
nTR = nT/nRuns + nFirstRemoved;
fcWinLength = 10; % placeholder
iTcEventSample_start = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset,'start');
[iTcEventSample_end,~,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset,'end');

% get run number for each event
eventRun = ceil(iTcEventSample_start/(nTR-nFirstRemoved));

% normalize TC
nROIs = size(tc,1);
switch tcNormOption
    case {'subject','all'}
        for j=1:nROIs
            tc(j,:) = (tc(j,:)-nanmean(tc(j,:)))/nanstd(tc(j,:));
        end
    case 'run'
        iRun = ceil((1:nT)/(nT/nRuns));
        for k=1:nRuns
            isInRun = (iRun==k);
            for j=1:nROIs
                tc(j,isInRun) = (tc(j,isInRun)-nanmean(tc(j,isInRun)))/nanstd(tc(j,isInRun));
            end
        end
    case 'none'
        % do nothing
end
    
fprintf('Done!\n');

%% Run SVD on timecourse data

if doMagPca
%     fprintf('Running SVD on magnitude data...\n');
%     % Run PCA on tcs
%     isNotCensoredSample = ~any(isnan(tc));
% 
%     % Run SVD
%     [~,Sm,Vm] = svd(tc(:,isNotCensoredSample)',0);
%     fracVar = cumsum(diag(Sm).^2)/sum(diag(Sm).^2);
%     % Perform dimensionality reduction on mag features
%     lastToKeep = find(fracVar<=fracMagVarToKeep,1,'last');
%     fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracMagVarToKeep*100)
%     tc_whitened = Vm(:,1:lastToKeep)'*tc; % rotate using SVD whitening matrix

    % Run PCA instead of SVD
    fprintf('Running PCA on magnitude data...\n');
    [err, errMsg, result] = func_CSD_PCA(tc', fracMagVarToKeep*100);
    Vm = result.coeffs;
    tc_whitened = result.pcaTS';
else
    tc_whitened = tc;
end
fprintf('Done!\n');

%% Get truth vectors
truth = nan(1,numel(eventNames));
if strcmp(label0,'other')
    truth(~strcmp(eventNames,label1)) = 0;
else
    truth(strcmp(eventNames,label0)) = 0;
end
if strcmp(label1,'other')
    truth(~strcmp(eventNames,label0)) = 1;
else
    truth(strcmp(eventNames,label1)) = 1;
end
%% Sample features
% get samples
isNanSample = isnan(iTcEventSample_start) | isnan(iTcEventSample_end);
iTcEventSample_start_COPY = iTcEventSample_start;
iTcEventSample_start_COPY(isNanSample) = 1;
iTcEventSample_end_COPY = iTcEventSample_end;
iTcEventSample_end_COPY(isNanSample) = 1;
iOkSample = find(~isnan(truth) & ~isNanSample & ...
    ~all(isnan(tc_whitened(:,iTcEventSample_start_COPY)),1) &...
    ~all(isnan(tc_whitened(:,iTcEventSample_end_COPY)),1));
% sample Mag feats
magFeats = nan(size(tc_whitened,1),numel(iOkSample));
magRoiFeats = nan(size(tc,1),numel(iOkSample));
for i=1:numel(iOkSample)
    magFeats(:,i) = mean(tc_whitened(:,iTcEventSample_start(iOkSample(i)):iTcEventSample_end(iOkSample(i))),2);
    % Get ROI-based mag for fwd models
    magRoiFeats(:,i) = mean(tc(:,iTcEventSample_start(iOkSample(i)):iTcEventSample_end(iOkSample(i))),2);
end
% magFeats = tc_whitened(:,iTcEventSample(iOkSample));
% magRoiFeats = tc(:,iTcEventSample(iOkSample)); % for fwd models
magRuns = eventRun(iOkSample);
magTimes = iTcEventSample_start(iOkSample);
magTruth = truth(iOkSample);
% replace nans with mean of non-nan trials (across all subjects)
for i=1:size(magFeats,1);
    magFeats(i,isnan(magFeats(i,:))) = nanmean(magFeats(i,:));
end
for i=1:size(magRoiFeats,1);
    magRoiFeats(i,isnan(magRoiFeats(i,:))) = nanmean(magRoiFeats(i,:));
end


%% NORMALIZE FEATS ACROSS RUNS

switch magNormOption
    case {'subject','all'}
        magFeats = zscore(magFeats,[],2);
        magRoiFeats = zscore(magRoiFeats,[],2);
    case 'run'
        for j=1:nRuns
            isInRun = (magRuns==j);
            magFeats(:,isInRun) = zscore(magFeats(:,isInRun),[],2);
            magRoiFeats(:,isInRun) = zscore(magRoiFeats(:,isInRun),[],2);
        end
    case 'none'
        
end



%% Leave One Out, vary time between train and test
LRparams.vinit=zeros(size(magFeats,1)+1,1);

% Set up
nTrials = numel(magTimes);
nSepTimes = 1;
[Az,AzLoo,yCv,nTrain,nTrainInRun,nTrainInCond] = deal(nan(nRuns,nSepTimes));
AzCv = nan(nSepTimes,1);
fwdModelCv = nan(nSepTimes,size(magRoiFeats,1));
clear statsCv
% Run loop

k=1;       
for j=1:nRuns % for each run
    % find train and test data
    isTest = (magRuns==j);
    isTrain = (magRuns~=j);
    nTrain(j,k) = sum(isTrain);
    nTrainInRun(j,k) = sum(isTrain & magRuns==j);
    nTrainInCond(j,k) = nan;%sum(isTrain & magRuns==j & magTruth==magTruth(isTest));

    % Peform classification
    trainData = permute(magFeats(:,isTrain),[1 3 2]);

%         [Az(j,k),AzLoo(j,k),statsCv(j,k)] = RunSingleSvm(trainData,magTruth(isTrain),LRparams);
%         yTest = statsCv(j,k).wts(1:end-1)*magFeats(:,iTest) + statsCv(j,k).wts(end);
    [Az(j,k),AzLoo(j,k),statsCv(j,k)] = RunSingleLR(trainData,magTruth(isTrain),LRparams);
    yTest = statsCv(j,k).wts(1:end-1)'*magFeats(:,isTest) + statsCv(j,k).wts(end);
    yCv(isTest,k) = yTest;
%         fwdModelCv(:,j,k) = statsCv(j,k).fwdModel;
end
AzCv(k) = rocarea(yCv(:,k),magTruth);
fwdModelCv(k,:) = yCv(:,k) \ magRoiFeats';
fprintf('LORO Az = %.3f\n',AzCv(k));

yCv_allTrials = nan(numel(iTcEventSample_start),nSepTimes);
yCv_allTrials(iOkSample,:) = yCv;

fprintf('Done!\n');

%% Run permutation loop
if nPerms>0
    fprintf('===Running %d permutations...\n',nPerms)
    [AzPerm,AzLooPerm,yCvPerm] = deal(nan(nRuns,nSepTimes,nPerms));
    AzCvPerm = nan(nSepTimes,nPerms);
    fwdModelCvPerm = nan(nSepTimes,size(magRoiFeats,1),nPerms);
    clear statsCvPerm
    for i=1:nPerms
        fprintf('>>>Permutation %d/%d...',i,nPerms);
        % get random truth permutation
        permOrder = randperm(numel(magTruth));
        magTruthPerm = magTruth(permOrder);
        magRunsPerm = magRuns(permOrder);
        k=1;
        for j=1:nRuns % for each run
            % find train and test data
            isTest = (magRunsPerm==j);
            isTrain = (magRunsPerm~=j);
%                 nTrain(j,k) = sum(isTrain);
%                 nTrainInRun(j,k) = sum(isTrain & magRuns==magRuns(iTest));
%                 nTrainInCond(j,k) = sum(isTrain & magRuns==magRuns(iTest) & magTruth==magTruth(iTest));

            % Peform classification
            trainData = permute(magFeats(:,isTrain),[1 3 2]);

    %         [AzPerm(j,k,i),AzLooPerm(j,k,i),statsCvPerm(j,k,i)] = RunSingleSvm(trainData,magTruthPerm(isTrain),LRparams);
    %         yTest = statsCvPerm(j,k,i).wts(1:end-1)*magFeats(:,iTest) + statsCvPerm(j,k,i).wts(end);
            [AzPerm(j,k,i),AzLooPerm(j,k,i),statsCvPerm(j,k,i)] = RunSingleLR(trainData,magTruthPerm(isTrain),LRparams);
            yTest = statsCvPerm(j,k,i).wts(1:end-1)'*magFeats(:,isTest) + statsCvPerm(j,k,i).wts(end);
            yCvPerm(isTest,k,i) = yTest;
    %         fwdModelCv(:,j,k) = statsCv(j,k).fwdModel;
        end
        AzCvPerm(k,i) = rocarea(yCvPerm(:,k,i),magTruthPerm);
        fwdModelCvPerm(k,:,i) = yCvPerm(:,k,i) \ magRoiFeats';
        fprintf('LORO Az = %.3f\n',AzCvPerm(k,i));

    end
    fprintf('Done!\n');
else
    [AzPerm,AzLooPerm,statsCvPerm,AzCvPerm,fwdModelCvPerm] = deal([]);
end

%% Plots
% if doPlot
%     cla; hold on;
%     plot(separationTimes'*TR, AzCv,'.-');
%     plot(separationTimes'*TR, mean(nTrain,1)/numel(magTimes),'.-');
%     nTrainInRun_this = mean(nTrainInRun,1);
%     nTrainInCond_this = mean(nTrainInCond,1);
%     plot(separationTimes'*TR, nTrainInRun_this/nTrainInRun_this(1),'.-');
%     plot(separationTimes'*TR, nTrainInCond_this/nTrainInCond_this(1),'.-');
%     PlotVerticalLines(median(diff(magTimes))*TR,'g--');
%     PlotVerticalLines(magTimes(end)/(sum(nRuns)*2)*TR,'m--');
%     PlotVerticalLines(magTimes(end)/(sum(nRuns))*TR,'c--');
%     xlabel('event times excluded from training set (+/-, s)')
%     ylabel('Cross-validated AUC')
%     title(sprintf('subject SBJ%02d',subject));
%     legend('AUC','frac training trials left','frac trials in same run','frac trials in same run & condition','median time between events','mean condition length','mean run length')
% end