function [p,Rsq,mask_size,mask_overlap_size,isOkSubj,fracCorrect_perm,r,r_spearman,p_spearman] = RunLeave1outPermutations(FC,fracCorrect,nPerms,corr_method,mask_method,thresh)

% [p,Rsq,mask_size,pos_mask_all,neg_mask_all,fracCorrect_perm,r,r_spearman,p_spearman] = RunLeave1outPermutations(FC,fracCorrect,nPerms,,corr_method,mask_method,thresh)
%
% Created 12/21/16 by DJ.
% Updated 1/4/17 by DJ - added corr_method and mask_method inputs
% Updated 2/22/17 by DJ - removed automatic FC Fisher normalization (atanh)
% Updated 2/23/17 by DJ - added Spearman corr outputs
% Updated 8/31/17 by DJ - allow already-permuted behavior as input

if ~exist('nPerms','var') || isempty(nPerms)
    if size(fracCorrect,2)>1
        nPerms = size(fracCorrect,2);
    else
        nPerms = 1000;               % # of permutations
    end
end
if ~exist('corr_method','var') || isempty(corr_method)
    % corr_method = 'robustfit'; % precise
    corr_method = 'corr'; % fast
end
if ~exist('mask_method','var') || isempty(mask_method)
    % mask_method = 'cpcr';% CP and CR values
    mask_method = 'one'; % binary mask
    % mask_method = 'log'; % weight = negative log of p value 
end
if ~exist('thresh','var') || isempty(thresh)
    thresh      = 0.01;               % p-value threshold for feature selection
end

% FCmat = atanh(FC);
% FCmat(isinf(FCmat)) = max(FCmat(~isinf(FCmat)));
% isOkSubj = squeeze(sum(sum(isnan(FCmat),1),2)==0);
isOkSubj = squeeze(sum(sum(isnan(FC),1),2)==0);

% n_node      = size(FC,1);                % number of nodes
train_mats  = FC(:,:,isOkSubj);                   % training data (n_node x n_node x n_sub symmetrical connectivity matrices)
% train_mats  = FCmat(:,:,isOkSubj);                   % training data (n_node x n_node x n_sub symmetrical connectivity matrices)
% test_mats   = FCmat(:,:,isOkSubj);                   % testing data (This will be the same as train_mats when you're training and testing on the same data. If you are training on task matrices and testing on rest matrices, for example, train_mats and test_mats will be different.)
fracCorrect_ok = fracCorrect(isOkSubj,:);                   % n_sub x 1 vector of behavior

n_sub       = size(train_mats,3); % number of subjects

% Added by DJ
% RANDOMIZE BEHAVIOR
if numel(fracCorrect_ok)==n_sub
    fprintf('Getting randomized behavior...\n');
    permBeh = nan(n_sub,nPerms); % matrix of permuted behavior
    for i=1:nPerms
        permBeh(:,i) = fracCorrect_ok(randperm(n_sub)');
    end
elseif size(fracCorrect,2)==nPerms
    fprintf('Using permuted behavior given as input...\n')
    permBeh = fracCorrect;
else
    error('fracCorrect must be nSubjx1 or nSubjxnPerms!')
end
tic; % Time execution
% [pos_mask_all, neg_mask_all] = deal(nan(n_node,n_node,n_sub,nPerms));
% [pos_mask_all, neg_mask_all] = deal([]);
[p, Rsq, r, r_spearman, p_spearman] = deal(nan(3,nPerms));
mask_size = deal(nan(n_sub,2,nPerms));
mask_overlap_size = nan(2,nPerms);
fracCorrect_perm = nan(n_sub,nPerms);
fprintf('===FINDING MASKS IN %d LOSO ITERATIONS...===\n',n_sub);
for iPerm = 1:nPerms
    fprintf('===Permutation %d/%d...\n',iPerm,nPerms);
    tic;
    % Randomize behavioral metric
    behav = permBeh(:,iPerm);
%     behav = fracCorrect_ok(randperm(numel(fracCorrect_ok)));
    
    % Get LOSO predictions
    [pred_pos, pred_neg, pred_glm,pos_mask,neg_mask] = ...
        RunLeave1outBehaviorRegression(train_mats,behav,thresh,corr_method,mask_method);
%     [pred_pos, pred_neg, pred_glm,pos_mask_all(:,:,:,iPerm),neg_mask_all(:,:,:,iPerm)] = ...
%         RunLeave1outBehaviorRegression(train_mats,behav,thresh,corr_method,mask_method);
    
    % assess predictive power
    [p1,Rsq1] = Run1tailedRegression(behav,pred_pos,true);
    r1 = corr(behav,pred_pos);
    [r1_spearman, p1_spearman] = corr(behav,pred_pos,'type','Spearman','tail','right');
    [p2,Rsq2] = Run1tailedRegression(behav,pred_neg,false);
    r2 = corr(behav,pred_neg);
    [r2_spearman, p2_spearman] = corr(behav,pred_neg,'type','Spearman','tail','left');
    [p3,Rsq3] = Run1tailedRegression(behav,pred_glm,true);
    r3 = corr(behav,pred_glm);
    [r3_spearman, p3_spearman] = corr(behav,pred_glm,'type','Spearman','tail','right');
    
    % Create outputs
    mask_size(:,:,iPerm) = [squeeze(sum(sum(pos_mask,1),2)), squeeze(sum(sum(neg_mask,1),2))];
%     mask_size(:,:,iPerm) = [squeeze(sum(sum(pos_mask_all(:,:,:,iPerm),1),2)), squeeze(sum(sum(neg_mask_all(:,:,:,iPerm),1),2))];
    mask_overlap_size(:,iPerm) = [sum(sum(all(pos_mask,3),1),2); sum(sum(all(neg_mask,3),1),2)];
    p(:,iPerm) = [p1;p2;p3];
    Rsq(:,iPerm) = [Rsq1;Rsq2;Rsq3];
    r(:,iPerm) = [r1;r2;r3];
    r_spearman(:,iPerm) = [r1_spearman; r2_spearman; r3_spearman];
    p_spearman(:,iPerm) = [p1_spearman; p2_spearman; p3_spearman];
    fracCorrect_perm(:,iPerm) = behav;
    % Time results
    t_exec = toc; % Time execution
    fprintf('===Done! Took %.3g seconds.\n',t_exec);

end
