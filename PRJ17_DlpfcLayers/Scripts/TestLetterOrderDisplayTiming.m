function TestLetterOrderDisplayTiming(data)

% Created 10/24/17 by DJ.

eventNames = data.events.display.name;
eventTimes = data.events.display.time;
eventDur = [diff(eventTimes); nan];

% test fixDur
idealStringDur = data.params.stringDur;
iStringEvents = find(strcmp(eventNames,'string'));
stringDur = eventDur(iStringEvents);

idealPauseDur = data.params.pauseDur;
pauseDur = eventDur(iStringEvents+1);

idealCueDur = data.params.cueDur;
iCueEvents = find(strcmp(eventNames,'cue'));
cueDur = eventDur(iCueEvents);

idealDelayRange = [data.params.minDelayDur, data.params.maxDelayDur];
delayDur = eventDur(iCueEvents+1);

idealTestDur = data.params.testDur;
iTestEvents = find(strcmp(eventNames,'test'));
testDur = eventDur(iTestEvents);

idealIsiRange = [data.params.minISI, data.params.maxISI];
isiDur = eventDur(iTestEvents+1);

% Plot
subplot(3,2,1); cla; hold on;
hist(stringDur);
PlotVerticalLines(idealStringDur,'r--');
xlabel('tString')
ylabel('# trials')
legend('distribution','ideal');

subplot(3,2,2); cla; hold on;
hist(pauseDur);
PlotVerticalLines(idealPauseDur,'r--');
xlabel('tPause')
ylabel('# trials')

subplot(3,2,3); cla; hold on;
hist(cueDur);
PlotVerticalLines(idealCueDur,'r--');
xlabel('tCue')
ylabel('# trials')

subplot(3,2,4); cla; hold on;
hist(delayDur);
PlotVerticalLines(idealDelayRange,'g--');
xlabel('tDelay')
ylabel('# trials')

subplot(3,2,5); cla; hold on;
hist(testDur);
PlotVerticalLines(idealTestDur,'r--');
xlabel('tTest')
ylabel('# trials')

subplot(3,2,6); cla; hold on;
hist(isiDur);
PlotVerticalLines(idealIsiRange,'g--');
xlabel('tIsi')
ylabel('# trials')

% Annotate figure
MakeFigureTitle(sprintf('Trial timing for file %s',data.params.filename));
