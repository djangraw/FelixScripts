% leave1out_prediction_CogStates_Natasha_wrapper.m
%
% Created 11/22/16 by DJ.
% Updated 12/5/16 by DJ - copied from _Fast to _Natasha


%% Get FC matrices
% Set up
subjects = [6:13,16:27];
demeanTs = false;%true;
separateTasks = true;
nSubj = numel(subjects);
% Get FC
FCtmp = GetFcForCogStateData(subjects(1),separateTasks,demeanTs);
FC = nan([size(FCtmp),nSubj]);
winInfo_cell = cell(1,nSubj);
for i=1:nSubj
    [FC(:,:,:,i),winInfo_cell{i}] = GetFcForCogStateData(subjects(i),separateTasks,demeanTs);
end
taskNames = winInfo_cell{1}.winNames;

%% Get behavior
nWindows = size(FC,3);
behavior_avg_RT = nan(nSubj,nWindows);
behavior_avg_PC = nan(nSubj,nWindows);
behDir='/data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/Behavior';
for i=1:numel(subjects)
    filename = sprintf('%s/SBJ%02d_Behavior.mat',behDir,i);
    foo = load(filename);
    behavior_avg_RT(i,:) = foo.averageRT;
    behavior_avg_PC(i,:) = foo.percentCorrect;
end

%% Get atlas & attention networks
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);
% Get Rosenberg Hi/Low-Attn matrices
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_model_268.mat');

%% Find networks that use avg FC data to predict avg behavior
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'REST','BACK','VIDE','MATH'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};
doPlot = true;

[P_true,Rsq_true,pred_pos_true,pred_neg_true,pred_glm_true,pos_mask_all_true,neg_mask_all_true] = leave1out_prediction_CogStates_Fast(FC,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,behTasks,doPlot);

%% Test single-task results
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'REST','BACK','VIDE','MATH'};
% behTasks = {'MATH'};
% behTasks = {'BACK','VIDE','MATH'};
behTasks = {'BACK'};
nRoi = size(FC,1);
mask_method = 'cpcr'; % 'one';

% turn off warning
warning('off','stats:robustfit:RankDeficient');
% run loop
[P_task,Rsq_task] = deal(nan(numel(fcTasks),numel(behTasks),3));
[pred_pos_task,pred_neg_task,pred_glm_task] = deal(nan(nSubj,numel(fcTasks),numel(behTasks)));
[pos_mask_all_task,neg_mask_all_task] = deal(nan(nRoi,nRoi,nSubj,numel(fcTasks),numel(behTasks)));
for i=1:numel(fcTasks)
    for j=1:numel(behTasks)
        fprintf('FC task %d/%d, beh task %d/%d...\n',i,numel(fcTasks),j,numel(fcTasks));
        [P_tmp,Rsq_tmp,pred_pos_tmp,pred_neg_tmp,pred_glm_tmp,pos_mask_all_tmp,neg_mask_all_tmp] = ...
            leave1out_prediction_CogStates_Fast(FC,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks(i),behTasks(j),mask_method);
        P_task(i,j,:) = reshape(P_tmp,1,1,3);
        Rsq_task(i,j,:) = reshape(Rsq_tmp,1,1,3);
        pred_pos_task(:,i,j) = pred_pos_tmp;
        pred_neg_task(:,i,j) = pred_neg_tmp;
        pred_glm_task(:,i,j) = pred_glm_tmp;
        pos_mask_all_task(:,:,:,i,j) = pos_mask_all_tmp;
        neg_mask_all_task(:,:,:,i,j) = neg_mask_all_tmp;
        fprintf('Saving...\n');
        save('SingleTaskLooMasks_cpcr_temp','pos_mask_all_task','neg_mask_all_task','subjects','fcTasks','behTasks');
    end
end
fprintf('Done!\n')

%% Save results
save('SingleTaskLooMasks','pos_mask_all_task','neg_mask_all_task','subjects','fcTasks','behTasks');

%% Plot single-task results
figure(824); clf;
for i=1:3
    subplot(1,3,i); hold on;
    imagesc(P_task(:,:,i));
    set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks,...
        'ytick',1:numel(fcTasks),'yticklabel',fcTasks,...
        'clim',[0 0.5]);
    xlabel('behavior predicted')
    ylabel('FC used')
    [iStars,jStars] = find(P_task(:,:,i)<0.05);
    plot(jStars,iStars,'r*');
    colorbar
    xlim([0 numel(behTasks)]+0.5);
    ylim([0 numel(fcTasks)]+0.5);
    title(sprintf('P values for %s network',names{i}))
end
figure(825); clf;
avgBeh = nan(nSubj,numel(behTasks));
for i=1:numel(behTasks)
    isOkTask = strncmp(behTasks{i},taskNames,length(behTasks{i}));
    avgBeh(:,i) = nanmean(behavior_avg_PC(:,isOkTask),2);
end
imagesc(avgBeh);
set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks);
ylabel('subject')
xlabel('behavior from task')
title('Cog States Data Behavior')
colorbar

%% Extract 2-back-predictive network using FC from each task
load('SingleTaskLooMasks_backBeh_p01.mat');
behTaskToPredict = 'BACK';
iBehTask = find(strcmp(behTasks,behTaskToPredict));
comboMat = nan(nRoi,nRoi,numel(fcTasks));
for i=1:numel(fcTasks)
    % get overlap across LOO iterations
    comboMat(:,:,i) = all(pos_mask_all_task(:,:,:,i,iBehTask),3) - all(neg_mask_all_task(:,:,:,i,iBehTask),3);
    subplot(2,2,i);
    VisualizeFcIn2d(comboMat(:,:,i),shenAtlas,shenLabels,shenColors,shenLabelNames,[],'top');
end

%% Extract 2-back-predictive network using FC from each task USING CP/CR AND SPECIFIED THRESHOLD

load('SingleTaskLooMasks_cpcr_temp.mat');
behTaskToPredict = 'BACK';
iBehTask = find(strcmp(behTasks,behTaskToPredict));

thresh = 0.002;

comboMat = nan(nRoi,nRoi,numel(fcTasks));
for i=1:numel(fcTasks)
    % get overlap across LOO iterations
    comboMat(:,:,i) = GetNetworkAtThreshold(neg_mask_all_task(:,:,:,i,iBehTask),pos_mask_all_task(:,:,:,i,iBehTask),thresh);
%     subplot(2,2,i);
%     VisualizeFcIn2d(comboMat(:,:,i),shenAtlas,shenLabels,shenColors,shenLabelNames,[],'top');
end

comboMat_vec = VectorizeFc(comboMat);
matSizes = sum(comboMat_vec~=0,1);
fprintf('# edges in each network: [%s]\n',num2str(matSizes));

