function [P,Rsq,pred_pos,pred_neg,pred_glm,pos_mask_all,neg_mask_all,behav] = ...
    leave1out_prediction_CogStates_Fast(FC,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,behTasks,doPlot,mask_method)

% leave1out_prediction_CogStates_Fast.m
%
% Adapted by DJ from leave1out_prediction.m, which is:
% Copyright 2015 Monica Rosenberg, Emily Finn, and Dustin Scheinost
% Created 10/17 by DJ based on leave1out_prediction_Distraction.m.
% leave1out_prediction_CogStates Created 11/21/16 by DJ based on
% CompareRosenbergAndOverlapPrediction.m
% leave1out_prediction_CogStates_Fast Created 11/23/16 by DJ - takes FC &
% behavior as input
% Updated 11/28/16 by DJ - fixed GLM coefficients to be ~pos-neg/2
% Updated 6/22/17 by DJ - added mask_method as input var

% Declare defaults
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
if ~exist('mask_method','var') || isempty(mask_method)
    mask_method = 'one'; % binary mask
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

%% Get scores
if doRand
    fprintf('===RANDOMIZING...===\n');
    FCrand = RandomizeFc(FCavg);
    FCmat = FCrand;
else
    FCmat = FCavg;
end
FCmat(isnan(FCmat)) = 0; % just zero out NaNs to make them uninformative
FCmat(isinf(FCmat) & FCmat>0) = max(FCmat(~isinf(FCmat)));
FCmat(isinf(FCmat) & FCmat<0) = min(FCmat(~isinf(FCmat)));
isOkSubj = squeeze(sum(sum(isnan(FCmat),1),2)==0); % remove any subjects that are all zeros

n_node      = 268;                % number of nodes
thresh      = 0.05;               % p-value threshold for feature selection
fit_method = 'mean'; % robustfit, sum, or mean
% thresh      = 1;               % p-value threshold for feature selection
% mask_method = 'log'; % weight = negative log of p value 
train_mats  = FCmat(:,:,isOkSubj);                   % training data (n_node x n_node x n_sub symmetrical connectivity matrices)
test_mats   = FCmat(:,:,isOkSubj);                   % testing data (This will be the same as train_mats when you're training and testing on the same data. If you are training on task matrices and testing on rest matrices, for example, train_mats and test_mats will be different.)
if doRandBeh
    fracCorrect_rand = fracCorrect(isOkSubj);
    fracCorrect_rand = fracCorrect_rand(randperm(numel(fracCorrect_rand)));
    behav       = fracCorrect_rand;                   % n_sub x 1 vector of behavior
else
    behav       = fracCorrect(isOkSubj);                   % n_sub x 1 vector of behavior
end
n_sub       = size(train_mats,3); % number of subjects
n_train_sub = n_sub-1;            % number of subjects in each round of cross-validation

pred_pos = zeros(n_sub,1);
pred_neg = zeros(n_sub,1);
pred_glm = zeros(n_sub,1);

aa     = ones(n_node,n_node);
aa_upp = triu(aa,1);
upp_id = find(aa_upp);   % indices of edges in the upper triangular of an n_node x n_node matrix
n_edge = length(upp_id); % total number of edges 

% Added by DJ
tic; % Time execution
[pos_mask_all, neg_mask_all] = deal(nan(n_node,n_node,n_sub));
mask_size_cell = cell(1,n_sub);

parfor excl_sub = 1:n_sub
    
    fprintf('Subject %d/%d...\n',excl_sub,n_sub);
    warning('off','stats:statrobustfit:IterationLimit'); % suppress this warning to speed up code
    
    % exclude data from left-out subject
    train_mats_tmp = train_mats;
    train_mats_tmp(:,:,excl_sub) = [];
    train_behav = behav;
    train_behav(excl_sub) = [];
    
    % create n_train_sub x n_edge matrix
    train_vect = reshape(train_mats_tmp, n_node*n_node, n_train_sub)';
    upp_vect   = train_vect(:,upp_id); 
    
    % relate behavior to edge strength across training subjects
    cp = zeros(n_edge, 1);
    cr = zeros(n_edge, 1);
    
    for ii = 1:n_edge
        [b,stats] = robustfit(upp_vect(:,ii), train_behav);
        cp(ii)    = stats.p(2);
        cr(ii)    = sign(stats.t(2))*sqrt((stats.t(2)^2/(n_train_sub-2))/(1+(stats.t(2)^2/(n_train_sub-2))));
    end

    % select edges based on threshold
    pos_edge = zeros(1, n_edge);
    neg_edge = zeros(1, n_edge);
    
    cp_pos           = find(cp<thresh & cr>0);
    cp_neg           = find(cp<thresh & cr<0);
    switch mask_method
        case {'one','binary'}
            pos_edge(cp_pos) = 1;
            neg_edge(cp_neg) = 1;
        case 'log'
            pos_edge(cp_pos) = -log(cp(cp_pos)) + log(thresh);
            neg_edge(cp_neg) = -log(cp(cp_neg)) + log(thresh);
        case 'cpcr' % just save out the cp and cr matrices
            pos_edge = cp';
            neg_edge = cr';
    end
    
    pos_mask = zeros(n_node, n_node);
    neg_mask = zeros(n_node, n_node);
        
    pos_mask(upp_id) = pos_edge; % Here, masks are NOT symmetrical. To make symmetrical, set pos_mask = pos_mask + pos_mask'
    neg_mask(upp_id) = neg_edge;
        
    % sum edges for training subjects
    train_pos_sum = zeros(n_train_sub,1);
    train_neg_sum = zeros(n_train_sub,1);
    
    for k = 1:n_train_sub
        train_pos_sum(k) = sum(sum(pos_mask.*train_mats_tmp(:,:,k)));
        train_neg_sum(k) = sum(sum(neg_mask.*train_mats_tmp(:,:,k)));    
    end
    
    % build model with training data
    switch fit_method
        case 'robustfit'
            b_pos      = robustfit(train_pos_sum, train_behav);
            b_neg      = robustfit(train_neg_sum, train_behav);
            robGLM_fit = robustfit([train_pos_sum train_neg_sum],train_behav);
        case 'sum'
            b_pos = [0 1];
            b_neg = [0 1];
            robGLM_fit = [0 1 -1]; 
        case 'mean'
            b_pos = [0 1]/sum(pos_mask(:));
            b_neg = [0 1]/sum(neg_mask(:));
            robGLM_fit = [0 1 -1]/(sum(pos_mask(:))+sum(neg_mask(:))); 
    end
    % generate predictions for left-out subject
    test_pos_sum = sum(sum(pos_mask.*test_mats(:,:,excl_sub)));
    test_neg_sum = sum(sum(neg_mask.*test_mats(:,:,excl_sub)));
    
    pred_pos(excl_sub) = (b_pos(2)*test_pos_sum) + b_pos(1);
    pred_neg(excl_sub) = (b_neg(2)*test_neg_sum) + b_neg(1);
    pred_glm(excl_sub) = robGLM_fit(1) + robGLM_fit(2)*test_pos_sum + robGLM_fit(3)*test_neg_sum;
     
    % Store masks and their sizes
    pos_mask_all(:,:,excl_sub) = pos_mask;
    neg_mask_all(:,:,excl_sub) = neg_mask;
    mask_size_cell{excl_sub} = [sum(pos_edge>0), sum(neg_edge>0)];
end
mask_size = cat(1,mask_size_cell{:});
t_exec = toc; % Time execution
fprintf('Done! Took %.3g seconds.\n',t_exec);



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
