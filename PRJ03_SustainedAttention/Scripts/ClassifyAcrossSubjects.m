vars = GetDistractionVariables();
subjects = vars.okSubjects;
homedir = sprintf('%s/Results/',vars.homedir);

% [FwdModel_bold,FwdModel_fc] = deal(cell(1,numel(subjects)));
label0_fc = 'attendedSpeech';
label1_fc = 'ignoredSpeech';
atlasType = 'Craddock';
TR = 2;
fcWinLength = 10;
nFirstRemoved = 3;
HrfOffset = 6;

magNormOption = 'run';
doMagPca = true;
fracMagVarToKeep = 0.9;
normFC = true;
doFcPca = true;
fracFcVarToKeep = 0.5; % 0.5 is the median for S9-30's nested CV
fcNormOption = 'run';

[tc_all,iTcEventSample_all,iFcEventSample_all,subjIndex_all,eventNames_all,eventSession_all] = deal([]);
subjOffset = zeros(1,numel(subjects));
for i=1:numel(subjects) % [8 10 13 18 20]%
    subject = subjects(i);
    fprintf('Subject %d...\n',subject);
    cd(homedir)
    fprintf('Loading files...\n');
    % Get input data
    cd(sprintf('%sSBJ%02d',homedir,subject));
    beh = load(sprintf('Distraction-SBJ%02d-Behavior.mat',subject));
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
    
    % get basic info
    nRuns = numel(beh.data);
    nT = size(tc,2);
    nTR = nT/nRuns + nFirstRemoved;
    nROIs = size(tc,1);
    
    % normalize TC
    switch magNormOption
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
    
    % Get trial times
    [iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset);

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

% normalize TC
% nROIs = size(tc_all,1);
% for i=1:nROIs
%     tc_all(i,:) = (tc_all(i,:)-nanmean(tc_all(i,:)))/nanstd(tc_all(i,:));
% end


if doMagPca
    % Run PCA on tcs
    isNotCensoredSample = ~any(isnan(tc_all));
    [Um,Sm,Vm] = svd(tc_all(:,isNotCensoredSample)',0);
    fracVar = cumsum(diag(Sm).^2)/sum(diag(Sm).^2);

    % Perform dimensionality reduction on mag features
    lastToKeep = find(fracVar<=fracMagVarToKeep,1,'last');
    fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracMagVarToKeep*100)
    tc_all_orthog = Vm(:,1:lastToKeep)'*tc_all; % rotate using SVD whitening matrix
else
    tc_all_orthog = tc_all;
end
%% Get FC features
% calculate sliding-window FC
tic;
FC = GetFcMatrices(tc_all_orthog,'sw',fcWinLength);
tFC = toc;
fprintf('Done! took %.3f seconds.\n',tFC);

%% normalize FC
% fprintf('Normalizing FC for each subject & ROI pair...\n')
% tic;
% for iSubj=1:numel(subjects)
%     fprintf('iSubj = %d/%d...\n',iSubj,numel(subjects));
%     isThisSubj = (subjIndex_all(1:size(FC,3))==iSubj);
%     FC(:,:,isThisSubj) = (FC(:,:,isThisSubj) - repmat(nanmean(FC(:,:,isThisSubj),3),[1 1 sum(isThisSubj)])) ./ ...
%         repmat(nanstd(FC(:,:,isThisSubj),0,3),[1 1 sum(isThisSubj)]);
% end
% tNORM = toc;
% fprintf('Done! took %.3f seconds.\n',tNORM);


% Apply Fisher z transform to correlation coefficients
if normFC
    FC = atanh(FC);
    FC(isinf(FC)) = nan;%max(abs(FC(~isinf(FC))));
end

%% run SVD on FC
if doFcPca
    tic;
    [Uf,Sf,Vf,FcPcTc] = PlotFcPca(FC,0,true);
    tSVD = toc;
    fprintf('Done! took %.3f seconds.\n',tSVD);
    
    % Reduce dimensionality
    cumsumS = cumsum(diag(Sf).^2)/sum(diag(Sf).^2);
    nPcsToKeep = find(cumsumS<=fracFcVarToKeep,1,'last');
    fc_2dmat = FcPcTc(1:nPcsToKeep,:);    
    fprintf('Reduced dimensionality to %d PCs.\n',nPcsToKeep);
else
    fc_2dmat = VectorizeFc(FC);
end


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
fcTruth = truth_all(isOkSample);
% replace nans with mean of non-nan trials (across all subjects)
for i=1:size(fcFeats,1);
    fcFeats(i,isnan(fcFeats(i,:))) = nanmean(fcFeats(i,:));
end

%% NORMALIZE FEATS ACROSS RUNS
switch fcNormOption
    case 'run'
        for i=1:1:numel(subjects)
            nRuns = max(fcSessions(fcSubjs==i));
            for j=1:nRuns
                isInRun = (fcSubjs==i & fcSessions==j);
                fcFeats(:,isInRun) = zscore(fcFeats(:,isInRun),[],2);
            end
        end
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

%% perform leave one subject out CV
clear stats;
[Az, AzLoso] = deal(nan(1,numel(subjects)));
yLoso = nan(size(fcTruth));
for i=1:numel(subjects)
    fprintf('Subject %d/%d...\n',i,numel(subjects));
    % find train and test data
    isTrain = (fcSubjs~=i);
    isTest = (fcSubjs==i);
    % Peform classification
    trainData = permute(fcFeats(:,isTrain),[1 3 2]);
    [Az(i),~,stats(i)] = RunSingleLR(trainData,fcTruth(isTrain),params);
    yTest = stats(i).wts(1:end-1)'*fcFeats(:,isTest) + stats(i).wts(end);
    AzLoso(i) = rocarea(yTest,fcTruth(isTest));
    yLoso(isTest) = yTest;
end
AzTotal = rocarea(yLoso,fcTruth);
fprintf('Done! Az=%.3f.\n',AzTotal);


%% A test: Single Subject Classification
params.LOO = true; % false; %
clear AzSS statsSS fwdModelSS
for i=1:numel(subjects)
%     try
    fprintf('Subject %d/%d...\n',i,numel(subjects));
    % find train and test data
    isTrain = (fcSubjs==i);
    % Peform classification
    trainData = permute(fcFeats(:,isTrain),[1 3 2]);
%     [~,AzSS(i),statsSS(i)] = RunSingleSvm(trainData,fcTruth(isTrain),params);
    [~,AzSS(i),statsSS(i)] = RunSingleLR(trainData,fcTruth(isTrain),params);
    fwdModelSS(:,i) = mean(statsSS(i).fwdModelLoo,2);
    fprintf('Subj %d/%d: LOO Az = %.3f\n',i,numel(subjects),AzSS(i));
%     catch
%         disp('Oops.');
%     end
end
fprintf('Done!\n');

% Plot results
subplot(131);
hist(AzSS,0.05:.1:.95);
xlabel('LOO AUC')
ylabel('# subjects')
title('Cross-subject SVD, single-subject classifier')

%% Another test: Leave One Run Out
params.LOO = false; % true; %
[AzLoro,statsLoro,fwdModelLoro,AzLoro,yLoro] = deal(cell(1,numel(subjects)));
AzLoro_subj = nan(1,numel(subjects));
for i=1:numel(subjects) % find(~ismember(subjects,[12, 20, 21, 27, 29, 23, 26]))%
    fprintf('Subject %d/%d...\n',i,numel(subjects));
    for j=1:max(fcSessions(fcSubjs==i)) % for each run
        % find train and test data
        isTrain = (fcSubjs==i & fcSessions~=j);
        isTest = (fcSubjs==i & fcSessions==j);
        % Peform classification
        trainData = permute(fcFeats(:,isTrain),[1 3 2]);
        
        [Az(j),AzLoo(j),statsLoro{i}(j)] = RunSingleSvm(trainData,fcTruth(isTrain),params);
        yTest = statsLoro{i}(j).wts(1:end-1)*fcFeats(:,isTest) + statsLoro{i}(j).wts(end);
%         [Az(j),AzLoo(j),statsLoro{i}(j)] = RunSingleLR(trainData,fcTruth(isTrain),params);
%         yTest = statsLoro{i}(j).wts(1:end-1)'*fcFeats(:,isTest) + statsLoro{i}(j).wts(end);
        AzLoro{i}(j) = rocarea(yTest,fcTruth(isTest));
        yLoro{i}(isTest(fcSubjs==i)) = yTest;
        fwdModelLoro{i}(:,j) = statsLoro{i}(j).fwdModel;
    end
    AzLoro_subj(i) = rocarea(yLoro{i},fcTruth(fcSubjs==i));
    fprintf('Subj %d/%d: LORO Az = %.3f\n',i,numel(subjects),AzLoro_subj(i));

end
fprintf('Done!\n');

% Plot results
subplot(132); cla;
hist(AzLoro_subj,0.05:.1:.95);
xlabel('LORO AUC')
ylabel('# subjects')
title('Cross-subject SVD, single-subject LORO classifier')

subplot(133); cla;
hist([AzLoro{:}],0.05:.1:.95);
xlabel('LORO AUC')
ylabel('# subject-run combinations')
title('Cross-subject SVD, single-subject LORO classifier')

% % Test for significance
% for i=1:size(fwdModelSS,1)
%     [p(i),h(i)] = signrank(fwdModelSS(i,:));
% end
% % FDR correct
% [FDR,q] = mafdr(p');