% RunCpmOnAdamSteelSrttData.m
%
% Created 11/7/17 by DJ.

% Load data
load('/data/jangrawdc/PRJ16_TaskFcManipulation/AdamSteelData/workspace06112018.mat','SRTT','FTT');

%% Extract info
FC = mean(cat(4,SRTT.corrMat{:}),4); % mean across runs
FC_fisher = atanh(FC);
FC_fisher(isinf(FC_fisher)) = max(abs(FC_fisher(~isinf(FC_fisher))))*sign(FC_fisher(isinf(FC_fisher)));
behav = SRTT.diffRun4RT; % RT difference between sequential & random blocks in run 4
behav1 = SRTT.diffRun1RT; % RT difference between sequential & random blocks in run 4

behav([7 9]) = []; % remove all-NaN FC subjects
behav1([7 9]) = []; % remove all-NaN FC subjects
FC_fisher(:,:,[7 9]) = []; % remove all-NaN FC subjects

%% Run CV
thresh = 0.1;
corr_method = 'robustfit';
% mask_method = 'one';
% nFolds = 10;
% [pred_pos, pred_neg, pred_glm,pos_mask_all,neg_mask_all] = ...
%     RunKfoldBehaviorRegression(FC_fisher,behav,thresh,corr_method,mask_method,nFolds);

% mask_method = 'cpcr';
% [~,~,~,cp_loo,cr_loo] = ...
%     RunLeave1outBehaviorRegression(FC_fisher,behav,thresh,corr_method,mask_method);

mask_method = 'cpcr';
[~,~,~,cp_loo1,cr_loo1] = ...
    RunLeave1outBehaviorRegression(FC_fisher,behav1,thresh,corr_method,mask_method);


%% Eval results

% P value thresholds for including an edge in the network
thresholds = .01:.01:1;
% Sweep threshold and calculate mask size and predictive ability for each
% [maskSizePos,maskSizeNeg,Rsq,p,r] = SweepRosenbergThresholds(cp_loo,cr_loo,FC_fisher,behav,thresholds,false);
[maskSizePos1,maskSizeNeg1,Rsq1,p1,r1] = SweepRosenbergThresholds(cp_loo1,cr_loo1,FC_fisher,behav1,thresholds,false);

figure(1); clf;
plot(maskSizePos1+maskSizeNeg1,r1(:,4));

% For single-threshold
% [r_run4,p_run4] = corr(pred_glm,behav);
% fprintf('run 4 RT diff: r=%.3f, p=%.3g\n',r_run4,p_run4);
