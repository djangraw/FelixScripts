function D = sumprior(prior,trainingwindowlength)

% Calculate the sum of a prior over a shifting training window.
%
% D = sumprior(prior,trainingwindowlength)
% 
% INPUTS:
% - prior is an mxn matrix, where m is the number of trials and n is the 
% assumed limit for jitter on a trial (including positive and negative 
% jitters).  prior = p(t_i|x_i,y_i,v) for the current iteration of logistic 
% regression, where t=jitter, x=data, y=truth, and v=spatial weights.
% - trainingwindowlength is the number of samples in each training window -
% that is, the width of the window over which we want to take a sum.
% 
% OUTPUTS:
% - D is an m-row matrix with n+trainingwindowlength-1 columns. It contains
% the sum over the training window at that particular jitter.  The first
% element in row i should equal prior(i,1), and the last should equal prior(i,end).
%
% Created 3/14/11 by DJ.
% Updated 8/25/11 by DJ - comments

% set up
ntrials = size(prior,1);
prior_padded = [zeros(ntrials,trainingwindowlength-1), prior, zeros(ntrials,trainingwindowlength-1)];
D = zeros(ntrials,size(prior,2)+trainingwindowlength-1);

% Take sum
for k=1:size(D,2)
    D(:,k) = sum(prior_padded(:,(1:trainingwindowlength)+k-1),2);
end