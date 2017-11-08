function [pred_pos, pred_neg, pred_glm,pos_mask_all,neg_mask_all] = RunKfoldBehaviorRegression(FC,behav,thresh,corr_method,mask_method,nFolds)

% [pred_pos, pred_neg, pred_glm,pos_mask_all,neg_mask_all] = RunKfoldBehaviorRegression(FC,behav,thresh,corr_method,mask_method,nFolds)
% [~,~,~,cp_all,cr_all] = RunLeave1outBehaviorRegression(FC,behav,thresh,corr_method,'cpcr',nFolds)
%
% INPUTS:
% -FC is an mxmxn matrix of functional connectivity edge values, where m is 
% the number of ROIs and n is the number of subjects.
% -behav is an n-element vector of behavioral scores.
% -thresh is the threshold of p values below which an FC edge will be
% considered significantly correlated with behavior.
% -corr_method is a string, either 'corr' [default] or 'robustfit',
% indicating which command should be used to find the correlations.
% -mask_method is a string, either 'one' [default] (binary mask), 'log'
% (weight by the -log of the p value), or 'cpcr' (return the cp and cr
% matrices). 
% -nFolds is a scalar indicating the number of CV folds to use.
%
% OUTPUTS:
% -pred_pos/neg/glm are n-element vectors containing the LOSO predictions
% based on positive, negative, or combination masks.
% -pos/neg_mask_all are mxmxn matrices containing the weight of each edge
% in each of the n LOSO iterations.
% -cp/cr are mxmxn matrices containing the p and r values for each edge in
% each of the n LOSO iterations.
%
% Created 12/29/16 by DJ.
% Updated 1/3/17 by DJ - comments
% Updated 2/21/17 by DJ - use parfor if robustfit option, otherwise "for"
% Updated 5/11/17 by DJ - removed *2 scaling factor for combo scores
% Updated 11/6/17 by DJ - moved from LOO to k-fold CV

if ~exist('thresh','var') || isempty(thresh)
    thresh = 0.01;               % p-value threshold for feature selection
end
if ~exist('corr_method','var') || isempty(corr_method)
    corr_method = 'corr'; % simple correlation
    % corr_method = 'robustfit'; % slower but more robust to outliers
end
if ~exist('mask_method','var') || isempty(mask_method)
    % mask_method = 'cpcr';% CP and CR values
    mask_method = 'one'; % binary mask
    % mask_method = 'log'; % weight = negative log of p value 
end

% Declare constants
n_node      = size(FC,1);                % number of nodes
n_sub       = size(FC,3); % number of subjects

% Get upper triangular elements
uppertri = triu(ones(n_node,n_node),1);
upp_id = find(uppertri);   % indices of edges in the upper triangular of an n_node x n_node matrix
n_edge = length(upp_id); % total number of edges 

% Set up
[pred_pos, pred_neg, pred_glm] = deal(nan(n_sub,1));
[pos_mask_all,neg_mask_all] = deal(nan(n_node,n_node,nFolds));
% Set up CV folds
cv = setCrossValidationStruct(sprintf('%dfold',nFolds),n_sub);
testingSubj = cv.outTrials;

% Run main loop
if strcmp(corr_method,'robustfit')
    [pred_pos_fold, pred_neg_fold, pred_glm_fold] = deal(cell(1,nFolds));
    parfor iFold = 1:nFolds

        excl_sub = testingSubj{iFold};
        n_train_sub = n_sub-numel(excl_sub);
        % Set up LOSO iteration
        fprintf('Fold %d/%d...\n',iFold,nFolds);
        warning('off','stats:statrobustfit:IterationLimit'); % suppress this warning to speed up code

        % exclude data from left-out subject
        train_mats_tmp = FC;
        train_mats_tmp(:,:,excl_sub) = [];
        train_behav = behav;
        train_behav(excl_sub) = [];

        % create n_train_sub x n_edge matrix
        train_vect = reshape(train_mats_tmp, n_node*n_node, n_train_sub)';
        upp_vect   = train_vect(:,upp_id); 

        % relate behavior to edge strength across training subjects
        switch corr_method
            case 'robustfit'
                cp = zeros(n_edge, 1);
                cr = zeros(n_edge, 1);

                for ii = 1:n_edge
                    [~,stats] = robustfit(upp_vect(:,ii), train_behav);
                    cp(ii)    = stats.p(2);
                    cr(ii)    = sign(stats.t(2))*sqrt((stats.t(2)^2/(n_train_sub-2))/(1+(stats.t(2)^2/(n_train_sub-2))));
                end
            case 'corr'
                [cr,cp] = corr(upp_vect, train_behav);
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

        % generate predictions for left-out subjects
        test_pos_sum = sum(sum(repmat(pos_mask,1,1,numel(excl_sub)).*FC(:,:,excl_sub))); % to speed up
        test_neg_sum = sum(sum(repmat(neg_mask,1,1,numel(excl_sub)).*FC(:,:,excl_sub))); % to speed up
        test_combo_sum = sum(sum(repmat(pos_mask-neg_mask,1,1,numel(excl_sub)).*FC(:,:,excl_sub)));

        pred_pos_fold{iFold} = test_pos_sum(:)/sum(pos_mask(:));
        pred_neg_fold{iFold} = test_neg_sum(:)/sum(neg_mask(:));
        pred_glm_fold{iFold} = test_combo_sum(:)/sum(pos_mask(:)+neg_mask(:));

        % Store masks and their sizes
        pos_mask_all(:,:,iFold) = pos_mask;
        neg_mask_all(:,:,iFold) = neg_mask;
        fprintf('Done!\n');
    end
    for iFold=1:nFolds
        pred_pos(testingSubj{iFold}) = pred_pos_fold{iFold};
        pred_neg(testingSubj{iFold}) = pred_neg_fold{iFold};
        pred_glm(testingSubj{iFold}) = pred_glm_fold{iFold};
    end
else % corr
    for iFold = 1:nFolds

        excl_sub = testingSubj{iFold};
        n_train_sub = n_sub-numel(excl_sub);
        % Set up LOSO iteration
        fprintf('Fold %d/%d...\n',iFold,nFolds);
        warning('off','stats:statrobustfit:IterationLimit'); % suppress this warning to speed up code

        % exclude data from left-out subject
        train_mats_tmp = FC;
        train_mats_tmp(:,:,excl_sub) = [];
        train_behav = behav;
        train_behav(excl_sub) = [];

        % create n_train_sub x n_edge matrix
        train_vect = reshape(train_mats_tmp, n_node*n_node, n_train_sub)';
        upp_vect   = train_vect(:,upp_id); 

        % relate behavior to edge strength across training subjects
        switch corr_method
            case 'robustfit'
                cp = zeros(n_edge, 1);
                cr = zeros(n_edge, 1);

                for ii = 1:n_edge
                    [~,stats] = robustfit(upp_vect(:,ii), train_behav);
                    cp(ii)    = stats.p(2);
                    cr(ii)    = sign(stats.t(2))*sqrt((stats.t(2)^2/(n_train_sub-2))/(1+(stats.t(2)^2/(n_train_sub-2))));
                end
            case 'corr'
                [cr,cp] = corr(upp_vect, train_behav);
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

        % generate predictions for left-out subjects
        test_pos_sum = sum(sum(repmat(pos_mask,1,1,numel(excl_sub)).*FC(:,:,excl_sub))); % to speed up
        test_neg_sum = sum(sum(repmat(neg_mask,1,1,numel(excl_sub)).*FC(:,:,excl_sub))); % to speed up
        test_combo_sum = sum(sum(repmat(pos_mask-neg_mask,1,1,numel(excl_sub)).*FC(:,:,excl_sub)));

        pred_pos(excl_sub) = test_pos_sum(:)/sum(pos_mask(:));
        pred_neg(excl_sub) = test_neg_sum(:)/sum(neg_mask(:));
        pred_glm(excl_sub) = test_combo_sum(:)/sum(pos_mask(:)+neg_mask(:));

        % Store masks and their sizes
        pos_mask_all(:,:,iFold) = pos_mask;
        neg_mask_all(:,:,iFold) = neg_mask;
%         fprintf('Done!\n');
    end
end