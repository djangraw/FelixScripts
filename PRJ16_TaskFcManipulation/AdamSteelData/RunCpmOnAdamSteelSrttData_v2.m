% RunCpmOnAdamSteelSrttData_v2.m
%
% Created 2/9/17 by DJ.

adamData = load('/data/jangrawdc/PRJ16_TaskFcManipulation/AdamSteelData/forDaveCPM.mat');
[idx,pred_pos,pred_neg,pred_glm,masks] = ...
    RunKfoldBehaviorRegression_adam(adamData.corrMat,adamData.behav,0.01,'robustfit','one');
%% with corr
[idx_cor,pred_pos_corr,pred_neg_corr,pred_glm_corr,masks_corr] = ...
    RunKfoldBehaviorRegression_adam(adamData.corrMat,adamData.behav,0.01,'corr','one');

%% predict
[r_robust,p_robust] = corr(pred_glm,adamData.behav(idx==1))
[r_corr,p_corr] = corr(pred_glm_corr,adamData.behav(idx==1))

lm = fitlm(pred_glm_corr,adamData.behav(idx==1));
lm.plot;

%% LOO, corr

nPerms = 1000;
[p,Rsq,mask_size,mask_overlap_size,isOkSubj,fracCorrect_perm,r,r_spearman,p_spearman] = ...
    RunLeave1outPermutations(adamData.corrMat(:,:,idx>0),adamData.behav(idx>0),nPerms,'corr','one',0.01);

%% Plot hist of r & p values
figure(621); clf;
subplot(1,2,1); hold on;
hist(r(3,:),100);
PlotVerticalLines(r_corr,'r');
xlabel('correlation with behavior');
ylabel('# permutations')
legend('permutations','true data');

subplot(1,2,2); hold on;
hist(p(3,:),100);
PlotVerticalLines(p_corr,'r');
xlabel('p value of correlation');
ylabel('# permutations')
legend('permutations','true data');

%%
FcOk_vec = VectorizeFc(adamData.corrMat(:,:,idx==1));
for i=1:size(FcOk_vec,2)
    subplot(6,6,i); cla; hold on;
    hist(FcOk_vec(:,i));
    PlotVerticalLines(mean(FcOk_vec(:,i)),'r-');
end