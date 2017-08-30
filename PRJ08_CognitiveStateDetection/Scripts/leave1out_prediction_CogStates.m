function [pred_pos,pred_neg,pred_glm,pos_mask_all,neg_mask_all] = ...
    leave1out_prediction_CogStates(subjects,doRandBeh)
% leave1out_prediction_CogStates.m
%
% Adapted by DJ from leave1out_prediction.m, which is:
% Copyright 2015 Monica Rosenberg, Emily Finn, and Dustin Scheinost
% Created 10/17 by DJ based on leave1out_prediction_Distraction.m.
% leave1out_prediction_CogStates Created 11/21/16 by DJ based on
% CompareRosenbergAndOverlapPrediction.m

% Declare constants
doRand = false; % Randomize FC matrix elements (separately for each subject)
% doRandBeh = false; % Randomize behavior between subjects
demeanTs = true;
separateTasks = true;

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
isOkTask = true(1,size(FC,3));
FCavg = squeeze(nanmean(FC(:,:,isOkTask,:),3));
% FCavg(isnan(FCavg)) = 0; % just zero out NaNs to make them uninformative

% Remove ROIs missing in any subject
isBadRoi = false(1,size(FC,1));
for i=1:nSubj
    isBadRoi_this = all(isnan(FCavg(:,:,i)) | FCavg(:,:,i)==0);
    isBadRoi = isBadRoi | isBadRoi_this;
end
FCavg(isBadRoi,:,:) = NaN;
FCavg(:,isBadRoi,:) = NaN;
% FCavg(isnan(FCavg)) = 0;

%% Get behavior
nWindows = size(FC,3);
behavior_avg_RT = nan(nSubj,nWindows);
behavior_avg_PC = nan(nSubj,nWindows);

cd /data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/Behavior
for i=1:numel(subjects)
    filename = sprintf('SBJ%02d_Behavior.mat',i);
    foo = load(filename);
    avg_RT = foo.averageRT;
    avg_PC = foo.percentCorrect;
    behavior_avg_RT(i,:) = avg_RT;
    behavior_avg_PC(i,:) = avg_PC;
end

%Average PC and RT
PC_avg = nanmean(behavior_avg_PC');
RT_avg = nanmean(behavior_avg_RT');

fracCorrect = PC_avg';


%% Get atlas & attention networks
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);

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
mask_method = 'one'; % binary mask
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
            robGLM_fit = [b_pos,b_neg]; 
        case 'mean'
            b_pos = [0 1]/sum(pos_mask(:));
            b_neg = [0 1]/sum(neg_mask(:));
            robGLM_fit = [b_pos,b_neg]; 
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
MakeFigureTitle(titleStr,0);

% Plot mask sizes
figure(624); clf;
set(gcf,'Position',[96 233 790 334]);
hist(mask_size,20);
legend('Pos','Neg');
xlabel('# Edges in Network');
ylabel('# LOSO iterations');
title([titleStr ': Size of predictive masks'])
