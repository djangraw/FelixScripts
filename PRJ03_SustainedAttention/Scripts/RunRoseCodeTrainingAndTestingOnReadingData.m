function RunRoseCodeTrainingAndTestingOnReadingData(FC,behav)

% Separate subjects into training and testing sets and evaluate ability to
% predict behavior.
%
% RunRoseCodeTrainingAndTestingOnReadingData(FC,behav)
%
% Created 12/30/16 by DJ.
% Updated 5/11/17 by DJ - removed *2 scaling factor for combo scores

%% Set up
nSubj = size(FC,3);
% nTrain = floor(nSubj/2);
[~,order] = sort(behav,'ascend');
iTrain = order(2:2:nSubj); %1:nTrain; % 
iTest = order(1:2:nSubj); % (nTrain+1):nSubj; %
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';

%% Run training set
% get training set
train_mats = FC(:,:,iTrain);
train_behav = behav(iTrain);
% Get LOSO predictions
% [pred_pos, pred_neg, pred_glm,pos_mask_all,neg_mask_all] = RunLeave1outBehaviorRegression(train_mats,train_behav,thresh,corr_method,mask_method);
[pred_pos, pred_neg, pred_glm,pos_mask,neg_mask] = RunTrainingBehaviorRegression(train_mats,train_behav,thresh,corr_method,mask_method);

%% assess predictive power
[p1,Rsq1,lm1] = Run1tailedRegression(train_behav,pred_pos,true);
[p2,Rsq2,lm2] = Run1tailedRegression(train_behav,pred_neg,false);
[p3,Rsq3,lm3] = Run1tailedRegression(train_behav,pred_glm,true);
r1 = sqrt(lm1.Rsquared.Ordinary);
r2 = sqrt(lm2.Rsquared.Ordinary);
r3 = sqrt(lm3.Rsquared.Ordinary);
% Print results
fprintf('===TRAINING SET (LOSO):\n');
fprintf('Pos vs. Behavior: Rsq=%.3g, r=%.3g, p=%.3g\n',Rsq1,r1,p1);
fprintf('Neg vs. Behavior: Rsq=%.3g, r=%.3g, p=%.3g\n',Rsq2,r2,p2);
fprintf('Combo vs. Behavior: Rsq=%.3g, r=%.3g, p=%.3g\n',Rsq3,r3,p3);

%% Get overlap matrices
% pos_mask_overlap = all(pos_mask_all>0,3);
% neg_mask_overlap = all(neg_mask_all>0,3);
pos_mask_overlap = pos_mask;
neg_mask_overlap = neg_mask;

%% Apply to new subjects
test_vecs = VectorizeFc(FC(:,:,iTest));
test_behav = behav(iTest);

pos_mask_overlap_vec = VectorizeFc(pos_mask_overlap);
neg_mask_overlap_vec = VectorizeFc(neg_mask_overlap);

pred_pos = (pos_mask_overlap_vec'*test_vecs)/sum(pos_mask_overlap_vec);
pred_neg = (neg_mask_overlap_vec'*test_vecs)/sum(neg_mask_overlap_vec);
pred_glm = ((pos_mask_overlap_vec-neg_mask_overlap_vec)'*test_vecs)/sum(pos_mask_overlap_vec+neg_mask_overlap_vec);
% pred_glm = ((pos_mask_overlap_vec-neg_mask_overlap_vec)'*test_vecs)/sum(pos_mask_overlap_vec+neg_mask_overlap_vec)*2;

[p4,Rsq4,lm4] = Run1tailedRegression(test_behav,pred_pos,true);
[p5,Rsq5,lm5] = Run1tailedRegression(test_behav,pred_neg,false);
[p6,Rsq6,lm6] = Run1tailedRegression(test_behav,pred_glm,true);
r4 = sqrt(lm4.Rsquared.Ordinary);
r5 = sqrt(lm5.Rsquared.Ordinary);
r6 = sqrt(lm6.Rsquared.Ordinary);

% Print results
fprintf('===TESTING SET:\n');
fprintf('Pos vs. Behavior: Rsq=%.3g, r=%.3g, p=%.3g\n',Rsq4,r4,p4);
fprintf('Neg vs. Behavior: Rsq=%.3g, r=%.3g, p=%.3g\n',Rsq5,r5,p5);
fprintf('Combo vs. Behavior: Rsq=%.3g, r=%.3g, p=%.3g\n',Rsq6,r6,p6);
%% Plot everything

clf;
subplot(131); hold on;
plot(inf,inf,'bx');
plot(inf,inf,'rx');
h1 = lm1.plot;
set(h1,'color','b');
h2 = lm4.plot;
set(h2,'color','r');
xlabel('frac correct')
ylabel('pos score')
title(sprintf('Pos vs. Behavior: Train Rsq=%.3g, p=%.3g\nTest Rsq=%.3g, p=%.3g',Rsq1,p1,Rsq4,p4));
legend('training','testing');

subplot(132); hold on;
plot(inf,inf,'bx');
plot(inf,inf,'rx');
h1 = lm2.plot;
set(h1,'color','b');
h2 = lm5.plot;
set(h2,'color','r');
xlabel('frac correct')
ylabel('neg score')
title(sprintf('Neg vs. Behavior: Train Rsq=%.3g, p=%.3g\nTest Rsq=%.3g, p=%.3g',Rsq2,p2,Rsq5,p5));
legend('training','testing');

subplot(133); hold on;
plot(inf,inf,'bx');
plot(inf,inf,'rx');
h1 = lm3.plot;
set(h1,'color','b');
h2 = lm6.plot;
set(h2,'color','r');
xlabel('frac correct')
ylabel('combined score')
title(sprintf('Combo vs. Behavior: Train Rsq=%.3g, p=%.3g\nTest Rsq=%.3g, p=%.3g',Rsq3,p3,Rsq6,p6));
legend('training','testing');

set(gcf,'Position', [127 515 1542 428])


