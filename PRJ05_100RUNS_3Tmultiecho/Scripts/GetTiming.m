function presses = GetTiming(duration,oldPresses)

% function presses = GetTiming(duration,oldPresses)
%
% INPUTS:
% -duration is a scalar indicating how long you would like the recording to
% last (in seconds).
% -oldPresses is a 2-column cell array containing the keypresses from a
% previous GetTiming run (in case you want to add more to it).
%
% OUTPUTS:
% -presses is a 2-column cell array where each row is a key pressed
% sometime during the session. The first column is the key name, and the
% second is a 2-column array where each row is the [onset, offset] times of
% a keypress.
%
% Created ~4/29/15 by DJ.
% Updated 2/6/18 by DJ - comments.

% Declare defaults
if ~exist('oldPresses','var') || isempty(oldPresses)
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

% Declare subfunctions
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