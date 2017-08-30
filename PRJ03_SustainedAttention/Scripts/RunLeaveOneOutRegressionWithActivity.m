function [score,networks,cp,cr] = RunLeaveOneOutRegressionWithActivity(activity,behav,thresh)

% function [scores,networks,cp,cr] = RunLeaveOneOutRegressionWithActivity(activity,behav,thresh)
%
% INPUTS:
% -activity is an mxn matrix where m is the number of ROIs and n is the number of subjects.
% -behav is an nx1 matrix containing the behavioral metric for each subject
% that you'd like to predict.
% -thresh is a scalar indicating the statistical threshold needed for an
% ROI to be included in a mask.
%
% OUTPUTS:
% -score is an nx1 matrix indicating each subject's score predicting their
% behavior from the LOSO iteration when they were left out.
% -networks is an mx1 matrix with +1 indicating ROIs where every LOSO
% iteration showed them positively correlated with behavior, and -1 where
% every LOSO iteration showed them negatively correlated with beh.
% -cr and cp are mxn matrices where (i,j) indicates the r and p value of
% the correlation between ROI i and behavior in the LOSO iteration where
% subject j was left out.
%
% Created 1/17/17 by DJ. 
% Updated 5/11/17 by DJ - switched from sum to mean

% set defaults
if ~exist('thresh','var') || isempty(thresh)
    thresh = 1;
end

%% Set up
[nROIs,nSubj] = size(activity);
[cr,cp,isPos,isNeg] = deal(nan(nROIs,nSubj));
n_train_sub = nSubj-1;

for i=1:nSubj
%     fprintf('Training LOSO iteration %d/%d...\n',i,nSubj);
    iTrain = [1:i-1, i+1:nSubj];
    for j=1:nROIs
        [~,stats] = robustfit(activity(j,iTrain),behav(iTrain));
        cp(j,i)    = stats.p(2);
        cr(j,i)    = sign(stats.t(2))*sqrt((stats.t(2)^2/(n_train_sub-2))/(1+(stats.t(2)^2/(n_train_sub-2))));
    end
end
% fprintf('Done!\n');

%% Threshold, score, and plot
% thresh = 1;
score = nan(nSubj,1);
for i=1:nSubj
    isPos(:,i) = cp(:,i)<thresh & cr(:,i)>0;
    isNeg(:,i) = cp(:,i)<thresh & cr(:,i)<0;
    score(i) = activity(:,i)'*(isPos(:,i)-isNeg(:,i))/sum(isPos(:,i)+isNeg(:,i));
end

networks = all(isPos,2) - all(isNeg,2);

