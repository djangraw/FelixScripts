function TryCrossSubjectFcClassifier(subjects,label1,label0)

%%
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
nSubj = numel(subjects);
[FC_all, FcTruth_all, FcRuns_all,FcSubj_all] = deal(cell(1,nSubj));
nFirstRemoved = 3;
fcWinLength = 10;
TR = 2;
HrfOffset=6;

for i=1:nSubj
    fprintf('=== Subject %d/%d...\n',i,nSubj);
    subject = subjects(i);
    %=== load
    cd(sprintf('%sSBJ%02d',homedir,subject));
    beh = load(sprintf('Distraction-SBJ%02d-Behavior.mat',subject));
    datadir = dir('AfniProc*');
    cd(datadir(1).name);
    tcFile = sprintf('AllSpheresNoOverlap_SBJ%02d_ROI_TS.1D',subject);
    tc = Read_1D(tcFile);

    %===fMRI
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
    
    %===behavior
    % Get trial times
    nRuns = numel(beh.data);
    nT = size(tc,2);
    nTR = nT/nRuns + nFirstRemoved;
    [iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset);
    % get run number for each event
    eventRun = ceil(iFcEventSample/(nTR-nFirstRemoved));
    iRun = ceil((1:nT)/(nT/nRuns));
    FC_big = nan(size(tc,1),size(tc,1),nT);
    % Get FC in each run separately
    for k=1:nRuns
        iThisRun = find(iRun==k);
        FC_thisRun = GetFcMatrices(tc(:,iThisRun),'sw',fcWinLength);
        FC_big(:,:,iThisRun(1:size(FC_thisRun,3))) = FC_thisRun;
    end
    FC_2dmat = VectorizeFc(FC_big);
    
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
    isOkSample = ~isnan(truth) & ~isNanSample & ~all(isnan(FC_2dmat(:,iFcEventSample_COPY)),1);
    % sample FC feats
    fcFeats = FC_2dmat(:,iFcEventSample(isOkSample));
    fcRuns = eventRun(isOkSample);
    fcTimes = iFcEventSample(isOkSample);
    fcTruth = truth(isOkSample);
    % replace nans with mean of non-nan trials (across all subjects)
    for k=1:size(fcFeats,1);
        fcFeats(k,isnan(fcFeats(k,:))) = nanmean(fcFeats(k,:));
    end

    FC_all{i} = fcFeats;
    FcTruth_all{i} = fcTruth;
    FcRuns_all{i} = fcRuns;
    FcSubj_all{i} = repmat(i,size(fcRuns));
end
%% load atlas
atlas = BrikLoad('Mask_EPIres_AllSpheresNoOverlap+tlrc');

%% Plot the results
FC_big = cat(2,FC_all{:});
% Apply Fisher z transform to correlation coefficients
% FC_big = atanh(FC_big);
% FC_big(isinf(FC_big)) = max(abs(FC_big(~isinf(FC_big))))*sign(FC_big(isinf(FC_big))); % nan; %

FcTruth_big = cat(2,FcTruth_all{:});
FcSubj_big = cat(2,FcRuns_all{:});
FcRuns_big = FcRuns_all{1};
for i=2:numel(FcRuns_all)
    FcRuns_big = cat(2,FcRuns_big,FcRuns_all{i}+FcRuns_big(end));
end
idx = ones(size(FC_thisRun,1),1);
idx(22:27) = 2;
idx(28:33) = 3;

figure(763); clf;
subplot(2,2,1);
imagesc(FC_big(:,FcTruth_big==0));
xlabel('trial')
ylabel('ROI pair')
title(label0)
set(gca,'clim',[-1 1])
colorbar
subplot(2,2,2);
imagesc(FC_big(:,FcTruth_big==1));
xlabel('trial')
ylabel('ROI pair')
title(label1)
set(gca,'clim',[-1 1])
colorbar
subplot(2,3,4);
PlotFcMatrix(UnvectorizeFc(median(FC_big(:,FcTruth_big==0),2)),[-1 1],atlas,idx);
title(label0)
subplot(2,3,5);
PlotFcMatrix(UnvectorizeFc(median(FC_big(:,FcTruth_big==1),2)),[-1 1],atlas,idx);
title(label1)
subplot(2,3,6);
diffFC = UnvectorizeFc(median(FC_big(:,FcTruth_big==1),2) - median(FC_big(:,FcTruth_big==0),2),0);
PlotFcMatrix(diffFC,[],atlas,idx);
title(sprintf('%s-%s',label1,label0))
% plot([median(FC_big(:,FcTruth_big==0),2), median(FC_big(:,FcTruth_big==1),2)]);
% ylabel('median FC across trials')
% xlabel('ROI pair')
% legend({label0,label1});

%% Classify using LORO

LRparams.regularize=1;
LRparams.lambda=1e-6;
LRparams.lambdasearch=true;
LRparams.eigvalratio=1e-4;
LRparams.vinit=[];
LRparams.show=0;
LRparams.LOO=false; % true; % 
LRparams.demean=false;
LRparams.LTO=false;%true;

% Set up
nRuns = max(FcRuns_big);
yCv = nan(numel(FcTruth_big),1);
[Az,AzLoo] = deal(nan(1,nRuns));
clear statsCv;
for j=1:nRuns % for each run
    fprintf('===Run %d/%d...\n',j,nRuns);
    % find train and test data
    isTest = (FcRuns_big==j);
    isTrain = (FcRuns_big~=j);

    % Peform classification
    trainData = permute(FC_big(:,isTrain),[1 3 2]);

%         [Az(j,k),AzLoo(j,k),statsCv(j,k)] = RunSingleSvm(trainData,fcTruth(isTrain),LRparams);
%         yTest = statsCv(j,k).wts(1:end-1)*fcFeats(:,iTest) + statsCv(j,k).wts(end);
    [Az(j),AzLoo(j),statsCv(j)] = RunSingleLR(trainData,FcTruth_big(isTrain),LRparams);
    yTest = statsCv(j).wts(1:end-1)'*FC_big(:,isTest) + statsCv(j).wts(end);
    yCv(isTest) = yTest;
%         fwdModelCv(:,j,k) = statsCv(j,k).fwdModel;
end
AzCv = rocarea(yCv,FcTruth_big);
fwdModelCv = yCv \ FC_big';
fprintf('LORO Az = %.3f\n',AzCv);
