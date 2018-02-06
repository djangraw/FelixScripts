% RunKfoldPredictionOnSrttData.m
%
% Created 11/7/17 by DJ.

% load('/data/jangrawdc/PRJ16_TaskFcManipulation/Results/FC_wholerun_2017-09-01.mat','FC_wholerun','fullTs');
% subjects = fullTs;
load('/data/jangrawdc/PRJ16_TaskFcManipulation/Results/FC_wholerun_2018-02-05.mat','FC_wholerun','subjects');
FC_fisher = atanh(FC_wholerun);
FC_fisher_vec = VectorizeFc(FC_fisher);
FC_fisher_vec = FC_fisher_vec-repmat(mean(FC_fisher_vec,1),size(FC_fisher_vec,1),1);
FC_fisher = UnvectorizeFc(FC_fisher_vec,0,true);
% Get matching behavior
fcSubj = nan(1,numel(subjects));
for i=1:numel(fcSubj)
    fcSubj(i) = str2double(subjects{i}(3:end));
end

%% Load SRTT behavior
filename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
fprintf('Loading reading behavior...\n');
behTable = ReadSrttBehXlsFile(filename);
fprintf('Done!\n');
behSubj = str2double(behTable.Properties.RowNames)';

%% match subjects
isOkSubj_beh = ismember(behSubj,fcSubj);
isOkSubj_fc = ismember(fcSubj,behSubj);
FC_match = FC_fisher(:,:,isOkSubj_fc);
isR3 = strncmp(behTable.Properties.VariableNames,'RT_R3',5);
isR1 = strncmp(behTable.Properties.VariableNames,'RT_R1',5);
isRTD = strncmp(behTable.Properties.VariableNames,'RT_Final_UnsMinus',5);
behav = mean(table2array(behTable(:,isR3)),2); % mean across all run 3 
behav31 = mean(table2array(behTable(:,isR3)),2) - mean(table2array(behTable(:,isR1)),2); % mean across all run 3 - run 1
behavRTD = mean(table2array(behTable(:,isRTD)),2); % mean across all run 3 
behav_match = behav(isOkSubj_beh);
behav_match31 = behav31(isOkSubj_beh);
behav_matchRTD = behavRTD(isOkSubj_beh);
FC_match(:,:,isnan(behav_match)) = [];
behav_match31(isnan(behav_match)) = [];
behav_matchRTD(isnan(behav_match)) = [];
behav_match(isnan(behav_match)) = [];
%% Run CV
thresh = 0.01;
nFolds = 10;
corr_method = 'robustfit'; %'corr'; %
mask_method = 'one';
[pred_pos, pred_neg, pred_glm,pos_mask_all,neg_mask_all] = RunKfoldBehaviorRegression(FC_match,behav_match,thresh,corr_method,mask_method,nFolds);

[pred_pos31, pred_neg31, pred_glm31,pos_mask_all31,neg_mask_all31] = RunKfoldBehaviorRegression(FC_match,behav_match31,thresh,corr_method,mask_method,nFolds);

[pred_posRTD, pred_negRTD, pred_glmRTD, pos_mask_allRTD, neg_mask_allRTD] = RunKfoldBehaviorRegression(FC_match,behav_matchRTD,thresh,corr_method,mask_method,nFolds);

%% Eval results
[r_run3,p_run3] = corr(pred_glm,behav_match,'type','Spearman');
fprintf('run 3 RT: r=%.3f, p=%.3g\n',r_run3,p_run3);
[r_run31,p_run31] = corr(pred_glm31,behav_match31,'type','Spearman');
fprintf('run 3 - run 1 RT: r=%.3f, p=%.3g\n',r_run31,p_run31);
[r_RTD,p_RTD] = corr(pred_glmRTD,behav_matchRTD,'type','Spearman');
fprintf('run Uns-Str RT: r=%.3f, p=%.3g\n',r_RTD,p_RTD);


%% Run CV With Reading Scores
[readScore,isOkSubj] = GetFirstReadingScorePc(behTable);
readScore_match = readScore(isOkSubj_beh);
FC_matchread= FC_fisher(:,:,isOkSubj_fc);
FC_matchread(:,:,isnan(readScore_match)) = [];
readScore_match(isnan(readScore_match)) = [];
[pred_pos_read, pred_neg_read, pred_glm_read,pos_mask_all_read,neg_mask_all_read] = RunKfoldBehaviorRegression(FC_matchread,readScore_match,thresh,corr_method,mask_method,nFolds);

%% Eval results
[r_read,p_read] = corr(pred_glm_read,readScore_match,'type','Spearman');
fprintf('Reading Score PC1: r=%.3f, p=%.3g\n',r_read,p_read);

%% Display regression
lm = fitlm(pred_glm_read,readScore_match);
figure(623); clf;
lm.plot();
xlabel('Mean FC in network');
ylabel('Reading Score PC #1')
title(sprintf('CPM (SRTT vs. Reading), thresh p<%g',thresh));

%% Display ROIs

mask_olap = all(pos_mask_all_read,3) - all(neg_mask_all_read,3);
h = PlotShenFcIn3d_Conn(mask_olap);
set(gcf,'Units','points','Position',[0  360  330  280]);
title(sprintf('CPM on SRTT data to predict Reading PC1, p<%g',thresh))
Save3dFcImages_Conn(h,[],'CPM_Srtt-ReadingPc1_p01');

%% CP/CR!
[~,~,~,cp_read,cr_read] = RunKfoldBehaviorRegression(FC_matchread,...
    readScore_match,thresh,corr_method,'cpcr',nFolds);
%% Sweep!
thresholds = 0.001:0.001:0.1;%0.0001:0.0001:0.01;
[maskSizePos,maskSizeNeg,Rsq,p,r,p_spearman,r_spearman] = SweepRosenbergThresholds_Kfold(cp_read,cr_read,FC_matchread,readScore_match,thresholds,true);
%% Plot results
figure(699); clf; hold on;
maskSize = maskSizePos+maskSizeNeg;
plot(maskSize,r_spearman(:,4));
lineVals = [0.005,0.01,0.05];
for i=1:numel(lineVals)
    iLine = find(thresholds>=lineVals(i),1);
    plot([1 1]*maskSize(iLine),[0 r_spearman(iLine,4)],'k--');
    plot(maskSize(iLine),r_spearman(iLine,4),'ro');
    text(maskSize(iLine),r_spearman(iLine,4)-.03,sprintf('p=%g',lineVals(i)));
end
ylim([0 0.4]);
xlabel('edges in network')
ylabel('Spearman correlation with behavior');
title('SRTT data vs. Reading PC#1: 10-fold CPM');
%% Display max
[rMax,iMax] = max(r_spearman(:,4));
fprintf('Max r=%.3g at thresh=%g, %g edges\n',rMax,thresholds(iMax),maskSize(iMax));

% Plot as 2D matrix
maskOlap = GetNetworkAtThreshold(cr_read,cp_read,thresholds(iMax));
figure(673); clf;
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels('region-hem');
PlotFcMatrix(maskOlap,[-1 1]*8,shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title(sprintf('SRTT-Reading Network (%d-fold, p<%g)',nFolds,thresholds(iMax)));
colormap jet


%% Run permutations
nPerms = 1000;
nSubj = numel(subjects);
iPerm = nan(nSubj,nPerms);
mask_method = 1;
[nPos_perm, nNeg_perm, r_perm, p_perm] = deal(nan(1,nPerms));
for i=1:nPerms 
    iPerm(:,i) = randperm(nSubj);
end
for i=1:nPerms
    fprintf('===PERM %d/%d===\n',i,nPerms);
    [~,~, pred_perm,pos_mask_perm,neg_mask_perm] = RunKfoldBehaviorRegression(FC_matchread,readScore_match(iPerm(:,i)),thresh,corr_method,mask_method,nFolds);
    nPos_perm(i) = sum(pos_mask_perm(:));
    nNeg_perm(i) = sum(neg_mask_perm(:));
    [r_perm(i),p_perm(i)] = corr(pred_perm,readScore_match(iPerm(:,i)),'type','Spearman');
end