function data = ImportBopItData(filename)

% Created 12/19/14 by DJ. 
% Updated 1/14/15 by DJ - added MW lines

if nargin==0
    filename = 'BopIt-1-1-DEMO.log'; % demo
end
minRT = 0.1; % RT (in s) considered too fast to be a real response

params = PsychoPy_ParseParams(filename,'START PARAMETERS','END PARAMETERS');
events = PsychoPy_ParseEvents(filename,[],'START EXPERIMENT');

% put response keys in a cell array of strings
if iscell(params.respKeys)
    respKeys_cell = params.respKeys;
else
    respKeys_cell = mat2cell(params.respKeys',ones(1,length(params.respKeys)));
end

% get performance
nTrials = numel(events.soundstart.time);
[performance.iResponse, performance.iCorrect, performance.isCorrect, performance.RT] = deal(nan(nTrials,1));
[performance.extraKeys, performance.extraRTs] = deal(cell(nTrials,1));
for i=1:nTrials
    if i<nTrials
        iKeys = find(events.key.time > events.soundstart.time(i)+minRT & events.key.time <= events.soundstart.time(i+1)+minRT & ismember(events.key.char, respKeys_cell));
    else
        iKeys = find(events.key.time > events.soundstart.time(i)+minRT & ismember(events.key.char, respKeys_cell));
    end
    if isempty(iKeys)
        performance.iResponse(i) = NaN;
        performance.RT(i) = NaN;
    else
        iFirstKey = iKeys(1);
        performance.iResponse(i) = find(strcmp(respKeys_cell,events.key.char{iFirstKey}));
        performance.RT(i) = events.key.time(iFirstKey) - events.soundstart.time(i);
    end
    performance.iCorrect(i) = find(strcmp(params.tones,events.soundset.tone{i}));
    performance.isCorrect(i) = performance.iResponse(i)==performance.iCorrect(i);
    % log any extra keypresses
    performance.nKeys(i) = length(iKeys);
    if performance.nKeys(i)>1
        performance.extraKeys{i} = events.key.char(iKeys(2:end));
        performance.extraRTs{i} = events.key.time(iKeys(2:end)) - events.soundstart.time(i);
    end
end

% get wandering catch presses
state.tWanders = events.key.time(strcmp(params.wanderKey,events.key.char));

% prepare output
data.params = params;
data.events = events;
data.performance = performance;


% ==== BEGIN PLOTTING ==== %

% Set up plot
clf;
h = zeros(2,2); % plots
MakeFigureTitle(filename);
starttime = events.soundstart.time(1);
% --- 1. Plot single-trial performance
h(1,1) = axes('position',[0.1 0.6 0.6 0.35]);
timeontask = events.soundstart.time - starttime;
plot(timeontask, performance.RT, 'b.-');
hold on
% plot erroneous keypresses as red o's
if any(~performance.isCorrect)
    RTtemp = performance.RT;
    RTtemp(isnan(RTtemp)) = params.respDur + minRT;
    plot(timeontask(~performance.isCorrect), RTtemp(~performance.isCorrect),'ro');
%     plot(timeontask(~performance.isCorrect), performance.RT(~performance.isCorrect),'ro');
else
    plot(-1,-1,'ro');
end
% plot extra keypresses as green +'s
if any(performance.nKeys>1)
    iMultikey = find(performance.nKeys>1);
    for j=1:numel(iMultikey)        
        plot(repmat(timeontask(iMultikey(j)),size(performance.extraRTs{iMultikey(j)})), performance.extraRTs{iMultikey(j)},'g+');
    end
else
    plot(-1,-1,'g+');
end
% add MW catch times
PlotVerticalLines(state.tWanders-starttime,'m:');

% annotate
ylim([0 params.respDur + minRT])
xlim([0 timeontask(end)])
legend('all trials','errors','extra responses');
xlabel('Time on Task (s)')
ylabel('Reaction Time (s)')
title('Single-trial performance')

% --- 2. Make vertical histogram of RTs
xBins = 0:0.001:params.respDur+minRT;
yBins = hist(performance.RT,xBins);
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
ylim([0 params.respDur + minRT]);
legend('RT proportion','median','95th percentile');
xlabel('% trials faster than RT')
ylabel('Reaction Time (s)')
title('Cumulative Histogram')

% update first plot with median & 95% RTs
plot(h(1,1),get(h(1,1),'xlim'), [xBins(i50RT) xBins(i50RT)],'k:');
plot(h(1,1),get(h(1,1),'xlim'), [xBins(i95RT) xBins(i95RT)],'k--');

% --- 3. Plot smoothed accuracy & RT
hTemp = axes('position',[0.1 0.15 0.6 0.35]);
% Pad and smooth PC
isCorrect_padded = [ones([1,100]), performance.isCorrect'];
PC_padded = SmoothData(isCorrect_padded,10,'half')*100;
PC = PC_padded(end-nTrials+1:end);
% Pad and smooth RT
RT_padded = [ones([1,100])*median(RTtemp), RTtemp'];
RTsmooth_padded = SmoothData(RT_padded,10,'half');
RTsmooth = RTsmooth_padded(end-nTrials+1:end);
% set up plot
[h(2,:),l1,l2] = plotyy(timeontask,RTsmooth,timeontask,PC);
% set(h(2,:),{'ycolor'},{'b';'r'})
set(l1,'linestyle','-','marker','.','color','b');
set(l2,'linestyle','-','marker','.','color','r');
% set properties
set(h(2,1),'xlim',[0 timeontask(end)],'ycolor','b','ylim',get(h(1,1),'ylim'),'ytick',get(h(1,1),'ytick')) % RT
set(h(2,2),'xlim',[0 timeontask(end)],'ycolor','r','ylim',[1/3 1]*100,'ytick',40:10:100) % PC
% add MW catch times
hold(h(2,1),'on')
PlotVerticalLines(state.tWanders-starttime,'m:');
% annotate
xlabel('Time on Task (s)')
ylabel(h(2,1),'RT (s) (smoothed, \sigma=10)')
ylabel(h(2,2),'Percent correct (smoothed, \sigma=10)')





