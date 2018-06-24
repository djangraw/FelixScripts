function data = ImportTappingData(filename)

% Created 12/30/14 by DJ. 

if nargin==0
    filename = 'Tapping-1-1-DEMO.log'; % demo
end

params = PsychoPy_ParseParams(filename,'START PARAMETERS','END PARAMETERS');
events = PsychoPy_ParseEvents(filename,[],'START EXPERIMENT');

% get performance
tTaps = events.key.time(strcmp(params.respKey, events.key.char));
nTrials = numel(tTaps);
performance.tapInterval = [NaN; diff(tTaps)]; % pad with nan for the first tap
performance.block = ones(nTrials,1);
tBlocks = [events.block.time, inf];
for i=1:length(tBlocks)-1
    performance.block(tTaps >= tBlocks(i) & tTaps < tBlocks(i+1)) = i;    
end
performance.tapInterval([1, find(diff(performance.block)~=0)+1]) = NaN; % exempt first tap in each block

% get wandering catch presses
state.tWanders = events.key.time(strcmp(params.wanderKey,events.key.char));

% prepare output
data.params = params;
data.events = events;
data.performance = performance;
data.state = state;


% ==== PLOT ==== %

% Set up plot
clf;
h = zeros(2,2); % plots
MakeFigureTitle(filename);

% --- 1. Plot performance
h(1,1) = axes('position',[0.1 0.6 0.6 0.35]);
starttime = events.block.time(1);
timeontask = tTaps - starttime;
plot(timeontask, performance.tapInterval, 'b.-');
hold on
PlotHorizontalLines(params.toneInterval,'c:');
PlotVerticalLines(events.block.time - starttime,'r');
plot(events.soundstart.time - starttime,repmat(params.toneInterval,numel(events.soundstart.time),1),'g+');
% add MW catch times
PlotVerticalLines(state.tWanders-starttime,'m:');
% Annotate
MakeLegend({'b.-','c:','r','g+','m:'},{'Time from last tap','Ideal tap interval','Block Start','Guide Tones','Subj reported MW'},[],[0.1,0.98]);
xlabel('Time on Task (s)')
ylabel('Inter-Tap Interval (s)')
title(filename,'interpreter','none');

% --- 2. Make vertical histogram of ITIs
xBins = min(performance.tapInterval):0.001:max(performance.tapInterval);
yBins = hist(performance.tapInterval,xBins);
h(1,2) = axes('position',[0.75 0.6 0.2 0.35]);
cBins = cumsum(yBins)/nTrials*100;
plot(cBins,xBins);
hold on
i50RT = find(cBins>=50,1);
i95RT = find(cBins>=95,1);
PlotHorizontalLines(xBins(i50RT),'k:');
PlotHorizontalLines(xBins(i95RT),'k--');
plot([cBins(i50RT),cBins(i50RT)],[0 xBins(i50RT)],'k:');
plot([cBins(i95RT),cBins(i95RT)],[0 xBins(i95RT)],'k--');
% annotate
xlim([0 100]);
ylim(get(h(1,1),'ylim'));
legend('ITI proportion','median','95th percentile');
xlabel('% trials faster than ITI')
ylabel('Inter-Tap Interval (s)')
title('Cumulative Histogram')

% update first plot with median & 95% ITIs
plot(h(1,1),get(h(1,1),'xlim'), [xBins(i50RT) xBins(i50RT)],'k:');
plot(h(1,1),get(h(1,1),'xlim'), [xBins(i95RT) xBins(i95RT)],'k--');



% --- 3. Plot change in ITI
h(2,1) = axes('position',[0.1 0.15 0.6 0.35]);
starttime = events.block.time(1);
timeontask = tTaps - starttime;
deltaITI = [NaN; diff(performance.tapInterval)];
plot(timeontask, deltaITI, 'b.-');
hold on
PlotHorizontalLines(0,'c:');
PlotVerticalLines(events.block.time - starttime,'r');
plot(events.soundstart.time - starttime,repmat(params.toneInterval,numel(events.soundstart.time),1),'g+');
% add MW catch times
PlotVerticalLines(state.tWanders-starttime,'m:');
% Annotate
MakeLegend({'b.-','c:','r','g+','m:'},{'Change in ITI','No change','Block Start','Guide Tones','Subj reported MW'},[],[0.1,0.98]);
xlabel('Time on Task (s)')
ylabel('Inter-Tap Interval (s)')
title(filename,'interpreter','none');

% --- 4. Make vertical histogram of delta-ITIs
xBins = min(deltaITI):0.001:max(deltaITI);
yBins = hist(deltaITI,xBins);
h(2,2) = axes('position',[0.75 0.15 0.2 0.35]);
cBins = cumsum(yBins)/nTrials*100;
plot(cBins,xBins);
hold on
i50RT = find(cBins>=50,1);
i95RT = find(cBins>=95,1);
i05RT = find(cBins>=5,1);
PlotHorizontalLines(xBins(i50RT),'k:');
PlotHorizontalLines(xBins([i05RT i95RT]),'k--');
plot([cBins(i50RT),cBins(i50RT)],[0 xBins(i50RT)],'k:');
plot([cBins(i95RT),cBins(i95RT)],[0 xBins(i95RT)],'k--');
plot([cBins(i05RT),cBins(i05RT)],[0 xBins(i05RT)],'k--');
% annotate
xlim([0 100]);
ylim(get(h(2,1),'ylim'));
legend('\delta ITI proportion','median','95th percentile');
xlabel('% trials faster than \delta ITI')
ylabel('\delta Inter-Tap Interval (s)')
title('Cumulative Histogram')

% update first plot with median & 95% RTs
plot(h(2,1),get(h(2,1),'xlim'), [xBins(i50RT) xBins(i50RT)],'k:');
plot(h(2,1),get(h(2,1),'xlim'), [xBins(i95RT) xBins(i95RT)],'k--');
plot(h(2,1),get(h(2,1),'xlim'), [xBins(i05RT) xBins(i05RT)],'k--');
