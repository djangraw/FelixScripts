function [template, data] = GetPcaTemplate(ALLEEG,iComps,tWin,smoothwidth,tLimits)

% Created 12/5/12 by DJ based on GetEegTemplate


disp('Getting PCA Template...')
% Declare defaults
if nargin<2 || isempty(iComps)
    iComps = 1:5;
end
if nargin<3 || isempty(tWin)
    tWin = [ALLEEG(1).times(1) ALLEEG(1).times(end)];
end
if nargin<4 || isempty(smoothwidth)
    smoothwidth = 1;
end
if nargin<5 || isempty(tLimits)
    tLimits = [-inf inf];
end

% Extract data
raweeg = cat(3,ALLEEG.data);
% Smooth data
smootheeg = nan(size(raweeg));
for i=1:size(raweeg,3)
     smootheeg(:,:,i) = conv2(raweeg(:,:,i),ones(1,smoothwidth)/smoothwidth,'same'); % same means output will be same size as input
end

% Set up
ntrials = size(smootheeg,3);
isInWin = ALLEEG(1).times>=tWin(1) & ALLEEG(1).times<=tWin(2);
windowSize = sum(isInWin);

% Perform PCA and normalize component activity
pca_input = reshape(smootheeg(:,isInWin,:),size(smootheeg,1),sum(isInWin)*size(smootheeg,3))';
[U,S,V] = svd(pca_input,'econ');    
longsmootheeg = reshape(smootheeg,size(smootheeg,1),size(smootheeg,2)*size(smootheeg,3));
longdata = diag(1./diag(S(iComps,iComps))) * V(:,iComps)'*longsmootheeg;
data = reshape(longdata,length(iComps),size(smootheeg,2),size(smootheeg,3));

% Get Limits on iMax for iterations
t = ALLEEG(1).times(1:end-windowSize)+round(windowSize/2)-mean(tWin); % indices match matchTimes
iFirst = find(t>=tLimits(1),1);
iLast = find(t<=tLimits(2),1,'last');

% Main loop
minDrift = 0.5; % convergence threshold
peakDrift = inf; % amount each trial has moved
iMax = zeros(ntrials,1);
iter = 0; % iteration count
while iter<=1 || peakDrift>minDrift
    iter = iter+1;
    fprintf('iter %d...',iter)
    % Update template
    if iter==1
        template = mean(data(:,isInWin,:),3);
    else
        template = UpdateEegTemplate(data,RealignedTimes,windowSize);
    end
    
    % Update raw match strength
    matchStrength = UpdateTemplateMatchStrength(data,template);
    
    % Crop match limits
    matchNew = zeros(size(matchStrength));
    matchNew(:,iFirst:iLast) = matchStrength(:,iFirst:iLast);        
    
    % Find predicted jitter time
    iMaxLast = iMax; % use max of each trial's distribution
    [~, iMax] = max(matchNew,[],2);        
    
    % Realign data
    RealignedTimes = full(sparse(1:length(iMax),iMax,1,size(matchStrength,1),size(matchStrength,2)));   
    
    % Print results
    if iter>1
        peakDrift = mean(abs(iMax-iMaxLast));
        fprintf('avg. peak drift: %.2f samples\n',peakDrift);
    else
        fprintf('\n')
    end
        
end


disp('Converged!')

plotresults = false;
if plotresults % DEBUG: Plot results

    chanlabels = cell(1,numel(iComps));
    for i=1:numel(iComps)
        chanlabels{i} = sprintf('PC #%d',iComps(i));
    end
    % Get truth data
    jitter = GetJitter(ALLEEG,'facecar');
    n1 = ALLEEG(1).trials;

    % template
    subplot(1,3,1); cla; hold on;
    plot(tWin(1):tWin(2),template');     
    legend(chanlabels)
    title(sprintf('Template, iter %d',iter))
    xlabel('time (ms)')
    ylabel('Voltage (uV)')
    % matchStrength
    subplot(1,3,2); cla; hold on;
    ImageSortedData(matchStrength(1:n1,:),t,1:n1,jitter(1:n1));
    ImageSortedData(matchStrength(n1+1:ntrials,:),t,n1+1:ntrials,jitter(n1+1:end));
    title(sprintf('Full matchStrength, iter %d',iter))
    axis([t(1) t(end) 1 ntrials]);
    xlabel('time (ms)')
    ylabel('<-- dataset 0    |    dataset 1 -->');
    % matchNew and RealignedTimes
    subplot(1,3,3); cla; hold on;
    [~,order1] = ImageSortedData(matchNew(1:n1,:),t,1:n1,jitter(1:n1));
    [~,order2] = ImageSortedData(matchNew(n1+1:ntrials,:),t,n1+1:ntrials,jitter(n1+1:end));
    scatter(t(iMax([order1, order2+n1])),1:ntrials,'m.');
    title(sprintf('Cropped matchStrength, iter %d',iter))
    axis([t(1) t(end) 1 ntrials]);
    xlabel('time (ms)')
    ylabel('<-- dataset 0    |    dataset 1 -->');

    drawnow;
end
