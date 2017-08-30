% GetBoldEpochs_script.m
%
% Created 3/16/16 by DJ.

subject=9;
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
TR = 2;
nFirstTRsRemoved = 3;
nTRsPerSession = 243;
doRound = false;

% load data
cd(sprintf('%s/SBJ%02d',homedir,subject))
% Read data file
load(sprintf('Distraction-%d-QuickRun',subject));


%% Get times
[pageStartTimes,pageEndTimes,eventSessions,eventTypes] = GetEventBoldSessionTimes(data);
% Get indices of start times
fprintf('Converting to TR indices...\n')
iPageStart_combo = ConvertBoldSessionTimeToComboTime(pageStartTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
% Get indices of fixation events
iPageEnd_combo = ConvertBoldSessionTimeToComboTime(pageEndTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
% Get event types
uniqueEventTypes = unique(eventTypes);
nEventTypes = numel(uniqueEventTypes);
durations = iPageEnd_combo - iPageStart_combo; % in TRs

%% Get Epochs
[err,boldData,Info] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
[err,doNotCensor,Info] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));
boldData(doNotCensor==0,:) = NaN;
boldTimes = (0:size(boldData,1)-1)*TR;
tWindow = (-1:10)*TR;
epochs = GetBoldEphochs(boldData,boldTimes,iPageStart_combo*TR,tWindow);
% ID incomplete epochs
isBadEpoch = squeeze(any(any(isnan(epochs),1),2));

%% Plot results
epochMean = nan(size(epochs,1),size(epochs,2),nEventTypes);
for i=1:nEventTypes
    isThisEventType = strcmp(uniqueEventTypes{i},eventTypes);
    epochMean(:,:,i) = nanmean(epochs(:,:,isThisEventType & ~isBadEpoch),3);
end

% Plot!
figure(661); clf;
MakeFigureTitle(sprintf('SBJ%02d',subject));
for i=1:nEventTypes
    subplot(3,2,i*2-1); cla; hold on;
    imagesc(tWindow,1:size(epochMean,2),epochMean(:,:,i)');
    hStart = PlotVerticalLines(0,'r:');
    set(hStart,'linewidth',2);
    xlabel('time (s)');
    ylabel('ROI');
    title(uniqueEventTypes{i});
    colorbar
    set(gca,'clim',[-1 1]*.015);
    axis([tWindow(1) tWindow(end), 1,size(epochMean,2)])
end

%% page through results
epochMean = nan(size(epochs,1),size(epochs,2),nEventTypes);
for i=1:nEventTypes
    subplot(3,2,i*2);
    iThisEventType = find(strcmp(uniqueEventTypes{i},eventTypes));
    for j=1:numel(iThisEventType)
        cla; hold on;
        imagesc(tWindow,1:size(epochMean,2),epochs(:,:,iThisEventType(j))');
        hStart = PlotVerticalLines(0,'r:');
        set(hStart,'linewidth',2);
        xlabel('time (s)');
        ylabel('ROI');
        title(sprintf('%s: trial %d',uniqueEventTypes{i},j));
        colorbar
        set(gca,'clim',[-1 1]*.1);
        axis([tWindow(1) tWindow(end), 1,size(epochMean,2)])
        pause
    end
end

%% Plot only one ROI across all trials
iROI = 66;
for i=1:nEventTypes
    isThisEventType = strcmp(uniqueEventTypes{i},eventTypes);
    subplot(3,2,i*2);
    cla; hold on;
    plot(tWindow,squeeze(epochs(:,iROI,isThisEventType & ~isBadEpoch))');
    plot(tWindow,epochMean(:,iROI,i),'k','linewidth',2);
    hStart = PlotVerticalLines(0,'g:');
    hEnd = PlotVerticalLines(mean(durations(isThisEventType & ~isBadEpoch)*TR),'r:');
    set([hStart, hEnd],'linewidth',2);
    xlabel('time (s)');
    ylabel('ROI');
    title(sprintf('%s: ROI %d',uniqueEventTypes{i},iROI));
    set(gca,'clim',[-1 1]*.1);
    xlim([tWindow(1), tWindow(end)])
       
end

%% Plot ROI pairs across trials

figure(662); clf;
MakeFigureTitle(sprintf('SBJ%02d',subject));
iROI = 67; jROI = 77;
ylims=[-.15 .15];
for i=1:nEventTypes
    isThisEventType = strcmp(uniqueEventTypes{i},eventTypes);
    subplot(3,2,i*2-1);
    cla; hold on;
    plot(tWindow,squeeze(epochs(:,iROI,isThisEventType & ~isBadEpoch))');
    plot(tWindow,epochMean(:,iROI,i),'k','linewidth',2);
    ylim(ylims);
    hStart = PlotVerticalLines(0,'g:');
    hEnd = PlotVerticalLines(mean(durations(isThisEventType & ~isBadEpoch)*TR),'r:');
    set([hStart, hEnd],'linewidth',2);
    xlabel('time (s)');
    ylabel('ROI');
    title(sprintf('%s: ROI %d',uniqueEventTypes{i},iROI));
    set(gca,'clim',[-1 1]*.1);
    xlim([tWindow(1), tWindow(end)])
    
    subplot(3,2,i*2);
    cla; hold on;
    plot(tWindow,squeeze(epochs(:,jROI,isThisEventType & ~isBadEpoch))');
    plot(tWindow,epochMean(:,jROI,i),'k','linewidth',2);
    ylim(ylims);
    hStart = PlotVerticalLines(0,'g:');
    hEnd = PlotVerticalLines(mean(durations(isThisEventType & ~isBadEpoch)*TR),'r:');
    set([hStart, hEnd],'linewidth',2);
    xlabel('time (s)');
    ylabel('ROI');
    title(sprintf('%s: ROI %d',uniqueEventTypes{i},jROI));
    set(gca,'clim',[-1 1]*.1);
    xlim([tWindow(1), tWindow(end)])
    
       
end
%% Trial by trial
figure(662); clf;
MakeFigureTitle(sprintf('SBJ%02d',subject));
iROI = 67; jROI = 77;
iTrials = 6:10;
ylims=[-.2 .2];
for i=1:nEventTypes
    iThisEventType = find(strcmp(uniqueEventTypes{i},eventTypes) & ~isBadEpoch);
    for j=1:numel(iTrials)
        subplot(3,numel(iTrials),(i-1)*numel(iTrials)+j);
        cla; hold on;
        plot(tWindow,squeeze(epochs(:,[iROI jROI],iThisEventType(iTrials(j))))');
        ylim(ylims);
        hStart = PlotVerticalLines(0,'g:');
        hEnd = PlotVerticalLines((durations(iThisEventType(iTrials(j)))*TR),'r:');
        set([hStart, hEnd],'linewidth',2);
        xlabel('time (s)');
        ylabel('BOLD signal');
        title(sprintf('%s: trial %d',uniqueEventTypes{i},iThisEventType(iTrials(j))));
        legend(sprintf('ROI %d',iROI),sprintf('ROI %d',jROI));
        set(gca,'clim',[-1 1]*.1);
        xlim([tWindow(1), tWindow(end)])
    end     
end

%% Plot against each other
figure(663); clf;
MakeFigureTitle(sprintf('SBJ%02d',subject));
iROI = 67; jROI = 77;
kROI = 66; lROI = 146;
ylims=[-.2 .2];
for i=1:nEventTypes
    isThisEventType = strcmp(uniqueEventTypes{i},eventTypes);
    subplot(3,2,i*2-1);
    cla; hold on;
    plot(squeeze(epochs(:,iROI,isThisEventType & ~isBadEpoch))', squeeze(epochs(:,jROI,isThisEventType & ~isBadEpoch))','.');
    xlim(ylims);
    ylim(ylims);
    xlabel(sprintf('ROI %d BOLD',iROI));
    ylabel(sprintf('ROI %d BOLD',jROI));
    title(sprintf('%s',uniqueEventTypes{i}));
    
    subplot(3,2,i*2);
    cla; hold on;
    plot(squeeze(epochs(:,kROI,isThisEventType & ~isBadEpoch))', squeeze(epochs(:,lROI,isThisEventType & ~isBadEpoch))','.');
    xlim(ylims);
    ylim(ylims);
    xlabel(sprintf('ROI %d BOLD',kROI));
    ylabel(sprintf('ROI %d BOLD',lROI));
    title(sprintf('%s',uniqueEventTypes{i}));       
end