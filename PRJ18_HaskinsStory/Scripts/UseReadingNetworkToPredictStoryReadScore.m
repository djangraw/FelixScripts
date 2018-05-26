% UseReadingNetworkToPredictStoryReadScore.m
%
% Created 5/25/28 by DJ.

% Get subjects
info = GetStoryConstants();

%% Get Reading Scores
[subj_sorted,readScore_sorted] = GetStoryReadingScores();
isOkSubj = ismember(subj_sorted,info.okReadSubj);
subj_sorted = subj_sorted(isOkSubj);
readScore_sorted = readScore_sorted(isOkSubj);

%% Get FC
[FC_wholerun, FC_taskonly] = GetFc_Story_wholerun(subj_sorted);
FC_wholerun(isnan(FC_wholerun)) = 0;
FC_taskonly(isnan(FC_taskonly)) = 0;
%% Load reading network
foo = load('/data/jangrawdc/PRJ03_SustainedAttention/Results/ReadingAndGradcptNetworks_optimal.mat');
readingNetwork = foo.readingNetwork;
readingNetwork_vec = VectorizeFc(readingNetwork);
clear foo

%% Get predicted reading scores
FC_fisher = atanh(FC_wholerun);
FC_fisher(isinf(FC_fisher)) = max(FC_fisher(~isinf(FC_fisher)))*sign(FC_fisher(isinf(FC_fisher)));
storyFcVecs = VectorizeFc(FC_fisher);
readScore_predicted = storyFcVecs'*readingNetwork_vec/sum(readingNetwork_vec~=0);

%% Correlate with actual reading score
lm = fitlm(readScore_sorted,readScore_predicted,'VarNames',{'ReadingPC1','ReadingNetworkScore'});
figure(46);
lm.plot();
[r_readnet,p_readnet] = corr(readScore_sorted',readScore_predicted);
fprintf('r_readnet = %.3g, p_readnet = %.3g\n',r_readnet,p_readnet);
title(sprintf('Reading Network Predictions: r=%.3g, p=%.3g',r_readnet,p_readnet));

%% Try CPM with training/testing split

[r_train,p_train,r_test,p_test,pos_mask_all,neg_mask_all] = ...
    RunCpmWithTrainTestSplit(FC_fisher,readScore_sorted');
fprintf('r_train = %.3g, p_train = %.3g\n', r_train,p_train);
fprintf('r_test = %.3g, p_test = %.3g\n', r_test,p_test);

%% Try with LOO CV
corr_method = 'robustfit';
mask_method = 'one'; 
thresh = 0.01; 
[pred_pos, pred_neg, pred_combo,pos_mask_all,neg_mask_all] = RunLeave1outBehaviorRegression(FC_fisher,readScore_sorted,thresh,corr_method,mask_method);
[r_loo,p_loo] = corr(pred_combo,readScore_sorted','tail','right');
fprintf('LOO CV: r=%.3g, p=%.3g\n',r_loo,p_loo);
