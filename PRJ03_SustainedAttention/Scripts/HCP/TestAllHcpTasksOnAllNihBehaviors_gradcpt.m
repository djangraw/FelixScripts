% TestAllHcpTasksOnAllNihBehaviors_gradcpt.m
%
% Created 1/16/18 by DJ based on TestAllHcpTasksOnAllNihBehaviors.

%% Get HCP Data from all tasks
tasks = {'emotion','gambling','language','motor','relational','rest1','rest2','social','wm'};
useEqualTrs = false;% true;

% Get GradCPT Network
cd /data/jangrawdc/PRJ03_SustainedAttention/Results
foo = load('ReadingAndGradcptNetworks_optimal.mat');
gradcptNetwork = foo.gradcptNetwork;
gradcptNetwork_vec = VectorizeFc(gradcptNetwork);

% Load behavior
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/FromEmily
% info = readtable('unrestricted_esfinn_7_14_2016_8_52_0.csv');
% beh = [info.PicSeq_Unadj, info.CardSort_Unadj, info.Flanker_Unadj, info.PicVocab_Unadj, info.ProcSpeed_Unadj, info.ListSort_Unadj, info.ReadEng_Unadj, info.PMAT24_A_CR];  
% behNames = {'Pic Seq (ep mem)','Card Sort (cog flex)','Flanker (inhib)','Pic Vocab (lang)','Pattern Compl (proc speed)','List Sort (WM)','Oral Reading Recog', 'PMAT (IQ)'};
[info, beh, behNames] = LoadHcpBehavior();

% Load FC matrices
foo = load(sprintf('HCP900_%s_mats',tasks{1}),'HCP900_sub_id');
nSubj = numel(foo.HCP900_sub_id);
[isIncompleteSubj_0, gradcptScore, hcpMotion] = deal(nan(nSubj,numel(tasks)));
for i=1:numel(tasks)
    fprintf('Task %d/%d...\n',i,numel(tasks));
    if useEqualTrs
        foo = load(sprintf('HCP900_%s_mats_176TRs',tasks{i}));
    else
        foo = load(sprintf('HCP900_%s_mats',tasks{i}));
    end
    hcpMats = foo.(sprintf('HCP900_%s_mats',tasks{i}));
    hcpVecs = VectorizeFc(hcpMats);    
    hcpSubj = foo.HCP900_sub_id;
    % Get gradcpt scores
    gradcptScore(:,i) = hcpVecs'*gradcptNetwork_vec/sum(gradcptNetwork_vec~=0);
    isIncompleteSubj_0(:,i) = all(hcpVecs==0)' | any(isnan(hcpVecs))';
    % Load Motion Data
    foo = load(sprintf('HCP900_%s_motion',tasks{i}));
    hcpMotion(:,i) = foo.(sprintf('HCP900_%s_motion',tasks{i}));
end

% Remove subjs with incomplete data
behSubj = info.Subject;
[~,iSubj] = ismember(hcpSubj,behSubj);
beh_oksubj = beh(iSubj,:);
isIncompleteSubj = any(isIncompleteSubj_0,2)' | any(isnan(beh_oksubj),2)' | any(isnan(hcpMotion),2)';
beh_oksubj_crop = beh_oksubj(~isIncompleteSubj,:);
readScore_oksubj_crop = gradcptScore(~isIncompleteSubj,:);
mot_oksubj_crop = hcpMotion(~isIncompleteSubj,:);

%% Use GradCPT Network on task data to Predict all behaviors from single task
climits = [-0.12, 0.22];
corrtype = 'Spearman';%'Pearson';
% Correlate with gradcpt scores
[r_true,p_true,r_partbeh,p_partbeh,r_partmot,p_partmot,r_partboth,p_partboth] = deal(nan(numel(tasks),size(beh_oksubj_crop,2)));
iControl = find(strcmp(behNames,'PMAT (IQ)'));
for i=1:numel(tasks)
    for j=1:size(beh_oksubj_crop,2)
        [r_true(i,j),p_true(i,j)] = corr(readScore_oksubj_crop(:,i), beh_oksubj_crop(:,j),'tail','right','type',corrtype);
        [r_partbeh(i,j),p_partbeh(i,j)] = partialcorr(readScore_oksubj_crop(:,i), beh_oksubj_crop(:,j),beh_oksubj_crop(:,iControl),'tail','right','type',corrtype);
        [r_partmot(i,j),p_partmot(i,j)] = partialcorr(readScore_oksubj_crop(:,i), beh_oksubj_crop(:,j),mot_oksubj_crop(:,i),'tail','right','type',corrtype);
        [r_partboth(i,j),p_partboth(i,j)] = partialcorr(readScore_oksubj_crop(:,i), beh_oksubj_crop(:,j),[beh_oksubj_crop(:,iControl), mot_oksubj_crop(:,i)],'tail','right','type',corrtype);
    end
end
% q_true = p_true*numel(p_true); % bonf
q_true = reshape(mafdr(p_true(:),'bhfdr',true),size(p_true));
q_partbeh = reshape(mafdr(p_partbeh(:),'bhfdr',true),size(p_true));
q_partmot = reshape(mafdr(p_partmot(:),'bhfdr',true),size(p_true));
q_partboth = reshape(mafdr(p_partboth(:),'bhfdr',true),size(p_true));

figure(634); clf; 
subplot(2,2,1); hold on;
imagesc(r_true);
[iSig,jSig] = find(q_true<0.05);
plot(jSig,iSig,'k*');
set(gca,'xtick',1:numel(behNames),'xticklabel',behNames,'ytick',1:numel(tasks),'yticklabel',tasks);
set(gca,'clim',climits);
title(sprintf('Ability of GradCPT Network Score (from fMRI task) to Predict Behavior\n(Correlation with GradCPT Network Score)'));
axis([0 numel(behNames) 0 numel(tasks)]+0.5);
xticklabel_rotate([],45);
xlabel('behavior')
ylabel('fMRI task');
colorbar

subplot(2,2,2); hold on;
imagesc(r_partbeh);
[iSig,jSig] = find(q_partbeh<0.05);
plot(jSig,iSig,'k*');
set(gca,'xtick',1:numel(behNames),'xticklabel',behNames,'ytick',1:numel(tasks),'yticklabel',tasks);
set(gca,'clim',climits);
title(sprintf('Partial Correlation of Behavior with GradCPT Network Score,\n controlling for %s)',behNames{iControl}));
axis([0 numel(behNames) 0 numel(tasks)]+0.5);
xticklabel_rotate([],45);
xlabel('behavior')
ylabel('fMRI task');
colorbar

subplot(2,2,3); hold on;
imagesc(r_partmot);
[iSig,jSig] = find(q_partmot<0.05);
plot(jSig,iSig,'k*');
set(gca,'xtick',1:numel(behNames),'xticklabel',behNames,'ytick',1:numel(tasks),'yticklabel',tasks);
set(gca,'clim',climits);
title(sprintf('Partial Correlation of Behavior with GradCPT Network Score,\n controlling for motion'));
axis([0 numel(behNames) 0 numel(tasks)]+0.5);
xticklabel_rotate([],45);
xlabel('behavior')
ylabel('fMRI task');
colorbar

subplot(2,2,4); hold on;
imagesc(r_partboth);
[iSig,jSig] = find(q_partboth<0.05);
plot(jSig,iSig,'k*');
set(gca,'xtick',1:numel(behNames),'xticklabel',behNames,'ytick',1:numel(tasks),'yticklabel',tasks);
set(gca,'clim',climits);
title(sprintf('Partial Correlation of Behavior with GradCPT Network Score,\n controlling for motion and %s)',behNames{iControl}));
axis([0 numel(behNames) 0 numel(tasks)]+0.5);
xticklabel_rotate([],45);
xlabel('behavior')
ylabel('fMRI task');
legend('q<0.05');
colorbar

if useEqualTrs
    MakeFigureTitle(sprintf('FC derived from first 176 TRs of each task (%s correlation)',corrtype));
else
    MakeFigureTitle(sprintf('FC derived from all TRs of each task (%s correlation)',corrtype));
end

%% Look at difference in FC in GradCPT Network Edges

% Find top and bottom 1/3 of oral reading performers
nSubj_crop = size(beh_oksubj_crop,1);
iReadBeh = find(strcmp(behNames,'Oral Reading Recog'));
[~,iSorted] = sort(beh_oksubj_crop(:,iReadBeh),'descend');
iTop = iSorted(1:floor(nSubj_crop/3)); % top 1/3
iBottom = iSorted(end-numel(iTop)+1:end); % bottom 1/3

% Find +/- edges
isPosEdge = gradcptNetwork_vec>0;
isNegEdge = gradcptNetwork_vec<0;

% Get FC
nEdges = numel(gradcptNetwork_vec);
[hcpVecs_mean_top, hcpVecs_mean_bot, hcpVecs_mean_all] = deal(nan(nEdges,numel(tasks)));
[FC_top_pos, FC_bot_pos, FC_all_pos] = deal(nan(sum(isPosEdge),numel(tasks)));
[FC_top_neg, FC_bot_neg, FC_all_neg] = deal(nan(sum(isNegEdge),numel(tasks)));
for i=1:numel(tasks)
    fprintf('Task %d/%d...\n',i,numel(tasks));
    if useEqualTrs
        foo = load(sprintf('HCP900_%s_mats_176TRs',tasks{i}));
    else
        foo = load(sprintf('HCP900_%s_mats',tasks{i}));
    end
    hcpMats = foo.(sprintf('HCP900_%s_mats',tasks{i}));
    hcpVecs = VectorizeFc(hcpMats);    
    hcpSubj = foo.HCP900_sub_id;
    % Get mean FC in top/bottom performers
    hcpVecs_crop = hcpVecs(:,~isIncompleteSubj);
    hcpVecs_mean_top(:,i) = mean(hcpVecs_crop(:,iTop),2);
    hcpVecs_mean_bot(:,i) = mean(hcpVecs_crop(:,iBottom),2);
    hcpVecs_mean_all(:,i) = mean(hcpVecs_crop(:,:),2);
    
    
    % Plot FC in +/- edges    
    FC_top_pos(:,i) = hcpVecs_mean_top(isPosEdge,i);
    FC_top_neg(:,i) = hcpVecs_mean_top(isNegEdge,i);
    FC_bot_pos(:,i) = hcpVecs_mean_bot(isPosEdge,i);
    FC_bot_neg(:,i) = hcpVecs_mean_bot(isNegEdge,i);
    FC_all_pos(:,i) = hcpVecs_mean_all(isPosEdge,i);
    FC_all_neg(:,i) = hcpVecs_mean_all(isNegEdge,i);

end

%% Plot FC in 2D?
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc.BRIK');
figure(236); clf;
avgscale = 10;
diffscale = 50;
for i=1:numel(tasks)
    % mean across subjs (pos)
    FcVec = zeros(nEdges,1);
    FcVec(isPosEdge) = FC_all_pos(:,i);
    FC = UnvectorizeFc(FcVec,0,true);
    subplot(ceil(numel(tasks)/2),4,2*i-1);
    VisualizeFcIn2d(FC*avgscale,shenAtlas,shenLabels_hem,shenColors_hem,[],shenInfo.Orientation, 'top');
    title(sprintf('%s task, mean across subjects',tasks{i}));
    % diff btw top & bot performers (pos edges)
    FcVec(isPosEdge) = FC_top_pos(:,i) - FC_bot_pos(:,i);
    FC = UnvectorizeFc(FcVec,0,true);
    subplot(ceil(numel(tasks)/2),4,2*i);
    VisualizeFcIn2d(FC*diffscale,shenAtlas,shenLabels_hem,shenColors_hem,[],shenInfo.Orientation, 'top');
    title(sprintf('%s task, top-bot 1/3 of subjects',tasks{i}));
    drawnow;
end
MakeFigureTitle('GradCPT Network Positive Edges');
%%
figure(237); clf;
avgscale = 10;
diffscale = 50;
for i=1:numel(tasks)
    % mean across subjs (pos)
    FcVec = zeros(nEdges,1);
    FcVec(isNegEdge) = FC_all_neg(:,i);
    FC = UnvectorizeFc(FcVec,0,true);
    subplot(ceil(numel(tasks)/2),4,2*i-1);
    VisualizeFcIn2d(FC*avgscale,shenAtlas,shenLabels_hem,shenColors_hem,[],shenInfo.Orientation, 'top');
    title(sprintf('%s task, mean across subjects',tasks{i}));
    % diff btw top & bot performers (pos edges)
    FcVec(isNegEdge) = FC_top_neg(:,i) - FC_bot_neg(:,i);
    FC = UnvectorizeFc(FcVec,0,true);
    subplot(ceil(numel(tasks)/2),4,2*i);
    VisualizeFcIn2d(FC*diffscale,shenAtlas,shenLabels_hem,shenColors_hem,[],shenInfo.Orientation, 'top');
    title(sprintf('%s task, top-bot 1/3 of subjects',tasks{i}));
    drawnow;
end
MakeFigureTitle('GradCPT Network Negative Edges');

%% Show histograms for each task
xHist_avg = linspace(-.5,.5,16);
xHist_diff = linspace(-.1,.1,16);
iLangTask = find(strcmp(tasks,'language'));
% nHist = nan(numel(xHist),numel(tasks));
nHist_all_pos = hist(FC_all_pos,xHist_avg);
nHist_all_neg = hist(FC_all_neg,xHist_avg);
nHist_diff_pos = hist(FC_top_pos-FC_bot_pos,xHist_diff);
nHist_diff_neg = hist(FC_top_neg-FC_bot_neg,xHist_diff);
figure(663); clf;
subplot(2,2,1); hold on;
plot(xHist_avg,nHist_all_neg,'.-');
plot(xHist_avg,nHist_all_neg(:,iLangTask),'y.-','LineWidth',2);
xlabel('mean FC in edge')
ylabel('# negative edges')
subplot(2,2,2); hold on;
plot(xHist_avg,nHist_all_pos,'.-');
plot(xHist_avg,nHist_all_pos(:,iLangTask),'y.-','LineWidth',2);
xlabel('mean FC in edge')
ylabel('# positive edges')
subplot(2,2,3); hold on;
plot(xHist_diff,nHist_diff_neg,'.-');
plot(xHist_diff,nHist_diff_neg(:,iLangTask),'y.-','LineWidth',2);
xlabel(sprintf('mean FC difference in edge\n(top-bottom reading recog performers)'))
ylabel('# negative edges')
subplot(2,2,4); hold on;
plot(xHist_diff,nHist_diff_pos,'.-');
plot(xHist_diff,nHist_diff_pos(:,iLangTask),'y.-','LineWidth',2);
xlabel(sprintf('mean FC difference in edge\n(top-bottom reading recog performers)'))
ylabel('# positive edges')
legend(tasks)


