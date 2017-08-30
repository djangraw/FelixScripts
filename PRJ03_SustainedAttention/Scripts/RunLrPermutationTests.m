function [Az,AzLoo,wts,wtsLoo] = RunLrPermutationTests(training,truth,nPerms,params)

% RunPermutationTests(training,truth,cvmode)
%
% Created 7/2/15 by DJ.
% Updated 8/13/15 by DJ - added wts and wtsLoo outputs.

% set up
nTrials = size(training,1);
nFeats = size(training,2);
Az = zeros(1,nPerms);
AzLoo = zeros(1,nPerms);
wts = zeros(nFeats+1,nPerms);
wtsLoo = zeros(nFeats+1,nPerms);
% make training data 2D
if size(training,3)==1
    disp('reorienting training data...');
    training = permute(training,[2 3 1]);
end

% main loop
fprintf('Running %d permutations...\n',nPerms);
for i=1:nPerms
    % upadte status bar
    fprintf('.');
    if mod(i,100)==0
        fprintf('%d\n',i);
    end
    % run permutation
    truth_perm = truth(randperm(nTrials));
    [Az(:,i), AzLoo(:,i), LRstats] = RunSingleLR(training,truth_perm,params);
    % save out weights
    if nargout>2
        wts(:,i) = LRstats.wts;
        if nargout>3
            wtsLoo(:,i) = mean(LRstats.wtsLoo,2);
        end
    end
end
fprintf('Done!\n');