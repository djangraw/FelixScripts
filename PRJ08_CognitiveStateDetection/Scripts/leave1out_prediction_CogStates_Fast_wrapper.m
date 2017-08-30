% leave1out_prediction_CogStates_Fast_wrapper.m
%
% Created 11/22/16 by DJ.
% Updated 6/9/17 by DJ - get cp/cr, use it to get network with a certain
% threshold.

%% Get FC matrices
% Set up
subjects = [6:13,16:27];
demeanTs = true;%true;
separateTasks = true;
nSubj = numel(subjects);
% Get FC
FCtmp = GetFcForCogStateData(subjects(1),separateTasks,demeanTs); % already Fisher-normalized in function
FC = nan([size(FCtmp),nSubj]);
winInfo_cell = cell(1,nSubj);
for i=1:nSubj
    [FC(:,:,:,i),winInfo_cell{i}] = GetFcForCogStateData(subjects(i),separateTasks,demeanTs); % already Fisher-normalized in function
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
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
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

[P_true,Rsq_true,pred_pos_true,pred_neg_true,pred_glm_true,pos_mask_all_true,neg_mask_all_true] = leave1out_prediction_CogStates_Fast(FC,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,behTasks,doPlot);

%% Save results
save('CogStates_RoseCode_DemeanTs_AllTasks_2017-06-09.mat','P_true','Rsq_true','pred_pos_true','pred_neg_true','pred_glm_true','pos_mask_all_true','neg_mask_all_true','behavior_avg_PC','fcTasks','behTasks','taskNames');


%%
behav = nanmean(behavior_avg_PC,2);
pred_pos = pred_pos_true;
pred_neg = pred_neg_true;
pred_glm = pred_glm_true;

%% Run permutation tests
% doRandBeh = true; % PERM TESTS!
% nPerms = 1000;
% P = nan(nPerms,3);
% Rsq = P;
% parfor i=1:nPerms
%     if mod(i,10)==0
%         fprintf('===Running permutation %d/%d...\n',i,nPerms);
%     end
%     [P(i,:),Rsq(i,:)] = TestRosenbergPredictions_CogStates_Fast(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,behTasks);
% end
% 

%% Plot permutation results
% figure(823); clf;
% names = {'Pos','Neg','GLM'};
% xHist = exp(min(log(P(:))):0.1:0);
% for i=1:3
%     subplot(1,3,i); hold on;
%     n = hist(P(:,i),xHist);
%     pctBelow = cumsum(n)/nPerms*100;
%     semilogx(xHist,pctBelow);
%     set(gca,'xscale','log')
%     xlabel('P value')
%     ylabel('% correlations')
%     title(sprintf('Behavior Permutations: %s Network',names{i}));
%     i5 = find(pctBelow>5,1);
%     xMin = min(get(gca,'xlim'));
%     semilogx([xMin xHist(i5)],[pctBelow(i5) pctBelow(i5)],'k--')
%     semilogx([xHist(i5) xHist(i5)],[0 pctBelow(i5)],'k--')
%     fprintf('p05_adj_%s = %.3g\n',names{i},xHist(i5));
% end
% % print adjusted p values from real analysis
% P_true_adj = nan(1,3);
% for i=1:3
%     P_true_adj(i) = mean(P(:,i)<P_true(i));
%     fprintf('p_true_adj_%s = %.3g\n',names{i},P_true_adj(i));
% end

%% Test single-task results
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'BACK','VIDE','MATH','REST'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};
nRoi = size(FC,1);

[P_task,Rsq_task] = deal(nan(numel(fcTasks),numel(behTasks),3));
[pred_pos_task,pred_neg_task,pred_glm_task,behav_task] = deal(nan(nSubj,numel(fcTasks),numel(behTasks)));
[pos_mask_all_task,neg_mask_all_task] = deal(nan(nRoi,nRoi,nSubj,numel(fcTasks),numel(behTasks)));
for i=1:numel(fcTasks)
    for j=1:numel(behTasks)
        [P_tmp,Rsq_tmp,pred_pos_tmp,pred_neg_tmp,pred_glm_tmp,pos_mask_all_tmp,neg_mask_all_tmp,behav_tmp] = ...
            leave1out_prediction_CogStates_Fast(FC,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks(i),behTasks(j));
        P_task(i,j,:) = reshape(P_tmp,1,1,3);
        Rsq_task(i,j,:) = reshape(Rsq_tmp,1,1,3);
        pred_pos_task(:,i,j) = pred_pos_tmp;
        pred_neg_task(:,i,j) = pred_neg_tmp;
        pred_glm_task(:,i,j) = pred_glm_tmp;
        behav_task(:,i,j) = behav_tmp;
        pos_mask_all_task(:,:,:,i,j) = pos_mask_all_tmp;
        neg_mask_all_task(:,:,:,i,j) = neg_mask_all_tmp;
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
        'clim',[0 0.7]);
    xlabel('behavior predicted')
    ylabel('FC used')
    [iStars,jStars] = find(P_task_fdr(:,:,i)<0.05);
    plot(jStars,iStars,'k*');
    colorbar
    xlim([0 numel(behTasks)]+0.5);
    ylim([0 numel(fcTasks)]+0.5);
    title(sprintf('R^2 values for %s network',names{i}))
    set(gca,'ydir','reverse');
end
colormap cool

%% Plot behavior
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


%% Load & Rearrange
load('CogStates_RoseCode_DemeanTs_task_2016-12-08.mat');
newOrder = [2 3 4 1];
fcTasks = fcTasks(newOrder);
P_task = P_task(newOrder,:,:);
P_task_fdr = P_task_fdr(newOrder,:,:);
Rsq_task = Rsq_task(newOrder,:,:);
neg_mask_all_task = neg_mask_all_task(:,:,:,newOrder,:);
pos_mask_all_task = pos_mask_all_task(:,:,:,newOrder,:);
pred_pos_task = pred_pos_task(:,newOrder,:);
pred_neg_task = pred_neg_task(:,newOrder,:);
pred_glm_task = pred_glm_task(:,newOrder,:);

%% Produce networks for each FC-beh matched pair
task_mask = nan(nRoi,nRoi,numel(behTasks));
for i=1:numel(behTasks)
    task_mask(:,:,i) = all(pos_mask_all_task(:,:,:,i,i),3) - all(neg_mask_all_task(:,:,:,i,i),3);
end
%save results
save('/data/jangrawdc/PRJ08_CognitiveStateDetection/Results/CogStates_RoseCode_DemeanTs_TaskMasks_2016-12-08','task_mask','behTasks');

%% Run updated single-task regression
%% Get cpcr
corr_method = 'robustfit';
mask_method = 'cpcr';
thresh = 0;

fcTasks = {'BACK','VIDE','MATH','REST'};
behTasks = {'BACK','VIDE','MATH'};
% fcTasks = {'BACK','ALL'};
% behTasks = {'BACK'};
nRoi = size(FC,1);

% [P_task,Rsq_task] = deal(nan(numel(fcTasks),numel(behTasks),3));
% [pred_pos_task,pred_neg_task,pred_glm_task,behav_task] = deal(nan(nSubj,numel(fcTasks),numel(behTasks)));
% [pos_mask_all_task,neg_mask_all_task] = deal(nan(nRoi,nRoi,nSubj,numel(fcTasks),numel(behTasks)));
[task_cp,task_cr] = deal(nan(nRoi,nRoi,nSubj,numel(fcTasks),numel(behTasks)));
tic;
for i=1:numel(fcTasks)
    % Get mean FC across relevant blocks
    if strcmp(fcTasks{i},'ALL')
        FC_this = squeeze(mean(FC,3));
    else        
        FC_this = squeeze(mean(FC(:,:,strncmp(fcTasks{i},taskNames,length(fcTasks{i})),:),3));
    end
    % If it's nan in any subject, set them all to zero
    isRowMissing = all(any(isnan(FC_this),3),2);
    FC_this(isRowMissing,:,:) = 0;
    FC_this(:,isRowMissing,:) = 0;

    for j=1:numel(behTasks)
        fprintf('FC task %d/%d, beh task %d/%d (%.1f seconds)...\n',i,numel(fcTasks),j,numel(behTasks),toc);
        beh = mean(behavior_avg_PC(:,strncmp(behTasks{j},taskNames,length(behTasks{j}))),2);
        
        [~,~,~,task_cp(:,:,:,i,j),task_cr(:,:,:,i,j)] = RunLeave1outBehaviorRegression(FC_this,beh,thresh,corr_method,mask_method);

    end
end
fprintf('Done! Took %.1f seconds.\n',toc);

%% Save results
% save('CogStates_RoseCode_CpCr_BackAll_2017-06-12.mat','task_cp','task_cr','fcTasks','behTasks');
% save('CogStates_RoseCode_CpCr_2017-06-09.mat','task_cp','task_cr','fcTasks','behTasks');
save('CogStates_RoseCode_CpCr_2017-06-16.mat','task_cp','task_cr','fcTasks','behTasks');

%% Sweep threshold & test masks



%% Get & evaluate masks given a threshold
% load('CogStates_RoseCode_CpCr_BackAll_2017-06-12.mat');
load('CogStates_RoseCode_CpCr_2017-06-16.mat');

[P_task,R_task,Rsq_task] = deal(nan(numel(fcTasks),numel(behTasks),3));
thresh = 0.0016;%0.01;
for i=1:numel(fcTasks)
    % Get mean FC across relevant blocks
    if strcmp(fcTasks{i},'ALL')
        FC_this = squeeze(mean(FC,3));
    else        
        FC_this = squeeze(mean(FC(:,:,strncmp(fcTasks{i},taskNames,length(fcTasks{i})),:),3));
    end
    % If it's nan in any subject, set them all to zero
    isRowMissing = all(any(isnan(FC_this),3),2);
    FC_this(isRowMissing,:,:) = 0;
    FC_this(:,isRowMissing,:) = 0;
    
    for j=1:numel(behTasks)
        fprintf('FC task %d/%d, beh task %d/%d (%.1f seconds)...\n',i,numel(fcTasks),j,numel(behTasks),toc);
        beh = mean(behavior_avg_PC(:,strncmp(behTasks{j},taskNames,length(behTasks{j}))),2);
        % Extract predictions given threshold
        netStrength = nan(nSubj,3); % pos,neg,glm
        nets = nan(nEdges,nSubj);
        for k=1:nSubj
            nets(:,k) = VectorizeFc(GetNetworkAtThreshold(task_cr(:,:,k,i,j),task_cp(:,:,k,i,j),thresh));
            netStrength(k,1) = (nets(:,k)>0)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)>0);
            netStrength(k,2) = (nets(:,k)<0)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)<0);
            netStrength(k,3) = nets(:,k)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)~=0);
        end
        [R_task(i,j,1), P_task(i,j,1)] = corr(beh,netStrength(:,1),'tail','right');
        [R_task(i,j,2), P_task(i,j,2)] = corr(beh,netStrength(:,2),'tail','left');
        [R_task(i,j,3), P_task(i,j,3)] = corr(beh,netStrength(:,3),'tail','right');
        pred_pos_task(:,i,j) = netStrength(:,1);
        pred_neg_task(:,i,j) = netStrength(:,2);
        pred_glm_task(:,i,j) = netStrength(:,3);
%         pos_mask_all_task(:,:,:,i,j) = pos_mask_all_tmp;
%         neg_mask_all_task(:,:,:,i,j) = neg_mask_all_tmp;

    end
end
Rsq_task = R_task.^2;
fprintf('Done! Took %.1f seconds.\n',toc);

% ...And Plot!
figure(824); clf;
set(gcf,'Position',[74 452 1785 417]);
P_task_fdr = reshape(mafdr(P_task(:),'bhfdr',true), size(P_task));
for i=1:3
    subplot(1,3,i); hold on;
    imagesc(Rsq_task(:,:,i));
    set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks,...
        'ytick',1:numel(fcTasks),'yticklabel',fcTasks,...
        'clim',[0 0.7]);
    xlabel('behavior predicted')
    ylabel('FC used')
    [iStars,jStars] = find(P_task_fdr(:,:,i)<0.05);
    plot(jStars,iStars,'k*');
    colorbar
    xlim([0 numel(behTasks)]+0.5);
    ylim([0 numel(fcTasks)]+0.5);
    title(sprintf('R^2 values for task-trained network, thresh p<%.3g',thresh))
    set(gca,'ydir','reverse');
end
colormap cool

%% Visualize networks at threshold

fcTask = 'BACK';
behTask = 'BACK';
thresh = 0.0119;%0.01;
% get indices of tasks
i = strncmp(fcTask,fcTasks,length(fcTask));
j = strncmp(behTask,fcTasks,length(behTask));

if strcmp(fcTask,'ALL')
    FC_this = squeeze(mean(FC,3));
else        
    FC_this = squeeze(mean(FC(:,:,strncmp(fcTask,taskNames,length(fcTask)),:),3));
end
% If it's nan in any subject, set them all to zero
isRowMissing = all(any(isnan(FC_this),3),2);
FC_this(isRowMissing,:,:) = 0;
FC_this(:,isRowMissing,:) = 0;

beh = mean(behavior_avg_PC(:,strncmp(behTask,taskNames,length(behTask))),2);
% Extract predictions given threshold
netStrength = nan(nSubj,3); % pos,neg,glm
nets = nan(nEdges,nSubj);
for k=1:nSubj
    nets(:,k) = VectorizeFc(GetNetworkAtThreshold(task_cr(:,:,k,i,j),task_cp(:,:,k,i,j),thresh));
end
netsAll = all(nets>0,2) - all(nets<0,2);
fprintf('threshold = %.3g: %d edges\n',thresh,sum(netsAll~=0));

figure(3);clf;
subplot(1,2,1);
VisualizeFcIn2d(UnvectorizeFc(netsAll,0,true),shenAtlas,shenLabels_hem,shenColors_hem,shenLabelNames_hem,shenInfo.Orientation,'top');
subplot(1,2,2);
VisualizeFcIn2d(UnvectorizeFc(netsAll,0,true),shenAtlas,shenLabels_hem,shenColors_hem,shenLabelNames_hem,shenInfo.Orientation,'left');
fprintf('Done!\n');
        
%% Save results
netsAll_mat = UnvectorizeFc(netsAll,0,true);
roiValsToSave = (any(netsAll_mat<0) & ~any(netsAll_mat>0)) + 2*(any(netsAll_mat>0) & any(netsAll_mat<0)) + 3*(any(netsAll_mat>0) & ~any(netsAll_mat<0));
roiValsToSave(isRowMissing) = -1;
if thresh==1
    outFilename = sprintf('FC-%s_beh-%s_thresh-1p0_NegBothPos',fcTask,behTask);
else
    outFilename = sprintf('FC-%s_beh-%s_thresh-0p%04d_NegBothPos',fcTask,behTask,round(thresh*1e4));
end
Opts = struct('Prefix',outFilename,'OverWrite','y');
WriteBrik(MapValuesOntoAtlas(shenAtlas,roiValsToSave),shenInfo,Opts);

%% Sweep Thresholds
thresholds = 10.^(-4:.05:0);
[P_task,R_task,Rsq_task] = deal(nan(numel(fcTasks),numel(behTasks),numel(thresholds),3));
nEdgesInNet = nan(numel(fcTasks),numel(behTasks),numel(thresholds));
tic;
for iThresh = 1:numel(thresholds)
    thresh = thresholds(iThresh);
    for i=1:numel(fcTasks)
        % Get mean FC across relevant blocks
        if strcmp(fcTasks{i},'ALL')
            FC_this = squeeze(mean(FC,3));
        else        
            FC_this = squeeze(mean(FC(:,:,strncmp(fcTasks{i},taskNames,length(fcTasks{i})),:),3));
        end
        % If it's nan in any subject, set them all to zero
        isRowMissing = all(any(isnan(FC_this),3),2);
        FC_this(isRowMissing,:,:) = 0;
        FC_this(:,isRowMissing,:) = 0;

        for j=1:numel(behTasks)
            fprintf('FC task %d/%d, beh task %d/%d (%.1f seconds)...\n',i,numel(fcTasks),j,numel(behTasks),toc);
            beh = mean(behavior_avg_PC(:,strncmp(behTasks{j},taskNames,length(behTasks{j}))),2);
            % Extract predictions given threshold
            netStrength = nan(nSubj,3); % pos,neg,glm
            nets = nan(nEdges,nSubj);
            for k=1:nSubj
%                 iTrain = [1:k-1, k+1:nSubj];
%                 nets(:,k) = VectorizeFc(GetNetworkAtThreshold(task_cr(:,:,iTrain,i,j),task_cp(:,:,iTrain,i,j),thresh));
                nets(:,k) = VectorizeFc(GetNetworkAtThreshold(task_cr(:,:,k,i,j),task_cp(:,:,k,i,j),thresh));
                netStrength(k,1) = (nets(:,k)>0)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)>0);
                netStrength(k,2) = (nets(:,k)<0)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)<0);
                netStrength(k,3) = nets(:,k)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)~=0);
            end
            nEdgesInNet(i,j,iThresh) = sum(all(nets>0,2) | all(nets<0,2));
            [R_task(i,j,iThresh,1), P_task(i,j,iThresh,1)] = corr(beh,netStrength(:,1),'tail','right');
            [R_task(i,j,iThresh,2), P_task(i,j,iThresh,2)] = corr(beh,netStrength(:,2),'tail','left');
            [R_task(i,j,iThresh,3), P_task(i,j,iThresh,3)] = corr(beh,netStrength(:,3),'tail','right');
            pred_pos_task(:,i,j,iThresh) = netStrength(:,1);
            pred_neg_task(:,i,j,iThresh) = netStrength(:,2);
            pred_glm_task(:,i,j,iThresh) = netStrength(:,3);
    %         pos_mask_all_task(:,:,:,i,j) = pos_mask_all_tmp;
    %         neg_mask_all_task(:,:,:,i,j) = neg_mask_all_tmp;

        end
    end
end

%% Plot
figure(623); clf;
hold on;
thresh = 0.01;
iThresh = find(thresholds==thresh);
colors = {'b','y','g'};
for i=1:numel(behTasks)
    plot(squeeze(nEdgesInNet(i,i,:))', squeeze(R_task(i,i,:,3))',colors{i});
end
for i=1:numel(behTasks)
    plot([1 1]*nEdgesInNet(i,i,iThresh), [0 R_task(i,i,iThresh,3)],[colors{i} '--']);
end
ylim([0 1]);
xlim([0 300]);
% plot(thresholds, squeeze(R_task(:,:,:,3))');
% plot(squeeze(nEdgesInNet)', squeeze(R_task(:,:,:,3))');
legend([behTasks,{sprintf('p=%.3g',thresh)}]);
xlabel('# edges')
ylabel('Pearson r between network score and behavior');
title('Networks trained on Matched Tasks')

%% Get behavior correlations between tasks
% Get requested tasks
behTasks = {'BACK','VIDE','MATH'};
fracCorrect = nan(size(FC,4),numel(behTasks));
for i=1:numel(behTasks)
    isOkTask = strncmp(behTasks{i},taskNames,length(behTasks{i}));
    fracCorrect(:,i) = nanmean(behavior_avg_PC(:,isOkTask),2);
    % RT_avg = nanmean(behavior_avg_RT(:,isOkTask)');
end

behCorr = corr(fracCorrect);
figure(873); clf;
set(gcf,'Position',[985 1072 360 260]);
imagesc(behCorr);
set(gca,'clim',[0 1],'xtick',1:numel(behTasks),'xticklabel',behTasks,'ytick',1:numel(behTasks),'yticklabel',behTasks);
colorbar;
title('Correlation of behavior across tasks')
colormap cool
%% Correlation of behavior with motion

%% Try correlating behavior with difference between 2-back and math tasks

FCavg = GetAvgFcAcrossTasks(FC,{'BACK'},taskNames);
FCavg = permute(FCavg,[1 2 4 3]);
behDiff = fracCorrect(:,strcmp(behTasks,'BACK')) - fracCorrect(:,strcmp(behTasks,'MATH'));
[P_true,Rsq_true,pred_pos_true,pred_neg_true,pred_glm_true,pos_mask_all_true,neg_mask_all_true] = leave1out_prediction_CogStates_Fast(FCavg,behDiff,{'BACK'},doRandBeh,doRand,{'BACK'},{'BACK'},doPlot);

%% Correlate & print
fprintf('===2-Back FC predicting 2-Back minus Math behavior:\n');
[r_pos,p_pos] = corr(pred_pos_true,behDiff,'tail','right');
[r_neg,p_neg] = corr(pred_neg_true,behDiff,'tail','left');
[r_glm,p_glm] = corr(pred_glm_true,behDiff,'tail','right');
fprintf('pos: r=%.3f,p=%.3g\n',r_pos,p_pos);
fprintf('neg: r=%.3f,p=%.3g\n',r_neg,p_neg);
fprintf('glm: r=%.3f,p=%.3g\n',r_glm,p_glm);

%% Correlate performance and FC on 2 blocks of same task
% Load GradCPT Network
load('/data/jangrawdc/PRJ03_SustainedAttention/Results/GradCptNetwork_p01.mat');

nEdges = numel(VectorizeFc(FC(:,:,1,1)));
[fcBlockCorr,behBlockCorr] = deal(nan(1,numel(behTasks)));
FcIcc_2part = nan(nEdges,numel(behTasks));
normByN=1;
fprintf('===1st vs 2nd block correlations\n');
for j=1:numel(behTasks)
    iOkTask = find(strncmp(behTasks{j},taskNames,length(behTasks{j})));
    behBlockCorr(j) = corr(behavior_avg_PC(:,iOkTask(1)),behavior_avg_PC(:,iOkTask(2)));
    
    Fc1_vec = VectorizeFc(squeeze(FC(:,:,iOkTask(1),:)));
    Fc2_vec = VectorizeFc(squeeze(FC(:,:,iOkTask(2),:)));
    for i=1:size(Fc1_vec,1)
        MSb = mean(var([Fc1_vec(i,:); Fc2_vec(i,:)],normByN,2)); % between-subject variance
        MSw = mean(var([Fc1_vec(i,:); Fc2_vec(i,:)],normByN,1)); % within-subject variance

        FcIcc_2part(i,j) = (MSb-MSw)/(MSb+MSw);
    end
    
    Fc1_score = GetFcTemplateMatch(squeeze(FC(:,:,iOkTask(1),:)),gradCptNetwork_p01,[],false,'meanmult')';
    Fc2_score = GetFcTemplateMatch(squeeze(FC(:,:,iOkTask(2),:)),gradCptNetwork_p01,[],false,'meanmult')';
    fcBlockCorr(j) = corr(Fc1_score,Fc2_score);
    fprintf('%s: beh = %.3f, GradCPT = %.3f, FcIcc = %.3f\n',behTasks{j},behBlockCorr(j),fcBlockCorr(j), nanmean(FcIcc_2part(:,j)));
end

FcIcc_2part = nanmean(FcIcc_2part,1);

figure(724); clf;
bar(behBlockCorr)
set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks);
ylabel('correlation of behavior between 1st & 2nd block')

