function [pred_pos, pred_neg, pred_glm,pos_mask,neg_mask] = RunTrainingBehaviorRegression(FC,behav,thresh,corr_method,mask_method)

% [pred_pos, pred_neg, pred_glm,pos_mask,neg_mask] = RunTrainingBehaviorRegression(FC,behav,thresh)
%
% Created 12/30/16 by DJ.
% Updated 5/11/17 by DJ - removed *2 scaling factor for combo scores

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

fprintf('Training networks on %d subjects...\n',n_sub);
% Turn off warning
warning('off','stats:statrobustfit:IterationLimit'); % suppress this warning to speed up code

train_behav = behav;

% create n_sub x n_edge matrix
train_vect = reshape(FC, n_node*n_node, n_sub)';
upp_vect   = train_vect(:,upp_id); 

% relate behavior to edge strength across training subjects
switch corr_method
    case 'robustfit'
        cp = zeros(n_edge, 1);
        cr = zeros(n_edge, 1);

        for ii = 1:n_edge
            [~,stats] = robustfit(upp_vect(:,ii), train_behav);
            cp(ii)    = stats.p(2);
            cr(ii)    = sign(stats.t(2))*sqrt((stats.t(2)^2/(n_sub-2))/(1+(stats.t(2)^2/(n_sub-2))));
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

% generate predictions for left-out subject
test_pos_sum = squeeze(sum(sum(pos_mask.*FC))); % to speed up
test_neg_sum = squeeze(sum(sum(neg_mask.*FC))); % to speed up
test_combo_sum = squeeze(sum(sum((pos_mask-neg_mask).*FC)));

pred_pos = test_pos_sum/sum(pos_mask(:));
pred_neg = test_neg_sum/sum(neg_mask(:));
pred_glm = test_combo_sum/sum(pos_mask(:)+neg_mask(:));
% pred_glm = test_combo_sum/sum(pos_mask(:)+neg_mask(:))*2;

fprintf('Done!\n');