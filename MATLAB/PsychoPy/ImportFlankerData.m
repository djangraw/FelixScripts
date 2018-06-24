function data = ImportFlankerData(filename)

% Created 1/26/15 by DJ. 

if nargin==0
    filename = 'Flanker-1-1-DEMO.log'; % demo
end
minRT = 0.1; % RT (in s) considered too fast to be a real response

params = PsychoPy_ParseParams(filename,'START PARAMETERS','END PARAMETERS');
events = PsychoPy_ParseEvents(filename,[],'START EXPERIMENT');

% get performance
iTrials = find(ismember(events.display.name,{'LeftTarget','RightTarget'}));
tTrials = events.display.time(iTrials);
nTrials = numel(tTrials);
[performance.isCongruent, performance.isCorrect, performance.RT] = deal(nan(nTrials,1));
[performance.extraKeys, performance.extraRTs] = deal(cell(nTrials,1));
for i=1:nTrials
    performance.isCongruent(i) = strcmp(events.display.name{iTrials(i)}(1:4),events.display.name{iTrials(i)-1}(1:4));
    if i<nTrials
        iKeys = find(events.key.time > tTrials(i)+minRT & events.key.time <= tTrials(i+1)+minRT & ismember(events.key.char,params.respKeys));
    else
        iKeys = find(events.key.time > tTrials(i)+minRT & ismember(events.key.char,params.respKeys));
    end
    if isempty(iKeys)
        performance.RT(i) = NaN;
    else
        iFirstKey = iKeys(1);
        performance.RT(i) = events.key.time(iFirstKey) - tTrials(i);
    end
    if xor(strcmp(events.display.name{iTrials(i)},'RightTarget'), strcmp(events.key.char(iKeys(1)),params.respKeys{1}))
        performance.isCorrect(i) = 1;
    else
        performance.isCorrect(i) = 0;
    end
    
    % log any extra keypresses
    performance.nKeys(i) = length(iKeys);
    if performance.nKeys(i)>1
        performance.extraKeys{i} = events.key.char(iKeys(2:end));
        performance.extraRTs{i} = events.key.time(iKeys(2:end)) - tTrials(i);
    end
end

% get wandering catch presses
state.tWanders = events.key.time(strcmp(params.wanderKey,events.key.char));

% prepare output
data.params = params;
data.events = events;
data.performance = performance;
data.state = state;

% ==== BEGIN PLOTTING ==== %

% Set up plot
clf;
h = zeros(2,2); % plots
MakeFigureTitle(filename);

% --- 1. Plot single-trial performance
starttime = events.block.time(1);
timeontask = tTrials - starttime;
% set up plot
h(1,1) = axes('position',[0.1 0.6 0.6 0.35]); hold on
% plot RTs
isC = performance.isCongruent>0; % for brevity
plot(timeontask(isC), performance.RT(isC), 'b.-');
plot(timeontask(~isC), performance.RT(~isC), 'c.-');
ylim([0 params.respDur + minRT])
xlim([0 timeontask(end)])
% plot erroneous keypresses as red o's
RTtemp = performance.RT;
if any(~performance.isCorrect)    
    RTtemp(isnan(RTtemp)) = params.respDur + minRT;
    plot(timeontask(~performance.isCorrect), RTtemp(~performance.isCorrect),'ro');
%     plot(timeontask(~performance.isCorrect), performance.RT(~performance.isCorrect),'ro');
else
    plot(-1,-1,'ro'); % filler for legend
end
% add MW catch times
if ~isempty(state.tWanders)
    PlotVerticalLines(state.tWanders-starttime,'m:');
else
    plot(-1,-2,'m:'); % filler for legend
end

% annotate
legend('congruent trials','incongruent trials','errors','subj reported MW');
xlabel('Time on Task (s)')
ylabel('Reaction Time (s)')
title('Single-trial performance')

% --- 2. Make vertical histogram of RTs
% set up plot
h(1,2) = axes('position',[0.75 0.6 0.2 0.35]); hold on
% get histogram
xBins = 0:0.001:params.respDur+minRT;
% yBins = hist(performance.RT(~performance.isTarget),xBins);
yBins1 = hist(RTtemp(isC),xBins);
yBins2 = hist(RTtemp(~isC),xBins);
cBins = cell(1,2);
cBins{1} = cumsum(yBins1)/sum(isC)*100;
cBins{2} = cumsum(yBins2)/sum(~isC)*100;
plot(cBins{1},xBins,'b');
plot(cBins{2},xBins,'c');
xlim([0 100]);
ylim([0 params.respDur + minRT]);
% plot median and 95th percentile lines
hold on
colors = {'b','c'};
for i=1:2
    i50RT = find(cBins{i}>=50,1);
    i95RT = find(cBins{i}>=95,1);
    PlotHorizontalLines(xBins(i50RT),[colors{i} ':']);
    PlotHorizontalLines(xBins(i95RT),[colors{i} '--']);
    plot([cBins{i}(i50RT),cBins{i}(i50RT)],[0 xBins(i50RT)],':','color',colors{i});
    plot([cBins{i}(i95RT),cBins{i}(i95RT)],[0 xBins(i95RT)],'--','color',colors{i});
    
    % update first plot with median & 95% RTs
    plot(h(1,1),get(h(1,1),'xlim'), [xBins(i50RT) xBins(i50RT)],':','color',colors{i});
    plot(h(1,1),get(h(1,1),'xlim'), [xBins(i95RT) xBins(i95RT)],'--','color',colors{i});
end
% annotate
legend('RT proportion','median','95th percentile');
xlabel('% trials faster than RT')
ylabel('Reaction Time (s)')
title('Cumulative Histogram')



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





