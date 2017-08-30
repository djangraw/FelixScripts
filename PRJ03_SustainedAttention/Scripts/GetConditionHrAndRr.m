function [HR_cat_median,RR_cat_median,eventCategories] = GetConditionHrAndRr(subject,doPlot)

% Created 7/15/16 by DJ.

% Handle inputs
if ~exist('doPlot','var') || isempty(doPlot)
    doPlot = false;
end

% Load data
disp('Loading raw traces...')
[rawEcg, rawResp, data] = GetEcgAndRespiration(subject);
Fs = 50; % standard for 3TC
t = (1:length(rawEcg{1}))'/Fs;

% Get event times
[pageStartTimes,pageEndTimes,eventSessions,eventTypes] = GetEventBoldSessionTimes(data);
eventCategories = unique(eventTypes);
nCats = numel(eventCategories);

% Main loop
disp('Getting Trialwise metrics...')
nRuns = numel(data);
[tEcgPeaks,tRespPeaks,HR,RR] = deal(cell(1,nRuns));
[HR_page,RR_page] = deal(nan(size(pageStartTimes)));
for i=1:nRuns
    fprintf('   Run %d/%d...\n',i,nRuns);
    % Get peaks
    tEcgPeaks{i} = GetEcgPeaks(rawEcg{i},Fs);
    tRespPeaks{i} = GetRespPeaks(rawResp{i},Fs);
    % Calculate HR
    [HR{i},RR{i}] = deal(nan(size(t)));
    for j=1:numel(tEcgPeaks{i})-1
        tMidPeak = mean(tEcgPeaks{i}(j:j+1));
        [~,iMidPeak] = min(abs(t-tMidPeak));
        HR{i}(iMidPeak) = 60/diff(tEcgPeaks{i}(j:j+1)); % in bpm
    end
    % Interpolate NaNs
    isOk = ~isnan(HR{i}); 
    HR{i}(~isOk) = interp1(t(isOk),HR{i}(isOk),t(~isOk),'linear','extrap');
    % Calculate RR
    for j=1:numel(tRespPeaks{i})-1
        tMidPeak = mean(tRespPeaks{i}(j:j+1));
        [~,iMidPeak] = min(abs(t-tMidPeak));
        RR{i}(iMidPeak) = 60/diff(tRespPeaks{i}(j:j+1)); % in bpm
    end
    % Interpolate NaNs
    isOk = ~isnan(RR{i}); 
    RR{i}(~isOk) = interp1(t(isOk),RR{i}(isOk),t(~isOk),'linear','extrap'); 
    % Get HR and RR during each event type
    iInSession = find(eventSessions==i);
    pageStart_in = pageStartTimes(iInSession);
    pageEnd_in = pageEndTimes(iInSession);
    eventType_in = eventTypes(iInSession);
    for j=1:numel(pageStart_in)
        isInPage = t>=pageStart_in(j) & t<=pageEnd_in(j);
        HR_page(iInSession(j)) = mean(HR{i}(isInPage));
        RR_page(iInSession(j)) = mean(RR{i}(isInPage));
    end
end

% Get Average for each event type
disp('Getting Means and Statistics...')
[HR_cat_median,RR_cat_median,HR_cat_ste,RR_cat_ste] = deal(nan(1,nCats));
for k=1:nCats
    isInCat = strcmp(eventTypes,eventCategories{k});
    HR_cat_median(k) = median(HR_page(isInCat));
    RR_cat_median(k) = median(RR_page(isInCat));
    HR_cat_ste(k) = std(HR_page(isInCat))/sqrt(sum(isInCat));
    RR_cat_ste(k) = std(RR_page(isInCat))/sqrt(sum(isInCat));
end
% Check for stat differences between categories
[pHR,~,statsHR] = kruskalwallis(HR_page,eventTypes,'off');
[pRR,~,statsRR] = kruskalwallis(RR_page,eventTypes,'off');
mcHR = multcompare(statsHR,'display','off');
mcRR = multcompare(statsRR,'display','off');

% Plot results
if doPlot
    disp('Plotting...')
    clf;
    subplot(2,1,1); cla; hold on;
    bar(HR_cat_median);
    errorbar(HR_cat_median,HR_cat_ste,'k.');      
    % add stars
    if pHR<0.05
        for i=1:size(mcHR,1)
            if mcHR(i,end)<0.05
                plot(mcHR(i,1:2),[1 1]*max(HR_cat_median+HR_cat_ste)+i, 'k.-');
                plot(mean(mcHR(i,1:2)),max(HR_cat_median+HR_cat_ste)+i+.5, 'k*');
            end
        end
    end
    set(gca,'xtick',1:nCats,'xticklabel',eventCategories);
    ylim([min(HR_cat_median-HR_cat_ste)-size(mcHR,1)-1, max(HR_cat_median+HR_cat_ste)+size(mcHR,1)+1])
    xlabel('event type')
    ylabel('HR (bpm)')
    title(sprintf('Median heart rate for subject %d',subject)); 

    subplot(2,1,2); cla; hold on;
    bar(RR_cat_median);
    errorbar(RR_cat_median,RR_cat_ste,'k.');
    if pRR<0.05
        for i=1:size(mcRR,1)
            if mcRR(i,end)<0.05
                plot(mcRR(i,1:2),[1 1]*max(RR_cat_median+RR_cat_ste)+i, 'k.-');
                plot(mean(mcRR(i,1:2)),max(RR_cat_median+RR_cat_ste)+i+.5, 'k*');
            end
        end
    end
    set(gca,'xtick',1:nCats,'xticklabel',eventCategories);
    ylim([min(RR_cat_median-RR_cat_ste)-size(mcRR,1)-1, max(RR_cat_median+RR_cat_ste)+size(mcRR,1)+1])
    xlabel('event type')
    ylabel('RR (bpm)')
    title(sprintf('Median respiration rate for subject %d',subject)); 
end
disp('Done!');
