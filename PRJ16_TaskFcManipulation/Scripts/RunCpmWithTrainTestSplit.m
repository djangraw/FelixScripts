function [r_train,p_train,r_test,p_test,pos_mask_all,neg_mask_all] = RunCpmWithTrainTestSplit(FC,behavior,corr_method,mask_method,thresh)

% [r_train,p_train,r_test,p_test,pos_mask_all,neg_mask_all] = RunCpmWithTrainTestSplit(FC,behavior,corr_method,mask_method,thresh)
%
% Created 9/21/17 by DJ.
% Updated 10/2/17 by DJ - added optional inputs corr_method, mask_method, thresh.

% Declare defaults
if ~exist('corr_method','var') || isempty(corr_method)
    corr_method = 'robustfit'; %'corr'; %
end
if ~exist('mask_method','var') || isempty(mask_method)
    mask_method = 'one'; 
end
if ~exist('thresh','var') || isempty(thresh)
    thresh = 0.01; 
end

% split into training and testing sets
nSubj = size(behavior,1);
isTrain = (1:nSubj)<ceil(nSubj/2);
isTest = ~isTrain;

fprintf('=== TRAINING...\n')
% Run LOO on training set to get network
FC_train = FC(:,:,isTrain);
behavior_train = behavior(isTrain);
[pred_pos, pred_neg, pred_combo,pos_mask_all,neg_mask_all] = RunLeave1outBehaviorRegression(FC_train,behavior_train,thresh,corr_method,mask_method);
[r_train,p_train] = corr(pred_combo,behavior_train,'tail','right');
fprintf('TRAINING LOO: r=%.3g, p=%.3g\n',r_train,p_train);

% Apply matrix to teseting set
fprintf('=== TESTING...\n')
FC_test = FC(:,:,isTest);
behavior_test = behavior(isTest);
[test_pos,test_neg,test_combo] = GetFcMaskMatch(FC_test,all(pos_mask_all,3),all(neg_mask_all,3));
[test_pos,test_neg,test_combo] = deal(test_pos',test_neg',test_combo');

[r_test,p_test] = corr(test_combo,behavior_test,'tail','right');
fprintf('TESTING LOO: r=%.3g, p=%.3g\n',r_test,p_test);
