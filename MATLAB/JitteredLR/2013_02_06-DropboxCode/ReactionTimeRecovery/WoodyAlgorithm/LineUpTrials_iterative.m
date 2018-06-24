function finalMatchStrength = LineUpTrials_iterative(ALLEEG,channels,tWin,smoothwidth)

% Created 12/4/12 by DJ based on LineUpTrials.m.
% Updated 12/5/12 by DJ - comments

% Declare options
option_exgaussian = false; % multiply by ex-gaussian distribution
option_exgausslimits = true; % use cumulative ex-gaussian to exclude top and bottom 1%
option_500limits = false; % exclude jitters outside of [-500 500]ms
option_cumulative = false; % to find best match, use point where cumulative matchStrength reaches 50% of total
option_pca = false; % use PCA found from given channels
option_mean = false; % use mean of given electrodes as a single pseudo-electrode

% Declare Defaults
if nargin<2 || isempty(channels)
    channels = 1:ALLEEG(1).nbchan;
end
if nargin<3 || isempty(tWin)
    tWin = [-50 50];
end
if nargin<4 || isempty(smoothwidth)
    smoothwidth = 1;
end

% Convert channel inputs to chanlocs indices
if iscell(channels)
    iChan = zeros(1,numel(channels));
    for i=1:numel(channels)
        iChan(i) = find(strcmpi(channels{i},{ALLEEG(1).chanlocs.labels}));
    end
elseif ischar(channels)
    iChan = find(strcmpi(channels,{ALLEEG(1).chanlocs.labels}));
else
    iChan = channels;
end


% Extract data
raweeg = cat(3,ALLEEG(1).data(iChan,:,:), ALLEEG(2).data(iChan,:,:));
% Smooth data
smootheeg = nan(size(raweeg));
for i=1:size(raweeg,3)
     smootheeg(:,:,i) = conv2(raweeg(:,:,i),ones(1,smoothwidth)/smoothwidth,'same'); % same means output will be same size as input
end

% Set up
ntrials = size(smootheeg,3);
isInWin = ALLEEG(1).times>=tWin(1) & ALLEEG(1).times<=tWin(2);
windowSize = sum(isInWin);

% Perform PCA
if option_pca % Perform PCA and normalize component activity
    iComps = 1:5;
    pca_input = reshape(smootheeg(:,isInWin,:),size(smootheeg,1),sum(isInWin)*size(smootheeg,3))';
    [U,S,V] = svd(pca_input,'econ');    
    longsmootheeg = reshape(smootheeg,size(smootheeg,1),size(smootheeg,2)*size(smootheeg,3));
    longdata = diag(1./diag(S(iComps,iComps))) * V(:,iComps)'*longsmootheeg;
    data = reshape(longdata,length(iComps),size(smootheeg,2),size(smootheeg,3));
    % plot pc's
    plotpcs = false;
    if plotpcs
        % Plot top 8 PC's
        for i=1:8
            subplot(3,3,i);cla;
            topoplot(V(:,i),ALLEEG(1).chanlocs);
            colorbar;
        end
        subplot(3,3,9);cla;
        plot([diag(S)/S(1), cumsum(diag(S).^2)/sum(diag(S).^2)],'.-');
        drawnow; 
        pctVar = (diag(S).^2)/sum(diag(S).^2);
        fprintf('components [%s] account for %.2f%% of variance\n',num2str(iComps),sum(pctVar(iComps))*100);
    end
elseif option_mean
    data = mean(smootheeg,1);
else
    data = smootheeg;
end


% Get truth data
jitter = GetJitter(ALLEEG,'facecar');
t = ALLEEG(1).times(1:end-windowSize)+round(windowSize/2)-mean(tWin);
n1 = ALLEEG(1).trials;

% get match components not dependent on data
if option_exgaussian
    exgauss = computeJitterPrior_exgaussian(t,struct('mu',-100.1325, 'sigma',49.6453, 'tau',100.1325,'mirror',1));
    exgauss = repmat(exgauss,ntrials,1);
elseif option_exgausslimits
    exgauss = computeJitterPrior_exgaussian(t,struct('mu',-100.1325, 'sigma',49.6453, 'tau',100.1325,'mirror',1));
    eg_cumsum = cumsum(exgauss);
    iFirst = find(eg_cumsum>0.01,1);
    iLast = find(eg_cumsum<0.99,1,'last');
elseif option_500limits
    iFirst = find(t>=-500,1);
    iLast = find(t<=500,1,'last');    
end

% Main loop
minDrift = 1;%0.5; % convergence threshold
peakDrift = inf; % amount each trial has moved
iter = 0; % iteration count
while iter<=1 || peakDrift>minDrift
    iter = iter+1;
    fprintf('iter %d...',iter)
    % Update template
    if iter==1
        template{iter} = mean(data(:,isInWin,:),3);
    else
        template{iter} = UpdateEegTemplate(data,RealignedTimes{iter-1},windowSize);
    end
    
    % Update raw match strength
    matchStrength{iter} = UpdateTemplateMatchStrength(data,template{iter});
    % Update match strength with options
    if option_exgaussian % multiply by ex-gaussian (point-by-point)
        matchNew{iter} = matchStrength{iter}.*exgauss;
    elseif option_exgausslimits || option_500limits % exclude 1% tails of ex-gaussian distribution
        matchNew{iter} = zeros(size(matchStrength{iter}));
        matchNew{iter}(:,iFirst:iLast) = matchStrength{iter}(:,iFirst:iLast);        
    else
        matchNew{iter} = matchStrength{iter};
    end
    
    % Find predicted jitter time
    if option_cumulative % use 50% point of cumulative distribution instead of max
        cumsumMatch = cumsum(matchNew{iter},2);
        iMax{iter} = zeros(1,ntrials);
        for j=1:ntrials
            iMax{iter}(j) = find(cumsumMatch(j,:)>=0.5*cumsumMatch(j,end),1);
        end        
    else % use max of each trial's distribution
        [~, iMax{iter}] = max(matchNew{iter},[],2);        
    end
    RealignedTimes{iter} = full(sparse(1:length(iMax{iter}),iMax{iter},1,size(matchStrength{iter},1),size(matchStrength{iter},2)));   
    
    avgMaxCorrelation(iter) = mean(max(matchNew{iter},[],2));
    % Print results
    if iter>1        
        peakDrift = mean(abs(iMax{iter}-iMax{iter-1}));
        fprintf('avg. peak drift: %.2f samples\n',peakDrift);
        fprintf('   increase in avgMaxCorrelation: %.2g\n',avgMaxCorrelation(iter)-avgMaxCorrelation(iter-1));
    else
        fprintf('\n')
    end
        
end

finalMatchStrength = matchNew{iter};

disp('Converged!  Plotting...')
% Set up plot
clf;
nIter = iter;
nPlots = 5;
iPlots = round(linspace(1,nIter,nPlots)); % pick plots evenly from all iterations
% Make legend labels
if option_pca
    chanlabels = cell(1,numel(iComps));
    for i=1:numel(iComps)
        chanlabels{i} = sprintf('PC #%d',iComps(i));
    end
elseif option_mean
    chanlabels = ['Mean of {' sprintf('%s ',ALLEEG(1).chanlocs(iChan).labels) '}'];    
else
    chanlabels = {ALLEEG(1).chanlocs(iChan).labels};
end
% Plot
for i=1:nPlots
    % template
    subplot(3,nPlots,i); cla; hold on;
    plot(tWin(1):tWin(2),template{iPlots(i)}');     
    legend(chanlabels)
    title(sprintf('Template, iter %d',iPlots(i)))
    xlabel('time (ms)')
    ylabel('Voltage (uV)')
    % matchStrength
    subplot(3,nPlots,nPlots+i); cla; hold on;
    ImageSortedData(matchStrength{iPlots(i)}(1:n1,:),t,1:n1,jitter(1:n1));
    ImageSortedData(matchStrength{iPlots(i)}(n1+1:ntrials,:),t,n1+1:ntrials,jitter(n1+1:end));
    title(sprintf('Full matchStrength, iter %d',iPlots(i)))
    axis([t(1) t(end) 1 ntrials]);
    xlabel('time (ms)')
    ylabel('<-- dataset 0    |    dataset 1 -->');
    % matchNew and RealignedTimes
    subplot(3,nPlots,nPlots*2+i); cla; hold on;
    [~,order1] = ImageSortedData(matchNew{iPlots(i)}(1:n1,:),t,1:n1,jitter(1:n1));
    [~,order2] = ImageSortedData(matchNew{iPlots(i)}(n1+1:ntrials,:),t,n1+1:ntrials,jitter(n1+1:end));
    scatter(t(iMax{iPlots(i)}([order1, order2+n1])),1:ntrials,'m.');
    title(sprintf('Cropped matchStrength, iter %d',iPlots(i)))
    axis([t(1) t(end) 1 ntrials]);
    xlabel('time (ms)')
    ylabel('<-- dataset 0    |    dataset 1 -->');
    % Update figure
    drawnow;
end

% Annotate plot
if option_pca
    MakeFigureTitle(sprintf('%s and %s\n%d to %d ms, PCA components [%s] ',ALLEEG(1).setname, ALLEEG(2).setname,tWin(1),tWin(2),num2str(iComps)));
else
    chancell = {ALLEEG(1).chanlocs(iChan).labels};
    chanstr = sprintf('%s, ',chancell{:});
    chanstr = chanstr(1:end-2);
    MakeFigureTitle(sprintf('%s and %s\n%d to %d ms, chans %s ',ALLEEG(1).setname, ALLEEG(2).setname,tWin(1),tWin(2),chanstr));
end

disp('Done!')