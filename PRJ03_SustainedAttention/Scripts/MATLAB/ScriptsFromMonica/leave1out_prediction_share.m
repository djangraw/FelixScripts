% Copyright 2015 Monica Rosenberg, Emily Finn, and Dustin Scheinost

% This code is released under the terms of the GNU GPL v2. This code
% is not FDA approved for clinical use; it is provided
% freely for research purposes. If using this in a publication
% please reference this properly as: 

% Rosenberg MD, Finn ES, Scheinost D, Papademetris X, Shen X, 
% Constable RT & Chun MM. (2016). A neuromarker of sustained
% attention from whole-brain functional connectivity. Nature Neuroscience 
% 19(1), 165-171.

% This code provides a framework for implementing functional
% connectivity-based behavioral prediction with leave-one-out cross-validaiton, as 
% described in Rosenberg, Finn et al 2016 (see above for full reference). 
% The first input ('train_mats') is a pre-calculated MxMxN matrix 
% containing all individual-subject connectivity matrices in the training 
% set, where M = number of nodes in the chosen brain atlas and N = number of
% subjects. Each element (i,j,k) in these matrices represents the
% correlation between the BOLD timecourses of nodes i and j in subject k
% during a single fMRI session. The second input ('behav') is the
% Nx1 vector of scores for the behavior of interest for all subjects.

% As in the reference paper, the predictive power of the model is assessed
% via correlation between predicted and observed scores across all
% subjects. Note that this assumes normal or near-normal distributions for
% both vectors, and does not assess absolute accuracy of predictions (only
% relative accuracy within the sample). It is recommended to explore
% additional/alternative metrics for assessing predictive power, such as
% prediction error sum of squares or prediction r^2.

clear;
clc;

n_node      = 268;                % number of nodes
thresh      = 0.01;               % p-value threshold for feature selection
train_mats  = ;                   % training data (n_node x n_node x n_sub symmetrical connectivity matrices)
test_mats   = ;                   % testing data (This will be the same as train_mats when you're training and testing on the same data. If you are training on task matrices and testing on rest matrices, for example, train_mats and test_mats will be different.)
behav       = ;                   % n_sub x 1 vector of behavior
n_sub       = size(train_mats,3); % number of subjects
n_train_sub = n_sub-1;            % number of subjects in each round of cross-validation

pred_pos = zeros(n_sub,1);
pred_neg = zeros(n_sub,1);
pred_glm = zeros(n_sub,1);

aa     = ones(n_node,n_node);
aa_upp = triu(aa,1);
upp_id = find(aa_upp);   % indices of edges in the upper triangular of an n_node x n_node matrix
n_edge = length(upp_id); % total number of edges 

for excl_sub = 1:n_sub;
    
    excl_sub
    
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
    pos_edge(cp_pos) = 1;
    cp_neg           = find(cp<thresh & cr<0);
    neg_edge(cp_neg) = 1;
    
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
    b_pos      = robustfit(train_pos_sum, train_behav);
    b_neg      = robustfit(train_neg_sum, train_behav);
    robGLM_fit = robustfit([train_pos_sum train_neg_sum],train_behav);
    
    % generate predictions for left-out subject
    test_pos_sum = sum(sum(pos_mask.*test_mats(:,:,excl_sub)));
    test_neg_sum = sum(sum(neg_mask.*test_mats(:,:,excl_sub)));
    
    pred_pos(excl_sub) = (b_pos(2)*test_pos_sum) + b_pos(1);
    pred_neg(excl_sub) = (b_neg(2)*test_neg_sum) + b_neg(1);
    pred_glm(excl_sub) = robGLM_fit(1) + robGLM_fit(2)*test_pos_sum + robGLM_fit(3)*test_neg_sum;
    
    mask_size(excl_sub,1) = sum(pos_edge);
    mask_size(excl_sub,2) = sum(neg_edge);
end

r_pos = corr(behav, pred_pos);
r_neg = corr(behav, pred_neg);
r_glm = corr(behav, pred_glm);

ax1 = subplot(2,2,1);
scatter(behav, pred_pos)
title(['pos r = ' num2str(r_pos)])
xlabel('Observed')
ylabel('Predicted')
axis equal

ax2 = subplot(2,2,2);
scatter(behav, pred_neg)
title(['neg r = ' num2str(r_neg)])
xlabel('Observed')
ylabel('Predicted')
axis equal

ax3 = subplot(2,2,3);
scatter(behav, pred_glm)
title(['glm r = ' num2str(r_glm)])
xlabel('Observed')
ylabel('Predicted')
axis equal

linkaxes([ax1,ax2,ax3],'xy')
