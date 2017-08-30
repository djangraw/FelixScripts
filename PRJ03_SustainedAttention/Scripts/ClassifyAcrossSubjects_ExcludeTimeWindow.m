% ClassifyAcrossSubjects_ExcludeTimeWindow.m
%
% Created 6/15/16 by DJ based on ClassifyAcrossSubjects.

subjects = [9:22 24:30];
nSubj = numel(subjects);
homedir = '/spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/';

% [FwdModel_bold,FwdModel_fc] = deal(cell(1,nSubj));
label0_fc = 'attendedSpeech';
label1_fc = 'ignoredSpeech';
atlasType = 'Craddock';
tcNormOption = 'run';

TR = 2;
fcWinLength = 10;
nFirstRemoved = 3;
HrfOffset = 6;

[tc_all,iTcEventSample_all,iFcEventSample_all,subjIndex_all,eventNames_all,eventSession_all] = deal([]);
subjOffset = zeros(1,nSubj);
for i=1:nSubj % [8 10 13 18 20]%
    subject = subjects(i);
    fprintf('Subject %d...\n',subject);
    cd(homedir)
    fprintf('Loading files...\n');
    % Get input data
    cd(sprintf('%sSBJ%02d',homedir,subject));
    beh = load(sprintf('Distraction-%d-QuickRun.mat',subject));
    % Load timecourses
    datadir = dir('AfniProc*');
    cd(datadir(1).name);
    switch atlasType
        case 'Craddock'
            [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
%             [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts_e2.1D',subject));
        case 'Shen'
            [~,tc] = Read_1D(sprintf('shen268_withSegTc_SBJ%02d_ROI_TS.1D',subject));
        otherwise
            error('Altas not recognized!');
    end
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
    
    % Get trial times
    nSessions = numel(beh.data);
    nT = size(tc,2);
    nTR = nT/nSessions + nFirstRemoved;
    [iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset);

    % normalize TC
    switch tcNormOption
        case 'subject'
            nROIs = size(tc,1);
            for j=1:nROIs
                tc(j,:) = (tc(j,:)-nanmean(tc(j,:)))/nanstd(tc(j,:));
            end
        case 'run'
            iRun = ceil((1:nT)/nTR);
            for k=1:nRuns
                isInRun = (iRun==k);
                for j=1:nROIs
                    tc(j,isInRun) = (tc(j,isInRun)-nanmean(tc(j,isInRun)))/nanstd(tc(j,isInRun));
                end
            end
        case 'none'
            % do nothing
    end
    
    % Add to matrices
    subjOffset(i) = size(tc_all,2);
    tc_all = cat(2,tc_all,tc);
    subjIndex_all = cat(2,subjIndex_all,repmat(i,1,nT));
    iTcEventSample_all = cat(2,iTcEventSample_all,iTcEventSample+subjOffset(i));
    iFcEventSample_all = cat(2,iFcEventSample_all,iFcEventSample+subjOffset(i));
    eventNames_all = cat(2,eventNames_all,eventNames');
    % get event session
    eventSession = ceil(iFcEventSample/(nTR-nFirstRemoved));
    eventSession_all = cat(2,eventSession_all,eventSession);
    
end
fprintf('Done!\n');

%% Run SVD on timecourse data
fracTcVarToKeep = 1;
% normalize TC
% nROIs = size(tc_all,1);
% for i=1:nROIs
%     tc_all(i,:) = (tc_all(i,:)-nanmean(tc_all(i,:)))/nanstd(tc_all(i,:));
% end
doMagPca = true;
magPcaOption = 'subject';

if doMagPca
    fprintf('Running SVD on magnitude data...\n');
    % Run PCA on tcs
    isNotCensoredSample = ~any(isnan(tc_all));
    switch magPcaOption
        case 'subject'
            tc_all_whitened = [];
            for i=1:nSubj
                % Run SVD
                fprintf('Subject %d/%d...\n',i,nSubj);
                tc_this = tc_all(:,subjIndex_all==i);
                isNotCensoredSample_this = isNotCensoredSample(subjIndex_all==i);
                [Um,Sm,Vm] = svd(tc_this(:,isNotCensoredSample_this)',0);
                fracVar = cumsum(diag(Sm).^2)/sum(diag(Sm).^2);
                % Perform dimensionality reduction on mag features
                lastToKeep = find(fracVar<=fracTcVarToKeep,1,'last');
                fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep*100)
                tc_this_whitened = Vm(:,1:lastToKeep)'*tc_this; % rotate using SVD whitening matrix
                tc_all_whitened(:,subjIndex_all==i) = tc_this_whitened;
            end
        case 'all'
            % Run SVD
            [Um,Sm,Vm] = svd(tc_all(:,isNotCensoredSample)',0);
            fracVar = cumsum(diag(Sm).^2)/sum(diag(Sm).^2);
            % Perform dimensionality reduction on mag features
            lastToKeep = find(fracVar<=fracTcVarToKeep,1,'last');
            fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep*100)
            tc_all_whitened = Vm(:,1:lastToKeep)'*tc_all; % rotate using SVD whitening matrix
    end
else
    tc_all_whitened = tc_all;
end
fprintf('Done!');

%% Get FC features
% calculate sliding-window FC
tic;
FC = GetFcMatrices(tc_all_whitened,'sw',fcWinLength);
tFC = toc;
fprintf('Done! took %.3f seconds.\n',tFC);

%% normalize FC
% fprintf('Normalizing FC for each subject & ROI pair...\n')
% tic;
% for iSubj=1:nSubj
%     fprintf('iSubj = %d/%d...\n',iSubj,nSubj);
%     isThisSubj = (subjIndex_all(1:size(FC,3))==iSubj);
%     FC(:,:,isThisSubj) = (FC(:,:,isThisSubj) - repmat(nanmean(FC(:,:,isThisSubj),3),[1 1 sum(isThisSubj)])) ./ ...
%         repmat(nanstd(FC(:,:,isThisSubj),0,3),[1 1 sum(isThisSubj)]);
% end
% tNORM = toc;
% fprintf('Done! took %.3f seconds.\n',tNORM);

normFC = true;
% Apply Fisher z transform to correlation coefficients
if normFC
    FC = atanh(FC);
    FC(isinf(FC)) = max(abs(FC(~isinf(FC)))); % nan; %
end

%% run SVD on FC 
fcPcaOption = 'all';

switch fcPcaOption
    case 'subject'
        [Uf,Sf,Vf,FcPcTc] = deal(cell(1,nSubj));
        for i=1:nSubj
            % Run SVD
            fprintf('Subject %d/%d...\n',i,nSubj);
            isthisSubj = (subjIndex_all==i);
            tic;
            [Uf{i},Sf{i},Vf{i},FcPcTc{i}] = PlotFcPca(FC(:,:,isThisSubj),0,true);
            tSVD = toc;
            fprintf('Done! took %.3f seconds.\n',tSVD);
        end
    case 'all'        
        tic;
        [Uf,Sf,Vf,FcPcTc] = PlotFcPca(FC,0,true);
        tSVD = toc;
        fprintf('Done! took %.3f seconds.\n',tSVD);
end
%% Reduce dimensionality
fracFcVarToKeep = 0.5; % 0.5 is the median for S9-30's nested CV

cumsumS = cumsum(diag(Sf).^2)/sum(diag(Sf).^2);
nPcsToKeep = find(cumsumS<=fracFcVarToKeep,1,'last');
fc_2dmat = FcPcTc(1:nPcsToKeep,:);    
fprintf('Reduced dimensionality to %d PCs.\n',nPcsToKeep);

%% Get truth vectors
truth_all = nan(1,numel(eventNames_all));
truth_all(strcmp(eventNames_all,label0_fc)) = 0;
truth_all(strcmp(eventNames_all,label1_fc)) = 1;

%% Sample features
% get samples
isNanSample = isnan(iFcEventSample_all);
iFcEventSample_all_COPY = iFcEventSample_all;
iFcEventSample_all_COPY(isNanSample) = 1;
isOkSample = ~isnan(truth_all) & ~isNanSample & ~all(isnan(fc_2dmat(:,iFcEventSample_all_COPY)),1);
% iFcEventSample_all(isNanSample) = nan;
% sample FC feats
fcFeats = fc_2dmat(:,iFcEventSample_all(isOkSample));
fcSubjs = subjIndex_all(iFcEventSample_all(isOkSample));
fcSessions = eventSession_all(isOkSample);
fcTimes = iFcEventSample_all(isOkSample);
fcTruth = truth_all(isOkSample);
% replace nans with mean of non-nan trials (across all subjects)
for i=1:size(fcFeats,1);
    fcFeats(i,isnan(fcFeats(i,:))) = nanmean(fcFeats(i,:));
end

%% NORMALIZE FEATS ACROSS RUNS
normOption = 'run';
switch normOption
    case 'subject'
    for i=1:1:nSubj
        isThisSubj = (fcSubjs==i);
        fcFeats(:,isThisSubj) = zscore(fcFeats(:,isThisSubj),[],2);
    end
    case 'run'
    for i=1:1:nSubj
        nRuns = max(fcSessions(fcSubjs==i));
        for j=1:nRuns
            isInRun = (fcSubjs==i & fcSessions==j);
            fcFeats(:,isInRun) = zscore(fcFeats(:,isInRun),[],2);
        end
    end
    case 'none'
        
end


%% Perform classification
% LR paramsfcTruth)
params.regularize=1;
params.lambda=1e-6;
params.lambdasearch=true;
params.eigvalratio=1e-4;
params.vinit=zeros(size(fcFeats,1)+1,1);
params.show=0;
params.LOO=false; % true; % 
params.demean=false;
params.LTO=false;%true;


%% Leave One Out, vary time between train and test
params.LOO = false; % true; %
separationTimes = 0:20:260; % in samples

% Set up
[AzCv,statsCv,fwdModelCv,yCv,nTrain,nTrainInCond] = deal(cell(1,nSubj));
AzCv_subj = nan(numel(separationTimes),nSubj);
% Run loop
for k=1:numel(separationTimes)
    separationTime = separationTimes(k);
    fprintf('---SeparationTime = %d...\n',separationTime);
    for i=1:nSubj % find(~ismember(subjects,[12, 20, 21, 27, 29, 23, 26]))%
        fprintf('Subject %d/%d...\n',i,nSubj);
        iThisSubj = find(fcSubjs==i);
        nTrials = numel(iThisSubj);
        for j=1:nTrials % for each trial
            % find train and test data
            iTest = iThisSubj(j);
            isTrain = (fcSubjs==i & abs(fcTimes-fcTimes(iTest))>separationTime);
            nTrain{i}(j,k) = sum(isTrain);
            nTrainInCond{i}(j,k) = sum(isTrain & fcSessions==fcSessions(iTest));
            nTrainInCond{i}(j,k) = sum(isTrain & fcSessions==fcSessions(iTest) & fcTruth==fcTruth(iTest));
            
            % Peform classification
            trainData = permute(fcFeats(:,isTrain),[1 3 2]);

            [Az(j),AzLoo(j),statsCv{i}(j,k)] = RunSingleSvm(trainData,fcTruth(isTrain),params);
            yTest = statsCv{i}(j,k).wts(1:end-1)*fcFeats(:,iTest) + statsCv{i}(j,k).wts(end);
    %         [Az(j),AzLoo(j),statsLoro{i}(j)] = RunSingleLR(trainData,fcTruth(isTrain),params);
    %         yTest = statsLoro{i}(j).wts(1:end-1)'*fcFeats(:,isTest) + statsLoro{i}(j).wts(end);
            AzCv{i}(j,k) = rocarea(yTest,fcTruth(iTest));
            yCv{i}(iTest,k) = yTest;
            fwdModelCv{i}(:,j,k) = statsCv{i}(j,k).fwdModel;
        end
        AzCv_subj(k,i) = rocarea(yCv{i}(fcSubjs==i,k),fcTruth(fcSubjs==i));
        fprintf('Subj %d/%d, sepTime=%d samples: Az = %.3f\n',i,nSubj,separationTime,AzCv_subj(k,i));

    end
end
fprintf('Done!\n');

%% Plots
cla; hold on;
plot(separationTimes'*TR, AzCv_subj,'.-');
plot(separationTimes'*TR, mean(nTrain{1},1)/numel(fcTimes),'.-');
nTrainInRun_this = mean(nTrainInRun{1},1);
nTrainInCond_this = mean(nTrainInCond{1},1);
plot(separationTimes'*TR, nTrainInRun_this/nTrainInRun_this(1),'.-');
plot(separationTimes'*TR, nTrainInCond_this/nTrainInCond_this(1),'.-');
PlotVerticalLines(median(diff(fcTimes))*TR,'g--');
PlotVerticalLines(fcTimes(end)/(sum(nRuns)*2)*TR,'m--');
PlotVerticalLines(fcTimes(end)/(sum(nRuns))*TR,'c--');
xlabel('event times excluded from training set (+/-, s)')
ylabel('Cross-validated AUC')
title(sprintf('subject SBJ%02d',subjects(1)));
legend('AUC','frac training trials left','frac trials in same run','frac trials in same run & condition','median time between events','mean condition length','mean run length')
