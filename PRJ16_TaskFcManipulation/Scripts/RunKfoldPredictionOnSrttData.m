% RunKfoldPredictionOnSrttData.m
%
% Created 11/7/17 by DJ.

load('/data/jangrawdc/PRJ16_TaskFcManipulation/Results/FC_wholerun_2017-09-01.mat','FC_wholerun','fullTs');
FC_fisher = atanh(FC_wholerun);
FC_fisher_vec = VectorizeFc(FC_fisher);
FC_fisher_vec = FC_fisher_vec-repmat(mean(FC_fisher_vec,1),size(FC_fisher_vec,1),1);
FC_fisher = UnvectorizeFc(FC_fisher_vec,0,true);
% Get matching behavior
fcSubj = nan(1,numel(fullTs));
for i=1:numel(fcSubj)
    fcSubj(i) = str2double(fullTs{i}(3:end));
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

