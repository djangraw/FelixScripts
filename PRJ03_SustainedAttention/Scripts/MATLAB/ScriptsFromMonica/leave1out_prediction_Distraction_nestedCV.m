% leave1out_prediction_Distraction_nestedCV.m

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

% Modified 10/4-5/16 by DJ.


% clear;
% clc;

% UseRosenbergMatsToPredictPerformance;
% [attnNetLabels,labelNames,colors] = GetAttnNetLabels(false);
FCmat = cat(3,FC{:});
FCmat = atanh(FCmat);
FCmat(isinf(FCmat)) = max(FCmat(~isinf(FCmat)));
isOkSubj = squeeze(sum(sum(isnan(FCmat),1),2)==0);

n_node      = 268;                % number of nodes
threshOptions = [0.0001 0.0005 0.001 0.005 0.01 0.05 0.1];
n_thresh = numel(threshOptions);
% thresh      = 0.05;               % p-value threshold for feature selection
train_mats  = FCmat(:,:,isOkSubj);                   % training data (n_node x n_node x n_sub symmetrical connectivity matrices)
test_mats   = FCmat(:,:,isOkSubj);                   % testing data (This will be the same as train_mats when you're training and testing on the same data. If you are training on task matrices and testing on rest matrices, for example, train_mats and test_mats will be different.)
behav       = fracCorrect(isOkSubj);                   % n_sub x 1 vector of behavior
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
mask_size_all = nan(2,n_thresh,n_sub);
[thresh_pos, thresh_neg] = deal(nan(1,n_sub));
[pos_mask_all, neg_mask_all] = deal(nan(n_node,n_node,n_thresh,n_sub));
[r_pos_train_all,r_neg_train_all,p_pos_train_all,p_neg_train_all] = deal(nan(n_thresh,n_sub));
parfor excl_sub = 1:n_sub;
    
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

    % NESTED CV LOOP
    
    [train_pos_sums, train_neg_sums] = deal(nan(n_train_sub,n_thresh));
    [r_pos_train,p_pos_train,r_neg_train,p_neg_train] = deal(nan(n_thresh,1));
    [pos_masks,neg_masks] = deal(nan(n_node,n_node,n_thresh));
    for j=1:n_thresh
        % select edges based on threshold
        thresh = threshOptions(j);
        
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
        for k = 1:n_train_sub
            train_pos_sums(k,j) = sum(sum(pos_mask.*train_mats_tmp(:,:,k)));
            train_neg_sums(k,j) = sum(sum(neg_mask.*train_mats_tmp(:,:,k)));
        end
        
        [r_pos_train(j),p_pos_train(j)] = corr(train_behav, train_pos_sums(:,j));
        [r_neg_train(j),p_neg_train(j)] = corr(train_behav, train_neg_sums(:,j));
%         [r_glm_train(j),p_glm_train(j)] = corr(train_behav, pred_glm);
        
        pos_masks(:,:,j) = pos_mask;
        neg_masks(:,:,j) = neg_mask;
        
        mask_size_all(:,j,excl_sub) = [sum(pos_edge); sum(neg_edge)];

    end
    
    % Get Nested CV maxima
    [~,jBestPos] = max(r_pos_train);
    [~,jBestNeg] = min(r_neg_train);
    
    % Store masks and effectiveness
    pos_mask_all(:,:,:,excl_sub) = pos_masks;
    neg_mask_all(:,:,:,excl_sub) = neg_masks;
    r_pos_train_all(:,excl_sub) = r_pos_train;
    r_neg_train_all(:,excl_sub) = r_neg_train;
    p_pos_train_all(:,excl_sub) = p_pos_train;
    p_neg_train_all(:,excl_sub) = p_neg_train;
    
    %--------------------
    train_pos_sum = train_pos_sums(:,jBestPos);
    train_neg_sum = train_neg_sums(:,jBestNeg);
    pos_mask = pos_masks(:,:,jBestPos);
    neg_mask = neg_masks(:,:,jBestNeg);
%     % Get for best version
    thresh_pos(excl_sub) = threshOptions(jBestPos);
    thresh_neg(excl_sub) = threshOptions(jBestNeg);
% 
%     pos_edge = zeros(1, n_edge);
%     neg_edge = zeros(1, n_edge);
% 
%     cp_pos           = find(cp<thresh_pos(excl_sub) & cr>0);
%     pos_edge(cp_pos) = 1;
%     cp_neg           = find(cp<thresh_pos(excl_sub) & cr<0);
%     neg_edge(cp_neg) = 1;
% 
%     pos_mask = zeros(n_node, n_node);
%     neg_mask = zeros(n_node, n_node);
% 
%     pos_mask(upp_id) = pos_edge; % Here, masks are NOT symmetrical. To make symmetrical, set pos_mask = pos_mask + pos_mask'
%     neg_mask(upp_id) = neg_edge;
% 
%     % sum edges for training subjects
%     train_pos_sum = zeros(n_train_sub,1);
%     train_neg_sum = zeros(n_train_sub,1);
% 
%     for k = 1:n_train_sub
%         train_pos_sum(k) = sum(sum(pos_mask.*train_mats_tmp(:,:,k)));
%         train_neg_sum(k) = sum(sum(neg_mask.*train_mats_tmp(:,:,k)));
%     end
    %--------------------
    
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
    
end

t_exec = toc; % Time execution
fprintf('Done! Took %.3g seconds.\n',t_exec);

%% Correlate and plot
[r_pos,p_pos] = corr(behav, pred_pos);
[r_neg,p_neg] = corr(behav, pred_neg);
[r_glm,p_glm] = corr(behav, pred_glm);

figure(522); clf;
ax1 = subplot(2,2,1);
scatter(behav, pred_pos)
title(sprintf('pos r = %.3g, p = %.3g',r_pos,p_pos))
xlabel('Observed')
ylabel('Predicted')
axis equal

ax2 = subplot(2,2,2);
scatter(behav, pred_neg)
title(sprintf('neg r = %.3g, p = %.3g',r_neg,p_neg))
xlabel('Observed')
ylabel('Predicted')
axis equal

ax3 = subplot(2,2,3);
scatter(behav, pred_glm)
title(sprintf('glm r = %.3g, p = %.3g',r_neg,p_neg))
xlabel('Observed')
ylabel('Predicted')
axis equal

linkaxes([ax1,ax2,ax3],'xy')
MakeFigureTitle(sprintf('Fisher Normed FC, CVed threshold'));

%% Look at mask sizes across thresholds

figure(913); clf;
subplot(221);
hist([thresh_pos; thresh_neg]',threshOptions)
xlabel('threshold')
ylabel('# subjects')
legend('pos','neg');
set(gca,'XScale','log')
title('threshold selected')

subplot(222);
plot(threshOptions,mean(mask_size_all,3),'.-')
xlabel('threshold')
ylabel('mean mask size across subjects')
legend('pos','neg');
set(gca,'XScale','log')
title('mask sizes');

subplot(223);
plot(threshOptions,r_pos_train_all,'.-');
xlabel('threshold')
ylabel('training data correlation coeff (pos)')
set(gca,'XScale','log')
title('subject-wise threshold selection')

subplot(224);
plot(threshOptions,r_neg_train_all,'.-');
xlabel('threshold')
ylabel('training data correlation coeff (neg)')
set(gca,'XScale','log')
title('subject-wise threshold selection')

%% Take best threshold and get overlap across subjects
jBest = 6;

if isempty(jBest);
    [pos_mask_best, neg_mask_best] = deal(nan(n_node,n_node,n_sub));
    for excl_sub = 1:n_sub
        [~,jBestPos] = max(r_pos_train_all(:,excl_sub));
        [~,jBestNeg] = min(r_neg_train_all(:,excl_sub));
        pos_mask_best(:,:,excl_sub) = pos_mask_all(:,:,jBestPos,excl_sub);
        neg_mask_best(:,:,excl_sub) = neg_mask_all(:,:,jBestNeg,excl_sub);
    end
    thresh = 'CV';
else
    pos_mask_best = squeeze(pos_mask_all(:,:,jBest,:));
    neg_mask_best = squeeze(neg_mask_all(:,:,jBest,:));    
    thresh = threshOptions(jBest);
end

groupByCluster = true;
pos_overlap = mean(pos_mask_best,3)==1;% >0;%
neg_overlap = mean(neg_mask_best,3)==1;% >0;%
clusterClimRead = [-1 1] * 82;%55;%*.1;
clusterClimRos = [-1 1] * 90;
clusterAvgMethod = 'sum'; %'mean';
figure(3);
clf;
subplot(2,2,1);
PlotFcMatrix(pos_overlap-neg_overlap,[-1 1],shenAtlas,attnNetLabels,true,colors,false);
title(sprintf('Reading data, pos - neg overlap, thresh = %s',num2str(thresh)))
subplot(2,2,2);
PlotFcMatrix(pos_overlap-neg_overlap,clusterClimRead,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Reading data, pos - neg overlap')
% See how this compares to Rosenberg networks
subplot(2,2,3);
PlotFcMatrix(attnNets.pos_overlap-attnNets.neg_overlap,[-1 1],shenAtlas,attnNetLabels,true,colors,false);
title('Rosenberg data, pos - neg overlap')
subplot(2,2,4);
PlotFcMatrix(attnNets.pos_overlap-attnNets.neg_overlap,clusterClimRos,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Rosenberg data, pos - neg overlap')

MakeLegend(colors,labelNames,2,[.55 .6]);
set(gcf,'Position', [3 329 1023 728]);
MakeFigureTitle(sprintf('threshold: %s\noverlap mask sizes: [%d %d]',num2str(thresh), sum(pos_overlap(:)), sum(neg_overlap(:))));

% Print overlap
figure(62); clf;

% Calculate level of overlap and odds of getting that much my chance:
% p = 1-hygecdf(x, 35778, k, n), where
% x = # overlapping edges
% k = # edges in the high-attention (757) or low-attention (630) network
% n = # edges in your network
distNets = struct('pos_overlap',pos_overlap,'neg_overlap',neg_overlap);
fields = fieldnames(distNets);
[nOverlap,pOverlap] = deal(nan(2));
fprintf('===Overlap significance assessed with hygecdf:\n');
for i=1:2
    for j=1:2
        nOverlap(i,j) = sum(sum(distNets.(fields{i}) & attnNets.(fields{j})));
        nInDistNets = sum(sum(distNets.(fields{i})));
        nInAttnNets = sum(sum(attnNets.(fields{j})));
        pOverlap(i,j) = 1-hygecdf(nOverlap(i,j), n_edge, nInAttnNets, nInDistNets);
        fprintf('Distraction %s vs. Rosenberg %s: p=%.3f\n',fields{i},fields{j},pOverlap(i,j));
    end
end

% plot overlap
hBar = bar(nOverlap);
% color to match Rosenberg JNeuro paper
set(hBar(1),'facecolor',[1 .5 0]);
set(hBar(2),'facecolor',[0 .65 .65]);
% Annotate plot
ylabel('# edges overlapping');
xlabel('Distraction Task Networks')
set(gca,'xticklabel',{'pos','neg'})
legend('Rosenberg pos (High-Attention)','Rosenberg neg (Low-Attention)','Location','NorthWest');
title(sprintf('Network Overlap Across Tasks\nthreshold: %s',num2str(thresh)));

%% Show regions of overlap and disagreement
clusterClimOverlap = [-1 1]*14;
clusterClimRead = [-1 1]*80;
clusterClimRos = [-1 1]*100;

figure(66);
clf;
subplot(3,2,1);
PlotFcMatrix((pos_overlap & attnNets.pos_overlap) - (neg_overlap & attnNets.neg_overlap),...
    [-1 1],shenAtlas,attnNetLabels,true,colors,false);
title(sprintf('Reading & Rosenberg data, pos - neg overlap, thresh = %s',num2str(thresh)))
subplot(3,2,2);
PlotFcMatrix((pos_overlap & attnNets.pos_overlap) - (neg_overlap & attnNets.neg_overlap),...
    clusterClimOverlap,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Reading & Rosenberg data, pos - neg overlap')
% See how this compares to Rosenberg networks
subplot(3,2,3);
PlotFcMatrix((pos_overlap & ~attnNets.pos_overlap) - (neg_overlap & ~attnNets.neg_overlap),...
    [-1 1],shenAtlas,attnNetLabels,true,colors,false);
title('Reading & NOT Rosenberg data, pos - neg overlap')
subplot(3,2,4);
PlotFcMatrix((pos_overlap & ~attnNets.pos_overlap) - (neg_overlap & ~attnNets.neg_overlap),...
    clusterClimRead,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Reading & NOT Rosenberg data, pos - neg overlap')
subplot(3,2,5);
PlotFcMatrix((~pos_overlap & attnNets.pos_overlap) - (~neg_overlap & attnNets.neg_overlap),...
    [-1 1],shenAtlas,attnNetLabels,true,colors,false);
title('Rosenberg & NOT Reading data, pos - neg overlap')
subplot(3,2,6);
PlotFcMatrix((~pos_overlap & attnNets.pos_overlap) - (~neg_overlap & attnNets.neg_overlap),...
    clusterClimRos,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Rosenberg & NOT Reading data, pos - neg overlap')


MakeLegend(colors,labelNames,2,[.55 .6]);
set(gcf,'Position', [3 30 1023 1028]);
MakeFigureTitle(sprintf('threshold: %s\noverlap mask sizes: [%d %d]',num2str(thresh), sum(pos_overlap(:)), sum(neg_overlap(:))));
