function [Vout] = FindMultiWindowWeights_v1p2(alldata,truth,trainingwindowoffset,posterior,priortimes,vinit,logist_settings)

% Created 12/11/12 by DJ.
% Updated 12/18/12 by DJ - v1p1
% Updated 12/19/12 by DJ - v1p2 (soft EM: changed jitter input to posterior)
% Updated 12/28/12 by DJ - cleanup, comments

% Set up
show = 0;
UnpackStruct(logist_settings);

% Get size parameters
nChan = size(alldata,1);
nOffsets = numel(trainingwindowoffset);
nTrials = size(alldata,3);
nJitters = size(posterior,2);
iJitters = priortimes;

% Get sample-by-sample truth and posterior values
[~,~,truthsamples] = meshgrid(1:nJitters,1,truth);
truthsamples = truthsamples(:); % put in vector
post = reshape(posterior',numel(posterior),1);

% Find indices of non-nan values within Vout matrix
newoffset = trainingwindowoffset - min(trainingwindowoffset)+1; % indices of Xout

% Declare Vout
Vout = nan(size(alldata,1)+1,max(newoffset));
% Learn weights for each offset
% fprintf('Learning weights...');
for i=1:nOffsets
    % Reshape weights and data for compatibility with logist_weighted
    wts = vinit(:,i);    
    data = reshape(alldata(:,trainingwindowoffset(i)+iJitters,:),[nChan,nJitters*nTrials])'; % make data into 2d matrix       
    % Find weights for this offset
    v = logist_weighted(data,truthsamples,wts,post,show,regularize,lambda,lambdasearch,eigvalratio);
    % save results
    Vout(:,newoffset(i)) = v';    
end

% fprintf('Done.\n');

end % function FindMultiWindowWeights_v1p0
