% TestGetEventSamples_script.m

% Declare MRI params
nRuns = 3;
trPerRun = 100; % in samples
nFirstRemoved = 0; % in samples
fcWinLength = 10; % in samples
TR = 2; % in seconds
hrfOffset = 0; % in sec
eventSample = [30 40 50]; % in samples
pageDurSample = 7; % in samples
nROIs = 4;
alignment = 'end';

% Declare behavioral params
tStart_beh = [20 30 40]; % time of first 't'
eventNames = {'attendSound','ignoreSound','whiteNoiseSound'}';
tPageDur = pageDurSample*TR;
tEvents_beh = eventSample*TR+tStart_beh;

% create behavior
clear data
for i=1:nRuns
    data(i).events.key = struct('char',{'t'},'time',tStart_beh(i)*1000); % in ms
    data(i).events.soundstart = struct('name',{eventNames(i)},'time',tEvents_beh(i)*1000); % in ms
    data(i).events.display = struct('name',{{sprintf('Page%d',i), 'Fixation'}},'time',[tEvents_beh(i)*1000, (tEvents_beh(i)+tPageDur)*1000]);
    data(i).params.subject = 99;
    data(i).params.maxPageTime = tPageDur; % in sec
end

% create data
mrData_cropped_all = [];
for i=1:nRuns
    mrData = zeros(nROIs,trPerRun);
    mrData(:,eventSample(i)+(1:pageDurSample)) = 1;% repmat(sin(1:pageDurSample),nROIs,1);
    mrData_cropped = mrData(:,nFirstRemoved+1:end);
    runOffset(i) = size(mrData_cropped_all,2);
    mrData_cropped_all = cat(2,mrData_cropped_all,mrData_cropped);
end

% find event times
[iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(data, ...
    fcWinLength, TR, nFirstRemoved, trPerRun, hrfOffset, alignment);
    
% plot results
clf; cla; hold on;
imagesc(mrData_cropped_all); 
colormap gray;
PlotVerticalLines(runOffset,'b');
PlotVerticalLines(iTcEventSample,'r');
PlotVerticalLines(iFcEventSample,'g--');
PlotVerticalLines(iFcEventSample+fcWinLength,'g-.');
ylim([1 nROIs]-0.5);
xlim([1 size(mrData_cropped_all,2)]-0.5);
MakeLegend({'b','r','g--','g-.'},{'run start','Mag sample','FC sample (win start)','FC win end'});
    
    
    