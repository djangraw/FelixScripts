function MakeFcMovie(FC,times,clim,event_times,event_names,timeplot,timeplotlabel)

% Play movie of functional connectivity alongside specified timecourses and
% events.
%
% MakeFcMovie(FC,times,clim,event_times,event_names,timeplot,timeplotlabel)
%
% INPUTS:
% -FC is an nxmxp matrix of functional connectivity, where FC(:,:,i) is the 
% connectivity matrix for time times(i).
% -times is a p-element vector of time values.
% -clim is a 2-element vector specifying the [min,max] colors on the color
% scale [default: min(FC(:)), max(FC(:))]
% -event_times is a q-element vector of times when events of interest
% occurred.
% -event_names is a q-element cell array of strings describing the events.
% -timeplot is a rxp-element matrix indicating the timecourses of r
% arbitrary variables.
% -timeplotlabel is an r-element cell array of strings labeling the
% timeplot variables.
% 
% Created 11/6-7/15 by DJ.

% -------- HANDLE INPUTS -------- %
% Declare defaults
if ~exist('times','var') || isempty(times)
    times = 1:size(FC,3);
end
if ~exist('clim','var') || isempty(clim)
    clim = [min(FC(:)), max(FC(:))];
end
if ~exist('event_times','var')
    event_times = [];
end
if ~exist('event_names','var')
    event_names = {};
end
if ~exist('timeplot','var') || isempty(times)
    timeplot=nan(length(times),1);
end
if size(timeplot,2)==length(times)
    timeplot = timeplot';
end
if ~exist('timeplotlabel','var')
    timeplotlabel = repmat({''},1,size(timeplot,2));
end
if ~iscell(timeplotlabel)
    timeplotlabel = {timeplotlabel};
end

% -------- MAIN PLOTS -------- %
figure; clf;
% Make FC plot
iTime = 1;
h.Main = axes('Position',[0.13 0.3 0.775 0.65]);
h.FcPlot = imagesc(FC(:,:,iTime));
hold on
xlabel('ROI');
ylabel('ROI');
axis square
set(gca,'clim',clim);
colorbar

% Make time plot
h.Time = axes('Position',[0.13 0.1 0.775 0.1]);
hold on
event_types = unique(event_names);
nTimeplots = size(timeplot,2);
nEventTypes = numel(event_types); 
colors = distinguishable_colors(nTimeplots + nEventTypes, {'w','k'});
for i=1:nTimeplots
    h.Timeplot{i} = plot(h.Time,times,timeplot(:,i),'ButtonDownFcn',@time_callback);
end
% Make event lines
hEventsCell = cell(nEventTypes,1);
% plot colors for legend
for i=1:nEventTypes
    plot(-1,-1,'color',colors(i+nTimeplots,:));
end
% plot events for real
for i=1:nEventTypes
    hEventsCell{i} = PlotVerticalLines(event_times(strcmp(event_names,event_types{i})),colors(i+nTimeplots,:));
end
h.Events = cat(2,hEventsCell{:});
% Make time selection bar
h.Line = plot(h.Time,times([iTime iTime]), get(gca,'YLim'),'k','linewidth',2); % Line indicating current time
% Annotate plot
xlim([times(1),times(end)])
xlabel('time (s)')
ylabel('data/events')
set(h.Time,'ButtonDownFcn',@time_callback)
legend([timeplotlabel(:);event_types(:)]);

% -------- GUI CONTROL SETUP -------- %
disp('Making GUI controls...')
h.Play = uicontrol('Style','togglebutton',...
                'String','Play',...
                'Units','normalized','Position',[.45 .2 .1 .05],...
                'Callback',@play_callback); % play button
h.Speed = uicontrol('Style','slider',...
                'Min',0.2,'Max',10,'Value',1,'SliderStep',[.05 .2],...
                'Units','normalized','Position',[.45 .25 .1 .025]); % speed slider
h.EventBack = uicontrol('Style','pushbutton',...
                'String','Event <',...
                'Units','normalized','Position',[.25 .2 .1 .05],...
                'Callback',@eventback_callback); % back-to-last-saccade button
h.Back = uicontrol('Style','pushbutton',...
                'String','<',...
                'Units','normalized','Position',[.38 .2 .05 .05],...
                'Callback',@back_callback); % back button
h.Fwd = uicontrol('Style','pushbutton',...
                'String','>',...
                'Units','normalized','Position',[.57 .2 .05 .05],...
                'Callback',@fwd_callback); % forward button            
h.EventFwd = uicontrol('Style','pushbutton',...
                'String','> Event',...
                'Units','normalized','Position',[.65 .2 .1 .05],...
                'Callback',@eventfwd_callback); % fwd-to-next-saccade button
              
disp('Done!')

% -------- SUBFUNCTIONS -------- %
function redraw() % Update the line and topoplot
    % Check that iTime is within allowable bounds
    if iTime<1, iTime=1;
    elseif iTime>numel(times), iTime = numel(times);
    end
    % Adjust plots
    set(h.Line,'XData',times(floor([iTime iTime])));
    axes(h.Main);
    delete(h.FcPlot);
    h.FcPlot = imagesc(FC(:,:,floor(iTime)));
    
    % Find display name
    iEvent = find(event_times<=times(floor(iTime)),1,'last'); 
    if isempty(iEvent)
        iEvent=0;
        eventname = 'None';
    else
        eventname = event_names{iEvent};
    end
    
    % Update title
    title(sprintf('t = %.3f s\n Event #%d: %s',times(floor(iTime)),iEvent,eventname)); 
    drawnow;
end

function time_callback(hObject,eventdata) % First mouse click on the Time plot brings us here
    cp = get(h.Time,'CurrentPoint'); % get the point(s) (x,y) where the person just clicked
    x = cp(1,1); % choose the x value of one point (the x values should all be the same).
    iTime = find(times>=x,1); % find closest time to the click
    redraw; % update line and topoplot
end    

function play_callback(hObject,eventdata)
    % Get button value
    button_is_on = get(hObject,'Value') == get(hObject,'Max');
    % Keep incrementing and plotting
    while button_is_on && iTime < numel(times) %until we press pause or reach the end
        iTime=iTime+get(h.Speed,'Value');
        redraw;
        button_is_on = get(hObject,'Value') == get(hObject,'Max');
    end
    set(hObject,'Value',get(hObject,'Min')); % if we've reached the end, turn off the play button
end %function play_callback

function back_callback(hObject,eventdata)
    iTime = iTime-1; % decrement time index
    redraw; % update line and topoplot
end

function fwd_callback(hObject,eventdata)
    iTime = iTime+1; % increment time index
    redraw; % update line and topoplot
end

function eventback_callback(hObject,eventdata)
    event = find(event_times<times(floor(iTime-1)),1,'last');
    if ~isempty(event)
        iTime = find(times>=event_times(event),1);    
        redraw; % update line and topoplot
    end
end

function eventfwd_callback(hObject,eventdata)
    event = find(event_times>times(floor(iTime)),1,'first');
    if ~isempty(event)
        iTime = find(times>=event_times(event),1);    
        redraw; % update line and topoplot
    end
end


end