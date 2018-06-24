function [p,posterior,p2,posterior2] = test_logisticregression_jittered_EM_v3p0(testsample,windowlength,windowoffset,v,jitterPrior,srate,pop_settings)

% Test the results of pop_logisticregression_jittered() on a test sample.
%
% [y,jitter] = test_logisticregression_jittered_EM_v3p0(testsample,windowlength,
%              windowoffset,jitterrange,v,jitterPrior,srate,pop_settings)
%
% INPUTS:
% -testsample is an dxn matrix of eeg data from a single trial, where d is
% the number of electrodes and n is the number of samples.
% -windowlength is the number of samples that were in your training window.
% -windowoffset is the offset of the center of your window, in samples,
% from the start of the trial.
% -jitterrange is a 2-element vector of min and max jitter values, in units of samples.
% -v is a (d+1)-element vector containing the spatial weights and bias 
% learned from pop_logisticregression_jittered(). 
% -jitterPrior is a struct with fields fn (a function pointer) and params
% (a struct containing the saccade times and other parameters that function
% needs).
% -srate is a constant indicating the sampling rate in Hz.
% -pop_settings is a struct indicating the options used in training
% (pop_logisticregression_jittered_EM.m), which should match those used in
% testing (this function).
%
% OUTPUTS:
% -y is the y value learned for this trial.
% -jitter is the jitter of this trial in samples, relative to windowoffset.
%
% Created 3/2/11 by DJ.
% Updated 9/14/11 by DJ & BC - forceOneWinner option, posterior0/1
% Updated 9/16/11 by DJ - added useTwoPosteriors option
% Updated 9/20/11 by DJ - added pop_settings struct, deNoiseData option
% Updated 10/4/11 by DJ - added useSymmetricLikelihood option (TO DO: fix)
% Updated 12/12/11 by DJ - added null_sigmamultiplier usage
% Updated 9/17/12 by DJ - fixed posteriors for useTwoPosteriors=0, forceOneWinner=1
% Updated 10/1/12 by DJ - smooth data up front (for speed), multiple trials & offsets
% Updated 10/5/12 by DJ - v2p1
% ...
% Updated 11/30/12 by DJ - fixed forceOneWinner p values

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
noffsets = length(windowoffset);

% Define initial prior
[prior,priortimes] = jitterPrior.fn((1000/srate)*(jitterrange(1):jitterrange(2)),jitterPrior.params);
priorrange = round((srate/1000)*[min(priortimes),max(priortimes)]);
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

TEST = false;
if TEST
    prior(:) = 1;
end

% Set up
[p,p2] = deal(nan(ntrials,noffsets));
[posterior,posterior2] = deal(nan(ntrials,length(priortimes),noffsets));

% Main loop
for i = 1:noffsets
    % Extract samples that could possibly be in the window
    iwindow = (windowoffset(i)+priorrange(1)) : (windowoffset(i)+priorrange(2));
    % croppeddata = smoothdata(:,iwindow);
    croppeddata = smoothdata(:,iwindow,:);
    % Reshape into 2D matrix
    croppeddata = reshape(croppeddata,[size(croppeddata,1),ntrials*length(iwindow)])';

    % Find the y value for each sample
    yvec = croppeddata*v(i,1:end-1)'+v(i,end); % vector version of y
    likevec = bernoull(ones(size(yvec)),yvec); % vector version of likelihook

    % Reshape back into 2D matrix
    ymat = reshape(yvec,length(yvec)/ntrials,ntrials)'; % (NxT) matrix version of y
    likelihood = reshape(likevec,length(likevec)/ntrials,ntrials)'; % (NxT) matrix version of y

    % Condition prior on y based on null distribution
    if pop_settings.conditionPrior
        condprior = exp(abs(ymat)).*prior;
%        condprior = (1-normpdf(ymat,null_mu,null_sigma*null_sigmamultiplier)/normpdf(0,0,null_sigma*null_sigmamultiplier)).*prior; % prior conditioned on y (p(t|y))
        condprior = condprior./repmat(sum(condprior,2),1,size(condprior,2)); % normalize so each trial sums to 1
    else
        condprior = prior;
    end

    % Compute posterior if c=0 or c=1
    posterior(:,:,i) = likelihood.*condprior; % p(t, c=1|v)
    posterior2(:,:,i) = (1-likelihood).*condprior; % p(t, c=0|v)
    if pop_settings.forceOneWinner
        [p(:,i),iMax] = max(posterior(:,:,i),[],2);
        posterior(:,:,i) = full(sparse(1:length(iMax),iMax,1,size(posterior,1),size(posterior,2)));            
        [p2(:,i),iMax] = max(posterior2(:,:,i),[],2);
        posterior2(:,:,i) = full(sparse(1:length(iMax),iMax,1,size(posterior2,1),size(posterior2,2)));            
        p = p./(p+p2);
        p2 = 1-p;
    else
        p(:,i) = sum(posterior(:,:,i),2);
        p2(:,i) = sum(posterior2(:,:,i),2);
    end
    
    % If any p values exceed 1 (probably due to round-off error), warn the user
    if max(max(p)) > (1+eps)
        [ix,iy] = find(p>1+eps);
        warning('DJ:test_v3p0:pval','p([%s],[%s]) is larger than 1!',num2str(ix'),num2str(iy'));
    end
    
end


