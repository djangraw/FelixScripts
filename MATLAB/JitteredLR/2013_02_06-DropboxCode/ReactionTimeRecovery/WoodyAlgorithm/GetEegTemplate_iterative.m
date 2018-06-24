function [template, data] = GetEegTemplate_iterative(ALLEEG,channels,tWin,smoothwidth,tLimits)

% Created 12/7/12 by DJ.

if nargin<2 || isempty(channels)
    channels = 1:ALLEEG(1).nbchan;
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

% Handle inputs
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
raweeg = cat(3,ALLEEG(1).data(iChan,:,:),ALLEEG(2).data(iChan,:,:));
% Smooth data
smootheeg = nan(size(raweeg));
for i=1:size(raweeg,3)
     smootheeg(:,:,i) = conv2(raweeg(:,:,i),ones(1,smoothwidth)/smoothwidth,'same'); % same means output will be same size as input
end


% Set up
data = smootheeg;
ntrials = size(data,3);
isInWin = ALLEEG(1).times>=tWin(1) & ALLEEG(1).times<=tWin(2);
windowSize = sum(isInWin);
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

    chanlabels = {ALLEEG(1).chanlocs.labels};
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