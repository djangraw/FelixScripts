function [pred_pos,pred_neg,pred_glm] = ...
    TestRosenbergPredictions_CogStates(subjects,doRandBeh)
% TestRosenbergPredictions_CogStates.m
%
% Adapted by DJ from leave1out_prediction.m, which is:
% Copyright 2015 Monica Rosenberg, Emily Finn, and Dustin Scheinost
% Created 10/17 by DJ based on leave1out_prediction_Distraction.m.
% leave1out_prediction_CogStates Created 11/21/16 by DJ based on
% CompareRosenbergAndOverlapPrediction.m
% TestRosenbergPredictions_CogStates Created 11/22/16 based on that code
% adapted for the existing Rosenberg networks.

% Declare constants
doRandBeh = true;
doRand = false; % Randomize FC matrix elements (separately for each subject)
% doRandBeh = false; % Randomize behavior between subjects
demeanTs = true;
separateTasks = true;
% fcTasks = {'MATH'};
fcTasks = {'REST','BACK','VIDE','MATH'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};

%% Get FC matrices
nSubj = numel(subjects);
FCtmp = GetFcForCogStateData(subjects(1),separateTasks,demeanTs);
FC = nan([size(FCtmp),nSubj]);
winInfo_cell = cell(1,nSubj);
for i=1:nSubj
    [FC(:,:,:,i),winInfo_cell{i}] = GetFcForCogStateData(subjects(i),separateTasks,demeanTs);
end

%% Compile and average across tasks
winInfo = [winInfo_cell{:}];
% isOkTask = ismember(winInfo(1).winNames,{'REST01-001','REST02-001','BACK01-001','BACK02-001','VIDE01-001','VIDE02-001'});
taskNames = winInfo(1).winNames;
FCavg = GetAvgFcAcrossTasks(FC,fcTasks,taskNames);

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
% Get requested tasks
isOkTask = true(1,size(FC,3));
for i=1:numel(taskNames)
    isOkTask(i) = any(strncmp(taskNames{i},behTasks,4));
end
%Average PC and RT
PC_avg = nanmean(behavior_avg_PC(:,isOkTask)');
RT_avg = nanmean(behavior_avg_RT(:,isOkTask)');

fracCorrect = PC_avg';


%% Get atlas & attention networks
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);
% Get Rosenberg Hi/Low-Attn matrices
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_model_268.mat');
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
    pred_glm(i) = (glmWeights(2)*pred_pos(i) + glmWeights(3)*pred_neg(i))/sum(glmWeights(2:3))/2; % normalize to put on same scale
end

%% Use overlap matrices to predict behavior

% Correlate
[r_pos,p_pos] = corr(behav, pred_pos);
[r_neg,p_neg] = corr(behav, pred_neg);
[r_glm,p_glm] = corr(behav, pred_glm);

figure(623); clf;
set(gcf,'Position',[96 652 1294 438]);
% Plot results
ax(1) = subplot(1,3,1);
lm = fitlm(behav,pred_pos,'Linear','VarNames',{'fracCorrect','PosNetworkPrediction'}); % least squares
lm.plot; % plot line & CI
% scatter(behav, pred_pos)
[p,F,d] = coefTest(lm);
p = p/2; % one-tailed test
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Positive Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq,p));
xlabel('Observed Behavior')
ylabel(sprintf('Reading Pos Mask Total (%s method)',fit_method))
% axis equal

ax(2) = subplot(1,3,2);
lm = fitlm(behav,pred_neg,'Linear','VarNames',{'fracCorrect','NegNetworkPrediction'}); % least squares
lm.plot; % plot line & CI
% scatter(behav, pred_neg)
[p,F,d] = coefTest(lm);
p = p/2; % one-tailed test
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Negative Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq,p));
xlabel('Observed Behavior')
ylabel(sprintf('Reading Neg Mask Total (%s method)',fit_method))
% axis equal

ax(3) = subplot(1,3,3);
lm = fitlm(behav,pred_glm,'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
lm.plot; % plot line & CI
% scatter(behav, pred_glm)
[p,F,d] = coefTest(lm);
p = p/2; % one-tailed test
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('GLM Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq,p));
xlabel('Observed Behavior')
ylabel(sprintf('Reading combined GLM Total (%s method)',fit_method))
% axis equal


linkaxes(ax,'xy')
titleStr = sprintf('Normed FC, threshold p<%.3g',thresh);
if doRand
   titleStr = ['RANDOMIZED ' titleStr];
end
if doRandBeh
    titleStr = ['RANDOMIZED BEHAVIOR, ' titleStr];    
end
if demeanTs
    titleStr = ['Demeaned TS, ' titleStr];
end
titleStr = ['Rosenberg Networks, ' titleStr];
MakeFigureTitle(titleStr,0);
