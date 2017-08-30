function presses = GetTiming(duration,oldPresses)

if nargin<2
    oldPresses = cell(0,2);
end
% make figure and axes.
figure(935); clf;
axes; 
% Plot timing line and annotate plot.
hLine = plot([0 0],[0 1],'k-');
xlim([0 duration]);
xlabel('time (s)');
ylabel('keypresses');
% title('Press escape to end.')

% set up keypress functions.
set(gcf,'KeyPressFcn',{@handleKeypress,hLine},'KeyReleaseFcn',{@handleKeyRelease,hLine})
set(gcf,'userdata',oldPresses);

% start timer
tic;
currTime = 0;
% Run loop
while currTime<duration
    currTime = toc;
    set(hLine,'xdata',repmat(toc,1,2));
    drawnow;
end
presses = get(gcf,'userdata');

% plot results
PlotTiming(presses);

end

function handleKeypress(hObj,hEvent,hLine)
    thisKey = hEvent.Key;
    presses = get(gcf,'userdata');
    iKey = find(strcmp(thisKey,presses(:,1)),1);
    if isempty(iKey)
        % Add row
        iKey = size(presses,1)+1;
        presses = [presses; {thisKey, zeros(0,2)}];
    end
    currTime = get(hLine,'xdata');
    presses{iKey,2} = [presses{iKey,2}; currTime];
    set(gcf,'userdata',presses);
end


function handleKeyRelease(hObj,hEvent,hLine)
    thisKey = hEvent.Key;
    presses = get(gcf,'userdata');
    iKey = find(strcmp(thisKey,presses(:,1)),1);
    if isempty(iKey)
        return;
    end
    currTime = get(hLine,'xdata');
    presses{iKey,2}(end,2) = currTime(1);
    set(gcf,'userdata',presses);
end