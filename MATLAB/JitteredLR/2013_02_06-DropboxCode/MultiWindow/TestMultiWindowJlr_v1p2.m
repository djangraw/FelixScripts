function [p,posterior,p2,posterior2] = TestMultiWindowJlr_v1p2(testsample,windowlength,windowoffset,v,jitterPrior,srate,pop_settings)

% Created 12/14/12 by DJ
% Updated 12/18/12 by DJ - v1p1 (new computeJitterProbabilities fn)
% Updated 12/19/12 by DJ - v1p2 (soft EM)

% Set options
if ~exist('pop_settings','var');
    pop_settings.forceOneWinner = 0; % make all posteriors 0 except max (i.e. find 'best saccade' in each trial)
    pop_settings.conditionPrior = 0;
    pop_settings.jitterrange = [-500 500];
    pop_settings.null_mu = NaN;
    pop_settings.null_sigma = NaN; 
    pop_settings.null_sigmamultiplier = NaN; 
end
UnpackStruct(pop_settings);
ntrials = size(testsample,3);

% Define initial prior
[prior,priortimes] = jitterPrior.fn((1000/srate)*((jitterrange(1)+1):jitterrange(2)),jitterPrior.params);
% Fix up prior
if size(prior,1)==1
    % Then the prior does not depend on the trial
    prior = repmat(prior,ntrials,1);
end
% Ensure the rows sum to 1
prior = prior./repmat(sum(prior,2),1,size(prior,2));

% Smooth data with moving average window
smoothdata = nan(size(testsample,1),size(testsample,2)-windowlength+1, size(testsample,3));
for i=1:ntrials
    smoothdata(:,:,i) = conv2(testsample(:,:,i),ones(1,windowlength)/windowlength,'valid'); % valid means exclude zero-padded edges without full overlap
end

% Set up
% Get data across windows & jitters
iWindow = (min(windowoffset)+min(jitterrange)):(max(windowoffset)+max(jitterrange));
X = smoothdata(:,iWindow,:);
X(end+1,:,:) = 1; % add for offset usage

newoffset = windowoffset - min(windowoffset) + 1; % indices of vMat

% Manipulate weight matrix for input to computeJitterProbabilities
vMat = nan(size(X,1),max(newoffset));
vMat(:,newoffset) = v;

% Calculate posteriors and p values
useComboPosteriors = false; % find c=0 and c=1 posteriors, then use in place of priors to get p values
if useComboPosteriors
    pt0 = computeJitterProbabilities_v1p2(X,vMat,zeros(ntrials,1),prior,forceOneWinner);
    pt1 = computeJitterProbabilities_v1p2(X,vMat,ones(ntrials,1),prior,forceOneWinner);
    [~,~,pt2,p2] = computeJitterProbabilities_v1p2(X,vMat,zeros(ntrials,1),pt0,forceOneWinner);
    [~,~,pt,p] = computeJitterProbabilities_v1p2(X,vMat,ones(ntrials,1),pt1,forceOneWinner);
    % Duplicate for each window
    posterior = repmat(pt1,[1,1,length(windowoffset)]);
    posterior2 = repmat(pt0,[1,1,length(windowoffset)]);
else
    [~,~,pt,p] = computeJitterProbabilities_v1p2(X,vMat,ones(ntrials,1),prior,forceOneWinner);
    [~,~,pt2,p2] = computeJitterProbabilities_v1p2(X,vMat,zeros(ntrials,1),prior,forceOneWinner);
    % Rearrange and normalize 
    posterior = pt./repmat(sum(pt,2),1,size(pt,2));
    posterior2 = pt2./repmat(sum(pt2,2),1,size(pt2,2));
end
% p = p;
% p2 = p2;
