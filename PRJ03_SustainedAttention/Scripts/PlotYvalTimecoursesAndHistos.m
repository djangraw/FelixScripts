% PlotYvalTimecoursesAndHistos.m
%
% Created 6/22/16 by DJ (in a hurry for OHBM) as TEMP_... .
% Updated 7/7/16 by DJ - updated name (removed TEMP_).

% Get weights from single, all- training classifier
% trainData = permute(fcFeats,[1 3 2]);
% isTrain(:) = true;
% [Az_all,AzLoo_all,statsCv_all] = RunSingleLR(trainData,fcTruth(isTrain),LRparams);
% w = statsCv_all.wts;

% Get avg weights from CV runs
allWts = cat(2,statsCv(:).wts);
w = mean(allWts,2);

% Get feats
fcFeats_all = FcPcTc_2dmat;
fcRuns_all = iRun;

% Normalize feats
switch fcNormOption
    case {'subject','all'}
        isOkSample = ~any(isnan(fcFeats_all),1);
        fcFeats_all(:,isOkSample) = zscore(fcFeats_all(:,isOkSample),[],2);
    case 'run'
        for j=1:nRuns
            isOkSample = ~any(isnan(fcFeats_all),1);
            isInRun = (fcRuns_all==j);
            fcFeats_all(:,isInRun & isOkSample) = zscore(fcFeats_all(:,isInRun & isOkSample),[],2);
        end
    case 'none'
end

% Apply weights to get y values
y = w(1:end-1)'*fcFeats_all+w(end);

%% ALTERNATIVELY: ROSENBERG SCORE
y = zscore(posMatch);
beh.question = question;

%% Plot results
figure(661); clf;
set(gcf,'Position',[3 32 1527 394]);
t = (0:numel(y)-1)*TR;
plot(t,y);
hold on;
isOkEvent = ~isnan(iFcEventSample);
eventTypes = {'whiteNoise','ignoredSpeech','attendedSpeech'};
shapes = 'osd';
for i=1:numel(eventTypes)
    isThis = strcmp(eventNames',eventTypes{i});
    plot(t(iFcEventSample(isOkEvent & isThis)),y(iFcEventSample(isOkEvent & isThis)),shapes(i));
end

% Get question pages
isReading = strncmp(beh.question.type,'reading',length('reading'));
qPages = cellfun(@min,beh.question.pages_adj(isReading));
isCorrect = beh.question.isCorrect(isReading)>0;
% Plot question pages
samplesCorrect = iFcEventSample(qPages(isCorrect));
samplesIncorrect = iFcEventSample(qPages(~isCorrect));
% PlotVerticalLines(samplesCorrect,'g--');
% PlotVerticalLines(samplesIncorrect,'r--');

yLimits = get(gca,'ylim'); 
yMin = min(yLimits);
for i=1:numel(samplesCorrect)
    if ~isnan(samplesCorrect(i))
        plot([1 1]*t(samplesCorrect(i)), [yMin, y(samplesCorrect(i))],'g--');
    end
end
for i=1:numel(samplesIncorrect)
    if ~isnan(samplesIncorrect(i))
        plot([1 1]*t(samplesIncorrect(i)), [yMin, y(samplesIncorrect(i))],'r--');
    end
end

% Annotate plot
grid on;
xlabel('Time (s)')
ylabel('Classifier output');
legend([{'Classifier output'},eventTypes],'Location','SouthWest');
xlim([0 numel(y)*TR]);

%% Make histogram

figure(662); clf; hold on;
% xHist = -100:10:100;
xHist = linspace(yLimits(1),yLimits(2),20);
nHist = zeros(numel(eventTypes),numel(xHist));
colors = 'gyr';
doArea = false;
clear hArea;
for i=1:numel(eventTypes)
    isThis = strcmp(eventNames',eventTypes{i});
    nHist(i,:) = hist(y(iFcEventSample(isOkEvent & isThis)),xHist);
    if doArea
        hArea(i) = area(xHist,nHist(i,:)','FaceColor',colors(i));
    else
        plot(xHist,nHist(i,:),colors(i));
    end
end
if doArea
    set(hArea,'faceAlpha',0.3);
    set(gca,'xticklabel',{},'yticklabel',{});
else
    for i=1:numel(eventTypes)
        isThis = strcmp(eventNames',eventTypes{i});
        PlotVerticalLines(nanmedian(y(iFcEventSample(isOkEvent & isThis))),[colors(i),'--']);
    end
    legend([eventTypes,'median']);
end
% plot(xHist,nHist');


