% TEMP_ClassifyStateFromFc_Mittner.m
%
% Created 11/23/15 by DJ.
% Updated 11/24/15 by DJ - added circle-arc plotting.
% Updated 12/3/15 by DJ - adapted from TEMP_ClassifyStateFromFc.m to use
% Mittner's ROIs

%% Set up
subject = 7;
% atlasType = 'Craddock';
procFolder = 'AfniProc_MultiEcho_2015-12-18';
atlasType = 'Mittner';
winLength = 15;

%% Calculate subject data
switch atlasType
    case 'Craddock'
        atlasDir = sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/%s',subject,procFolder);
        atlasFile = sprintf('CraddockAtlas_200Rois_SBJ%02depires+tlrc',subject);
%         cd atlasDir;
%         [atlasFile,atlasDir] = uigetfile({'*.BRIK','BRIK files','*.nii','NIFTI files','*.nii.gz','GZipped NIFTI files'},'Select atlas file'); % sprintf('CraddockAtlas_200Rois_SBJ%02depires+tlrc',subject);
    case 'Mittner'
        atlasDir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Mittner_2014_rois';
        atlasFile = 'Cube_4.5mm_all+tlrc';
end
% load atlas file
cd(atlasDir);
[err,atlas,atlasInfo,ErrMsg] = BrikLoad(atlasFile);
% get data file
dataDir = sprintf('/spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/%s',subject,procFolder);
dataFile = sprintf('errts.SBJ%02d.tproject+tlrc.BRIK',subject);
cd(dataDir);
[tc,FC] = SaveDistractionFCs(dataFile,atlas,winLength,sprintf('../SBJ%02d_FC_%s_%s',subject,procFolder,atlasType));
cd ..
%% Load SBJ data

if subject==5
    subjectName = 'SBJ05';
    analysisName = sprintf('TEMP_SBJ05_FC_MultiEcho_2015-12-08_%s',atlasType);
    behaviorName = 'Distraction-5-behavior';
elseif subject==6
    subjectName = 'SBJ06';
    analysisName = sprintf('SBJ06_FC_MultiEcho_2015-12-17_%s',atlasType);
    behaviorName = 'DistractionTask-6-QuickRun.mat';
elseif subject==7
    subjectName = 'SBJ07';
    analysisName = sprintf('SBJ07_FC_AfniProc_MultiEcho_2015-12-18_%s',atlasType);
    behaviorName = 'Distraction-7-QuickRun.mat';
end

% cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S05_2015-10-30
load(behaviorName);
load(analysisName);

% [U,S,V,PCtc] = PlotFcPca(FC(:,:,1:600),6,true);
[U,S,V,PCtc] = PlotFcPca(FC(:,:,:),6,true);
MakeFigureTitle(sprintf('DistractionTask %s',analysisName));

%% Get events
TR = 2; % repetition time (s)
nTR = 8*60/TR; % # of TRs per 8-minute session
nFirstRemoved = 3; % TRs removed before fMRI analysis
HrfOffset = 6; % Delay due to HRF lag
pageDur = 14; % duration of page (seconds)
% winLength = 7; % TRs
winDur = winLength*TR; % length of FC window (seconds)

[event_times,event_names] = deal(cell(1,numel(data)));
for i=1:numel(data)
    offset = (i-1)*(nTR-nFirstRemoved)*TR; % time (s) of first kept TR in fMRI data
    startTime = data(i).events.key.time(1); % this key is a T!
%     TrTimes = (nFirstRemoved:nTR-1)*TR; % times within this session
    event_times{i} = [offset; (data(i).events.soundstart.time - startTime)/1000 + offset];
    event_names{i} = [{'SessionStart'}; data(i).events.soundstart.name];    
end
event_times = cat(1,event_times{:});
event_names = cat(1,event_names{:});

%% Get event timing
% Get time of each FC window's START
tFC = (0:size(PCtc,2))*TR;
% tFC = (0:599)*TR - HrfOffset;
tTC = (0:size(PCtc,2))*TR;

% Get FC and tc event sample numbers
iEventSample = nan(1,numel(event_times));
iTcEventSample = nan(1,numel(event_times));
for i=1:numel(event_times)
    if event_times(i)<tFC(end)
        if ~isempty(find(tFC + winDur <= event_times(i) + pageDur,1,'last'))
            % Get indices of FC matrix that end at the END of a page
            iEventSample(i) = find(tFC + winDur <= event_times(i) + pageDur,1,'last');    
            % Get indices of tc matrix that start in the middle of the page.
            iTcEventSample(i) = find(tTC <= event_times(i) + pageDur/2,1,'last');
        end
    end
end
% Get truth data
truth = strcmp(event_names,'whiteNoiseSound')';
truth = truth(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart'));
    
%% Run Classification
switch atlasType
    case 'Craddock'
        % nFeats = 1:55; % # of FC PC feats to use
        nFeats = 0:10:200;
    case 'Mittner'
        nFeats = 0:11;
end


params.regularize = 1;
params.lambda = 1e-6;
params.lambdasearch = true;
params.eigvalratio = 1e-4;
% params.vinit = zeros(size(feats,1)+1,1);
params.show = 0;
params.LOO = true;

% Get all TC feats
tcFeats = tc(:,iTcEventSample(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart')));
% Set up
[Az,AzLoo] = deal(nan(1,numel(nFeats)));
clear stats
for i = 1:numel(nFeats)
    % Extract features
    fcFeats = PCtc(1:nFeats(i),iEventSample(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart')));
    feats = cat(1,fcFeats,tcFeats);
    
    % Classify
    params.vinit = zeros(size(feats,1)+1,1); % initialize v with correct nFeats
    [Az(i),AzLoo(i),stats(i)] = RunSingleLR(permute(feats,[1 3 2]),truth,params);

    % Print results
    fprintf('nFeats=%d: AzLoo = %.3f\n',nFeats(i),AzLoo(i));
end
%% Plot results

figure(572); clf;
plot(nFeats,[Az;AzLoo]);
hold on
PlotHorizontalLines(0.5,'k--');
xlabel('# PCs included')
ylabel('AUC')
legend('Training','LOO')
ylim([0.4 1]);
grid on
title(sprintf('Predicting Condition from FC Data: \n%s',analysisName),'interpreter','none')

%% Get mean FC for each condition
normalizeForPlotting = false;
% Get FC features
FC_events = FC(:,:,iEventSample(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart')));
% get ROI timecourses
TC_events = tc(:,iTcEventSample(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart')));

% normalize
if normalizeForPlotting
    FC_norm = (FC_events-repmat(mean(FC(:,:,1:size(PCtc,2)),3),1,1,size(FC_events,3)))./repmat(std(FC(:,:,1:size(PCtc,2)),[],3),1,1,size(FC_events,3));
    TC_norm = (TC_events-repmat(mean(tc(:,1:size(PCtc,2)),2),1,size(TC_events,2)))./repmat(std(tc(:,1:size(PCtc,2)),[],2),1,size(TC_events,2));
else
    FC_norm = FC_events;
    TC_norm = TC_events;
end
% get mean FC during truth=0 and 1
FCmean_0 = mean(FC_norm(:,:,truth==0),3);
FCmean_1 = mean(FC_norm(:,:,truth==1),3);
% set diagonals to 0 so we don't throw off scaling
FCmean_0(logical(eye(size(FCmean_0)))) = 0;
FCmean_1(logical(eye(size(FCmean_1)))) = 0;
% get mean TC of activity during truth=0 and 1
TCmean_0 = mean(TC_norm(:,truth==0),2);
TCmean_1 = mean(TC_norm(:,truth==1),2);


% load atlas
% thisdir = cd;
% atlasToUse = 'craddock';
% switch atlasToUse
%     case 'craddock'
%         cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/craddock_2011_parcellations
%         atlasfile = 'CraddockAtlas_200Rois+orig.BRIK.gz';
%     case 'shen'
%         cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Shen_2013_parcellations
%         atlasfile = '';
% end
% [err,atlas,atlasInfo,ErrMsg] = BrikLoad(atlasfile);
% cd(thisdir)

%% Plot
switch atlasType
    case 'Craddock'
        nClusters = 10;
        idx = ClusterRoisSpatially(atlas,nClusters);
        ROI_names = cell(1,nClusters);
        for i=1:nClusters
            ROI_names{i} = sprintf('ROI#%d',i);
        end
    case 'Mittner'
        idx = 1:max(atlas(:)); % each ROI is its own cluster
        ROI_names = {'PCC','mPFC','lIPC','rIPL','rIPS','lIPS','SMA','rIL','lIL','rDLPFC','lDLPFC'};
end
threshold = 0.5;
figure(200); clf;
subplot(131);
PlotConnectivityOnCircle(atlas,idx,FCmean_0,threshold,ROI_names,false)
title('Irrelevant Speech')
subplot(132);
PlotConnectivityOnCircle(atlas,idx,FCmean_1,threshold,ROI_names,false)
title('White Noise')
subplot(133);
PlotConnectivityOnCircle(atlas,idx,FCmean_1-FCmean_0,0.1,ROI_names,false)
title('White Noise - Irrelevant Speech')
%% Plot as matrices
figure(202); clf;
subplot(131);
imagesc(FCmean_0);
axis square
clim = [-.8 .8];
set(gca,'clim',clim,'xtick',idx,'xticklabel',ROI_names,'ytick',idx,'yticklabel',ROI_names);
title('Irrelevant Speech')
colorbar
subplot(132);
imagesc(FCmean_1);
axis square
set(gca,'clim',clim,'xtick',idx,'xticklabel',ROI_names,'ytick',idx,'yticklabel',ROI_names);
title('White Noise')
colorbar
subplot(133);
imagesc(FCmean_1-FCmean_0);
axis square
set(gca,'clim',[-.3 .3],'xtick',idx,'xticklabel',ROI_names,'ytick',idx,'yticklabel',ROI_names);
title('White Noise - Irrelevant Speech')
colorbar
%% Plot as bar graphs
nClusters = numel(ROI_names);
pairNames = cell(nClusters,nClusters);
for i=1:nClusters
    for j=1:nClusters
        pairNames{i,j} = sprintf('%s/%s',ROI_names{i},ROI_names{j});
    end
end

% get indices
indices = zeros(size(FCmean_0));
indices(1:end) = 1:numel(indices);

% Plot
figure(204); clf;
subplot(2,3,1);
bar([reshape(FCmean_0(1:4,5:end),28,1), reshape(FCmean_1(1:4,5:end),28,1)]);
legend('Irrelevant Speech','White Noise');
xlabel('ROI pair')
ylabel('Mean FC')
title('DMN<-->ACN')
ylim([-.4 .8])
set(gca,'xtick',1:28,'xticklabel',reshape(pairNames(1:4,5:end),28,1));
xticklabel_rotate;

subplot(2,3,2);
bar([nonzeros(triu(FCmean_0(1:4,1:4),1)), nonzeros(triu(FCmean_1(1:4,1:4),1))]);
legend('Irrelevant Speech','White Noise');
xlabel('ROI pair')
ylabel('Mean FC')
title('DMN<-->DMN')
ylim([-.4 .8])
set(gca,'xtick',1:6,'xticklabel',pairNames(nonzeros(triu(indices(1:4,1:4),1))));
xticklabel_rotate;

subplot(2,3,3);
bar([nonzeros(triu(FCmean_0(5:end,5:end),1)), nonzeros(triu(FCmean_1(5:end,5:end),1))]);
legend('Irrelevant Speech','White Noise');
xlabel('ROI pair')
ylabel('Mean FC')
title('ACN<-->ACN')
ylim([-.4 .8])
xlim([0 22])
set(gca,'xtick',1:21,'xticklabel',pairNames(nonzeros(triu(indices(5:end,5:end),1))));
xticklabel_rotate;

subplot(2,3,4);
bar([TCmean_0(1:4),TCmean_1(1:4)]);
legend('Irrelevant Speech','White Noise');
xlabel('ROI')
ylabel('Mean TC')
title('DMN')
% ylim([-.4 .8])
set(gca,'xtick',1:4,'xticklabel',ROI_names(1:4));
xticklabel_rotate;

subplot(2,3,5);
bar([TCmean_0(5:end),TCmean_1(5:end)]);
legend('Irrelevant Speech','White Noise');
xlabel('ROI')
ylabel('Mean TC')
title('ACN')
% ylim([-.4 .8])
set(gca,'xtick',1:nClusters-4,'xticklabel',ROI_names(5:end));
xticklabel_rotate;

%% Get timecourse and questions when weights are applied
nPcsToInclude = 180;

iFirstUsable = find(~isnan(iEventSample),1);
iAllPages = nan(1,120); % total nPages
foo = iEventSample(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart'));
iAllPages((1:numel(foo))+iFirstUsable-1) = foo;
% Get PC + TC data
allData = [PCtc(1:nPcsToInclude,:); tc(:,(1:size(PCtc,2))+nanmedian(iTcEventSample-iEventSample))]; % make sure to offset in time
TC_events = tc(:,iTcEventSample(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart')));

% allData = [PCtc; tc(:,(1:size(PCtc,2))+nanmedian(iTcEventSample-iEventSample))]; % make sure to offset in time
trainlabels = nan(1,size(PCtc,2));
trainlabels(iEventSample(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart'))) = truth;
% get the data index corresponding to each question
% qPages_vec = round(cat(1,questions.qPages));
qPages_cell = questions.qPages_cell;
qIndices_cell = cell(1,numel(qPages_cell));%_vec));
isBadQ = false(1,numel(qPages_cell));
for i=1:numel(qPages_cell) %_vec)
%     qIndices_cell{i} = iAllPages(qPages_vec(i));
    qIndices_cell{i} = iAllPages(qPages_cell{i});  
    if isnan(qIndices_cell{i})
        isBadQ(i) = true;
    end
end
isCorrect = cat(1,questions.isCorrect);
% reject questions from pages where we don't have data
% isBadQ = cellfun(@isnan,qIndices_cell);
qIndices_cell(isBadQ) = [];
isCorrect(isBadQ) = [];

params.vinit = zeros(size(allData,1)+1,1);
nPerms = 100;
% Run!
[AzLoo,Az_accuracy,AzLoo_perm,Az_accuracy_perm] = ...
    GetLrAccuracyPredictions(allData,trainlabels,qIndices_cell,isCorrect,params,nPerms);
