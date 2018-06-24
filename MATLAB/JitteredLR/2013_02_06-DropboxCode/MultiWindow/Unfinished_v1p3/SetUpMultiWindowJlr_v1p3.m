function [vOut,fmOut] = SetUpMultiWindowJlr_v1p3(ALLEEG, trainingwindowlength, trainingwindowoffset, vinit, jitterPrior, pop_settings, logist_settings)

% [vOut] = SetUpMultiWindowJlr_v1p3(ALLEEG, trainingwindowlength, trainingwindowoffset, vinit, pop_settings, logist_settings)
%
% INPUTS:
% -ALLEEG is 1x2, each with D electrodes
% -trainingwindowlength is a scalar
% -trainingwindowoffset is 1xP
% -vinit is DxP
% -pop_settings is a struct
% -logist_settings is a struct
%
% OUTPUTS:
% -vOut is DxP
%
% Created 12/11/12 by DJ.
% Updated 12/18/12 by DJ - v1p1 (computeJitterProbabilities has corrected
% posterior size, p values)
% Updated 12/19/12 by DJ - v1p2 (soft EM)
% Updated 12/28/12 by DJ - fmOut size correction
% Updated 1/8/13 by DJ - v1p3 (reward c'=c and penalize c'=-c)

plotdebugfigs = false;
   
vinit(vinit==0) = vinit(vinit==0)+1e-100;

% Unpack options
UnpackStruct(pop_settings); % convergencethreshold,jitterrange,weightprior,forceOneWinner,conditionPrior
UnpackStruct(logist_settings); % eigvalratio,lambda,lambdasearch,regularize,useOffset

% Set up truth labels (one for each data sample in the window on each trial
ntrials1 = ALLEEG(1).trials;
ntrials2 = ALLEEG(2).trials;

% Extract data
raweeg1 = ALLEEG(1).data(:,:,:);
raweeg2 = ALLEEG(2).data(:,:,:);
% Smooth data
smootheeg1 = nan(size(raweeg1,1),size(raweeg1,2)-trainingwindowlength+1, size(raweeg1,3));
smootheeg2 = nan(size(raweeg2,1),size(raweeg2,2)-trainingwindowlength+1, size(raweeg2,3));
for i=1:size(raweeg1,3)
     smootheeg1(:,:,i) = conv2(raweeg1(:,:,i),ones(1,trainingwindowlength)/trainingwindowlength,'valid'); % valid means exclude zero-padded edges without full overlap
end
for i=1:size(raweeg2,3)
     smootheeg2(:,:,i) = conv2(raweeg2(:,:,i),ones(1,trainingwindowlength)/trainingwindowlength,'valid'); % valid means exclude zero-padded edges without full overlap
end

% Get prior
[ptprior,priortimes] = jitterPrior.fn((1000/ALLEEG(1).srate)*((jitterrange(1)+1):jitterrange(2)),jitterPrior.params);
% Make prior into a matrix and normalize rows 
if size(ptprior,1) == 1 % Then the prior does not depend on the trial    
    ptprior = repmat(ptprior,ntrials1+ntrials2,1);
end
ptprior = ptprior./repmat(sum(ptprior,2),1,size(ptprior,2)); % Ensure the rows sum to 1
% Re-weight priors according to the number of trials in each class
if weightprior
    ptprior(truth_trials==1,:) = ptprior(truth_trials==1,:) / sum(truth_trials==1);
    ptprior(truth_trials==0,:) = ptprior(truth_trials==0,:) / sum(truth_trials==0);
end
% Make the prior the initial condition for the posteriors
pt = ptprior;
if forceOneWinner
    % Get posteriors
    [~,iMax] = max(pt,[],2);
    pt = full(sparse(1:length(iMax),iMax,1,size(pt,1),size(pt,2))); % all zeros except at max points    
end
pt2 = pt;
% [~,iMax] = max(pt,[],2);
% jitters = priortimes(iMax);

% Get data and truth matrices
alldata = cat(3,smootheeg1,smootheeg2);
truth = [zeros(ntrials1,1); ones(ntrials2,1)]; % The truth value associated with each trial

% Get data across windows & jitters
iWindow = (min(trainingwindowoffset)+min(jitterrange)):(max(trainingwindowoffset)+max(jitterrange));
x = alldata(:,iWindow,:);
x(end+1,:,:) = 1; % add for offset usage

% Set up for loop
vCrop = vinit;
vCrop_prev = vCrop;
% priortimes = (jitterrange(1)+1):jitterrange(2);
% pt = zeros(ntrials1+ntrials2,length(priortimes));
% jitters = zeros(1,ntrials1+ntrials2);
iter = 0;
% draw debug figures
if plotdebugfigs
    PlotDebugFigures(iter,vCrop,pt,jitterrange,trainingwindowoffset,ALLEEG);
end
%%% MAIN LOOP %%%
while iter==0 || (subspace(vCrop,vCrop_prev)>convergencethreshold && iter<max_iter)
    iter = iter+1;    
    fprintf('Iteration %d...\n',iter);
    vCrop_prev = vCrop;
    if iter==1
        [v] = FindMultiWindowWeights_v1p2(alldata,truth,trainingwindowoffset,pt,priortimes,vCrop_prev,logist_settings); 
    else
        [v] = FindMultiWindowWeights_v1p2(cat(3,alldata,alldata), [truth; truth], trainingwindowoffset, cat(1,pt,pt2), priortimes, vCrop_prev, logist_settings); 
    end

    
    [pt,pvals] = computeJitterProbabilities_v1p2(x,v,truth,ptprior,forceOneWinner);
    [pt2,pvals2] = computeJitterProbabilities_v1p2(x,v,1-truth,ptprior,forceOneWinner);
    
    Az = rocarea(pvals,truth);
    % Update vCrop and jitters
    isinwin = ~isnan(v(1,:));
    vCrop = v(:,isinwin);
    % draw debug figures
    if plotdebugfigs
        PlotDebugFigures(2*iter,vCrop,pt,jitterrange,trainingwindowoffset,ALLEEG);
        PlotDebugFigures(2*iter+1,vCrop,pt2,jitterrange,trainingwindowoffset,ALLEEG);
%         PlotDebugFigures(iter,vCrop,cat(1,pt,pt2),jitterrange,trainingwindowoffset,ALLEEG);
    end    
    % Print text output
    fprintf('Az = %.3g, subspace = %.3g\n', Az, subspace(vCrop,vCrop_prev) );
end

fprintf('Converged!  Preparing output...\n');

vOut = vCrop;
fmOut = vCrop(1:end-1,:); % TO DO: define this!

fprintf('Done.\n');

end % function pop_logisticregression_jittered


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       HELPER FUNCTIONS                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotDebugFigures(iter,vCrop,pt,priorrange,trainingwindowoffset,ALLEEG)    
    % Set up
    nRows = 2;
    nCols = 2;
    iPlot = mod(iter,nRows*nCols)+1;    
    [jitter_truth,truth_trials] = GetJitter(ALLEEG,'facecar');
    n1 = ALLEEG(1).trials;
    n2 = ALLEEG(2).trials;

    % Initialize figures
    figures = 111:113;
    if iter==0     
        for iFig = figures
            figure(iFig); clf;
        end
    end       
    
    % Plot v
    figure(figures(1));
    nWindows = size(vCrop,2);
    for iWin=1:nWindows
        subplot(nRows*nCols,nWindows,nWindows*(iPlot-1)+iWin); cla;
        topoplot(vCrop(1:end-1,iWin),ALLEEG(2).chanlocs);
        title(sprintf('iter %d weight vector (raw)\n (bias = %0.2g)(t=%gs)',iter,vCrop(end,iWin),ALLEEG(1).times(trainingwindowoffset(iWin))))
        colorbar;
    end
           
    % Plot posteriors
    figure(figures(2));    
    subplot(nRows,nCols,iPlot); cla; hold on;
    priortimes = (priorrange(1)+1):priorrange(2);
    [~,order1] = ImageSortedData(pt(1:n1,:),priorrange,1:n1,jitter_truth(1:n1)); colorbar;    
    [~,order2] = ImageSortedData(pt(n1+1:end,:),priorrange,n1+(1:n2),jitter_truth(n1+1:end)); colorbar;    
    [~,iMax] = max(pt([order1,n1+order2],:),[],2);    
    jitters = priortimes(iMax);
    scatter(jitters,1:(n1+n2),'m.');
    title(sprintf('iter %d Posteriors',iter));
    axis([min(priorrange) max(priorrange) 1 n1+n2])
    xlabel('Jitter (samples)');
    if iter==0        
        title(sprintf('Priors p(t_i,c_i)'))            
    end    
    ylabel('Trial');

    % Plot MAP jitter vs. posterior at that jitter
    figure(figures(3));
    subplot(nRows,nCols,iPlot); cla; hold on; 
    [~,maxinds] = max(pt,[],2);
    locs = find(truth_trials==0)';
    scatter(priortimes(maxinds(locs)),pt(sub2ind(size(pt),locs,maxinds(locs))),50,'blue','filled');
    locs = find(truth_trials==1)';    
    scatter(priortimes(maxinds(locs)),pt(sub2ind(size(pt),locs,maxinds(locs))),50,'red','filled');
    if priorrange(2)>priorrange(1)
        xlim([priorrange(1),priorrange(2)]);
    end
    title(sprintf('iter %d MAP jitter',iter));
    legend('MAP jitter values (l=0)','MAP jitter values (l=1)','Location','Best');
    xlabel('Jitter (samples)');
    ylabel('Posterior at that jitter');
  
    drawnow;
end

