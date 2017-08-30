% SweepThresholdOnGradCptNetwork_MultiTaskData.m
%
% Created 6/20/17 by DJ.

%% Load GradCPT Network and multi-task data
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

% Get behavior
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

% Get atlas & attention networks
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);
% Get Rosenberg Hi/Low-Attn matrices
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_model_268.mat');
foo = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/Rosenberg2016_weights.mat');
gradcpt_cp = UnvectorizeFc(cat(2,foo.cp{:}),0,true);
gradcpt_cr = UnvectorizeFc(cat(2,foo.cr{:}),0,true);

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
                nets(:,k) = VectorizeFc(GetNetworkAtThreshold(gradcpt_cr(:,:,k),gradcpt_cp(:,:,k),thresh));
                netStrength(k,1) = (nets(:,k)>0)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)>0);
                netStrength(k,2) = (nets(:,k)<0)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)<0);
                netStrength(k,3) = nets(:,k)'*VectorizeFc(FC_this(:,:,k))/sum(nets(:,k)~=0);
            end
            nEdgesInNet(i,j,iThresh) = sum(all(nets>0,2) | all(nets<0,2));
            [R_task(i,j,iThresh,1), P_task(i,j,iThresh,1)] = corr(beh,netStrength(:,1),'tail','right');
            [R_task(i,j,iThresh,2), P_task(i,j,iThresh,2)] = corr(beh,netStrength(:,2),'tail','left');
            [R_task(i,j,iThresh,3), P_task(i,j,iThresh,3)] = corr(beh,netStrength(:,3),'tail','right');
%             pred_pos_task(:,i,j,iThresh) = netStrength(:,1);
%             pred_neg_task(:,i,j,iThresh) = netStrength(:,2);
%             pred_glm_task(:,i,j,iThresh) = netStrength(:,3);
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
xlim([0 2000]);
% plot(thresholds, squeeze(R_task(:,:,:,3))');
% plot(squeeze(nEdgesInNet)', squeeze(R_task(:,:,:,3))');
legend([behTasks,{sprintf('p=%.3g',thresh)}]);
xlabel('# edges')
ylabel('Pearson r between network score and behavior');
title('Networks trained on GradCPT Tasks')