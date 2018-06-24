function finalMatchStrength = LineUpTrials_rawdata(raweeg,times,tWin,smoothwidth,chanlocs,true_jitter,options)

% Created 5/15/13 by DJ based on LineUpTrials_iterative.
% Updated 11/1/13 by DJ - added true_jitter and options inputs

% Declare options
option_exgaussian = false; % multiply by ex-gaussian distribution
option_exgausslimits = false; % use cumulative ex-gaussian to exclude top and bottom 1%
option_500limits = true; % exclude jitters outside of [-500 500]ms
option_cumulative = false; % to find best match, use point where cumulative matchStrength reaches 50% of total
option_pca = true; % use PCA found from given channels
option_mean = false; % use mean of given electrodes as a single pseudo-electrode
option_plot = true; % plot results

% Declare Defaults
if nargin<2 || isempty(times)
    times = 1:size(raweeg,2);
end
if nargin<3 || isempty(tWin)
    tWin = [-50 50];
end
if nargin<4 || isempty(smoothwidth)
    smoothwidth = 1;
end
if nargin<5 || isempty(chanlocs)
    chanlocs = [];
    option_plot = 0;
end
if nargin<6 || isempty(true_jitter)
    ntrials = size(raweeg,3);
    true_jitter = zeros(1,ntrials);
end
jitter = true_jitter;
if nargin>=7 && ~isempty(options)
    UnpackStruct(options);
end

% Smooth data
smootheeg = nan(size(raweeg));
for i=1:size(raweeg,3)
     smootheeg(:,:,i) = conv2(raweeg(:,:,i),ones(1,smoothwidth)/smoothwidth,'same'); % same means output will be same size as input
end

% Set up
ntrials = size(smootheeg,3);
isInWin = times>=tWin(1) & times<=tWin(2);
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
    if option_plot
        figure(523); clf;
        % Plot top 8 PC's
        for i=1:8
            subplot(3,3,i);cla;
            topoplot(V(:,i),chanlocs);
            title(sprintf('PC #%d',i));
            colorbar;
        end
        subplot(3,3,9);cla;
        plot([diag(S)/S(1), cumsum(diag(S).^2)/sum(diag(S).^2)],'.-');
        xlabel('PCs included');
        ylabel('% variance included');
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
t = times(1:end-windowSize)+round(windowSize/2)-mean(tWin);

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

disp('Converged!');
if option_plot
    disp('Plotting...')
    % Set up plot
    figure(524); clf;
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
        chanlabels = ['Mean of {' sprintf('%s ',chanlocs.labels) '}'];    
    else
        chanlabels = {chanlocs.labels};
    end
    % Plot
    for i=1:nPlots
        % template
        subplot(3,nPlots,i); cla; hold on;
        plot(times(isInWin),template{iPlots(i)}');     
        legend(chanlabels)
        title(sprintf('Template, iter %d',iPlots(i)))
        xlabel('time (ms)')
        ylabel('Voltage (uV)')
        % matchStrength
        subplot(3,nPlots,nPlots+i); cla; hold on;
        ImageSortedData(matchStrength{iPlots(i)},t,1:ntrials,jitter);        
        title(sprintf('Full matchStrength, iter %d',iPlots(i)))
        axis([t(1) t(end) 1 ntrials]);
        xlabel('time (ms)')
        ylabel('trial #');
        % matchNew and RealignedTimes
        subplot(3,nPlots,nPlots*2+i); cla; hold on;
        [~,order] = ImageSortedData(matchNew{iPlots(i)},t,1:ntrials,jitter);        
        scatter(t(iMax{iPlots(i)}(order)),1:ntrials,'m.');
        title(sprintf('Cropped matchStrength, iter %d',iPlots(i)))
        axis([t(1) t(end) 1 ntrials]);
        xlabel('time (ms)')
        ylabel('trial #');
        % Update figure
        drawnow;
    end

    % Annotate plot
    if option_pca
        MakeFigureTitle(sprintf('%d to %d ms, PCA components [%s] ',tWin(1),tWin(2),num2str(iComps)));
    else
        chancell = {chanlocs.labels};
        chanstr = sprintf('%s, ',chancell{:});
        chanstr = chanstr(1:end-2);
        MakeFigureTitle(sprintf('%d to %d ms, chans %s ',tWin(1),tWin(2),chanstr));
    end
end

disp('Done!')