function [P,Rsq,pred_pos,pred_neg,pred_glm,behav] = TestRosenbergPredictions_CogStates_Natasha(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,behTasks,doPlot)
% TestRosenbergPredictions_CogStates_Natasha.m
%
% Adapted by DJ from leave1out_prediction.m, which is:
% Copyright 2015 Monica Rosenberg, Emily Finn, and Dustin Scheinost
% Created 10/17 by DJ based on leave1out_prediction_Distraction.m.
% leave1out_prediction_CogStates Created 11/21/16 by DJ based on
% CompareRosenbergAndOverlapPrediction.m
% TestRosenbergPredictions_CogStates Created 11/22/16 based on that code
% adapted for the existing Rosenberg networks.
% TestRosenbergPredictions_CogStates_Fast does the same thing with
% pre-loaded FC and networks.
%
% Updated 11/28/16 by DJ - fixed GLM output to be match with pos-neg mask
% Updated 12/5/16 by DJ - copied from _Fast to _Natasha

%% Declare constants
if ~exist('taskNames','var') || isempty(taskNames)
    taskNames = {'REST01-001','BACK01-001','VIDE01-001','MATH01-001','BACK02-001','REST02-001','MATH02-001','VIDE02-001'};
end
if ~exist('doRand','var') || isempty(doRand)
    doRand = false; % Randomize FC matrix elements (separately for each subject)
end
if ~exist('doRandBeh','var') || isempty(doRandBeh)
    doRandBeh = false; % Randomize behavior between subjects
end
if ~exist('fcTasks','var') || isempty(fcTasks)
    fcTasks = {'REST','BACK','VIDE','MATH'};
end
if ~exist('behTasks','var') || isempty(behTasks)
    behTasks = {'BACK','VIDE','MATH'};
end
if ~exist('doPlot','var') || isempty(doPlot)
    doPlot = false;
end

%% Compile and average across tasks
FCavg = GetAvgFcAcrossTasks(FC,fcTasks,taskNames);

%% Get behavior
% Get requested tasks
isOkTask = false(size(FC,3),1);
for i=1:numel(behTasks)
    isOkTask = isOkTask | strncmp(behTasks{i},taskNames,length(behTasks{i}));
end
%Average PC and RT
fracCorrect = nanmean(behavior_avg_PC(:,isOkTask),2);
% RT_avg = nanmean(behavior_avg_RT(:,isOkTask)');


%% Get atlas & attention networks
rosePos = attnNets.pos_overlap; % Rosenberg high-attention network
roseNeg = attnNets.neg_overlap; % Rosenberg low-attention network
glmWeights = attnNets.robGLM_fit;

%% Get scores
if doRand
    fprintf('===RANDOMIZING...===\n');
    FCrand = RandomizeFc(FCavg);
    FCmat = FCrand;
else
    FCmat = FCavg;
end
% FCmat(isnan(FCmat)) = 0; % just zero out NaNs to make them uninformative
FCmat(isinf(FCmat) & FCmat>0) = max(FCmat(~isinf(FCmat)));
FCmat(isinf(FCmat) & FCmat<0) = min(FCmat(~isinf(FCmat)));
nSubj = size(FCmat,3);
isOkSubj = true(1,nSubj);%    squeeze(sum(sum(isnan(FCmat),1),2)==0); % remove any subjects that are all zeros

test_mats  = FCmat(:,:,isOkSubj);                   % training data (n_node x n_node x n_sub symmetrical connectivity matrices)
if doRandBeh
    fprintf('===RANDOMIZING BEHAVIOR...===\n');
    fracCorrect_rand = fracCorrect(isOkSubj);
    fracCorrect_rand = fracCorrect_rand(randperm(numel(fracCorrect_rand)));
    behav       = fracCorrect_rand;                   % n_sub x 1 vector of behavior
else
    behav       = fracCorrect(isOkSubj);                   % n_sub x 1 vector of behavior
end
n_sub       = size(test_mats,3); % number of subjects

[pred_pos, pred_neg, pred_glm] = deal(nan(size(behav)));
for i=1:n_sub
    pred_pos(i) = GetFcTemplateMatch(test_mats(:,:,i),rosePos,[],false,'meanmult');
    pred_neg(i) = GetFcTemplateMatch(test_mats(:,:,i),roseNeg,[],false,'meanmult');
%     pred_glm(i) = (glmWeights(2)*pred_pos(i) + glmWeights(3)*pred_neg(i))/sum(glmWeights(2:3))/2; % normalize to put on same scale
    pred_glm(i) = GetFcTemplateMatch(test_mats(:,:,i),rosePos-roseNeg,[],false,'meanmult');
end

%% Use overlap matrices to predict behavior

% Correlate
% [r_pos,p_pos] = corr(behav, pred_pos);
% [r_neg,p_neg] = corr(behav, pred_neg);
% [r_glm,p_glm] = corr(behav, pred_glm);

P = nan(1,3);
Rsq = nan(1,3);

lm1 = fitlm(behav,pred_pos,'Linear','VarNames',{'fracCorrect','PosNetworkPrediction'}); % least squares
[P_this,F,d] = coefTest(lm1);
if lm1.Coefficients.Estimate(2)>0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm1.Rsquared.Adjusted;
fprintf('Pos: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(1) = P_this; Rsq(1) = Rsq_this;

lm2 = fitlm(behav,pred_neg,'Linear','VarNames',{'fracCorrect','NegNetworkPrediction'}); % least squares
[P_this,F,d] = coefTest(lm2);
if lm2.Coefficients.Estimate(2)<0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm2.Rsquared.Adjusted;
fprintf('Neg: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(2) = P_this; Rsq(2) = Rsq_this;

lm3 = fitlm(behav,pred_glm,'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
[P_this,F,d] = coefTest(lm3);
if lm3.Coefficients.Estimate(2)>0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm3.Rsquared.Adjusted;
fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(3) = P_this; Rsq(3) = Rsq_this;

if doPlot
    subplot(1,3,1);
    lm1.plot;
    title(sprintf('Positive Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(1),P(1)));
    xlabel('Observed Behavior')
    ylabel(sprintf('Pos Mask Total'))

    subplot(1,3,2);
    lm2.plot;
    title(sprintf('Negative Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(2),P(2)));
    xlabel('Observed Behavior')
    ylabel(sprintf('Neg Mask Total'))

    subplot(1,3,3);
    lm3.plot;
    title(sprintf('Combined Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(3),P(3)));
    xlabel('Observed Behavior')
    ylabel(sprintf('Pos-Neg Mask Total'))

end

