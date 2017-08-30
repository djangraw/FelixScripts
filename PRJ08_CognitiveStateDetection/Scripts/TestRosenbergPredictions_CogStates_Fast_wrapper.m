% TestRosenbergPredictions_CogStates_Fast_wrapper.m
%
% Created 11/22/16 by DJ.

%% Get FC matrices
% Set up
subjects = [6:13,16:27];
demeanTs = true;
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
cd /data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/Behavior
for i=1:numel(subjects)
    filename = sprintf('SBJ%02d_Behavior.mat',i);
    foo = load(filename);
    behavior_avg_RT(i,:) = foo.averageRT;
    behavior_avg_PC(i,:) = foo.percentCorrect;
end

%% Get atlas & attention networks
% shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/EPIres_shen_1mm_268_parcellation+tlrc');
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);
% Get Rosenberg Hi/Low-Attn matrices
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_model_268.mat');

%% Run 'True Test'
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'BACK','VIDE','MATH','REST'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};
doPlot = true;

[P_true,Rsq_true] = TestRosenbergPredictions_CogStates_Fast(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,behTasks,doPlot);


%% Run permutation tests
doRandBeh = true; % PERM TESTS!
nPerms = 1000;
P = nan(nPerms,3);
Rsq = P;
parfor i=1:nPerms
    if mod(i,10)==0
        fprintf('===Running permutation %d/%d...\n',i,nPerms);
    end
    [P(i,:),Rsq(i,:)] = TestRosenbergPredictions_CogStates_Fast(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,behTasks);
end


%% Plot permutation results
figure(823); clf;
names = {'GradCPT Positive','GradCPT Negative','GradCPT Combined'};
xHist = exp(min(log(P(:))):0.1:0);
for i=1:3
    subplot(1,3,i); hold on;
    n = hist(P(:,i),xHist);
    pctBelow = cumsum(n)/nPerms*100;
    semilogx(xHist,pctBelow);
    set(gca,'xscale','log')
    xlabel('P value')
    ylabel('% correlations')
    title(sprintf('Behavior Permutations: %s Network',names{i}));
    i5 = find(pctBelow>5,1);
    xMin = min(get(gca,'xlim'));
    semilogx([xMin xHist(i5)],[pctBelow(i5) pctBelow(i5)],'k--')
    semilogx([xHist(i5) xHist(i5)],[0 pctBelow(i5)],'k--')
    fprintf('p05_adj_%s = %.3g\n',names{i},xHist(i5));
end
% print adjusted p values from real analysis
P_true_adj = nan(1,3);
for i=1:3
    P_true_adj(i) = mean(P(:,i)<P_true(i));
    fprintf('p_true_adj_%s = %.3g\n',names{i},P_true_adj(i));
end

%% Test single-task results
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'BACK','VIDE','MATH','REST'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};

[P_task,Rsq_task] = deal(nan(numel(fcTasks),numel(behTasks),3));
behav_task = nan(nSubj,numel(fcTasks),numel(behTasks));
for i=1:numel(fcTasks)
    for j=1:numel(behTasks)
        [P_tmp,Rsq_tmp,pred_pos_tmp,pred_neg_tmp,pred_glm_tmp,behav_tmp] = TestRosenbergPredictions_CogStates_Fast(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks(i),behTasks(j));
        P_task(i,j,:) = reshape(P_tmp,1,1,3);
        Rsq_task(i,j,:) = reshape(Rsq_tmp,1,1,3);
    end
end

%% Plot single-task results
figure(824); clf;
set(gcf,'Position',[74 452 1785 417]);
P_task_fdr = reshape(mafdr(P_task(:),'bhfdr',true), size(P_task));
for i=1:3
    subplot(1,3,i); hold on;
    imagesc(Rsq_task(:,:,i));
    set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks,...
        'ytick',1:numel(fcTasks),'yticklabel',fcTasks,...
        'ydir','reverse','clim',[0 1] *0.7);%max(Rsq_task(:)));%[0 0.1]);
    xlabel('behavior predicted')
    ylabel('FC used')
    [iStars,jStars] = find(P_task_fdr(:,:,i)<0.05);
    plot(jStars,iStars,'k*');
    colorbar
    xlim([0 numel(behTasks)]+0.5);
    ylim([0 numel(fcTasks)]+0.5);
    title(sprintf('R^2 values for %s network',names{i}))
end
colormap cool




%% Test single-task results with DMN Network
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'BACK','VIDE','MATH','REST'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};
network = 'Vis/Aud Language'; % 'DAN/DMN';
if strcmp(network,'Vis/Aud Language')
    load('VisAudNetwork_match15.mat');
    NetStruct.pos_overlap = VisAudNetwork>0;
    NetStruct.neg_overlap = VisAudNetwork<0;
    NetStruct.robGLM_fit = nan;
else
    load('/data/jangrawdc/PRJ03_SustainedAttention/Results/DanDmnNetwork_match15.mat');
    NetStruct.pos_overlap = DanDmnNetwork>0;
    NetStruct.neg_overlap = DanDmnNetwork<0;
    NetStruct.robGLM_fit = nan;
end
[P_task,Rsq_task] = deal(nan(numel(fcTasks),numel(behTasks),3));
behav_task = nan(nSubj,numel(fcTasks),numel(behTasks));
for i=1:numel(fcTasks)
    for j=1:numel(behTasks)
        [P_tmp,Rsq_tmp,pred_pos_tmp,pred_neg_tmp,pred_glm_tmp,behav_tmp] = TestRosenbergPredictions_CogStates_Fast(FC,NetStruct,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks(i),behTasks(j));
        P_task(i,j,:) = reshape(P_tmp,1,1,3);
        Rsq_task(i,j,:) = reshape(Rsq_tmp,1,1,3);
    end
end

%% Plot single-task results with DAN/DMN Network
figure(824); clf;
set(gcf,'Position',[74 452 1785 417]);
P_task_fdr = reshape(mafdr(P_task(:),'bhfdr',true), size(P_task));
names = {'DAN/DMN Positive','DAN/DMN Negative','DAN/DMN Combined'};
names = {'Vis/Aud Positive','Vis/Aud Negative','Vis/Aud Combined'};
for i=1:3
    subplot(1,3,i); hold on;
    imagesc(Rsq_task(:,:,i));
    set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks,...
        'ytick',1:numel(fcTasks),'yticklabel',fcTasks,...
        'ydir','reverse','clim',[0 1] *0.7);%max(Rsq_task(:)));%[0 0.1]);
    xlabel('behavior predicted')
    ylabel('FC used')
    [iStars,jStars] = find(P_task_fdr(:,:,i)<0.05);
    plot(jStars,iStars,'k*');
    colorbar
    xlim([0 numel(behTasks)]+0.5);
    ylim([0 numel(fcTasks)]+0.5);
    title(sprintf('R^2 values for %s network',names{i}))
end
colormap cool

%% Plot performance 
figure(825); clf;
set(gcf,'Position',[185 918 1354 385]);
% as matrix
avgBeh = nan(nSubj,numel(behTasks));
for i=1:numel(behTasks)
    isOkTask = strncmp(behTasks{i},taskNames,length(behTasks{i}));
    avgBeh(:,i) = nanmean(behavior_avg_PC(:,isOkTask),2);
end
subplot(1,2,1);
imagesc(avgBeh);
set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks);
ylabel('subject')
xlabel('behavior from task')
title('Cog States Data Behavior')
colorbar

subplot(1,2,2);
xBeh = 45:10:100;
nBeh = hist(avgBeh,xBeh);
pctBeh = nBeh/nSubj*100;
bar(xBeh,pctBeh);
set(gca,'xtick',40:10:100);
legend(behTasks,'Location','Northwest');
xlabel('% correct on task');
ylabel('% subjects');
title('Behavior Histograms');

%% Test single-block results
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'REST','BACK','VIDE','MATH'};
% behTasks = {'MATH'};
% behTasks = {'BACK','VIDE','MATH'};
taskBlocks = {'BACK01','VIDE01','MATH01','BACK02','MATH02','VIDE02'};
% taskBlocks = {'REST01','BACK01','VIDE01','MATH01','BACK02','REST02','MATH02','VIDE02'};

[P_block,Rsq_block] = deal(nan(numel(taskBlocks),3));
[pred_pos_block, pred_neg_block] = deal(nan(nSubj,numel(taskBlocks)));
for j=1:numel(taskBlocks)
    % Use FC from all blocks to predict behavior in one block
%     [P_tmp,Rsq_tmp,pred_pos_tmp,pred_neg_tmp] = TestRosenbergPredictions_CogStates_Fast(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,taskBlocks(j));
    % Use FC from one block to predict behavior in same block
    [P_tmp,Rsq_tmp,pred_pos_tmp,pred_neg_tmp] = TestRosenbergPredictions_CogStates_Fast(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,taskBlocks(j),taskBlocks(j));
    P_block(j,:) = reshape(P_tmp,1,3);
    Rsq_block(j,:) = reshape(Rsq_tmp,1,3);
    pred_pos_block(:,j) = pred_pos_tmp;
    pred_neg_block(:,j) = pred_neg_tmp;
end

%% Plot single-task results
figure(824); clf;
for i=1:3
    subplot(1,3,i); hold on;
    bar(P_block(:,i));
    set(gca,'xtick',1:numel(taskBlocks),'xticklabel',taskBlocks);
    xlabel('behavior predicted')
    ylabel('P value')
%     iStars = find(P_block(:,i)<0.05);
%     plot(iStars,ones(size(iStars))*.09,'r*');
    xlim([0 numel(taskBlocks)]+0.5);
    ylim([0 0.5]);
    title(sprintf('P values for %s network',names{i}))
end


figure(825); clf;
% avgBeh = nan(nSubj,numel(behTasks));
isOkTask = false(numel(taskNames),1);
for i=1:numel(taskBlocks)
    isOkTask = isOkTask | strncmp(taskBlocks{i},taskNames,length(taskBlocks{i}));
%     avgBeh(:,i) = nanmean(behavior_avg_PC(:,isOkTask),2);
end
% imagesc(avgBeh);
% set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks);
% ylabel('subject')
% xlabel('behavior from task')
% title('Cog States Data Behavior')
% colorbar
behTaskTypes = {'BACK','VIDE','MATH'};
behMatched = behavior_avg_PC(:,isOkTask);
% can we tell 1st from 2nd?
subplot(3,2,1);
imagesc(pred_pos_block-pred_neg_block);
set(gca,'xtick',1:size(pred_pos_block,2),'xticklabel',taskBlocks)
xlabel('block')
ylabel('subject')
title('Rosenberg score (pos-neg)')
colorbar
subplot(3,2,2);
imagesc(behMatched);
set(gca,'xtick',1:size(pred_pos_block,2),'xticklabel',taskBlocks)
xlabel('block')
ylabel('subject')
title('% correct')
colorbar

roseScore_byType = nan(nSubj,2,numel(behTaskTypes));
PC_byType = nan(nSubj,2,numel(behTaskTypes));
for i=1:numel(behTaskTypes)
    iBlocks = find(strncmp(behTaskTypes{i},taskBlocks,length(behTaskTypes{i})));
    roseScore_byType(:,:,i) = pred_pos_block(:,iBlocks) - pred_neg_block(:,iBlocks);
    PC_byType(:,:,i) = behMatched(:,iBlocks);

    subplot(3,3,3+i); hold on;
    hist(roseScore_byType(:,2,i)-roseScore_byType(:,1,i));
    PlotVerticalLines(median(roseScore_byType(:,2,i)-roseScore_byType(:,1,i)),'r--');
    ylabel('# subjects')
    xlabel(sprintf('Rosenberg score (pos-neg)\nfor block 2 - 1'))
    title(behTaskTypes{i})
    fprintf('%s: %.1f%% 2>1\n',behTaskTypes{i},mean(roseScore_byType(:,2,i)>roseScore_byType(:,1,i))*100);
end
% can we tell best from worst?
for i=1:numel(behTaskTypes)
    iBlocks = find(strncmp(behTaskTypes{i},taskBlocks,length(behTaskTypes{i})));
    roseScore_byType(:,:,i) = pred_pos_block(:,iBlocks) - pred_neg_block(:,iBlocks);
    PC_byType(:,:,i) = behMatched(:,iBlocks);
    isFlipped = PC_byType(:,2,i)>PC_byType(:,1,i);
    PC_byType(isFlipped,:,i) = fliplr(PC_byType(isFlipped,:,i));
    roseScore_byType(isFlipped,:,i) = fliplr(roseScore_byType(isFlipped,:,i));
    
    subplot(3,3,6+i); hold on;
    hist(roseScore_byType(:,2,i)-roseScore_byType(:,1,i));
    PlotVerticalLines(median(roseScore_byType(:,2,i)-roseScore_byType(:,1,i)),'r--');
    ylabel('# subjects')
    xlabel(sprintf('Rosenberg score (pos-neg)\nfor best - worst block'))
    title(behTaskTypes{i})
    fprintf('%s: %.1f%% worst>best\n',behTaskTypes{i},mean(roseScore_byType(:,2,i)>roseScore_byType(:,1,i))*100);
end
