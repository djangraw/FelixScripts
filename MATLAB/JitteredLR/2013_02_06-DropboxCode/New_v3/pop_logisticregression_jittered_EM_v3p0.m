% pop_logisticregression_jittered_EM_v3p0() - Determine linear discriminating vector between two datasets.
%                       using logistic regression on data where jitter of
%                       each trial is uncertain with Expectation
%                       Maximization
%
% Usage:
%   >> pop_logisticregression_jittered_EM_v3p0( ALLEEG, datasetlist, chansubset, trainingwindowlength, trainingwindowoffset, regularize, lambda, lambdasearch, eigvalratio, vinit, jitterrange, convergencethreshold, jitterPrior);
%
% Inputs:
%   ALLEEG               - array of datasets
%   datasetlist          - list of datasets
%   chansubset           - vector of channel subset for dataset 1          [1:min(Dset1,Dset2)]
%   trainingwindowlength - Length of training window in samples            [all]
%   trainingwindowoffset - Offset(s) of training window(s) in samples      [1]
%   regularize           - regularize [1|0] -> [yes|no]                    [0]
%   lambda               - regularization constant for weight decay.       [1e-6]
%                            Makes logistic regression into a support 
%                            vector machine for large lambda
%                            (cf. Clay Spence)
%   lambdasearch         - [1|0] -> search for optimal regularization 
%                            constant lambda
%   eigvalratio          - if the data does not fill D-dimensional
%                            space, i.e. rank(x)<D, you should specify 
%                            a minimum eigenvalue ratio relative to the 
%                            largest eigenvalue of the SVD.  All dimensions 
%                            with smaller eigenvalues will be eliminated 
%                            prior to the discrimination. 
%   vinit                - initialization for faster convergence           [zeros(D+1,1)]
%   jitterrange          - 2-element vector specifying the minimum and
%                           maximum jitter values (in units of samples)
%   convergencethreshold - max change in Az that must be observed in order
%                          for the iteration loop to exit. [.01]
%   jitterPrior          - a structure containing params for the jitter
%                            prior pdf with the following fields:
%                           fn: a function handle that returns the prior
%                               pdf
%                           params: a structure of PDF parameters to pass
%                               to the prior pdf function
%                           The fn should be prototyped as follows:
%                           function pdf = @fn(t,params)
%                               Where t is a set of points to evaluate the
%                               pdf at
%
% References:
%
% @article{gerson2005,
%       author = {Adam D. Gerson and Lucas C. Parra and Paul Sajda},
%       title = {Cortical Origins of Response Time Variability
%                During Rapid Discrimination of Visual Objects},
%       journal = {{NeuroImage}},
%       year = {in revision}}
%
% @article{parra2005,
%       author = {Lucas C. Parra and Clay D. Spence and Adam Gerson 
%                 and Paul Sajda},
%       title = {Recipes for the Linear Analysis of {EEG}},
%       journal = {{NeuroImage}},
%       year = {in revision}}
%
% Authors: Dave Jangraw (dcj2110@columbia.edu, 2011)
%          Bryan Conroy (bc2468@columbia.edu,2011)
% Based on program pop_logisticregression, coded by:
%          Adam Gerson (adg71@columbia.edu, 2004),
%          with Lucas Parra (parra@ccny.cuny.edu, 2004)
%          and Paul Sajda (ps629@columbia,edu 2004)

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2004 Adam Gerson, Lucas Parra and Paul Sajda
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% 5/21/2005, Fixed bug in leave one out script, Adam
% 4/2011 - Adjusted for jittered EM algorithm, Bryan & Dave
% 5/20/2011 - Added weightprior capability, Dave
% 8/3/2011 - Allow flexible prior size using priorrange, Bryan
% 8/24/2011 - Fixed plotting bug (jitterrange -> priorrange), Dave 
% 9/6/2011 - 1st iteration prior is first saccade on each trial, Dave
% 9/12/2011 - added removeBaselineYVal option, Bryan & Dave
% 9/14/2011 - added forceOneWinner option, fwdmodel uses y2, ellv 
%   calculated using bp, Dave & Bryan 
% 9/15/2011 - added forceOneWinner to ComputePosteriorLabel, Dave
% 9/16/2011 - fixed weightprior bug in ComputePosterior, added 
%   useTwoPosteriors option, Dave
% 9/19/2011 - save settings to etc fields of ALLEEG, Dave
% 9/20/2011 - deNoiseData option, Dave
% 10/4/2011 - useSymmetricLikelihood option, Dave - NO LONGER USED
% 10/6/2011 - conditionPrior option, cleaned up pop_settings, Dave
% 12/12/2011 - added sigmamultiplier option, Dave
% 9/18/2012 - smooth eeg up front, added GetNullDistribution to make
%   conditionPrior option work without saccade-based data (everything 
%   outside the priorrange window is considered 'null' data), Dave
% 9/21/2012 - TEMP: vFirstIter output, D initialized to D from base workspace, Dave
% 9/24/2012 - fixed smootheeg scaling (divided by trainingwindowlength), Dave
% 9/25/2012 - added ptprior_truprior etc., Dave
% 9/25/2012 - made work with conditionPrior off, Dave
% 10/1/2012 - weighted forward model calculation, Dave
% 10/2/2012 - include sigmamultiplier in posterior calculations, calculte
%   posteriors at the end for weighted fwdmodel, Dave
% 10/5/2012 - v2p1, Dave
% 11/14/2012 - code cleanup, consolidated condPrior options
% 11/15/2012 - switched to _betatest_v2p2, removed trainingwindowlength
%   input to that fn, Dave
% ...
% 11/27-29/2012 - added useOffset setting, PlotDebugFigs function, fixed forceOneWinner py values, Dave

function [ALLEEG, com, vout, vFirstIter] = pop_logisticregression_jittered_EM_v3p0(ALLEEG, setlist, chansubset, trainingwindowlength, trainingwindowoffset, vinit, jitterPrior, pop_settings, logist_settings)

% Set plot settings
show=0; % don't show boundary
showaz=1; % display Az values as we iterate
plotdebugfigs = 0; % plot posteriors, likelihoods, weight vector scalp maps as we iterate
    
% Unpack options
UnpackStruct(pop_settings);
UnpackStruct(logist_settings);
if ~exist('useOffset','var'), useOffset = false; end % set default here for use with old versions of wrapper code

com = '';
if nargin < 1
    help pop_logisticregression_jittered_EM;
    return;
end;   
if isempty(ALLEEG)
    error('pop_logisticregression_jittered_EM(): cannot process empty sets of data');
end;
if jitterrange(1) > jitterrange(2)
    error('jitterrange must be 2-element vector sorted in ascending order!');
end

% Set up truth labels (one for each data sample in the window on each trial
ALLEEG(setlist(1)).trials = size(ALLEEG(setlist(1)).data,3);
ALLEEG(setlist(2)).trials = size(ALLEEG(setlist(2)).data,3);
ntrials1 = ALLEEG(setlist(1)).trials;
ntrials2 = ALLEEG(setlist(2)).trials;
truth_trials = [zeros(ntrials1,1);ones(ntrials2,1)]; % The truth value associated with each trial

% Initialize ica-related fields
ALLEEG(setlist(1)).icaweights=zeros(length(trainingwindowoffset),ALLEEG(setlist(1)).nbchan);
ALLEEG(setlist(2)).icaweights=zeros(length(trainingwindowoffset),ALLEEG(setlist(2)).nbchan);
% In case a subset of channels are used, assign unused electrodes in scalp projection to NaN
ALLEEG(setlist(1)).icawinv=nan.*ones(length(trainingwindowoffset),ALLEEG(setlist(1)).nbchan)';
ALLEEG(setlist(2)).icawinv=nan.*ones(length(trainingwindowoffset),ALLEEG(setlist(2)).nbchan)';
ALLEEG(setlist(1)).icasphere=eye(ALLEEG(setlist(1)).nbchan);
ALLEEG(setlist(2)).icasphere=eye(ALLEEG(setlist(2)).nbchan);
% Initialize vout
vout = nan(length(trainingwindowoffset),length(chansubset)+1);

% Extract data
raweeg1 = ALLEEG(setlist(1)).data(chansubset,:,:);
raweeg2 = ALLEEG(setlist(2)).data(chansubset,:,:);
% Smooth data
smootheeg1 = nan(size(raweeg1,1),size(raweeg1,2)-trainingwindowlength+1, size(raweeg1,3));
smootheeg2 = nan(size(raweeg2,1),size(raweeg2,2)-trainingwindowlength+1, size(raweeg2,3));
for i=1:size(raweeg1,3)
     smootheeg1(:,:,i) = conv2(raweeg1(:,:,i),ones(1,trainingwindowlength)/trainingwindowlength,'valid'); % valid means exclude zero-padded edges without full overlap
end
for i=1:size(raweeg2,3)
     smootheeg2(:,:,i) = conv2(raweeg2(:,:,i),ones(1,trainingwindowlength)/trainingwindowlength,'valid'); % valid means exclude zero-padded edges without full overlap
end


% Define initial prior
[ptprior,priortimes] = jitterPrior.fn((1000/ALLEEG(setlist(1)).srate)*(jitterrange(1):jitterrange(2)),jitterPrior.params);
priorrange = round((ALLEEG(setlist(1)).srate/1000)*[min(priortimes),max(priortimes)]);
truth=[zeros((diff(priorrange)+1)*ntrials1,1); ones((diff(priorrange)+1)*ntrials2,1)];

DEBUG_BRYAN = false;
if DEBUG_BRYAN
    addpath('~/Dropbox/JitteredLogisticRegression/code/ReactionTimeRecovery/PlotResults/');
    [jitter_truth,~] = GetJitter(ALLEEG,'facecar');
    jitter_truth_inds = interp1(priortimes,1:numel(priortimes),jitter_truth,'nearest');
end
DEBUG_BRYAN = false;

% make sure training windows fit within size of data
if max(trainingwindowlength+trainingwindowoffset+priorrange(2)-1)>ALLEEG(setlist(1)).pnts,
    error('pop_logisticregression_jitter(): training window exceeds length of dataset 1');
end
if max(trainingwindowlength+trainingwindowoffset+priorrange(2)-1)>ALLEEG(setlist(2)).pnts,
    error('pop_logisticregression_jitter(): training window exceeds length of dataset 2');
end

% Make prior into a matrix and normalize rows 
if size(ptprior,1) == 1
    % Then the prior does not depend on the trial
    ptprior = repmat(ptprior,ntrials1+ntrials2,1);
end
% Ensure the rows sum to 1
ptprior = ptprior./repmat(sum(ptprior,2),1,size(ptprior,2));

% Re-weight priors according to the number of trials in each class
if weightprior
    ptprior(truth_trials==1,:) = ptprior(truth_trials==1,:) / sum(truth_trials==1);
    ptprior(truth_trials==0,:) = ptprior(truth_trials==0,:) / sum(truth_trials==0);
end

if plotdebugfigs
    PlotDebugFigures(0,vinit,ptprior,priorrange,nan(size(ptprior)),nan(size(ptprior)),truth_trials,ntrials1+2,ALLEEG)
end

%%% MAIN LOOP %%%
MAX_ITER = 50; % the max number of iterations allowed
for i=1:length(trainingwindowoffset) % For each training window   
    % Get mean (1xD) and covariance (DxD) for the null samples on each electrode
    if conditionPrior
        [nullx.mu, nullx.covar] = GetNullDistribution(smootheeg1,smootheeg2,trainingwindowoffset(i),priorrange);
        nully.sigmamultiplier = null_sigmamultiplier; % widen distribution by the specified amount
    else
        nully = [];
    end     
    tllv = -inf; % true log likelihood - should increase on each iteration.
    
    % Put de-jittered data into [D x (N*T] matrix for input into logist
    [x, trialnum] = AssembleData(smootheeg1,smootheeg2,trainingwindowoffset(i),priorrange);
%        for j=1:size(x,1)
%            x(j,:) = x(j,:)/max(sqrt(sum(x(j,:).^2)),1e-8);            
%        end
    % get D vector
    D = ptprior;
    if DEBUG_BRYAN
        
        for j=1:size(D,1)
            D(j,:)=0;
            D(j,jitter_truth_inds(j))=1;
        end
%        ptprior(:)=1/size(ptprior,2);
    end
    Dvec = reshape(D',1,numel(D));
    ptpriorvec = reshape(ptprior',1,numel(ptprior));

    % Calculate weights using logistic regression
%     v = logist_weighted_v2p1(x,truth,vinit,Dvec',show,regularize,lambda,lambdasearch,eigvalratio); % calculate logistic regression weights
    v = logist_weighted_betatest_v3p0(x,truth,vinit,Dvec',show,regularize,lambda,lambdasearch,eigvalratio,[],trialnum,ptpriorvec',useOffset); % calculate logistic regression weights        
    if ~useOffset
        v(end) = 0;
    end
    
    % Update null y distribution
    if conditionPrior        
        nully.mu = nullx.mu'*v(1:end-1)+v(end);
        nully.sigma = sqrt(v(1:end-1)'*nullx.covar*v(1:end-1) + v(1:end-1)'*(nullx.mu'*nullx.mu)*v(1:end-1));    
    end
    % Store results from first iteration
    vFirstIter = v;
    % Calculate y values given these weights
    y = x*v(1:end-1) + v(end); 

    % Compute the true log-likelihood value:
    % sum_over_trials(log(sum_over_saccades(p(c|y,ti)*p(ti|y))))
    tllv = [tllv sum(log(ComputePosteriorLabel(ptprior,y,truth,forceOneWinner,conditionPrior,nully)))-lambda/4*sum(v(1:end-1).^2)];
    
    % adjust posterior
	[py, ~] = ComputePosteriorLabel(ptprior,y,ones(size(y)),forceOneWinner,conditionPrior,nully);
    nully.sigmamultiplier = null_sigmamultiplier; % widen distribution by the specified amount
    
    % Calculate ROC curve and Az value
    [Az,Ry,Rx] = rocarea(py,truth_trials); % find ROC curve
    % Initialize list of iteration results
    iterAz = [NaN Az]; % NaN included so indices will match tllv,etc.
        
    % Display results
    if showaz, fprintf('Window Onset: %d; iteration %d; Az: %6.3f; Average weight/sample (in LR): %.2f\n',trainingwindowoffset(i),length(iterAz)-1,Az,sum(Dvec)/length(Dvec)); end
    vprev = zeros(size(v));
    
    while subspace(vprev+eps,v)>convergencethreshold 
        vprev = v;
        % adjust prior
        [D,lkhd,cndp] = ComputePosterior(ptprior,y,truth,weightprior,forceOneWinner,conditionPrior,nully);
        
        if plotdebugfigs
            PlotDebugFigures(length(iterAz)-1,v,D,priorrange,lkhd,cndp,py,ntrials1+2,ALLEEG)
        end
        
        % Now we will update ptprior
        % Fit ex-gaussian to mean of D
%R=fminsearch(@(params) eglike(params,data),pinit);  % given the data, and starting parameters in
                                            % pinit, find the parameter values that minimize eglike	
											% the function returns R=[mu, sig, tau]        
        
%        ptprior = repmat(mean(D),size(ptprior,1),1);reshape(ptprior',1,numel(ptprior));
        Dvec = reshape(D',1,numel(D));
        
        % Calculate weights using logistic regression
        
        % Calculate weights
%         v = logist_weighted(x,truth,v,Dvec',show,regularize,lambda,lambdasearch,eigvalratio); % without nully distribution                    
        v = logist_weighted_betatest_v3p0(x,truth,v,Dvec',show,regularize,lambda,lambdasearch,eigvalratio,nully,trialnum,ptpriorvec',useOffset); % calculate logistic regression weights        
        if ~useOffset
            v(end) = 0;
        end

        y = x*v(1:end-1) + v(end); % calculate y values given these weights
%         yprev = x*vprev(1:end-1) + vprev(end);
        
        % Compute the true log-likelihood value: sum_over_trials(log(sum_over_saccades(p(c|y,ti)*p(ti|y))))
        tllv = [tllv sum(log(ComputePosteriorLabel(ptprior,y,truth,forceOneWinner,conditionPrior,nully)))-lambda/4*sum(v(1:end-1).^2)];
        % adjust posterior
        [py, ~] = ComputePosteriorLabel(ptprior,y,ones(size(y)),forceOneWinner,conditionPrior,nully);
                
        % Prevent infinite loop
        if length(iterAz)>MAX_ITER;
            break; 
        end
        
        % Calculate ROC curve and Az value
        Az = rocarea(py,truth_trials); % find ROC curve        
        iterAz = [iterAz Az]; % Add to list of iteration results
        % Display results        
        if showaz, fprintf('Window Onset: %d; iteration %d; Az: %6.3f; TLLVold: %.2f, TLLV: %.2f; Pct change in filter weights: %.2f; Weight subspace: %.2f; Average weight/sample (in LR): %.2f\n',...
                trainingwindowoffset(i),length(iterAz)-1,Az,tllv(end-1),tllv(end),100*sqrt(sum((v-vprev).^2))/sqrt(sum(vprev.^2)),subspace(vprev+eps,v),sum(Dvec)/length(Dvec)); 
        end
    end
    
    % Display results
    if showaz, fprintf('Window Onset: %d; FINAL Az: %6.3f\n',trainingwindowoffset(i),Az); end
    AzAll(i) = Az; % record Az value
    
    if 0
        locs0 = find(truth_trials==0);
        [~,ord0] = sort(jitter_truth_inds(locs0),'descend');
        locs1 = find(truth_trials==1);
        [~,ord1] = sort(jitter_truth_inds(locs1),'descend');
        A = D(locs0(ord0),:);
        figure;
        subplot(1,2,1);
        imagesc(A);colorbar;
        hold on;scatter(jitter_truth_inds(locs0(ord0)),1:numel(ord0),50,'black','filled');
        subplot(1,2,2);
        A = D(locs1(ord1),:);
        imagesc(A);colorbar;
        hold on;scatter(jitter_truth_inds(locs1(ord1)),1:numel(ord1),50,'black','filled');
        [~,q]=max(D,[],2);corr(q,jitter_truth_inds')
        mp1=0;mp2=0;for j=1:numel(jitter_truth_inds);mp1=mp1+D(j,jitter_truth_inds(j));mp2=mp2+ptprior(j,jitter_truth_inds(j));end;[mp1,mp2]/numel(jitter_truth_inds)
    end
    
    % Compute forward model
    [D,~] = ComputePosterior(ptprior,y,truth,weightprior,forceOneWinner,conditionPrior,nully); % Get posterior one last time
    Dvec = reshape(D',1,numel(D));
    Dmat = repmat(Dvec',1,size(x,2)); % Make a matrix the size of x
    a = y \ (x.*Dmat); % weight x by Dmat before dividing
    
    % Save newly-determined weights and forward model to EEG struct
    ALLEEG(setlist(1)).icaweights(i,chansubset)=v(1:end-1)';
    ALLEEG(setlist(2)).icaweights(i,chansubset)=v(1:end-1)';
    ALLEEG(setlist(1)).icawinv(chansubset,i)=a'; % consider replacing with asetlist1
    ALLEEG(setlist(2)).icawinv(chansubset,i)=a'; % consider replacing with asetlist2 
    % Save weights to output    
    vout(i,:) = v';    
end;

% Save settings to etc field of struct
if conditionPrior
    pop_settings.null_mu = nully.mu;
    pop_settings.null_sigma = nully.sigma;
else
    pop_settings.null_mu = NaN;
    pop_settings.null_sigma = NaN;
end
ALLEEG(setlist(1)).etc.pop_settings = pop_settings;
ALLEEG(setlist(2)).etc.pop_settings = pop_settings;   
ALLEEG(setlist(1)).etc.posteriors = D(truth_trials==0, :);
ALLEEG(setlist(2)).etc.posteriors = D(truth_trials==1, :);

% Declare command string for output
com = sprintf('pop_logisticregression_jittered_EM( %s, [%s], [%s], [%s], [%s]);',...
    inputname(1), num2str(setlist), num2str(chansubset), ...
    num2str(trainingwindowlength), num2str(trainingwindowoffset));
fprintf('Done.\n');
return;

end % function pop_logisticregression_jittered


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       HELPER FUNCTIONS                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [muX,covarX] = GetNullDistribution(data1,data2,thistrainingwindowoffset,jitterrange) 
    % Crop data to null parts
%     inull = [1:(thistrainingwindowoffset+jitterrange(1)-1), (thistrainingwindowoffset+jitterrange(2)+trainingwindowlength):length(data1)];
    inull = [1:(thistrainingwindowoffset+jitterrange(1)-1), (thistrainingwindowoffset+jitterrange(2)+1):size(data1,2)];
    X = cat(3,data1(:,inull,:),data2(:,inull,:));
    X = reshape(X,[size(X,1),size(X,3)*length(inull)]);
    % Get mean and std
    muX = mean(X,2);
    covarX = X*X'/size(X,2); % if y=v*X, std(y,1)=sqrt(v*covarX*v'-v*muX^2);
    % if y=w*X+b, std(y,1) = sqrt(w*covarX*w' + w*muX*muX'*w')
    
end % function GetNullDistribution


% FUNCTION AssembleData:
% Put de-jittered data into [(N*T) x D] matrix for input into logist
function [x, trialnum] = AssembleData(data1,data2,thistrainingwindowoffset,jitterrange) 
    % Declare constants
    iwindow = (thistrainingwindowoffset+jitterrange(1)) : (thistrainingwindowoffset+jitterrange(2));
    % Concatenate trials from 2 datasets
    x = cat(3,data1(:,iwindow,:),data2(:,iwindow,:));
    trialnum = repmat(reshape(1:size(x,3), 1,1,size(x,3)), 1, size(x,2));
    % Reshape into 2D matrix
    x = reshape(x,[size(x,1),size(x,3)*length(iwindow)])';
    trialnum = reshape(trialnum,[size(trialnum,1),size(trialnum,3)*length(iwindow)])';
    
end % function AssembleData


function [posteriorLabel, condprior] = ComputePosteriorLabel(prior, y, truth, forceOneWinner,conditionPrior,nully)
    % Put y and truth into matrix form 
    ntrials = size(prior,1);
    ymat = reshape(y,length(y)/ntrials,ntrials)';
    truthmat = reshape(truth,length(truth)/ntrials,ntrials)';    
    % Calculate likelihood
    likelihood = bernoull(truthmat,ymat);    
    % Condition prior on y value: more extreme y values indicate more informative time points
    if conditionPrior 
        condprior = exp(abs(ymat)).*prior;
%        condprior = (1-normpdf(ymat,nully.mu,nully.sigma*nully.sigmamultiplier)/normpdf(0,0,nully.sigma*nully.sigmamultiplier)).*prior; % prior conditioned on y (p(t|y))
        condprior = condprior./repmat(sum(condprior,2),1,size(condprior,2)); % normalize so each trial sums to 1
    else
        condprior = prior;
    end    
    % Calculate posterior label
    posterior = likelihood.*condprior;
    if forceOneWinner
        posterior2 = (1-likelihood).*condprior;
        p = max(posterior,[],2);
        p2 = max(posterior2,[],2);
        posteriorLabel = p./(p+p2);
    else
        posteriorLabel = sum(posterior,2);
    end

end % function ComputePosteriorLabel


function [posterior,likelihood,condprior] = ComputePosterior(prior, y, truth,weightprior,forceOneWinner,conditionPrior,nully)
    % Put y and truth into matrix form 
    ntrials = size(prior,1);
    ymat = reshape(y,length(y)/ntrials,ntrials)';
    truthmat = reshape(truth,length(truth)/ntrials,ntrials)';
    % Calculate likelihood
    likelihood = bernoull(truthmat,ymat);
    % Condition prior on y value: more extreme y values indicate more informative time points
    if conditionPrior % (NOTE: normalization not required, since we normalize later)
%        condprior = (1-normpdf(ymat,nully.mu,nully.sigma*nully.sigmamultiplier)/normpdf(0,0,nully.sigma*nully.sigmamultiplier)).*prior; % prior conditioned on y (p(t|y))    
        condprior = exp(abs(ymat)).*prior;
    else
        condprior = prior;
    end
    condprior = condprior./repmat(sum(condprior,2),1,size(condprior,2));
    
    % Calculate posterior
    posterior = likelihood.*condprior;
    % If requested, make all posteriors 0 except max
    if forceOneWinner
        [~,iMax] = max(posterior,[],2); % finds max posterior on each trial (takes first one if there's a tie)
        posterior = full(sparse(1:size(posterior,1),iMax,1,size(posterior,1),size(posterior,2))); % zeros matrix with 1's at the iMax points in each row
    end
    % Normalize rows
    posterior = posterior./repmat(sum(posterior,2),1,size(posterior,2));
    % Re-weight priors according to the number of trials in each class
    if weightprior
        posterior(truthmat(:,1)==1,:) = posterior(truthmat(:,1)==1,:) / sum(truthmat(:,1)==1);
        posterior(truthmat(:,1)==0,:) = posterior(truthmat(:,1)==0,:) / sum(truthmat(:,1)==0);
    end

end % function ComputePosterior


function PlotDebugFigures(iter,v,D,priorrange,lkhd,cndp,py,iTrialToPlot,ALLEEG)    
    % Set up
    nRows = 2;
    nCols = 2;
    iPlot = mod(iter,nRows*nCols)+1;    
    [jitter_truth,truth_trials] = GetJitter(ALLEEG,'facecar');
    n1 = ALLEEG(1).trials;
    n2 = ALLEEG(2).trials;

    % Initialize figures
    if iter==0     
        for iFig = 111:117
            figure(iFig); clf;
        end
    end       
    
    % Plot v
    figure(111);
    subplot(nRows,nCols,iPlot); cla;
    topoplot(v(1:end-1),ALLEEG(2).chanlocs);
    title(sprintf('iter %d weight vector (raw)\n (bias = %0.2g)(t=%gs)',iter,v(end),NaN))
    colorbar;
    
    % Plot likelihood
    figure(112);
    subplot(nRows,nCols,iPlot); cla; hold on;
    ImageSortedData(lkhd(1:n1,:),priorrange,1:n1,jitter_truth(1:n1)); colorbar;
    ImageSortedData(lkhd(n1+1:end,:),priorrange,n1+(1:n2),jitter_truth(n1+1:end)); colorbar;
    axis([min(priorrange) max(priorrange) 1 n1+n2])
    title(sprintf('iter %d Likelihood',iter));
    xlabel('Jitter (samples)');
    ylabel('Trial');

    % Plot conditioned prior
    figure(113);
    subplot(nRows,nCols,iPlot); cla; hold on;
    ImageSortedData(cndp(1:n1,:),priorrange,1:n1,jitter_truth(1:n1)); colorbar;
    ImageSortedData(cndp(n1+1:end,:),priorrange,n1+(1:n2),jitter_truth(n1+1:end)); colorbar;
    axis([min(priorrange) max(priorrange) 1 n1+n2])
    title(sprintf('iter %d Conditioned Prior',iter));
    xlabel('Jitter (samples)');
    ylabel('Trial');
        
    % Plot D
    figure(114);
    subplot(nRows,nCols,iPlot); cla; hold on;
    ImageSortedData(D(1:n1,:),priorrange,1:n1,jitter_truth(1:n1)); colorbar;
    ImageSortedData(D(n1+1:end,:),priorrange,n1+(1:n2),jitter_truth(n1+1:end)); colorbar;    
    title(sprintf('iter %d Posteriors',iter));
    axis([min(priorrange) max(priorrange) 1 n1+n2])
    xlabel('Jitter (samples)');
    if iter==0        
        title(sprintf('Priors p(t_i,c_i)'))            
    end    
    ylabel('Trial');

    % Plot probability of labels
    figure(115);
    subplot(nRows,nCols,iPlot); cla; hold on;
    plot(py);
    axis([1 n1+n2 0 1])
    PlotVerticalLines(n1+0.5,'r--');
    title(sprintf('iter %d p(c=1)',iter));
    xlabel('Trial');
    ylabel('Probability');

    % Plot MAP jitter vs. posterior at that jitter
    figure(116);
    subplot(nRows,nCols,iPlot); cla; hold on; 
    [~,maxinds] = max(D,[],2);
    locs = find(truth_trials==0)';
    jittervals = priorrange(1):priorrange(2);
    scatter(jittervals(maxinds(locs)),D(sub2ind(size(D),locs,maxinds(locs))),50,'blue','filled');
    locs = find(truth_trials==1)';    
    scatter(jittervals(maxinds(locs)),D(sub2ind(size(D),locs,maxinds(locs))),50,'red','filled');
    if priorrange(2)>priorrange(1)
        xlim([priorrange(1),priorrange(2)]);
    end
    title(sprintf('iter %d MAP jitter',iter));
    legend('MAP jitter values (l=0)','MAP jitter values (l=1)','Location','Best');
    xlabel('Jitter (samples)');
    ylabel('Posterior at that jitter');

    % Plot posterior of single trial
    figure(117);
    subplot(nRows,nCols,iPlot); cla; hold on;
    plot((priorrange(1):priorrange(2))*1000/ALLEEG(1).srate,D(iTrialToPlot,:));
    PlotVerticalLines(jitter_truth(iTrialToPlot),'r--');
    xlabel('time (ms)')
    ylabel('p(t_i | c_i, y_i)')
    title(sprintf('iter %d Posterior of trial %d',iter,iTrialToPlot))
    if iter==0
        ylabel('p(t_i)')
        title(sprintf('Prior distribution of trial i=%d',iTrialToPlot))            
    end
    
    pause(0.5);
end
