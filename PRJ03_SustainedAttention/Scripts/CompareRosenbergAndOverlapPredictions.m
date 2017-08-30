% leave1out_prediction_Distraction.m
%
% Adapted by DJ from leave1out_prediction.m, which is:

% Copyright 2015 Monica Rosenberg, Emily Finn, and Dustin Scheinost

% Created 10/17 by DJ based on leave1out_prediction_Distraction.m.

% clear;
% clc;

% UseRosenbergMatsToPredictPerformance;

%% Get atlas & attention networks
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
uppertri = triu(ones(size(attnNets.pos_overlap,1)),1);
attnNets.pos_overlap(~uppertri) = 0;
attnNets.neg_overlap(~uppertri) = 0;
[attnNetLabels,labelNames,colors] = GetAttnNetLabels(false);

%% Get scores

doRand = false;
doRandBeh = false;
if doRand
    fprintf('===RANDOMIZING...===\n');
    FCrand = RandomizeFc(FC);
    FCmat = cat(3,FCrand{:});
else
    FCmat = cat(3,FC{:});
end
FCmat = atanh(FCmat);
FCmat(isinf(FCmat)) = max(FCmat(~isinf(FCmat)));
isOkSubj = squeeze(sum(sum(isnan(FCmat),1),2)==0);

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

% ===== SAME WITH ROSENBERG OVERLAP AND MATRICES
[pred_pos_olap, pred_neg_olap, pred_glm_olap] = deal(zeros(n_sub,1));
[pred_pos_rose, pred_neg_rose, pred_glm_rose] = deal(zeros(n_sub,1));


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
    
    
    % ==== SAME WITH ROSENBERG OVERLAP    
    pos_mask = pos_mask & attnNets.pos_overlap; % Here, masks are NOT symmetrical. To make symmetrical, set pos_mask = pos_mask + pos_mask'
    neg_mask = neg_mask & attnNets.neg_overlap;
        
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
            b_pos = [1 1];
            b_neg = [1 1];
            robGLM_fit = [b_pos,b_neg]; 
        case 'mean'
            b_pos = [1 1]/sum(pos_mask(:));
            b_neg = [1 1]/sum(neg_mask(:));
            robGLM_fit = [b_pos,b_neg]; 
    end
    % generate predictions for left-out subject
    test_pos_sum = sum(sum(pos_mask.*test_mats(:,:,excl_sub)));
    test_neg_sum = sum(sum(neg_mask.*test_mats(:,:,excl_sub)));
    
    pred_pos_olap(excl_sub) = (b_pos(2)*test_pos_sum) + b_pos(1);
    pred_neg_olap(excl_sub) = (b_neg(2)*test_neg_sum) + b_neg(1);
    pred_glm_olap(excl_sub) = robGLM_fit(1) + robGLM_fit(2)*test_pos_sum + robGLM_fit(3)*test_neg_sum;

    % ==== END "SAME WITH ROSENBERG OVERLAP"   
    
    % ==== SAME WITH ROSENBERG MATRICES    
    pos_mask = attnNets.pos_overlap; % Here, masks are NOT symmetrical. To make symmetrical, set pos_mask = pos_mask + pos_mask'
    neg_mask = attnNets.neg_overlap;
        
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
            b_pos = [1 1];
            b_neg = [1 1];
            robGLM_fit = [b_pos,b_neg]; 
        case 'mean'
            b_pos = [1 1]/sum(pos_mask(:));
            b_neg = [1 1]/sum(neg_mask(:));
            robGLM_fit = [b_pos,b_neg]; 
    end
    % generate predictions for left-out subject
    test_pos_sum = sum(sum(pos_mask.*test_mats(:,:,excl_sub)));
    test_neg_sum = sum(sum(neg_mask.*test_mats(:,:,excl_sub)));
    
    pred_pos_rose(excl_sub) = (b_pos(2)*test_pos_sum) + b_pos(1);
    pred_neg_rose(excl_sub) = (b_neg(2)*test_neg_sum) + b_neg(1);
    pred_glm_rose(excl_sub) = robGLM_fit(1) + robGLM_fit(2)*test_pos_sum + robGLM_fit(3)*test_neg_sum;

    % ==== END "SAME WITH ROSENBERG MATRICES"  

    
%     mask_size(excl_sub,1) = sum(pos_edge);
%     mask_size(excl_sub,2) = sum(neg_edge);

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
[r_pos_rose,p_pos_rose] = corr(behav, pred_pos_rose);
[r_neg_rose,p_neg_rose] = corr(behav, pred_neg_rose);
[r_glm_rose,p_glm_rose] = corr(behav, pred_glm_rose);
[r_pos_read,p_pos_read] = corr(behav, pred_pos);
[r_neg_read,p_neg_read] = corr(behav, pred_neg);
[r_glm_read,p_glm_read] = corr(behav, pred_glm);
[r_pos_both,p_pos_both] = corr(behav, pred_pos_olap);
[r_neg_both,p_neg_both] = corr(behav, pred_pos_olap);
[r_glm_olap,p_glm_olap] = corr(behav, pred_glm_olap);

% Plot
figure(522); clf;
ax(1) = subplot(3,2,1);
scatter(behav, pred_pos_rose)
title(sprintf('pos r = %.3g, p = %.3g',r_pos_rose,p_pos_rose))
xlabel('Observed Behavior')
ylabel('Rosenberg Pos Mask Sum')
% axis equal

ax(2) = subplot(3,2,2);
scatter(behav, pred_neg_rose)
title(sprintf('neg r = %.3g, p = %.3g',r_neg_rose,p_neg_rose))
xlabel('Observed Behavior')
ylabel('Rosenberg Neg Mask Sum')
% axis equal

ax(3) = subplot(3,2,3);
scatter(behav, pred_pos)
title(sprintf('pos r = %.3g, p = %.3g',r_pos_read,p_pos_read))
xlabel('Observed Behavior')
ylabel('Reading Pos Mask Sum')
% axis equal

ax(4) = subplot(3,2,4);
scatter(behav, pred_neg)
title(sprintf('neg r = %.3g, p = %.3g',r_neg_read,p_neg_read))
xlabel('Observed Behavior')
ylabel('Reading Neg Mask Sum')
% axis equal

ax(5) = subplot(3,2,5);
scatter(behav, pred_pos_olap)
title(sprintf('pos r = %.3g, p = %.3g',r_pos_both,p_pos_both))
xlabel('Observed Behavior')
ylabel('Overlap Pos Mask Sum')
% axis equal

ax(6) = subplot(3,2,6);
scatter(behav, pred_neg_olap)
title(sprintf('neg r = %.3g, p = %.3g',r_neg_both,p_neg_both))
xlabel('Observed Behavior')
ylabel('Overlap Neg Mask Sum')
% axis equal



linkaxes([ax],'xy')
if doRand
    MakeFigureTitle(sprintf('RANDOMIZED Fisher Normed FC, threshold p<%.3g',thresh));
elseif doRandBeh
    MakeFigureTitle(sprintf('RANDOMIZED BEHAVIOR Fisher Normed FC, threshold p<%.3g',thresh));    
else
    MakeFigureTitle(sprintf('Fisher Normed FC, threshold p<%.3g',thresh));
end


