function [AzCv, fwdModelCv, statsCv, newParams, AzCvPerm, fwdModelCvPerm, statsCvPerm, yCv_allTrials] = ClassifySubject_FC_ExcludeTimeWindow(subject,separationTimes,allParams)

% [AzCv, fwdModelCv, statsCv, newParams, AzCvPerm, fwdModelCvPerm, statsCvPerm, yCv_allTrials] = ClassifySubject_FC_ExcludeTimeWindow(subject,separationTimes,allParams)
%
% Classify a single subject's data - with varied separation times between
% testing and training samples - using Functional Connectivity features.
%
% Created 6/15/16 by DJ based on ClassifyAcrossSubjects.
% Updated 6/18/16 by DJ - added permutation option and outputs.
% Updated 6/21/16 by DJ - added yCv_allTrials output.
% Updated 8/26/16 by DJ - allow custom atlasType
% Updated 9/1/16 by DJ - added | fcRuns~=fcRuns(iTest) condition to iTrain
if ~exist('separationTimes','var') || isempty(separationTimes)
    separationTimes = 0:20:260; % in samples
end
if ~exist('allParams','var')
    allParams = [];
end
% Declare defaults
defaultParams.homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
defaultParams.label0_fc = 'attendedSpeech';
defaultParams.label1_fc = 'ignoredSpeech';
defaultParams.atlasType = 'Craddock'; % Craddock, Craddock_e2, or Shen
defaultParams.tcNormOption = 'run'; % 'run' or 'subject'
defaultParams.TR = 2;
defaultParams.fcWinLength = 10;
defaultParams.nFirstRemoved = 3;
defaultParams.HrfOffset = 6;
defaultParams.doMagPca = true;
defaultParams.fracMagVarToKeep = 1;
defaultParams.fisherNormFC = true;
defaultParams.fracFcVarToKeep = 0.5; % 0.5 is the median for S9-30's nested CV
defaultParams.fcNormOption = 'run'; % 'run' or 'subject'
defaultParams.doPlot = true;
defaultParams.doRandTc = false;
defaultParams.doRandFc = false;
defaultParams.doBalancedTrainingSet = false;

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
% beh = load(sprintf('Distraction-%d-QuickRun.mat',subject));
beh = load(sprintf('Distraction-SBJ%02d-Behavior.mat',subject));

% Load timecourses
% datadir = dir('AfniProc*');
% cd(datadir(1).name);
cd('AfniProc_MultiEcho_2016-09-22');
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

if doRandTc
    fprintf('====RANDOMIZING TC!!!!!\n')
    tc = tc(:,randperm(size(tc,2)));
%     tc = randn(size(tc));
end

% Get trial times
nRuns = numel(beh.data);
nT = size(tc,2);
nTR = nT/nRuns + nFirstRemoved;
[iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset);
% get run number for each event
eventRun = ceil(iFcEventSample/(nTR-nFirstRemoved));
iRun = ceil((1:nT)/(nT/nRuns));

% normalize TC
nROIs = size(tc,1);
switch tcNormOption
    case {'subject','all'}
        for j=1:nROIs
            tc(j,:) = (tc(j,:)-nanmean(tc(j,:)))/nanstd(tc(j,:));
        end
    case 'run'
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

%% Get FC features
% calculate sliding-window FC
tic;
FC = nan(size(tc_whitened,1),size(tc_whitened,1),nT);
% Get FC in each run separately
for k=1:nRuns
    iThisRun = find(iRun==k);
    FC_thisRun = GetFcMatrices(tc_whitened(:,iThisRun),'sw',fcWinLength);
    FC(:,:,iThisRun(1:size(FC_thisRun,3))) = FC_thisRun;
end
% Get FC in all runs together
% FC = GetFcMatrices(tc_whitened,'sw',fcWinLength);
tFC = toc;
fprintf('Done! took %.3f seconds.\n',tFC);

%% normalize FC

% Apply Fisher z transform to correlation coefficients
if fisherNormFC
    FC = atanh(FC);
    FC(isinf(FC)) = max(abs(FC(~isinf(FC))))*sign(FC(isinf(FC))); % nan; %
end

%% run SVD on FC 
% tic;
% [~,Sf,Vf,FcPcTc] = PlotFcPca(FC,0,true);
% tSVD = toc;
% fprintf('Done! took %.3f seconds.\n',tSVD);
% 
% %% Reduce dimensionality
% cumsumS = cumsum(diag(Sf).^2)/sum(diag(Sf).^2);
% nPcsToKeep = find(cumsumS<=fracFcVarToKeep,1,'last');
% while isempty(nPcsToKeep) || nPcsToKeep<10
%     fracFcVarToKeep = fracFcVarToKeep+(1-fracFcVarToKeep)/2;
%     nPcsToKeep = find(cumsumS<=fracFcVarToKeep,1,'last');
% end
% newParams.fracFcVarToKeep = fracFcVarToKeep; % put back in params struct
% FcPcTc_2dmat = FcPcTc(1:nPcsToKeep,:);    
% fprintf('Reduced dimensionality to %d PCs.\n',nPcsToKeep);

% Run PCA instead of SVD
fprintf('Running PCA on FC data...\n');
[err, errMsg, result] = func_CSD_PCA(VectorizeFc(FC)', fracFcVarToKeep*100);
Vf = result.coeffs;
FcPcTc_2dmat = result.pcaTS';

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
isNanSample = isnan(iFcEventSample);
iFcEventSample_COPY = iFcEventSample;
iFcEventSample_COPY(isNanSample) = 1;
isOkSample = ~isnan(truth) & ~isNanSample & ~all(isnan(FcPcTc_2dmat(:,iFcEventSample_COPY)),1);
% sample FC feats
fcFeats = FcPcTc_2dmat(:,iFcEventSample(isOkSample));
fcRuns = eventRun(isOkSample);
fcTimes = iFcEventSample(isOkSample);
fcTruth = truth(isOkSample);
% replace nans with mean of non-nan trials (across all subjects)
for i=1:size(fcFeats,1);
    fcFeats(i,isnan(fcFeats(i,:))) = nanmean(fcFeats(i,:));
end

% Get ROI-based FC for fwd models
FcRoi = GetFcMatrices(tc,'sw',fcWinLength);
if fisherNormFC
    FcRoi = atanh(FcRoi);
    FcRoi(isinf(FcRoi)) = max(abs(FcRoi(~isinf(FcRoi))))*sign(FcRoi(isinf(FcRoi))); % nan; %
end
FcRoi_2dmat = VectorizeFc(FcRoi);
fcRoiFeats = FcRoi_2dmat(:,iFcEventSample(isOkSample));

%% NORMALIZE FEATS ACROSS RUNS

switch fcNormOption
    case {'subject','all'}
        fcFeats = zscore(fcFeats,[],2);
        fcRoiFeats = zscore(fcRoiFeats,[],2);
    case 'run'
        for j=1:nRuns
            isInRun = (fcRuns==j);
            fcFeats(:,isInRun) = zscore(fcFeats(:,isInRun),[],2);
            fcRoiFeats(:,isInRun) = zscore(fcRoiFeats(:,isInRun),[],2);
        end
    case 'none'
        
end



%% Leave One Out, vary time between train and test
LRparams.vinit=zeros(size(fcFeats,1)+1,1);

% Set up
nTrials = numel(fcTimes);
nSepTimes = numel(separationTimes);
[Az,AzLoo,yCv,nTrain,nTrainInRun,nTrainInCond,nTrainNotInCond,fracTrainInCat] = deal(nan(nTrials,nSepTimes));
AzCv = nan(nSepTimes,1);
fwdModelCv = nan(nSepTimes,size(fcRoiFeats,1));
clear statsCv fwdModelCv
% Run loop
if doRandFc
    fprintf('===SCRAMBLING FC FEATURES!!!\n');
    fcFeats = fcFeats(:,randperm(size(fcFeats,2)));
end
for k=1:nSepTimes
    separationTime = separationTimes(k);
    fprintf('---SeparationTime = %d...\n',separationTime);
        
    for j=1:nTrials % for each trial
        % find train and test data
        iTest = j;
        isTrain = abs(fcTimes-fcTimes(iTest))>separationTime | fcRuns~=fcRuns(iTest);
        nTrain(j,k) = sum(isTrain);
        nTrainInRun(j,k) = sum(isTrain & fcRuns==fcRuns(iTest));
        nTrainInCond(j,k) = sum(isTrain & fcRuns==fcRuns(iTest) & fcTruth==fcTruth(iTest));
        nTrainNotInCond(j,k) = sum(isTrain & fcRuns==fcRuns(iTest) & fcTruth~=fcTruth(iTest));
        fracTrainInCat(j,k) = mean(isTrain & fcTruth==fcTruth(iTest));

        if doBalancedTrainingSet
            if nTrainInCond(j,k)>nTrainNotInCond(j,k)
                nToRemove = nTrainInCond(j,k) - nTrainNotInCond(j,k);
                iRemovable = find(isTrain & fcRuns==fcRuns(iTest) & fcTruth==fcTruth(iTest));
            elseif nTrainInCond(j,k)<nTrainNotInCond(j,k)
                nToRemove = nTrainNotInCond(j,k) - nTrainInCond(j,k);
                iRemovable = find(isTrain & fcRuns==fcRuns(iTest) & fcTruth~=fcTruth(iTest));
            else
                iRemovable = [];
                nToRemove = 0;
            end
            iRemove = iRemovable(randperm(numel(iRemovable)));
            iRemove = iRemove(1:nToRemove);
            isTrain(iRemove) = false;
            if sum(isTrain & fcRuns==fcRuns(iTest))>0 && mean(fcTruth(isTrain & fcRuns==fcRuns(iTest)))~=0.5
                error('Training set not balanced!');
            end
        end
        
        % Peform classification
        trainData = permute(fcFeats(:,isTrain),[1 3 2]);

%         [Az(j,k),AzLoo(j,k),statsCv(j,k)] = RunSingleSvm(trainData,fcTruth(isTrain),LRparams);
%         yTest = statsCv(j,k).wts(1:end-1)*fcFeats(:,iTest) + statsCv(j,k).wts(end);
        [Az(j,k),AzLoo(j,k),statsCv(j,k)] = RunSingleLR(trainData,fcTruth(isTrain),LRparams);
        yTest = statsCv(j,k).wts(1:end-1)'*fcFeats(:,iTest) + statsCv(j,k).wts(end);
        yCv(iTest,k) = yTest;
%         fwdModelCv(:,j,k) = statsCv(j,k).fwdModel;
    end
    AzCv(k) = rocarea(yCv(:,k),fcTruth);
    fwdModelCv(k,:) = yCv(:,k) \ fcRoiFeats';
    fprintf('sepTime=%d samples: Az = %.3f\n',separationTime,AzCv(k));

end
yCv_allTrials = nan(numel(iFcEventSample),nSepTimes);
yCv_allTrials(isOkSample,:) = yCv;
fprintf('Done!\n');

%% Run permutation loop
if nPerms>0
    fprintf('===Running %d permutations...\n',nPerms)
    [AzPerm,AzLooPerm,yCvPerm] = deal(nan(nTrials,nSepTimes,nPerms));
    AzCvPerm = nan(nSepTimes,nPerms);
    fwdModelCvPerm = nan(nSepTimes,size(fcRoiFeats,1),nPerms);
    clear statsCvPerm
    for i=1:nPerms
        fprintf('>>>Permutation %d/%d...\n',i,nPerms);
        % get random truth permutation
        fcTruthPerm = fcTruth(randperm(numel(fcTruth)));
        for k=1:nSepTimes
            separationTime = separationTimes(k);
            fprintf('---SeparationTime = %d...\n',separationTime);

            for j=1:nTrials % for each trial
                % find train and test data
                iTest = j;
                isTrain = abs(fcTimes-fcTimes(iTest))>separationTime;
%                 nTrain(j,k) = sum(isTrain);
%                 nTrainInRun(j,k) = sum(isTrain & fcRuns==fcRuns(iTest));
%                 nTrainInCond(j,k) = sum(isTrain & fcRuns==fcRuns(iTest) & fcTruth==fcTruth(iTest));

                % Peform classification
                trainData = permute(fcFeats(:,isTrain),[1 3 2]);

        %         [AzPerm(j,k,i),AzLooPerm(j,k,i),statsCvPerm(j,k,i)] = RunSingleSvm(trainData,fcTruthPerm(isTrain),LRparams);
        %         yTest = statsCvPerm(j,k,i).wts(1:end-1)*fcFeats(:,iTest) + statsCvPerm(j,k,i).wts(end);
                [AzPerm(j,k,i),AzLooPerm(j,k,i),statsCvPerm(j,k,i)] = RunSingleLR(trainData,fcTruthPerm(isTrain),LRparams);
                yTest = statsCvPerm(j,k,i).wts(1:end-1)'*fcFeats(:,iTest) + statsCvPerm(j,k,i).wts(end);
                yCvPerm(iTest,k,i) = yTest;
        %         fwdModelCv(:,j,k) = statsCv(j,k).fwdModel;
            end
            AzCvPerm(k,i) = rocarea(yCvPerm(:,k,i),fcTruthPerm);
            fwdModelCvPerm(k,:,i) = yCvPerm(:,k,i) \ fcRoiFeats';
            fprintf('sepTime=%d samples: Az = %.3f\n',separationTime,AzCvPerm(k,i));

        end
    end
    fprintf('Done!\n');
else
    [AzPerm,AzLooPerm,statsCvPerm,AzCvPerm,fwdModelCvPerm] = deal([]);
end

%% Plots
if doPlot
    cla; hold on;
    plot(separationTimes'*TR, AzCv,'.-');
    plot(separationTimes'*TR, mean(nTrain,1)/numel(fcTimes),'.-');
    nTrainInRun_this = mean(nTrainInRun,1);
    nTrainInCond_this = mean(nTrainInCond,1);
    fracTrainInCat_this = mean(fracTrainInCat,1);
    plot(separationTimes'*TR, nTrainInRun_this/nTrainInRun_this(1),'.-');
    plot(separationTimes'*TR, nTrainInCond_this/nTrainInCond_this(1),'.-');
    plot(separationTimes'*TR, fracTrainInCat_this,'.-');
    PlotVerticalLines(median(diff(fcTimes))*TR,'g--');
    PlotVerticalLines(fcTimes(end)/(sum(nRuns)*2)*TR,'m--');
    PlotVerticalLines(fcTimes(end)/(sum(nRuns))*TR,'c--');
    xlabel('event times excluded from training set (+/-, s)')
    ylabel('Cross-validated AUC')
    title(sprintf('subject SBJ%02d',subject));
    legend('AUC','frac training trials left','frac trials in same run','frac trials in same run & condition','median time between events','frac training trials in category','mean condition length','mean run length')
end
