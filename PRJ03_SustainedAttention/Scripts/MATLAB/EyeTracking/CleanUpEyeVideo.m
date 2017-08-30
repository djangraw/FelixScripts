function h = CleanUpEyeVideo(video,pos_pup,rad_pup,pos_cr,rad_cr,times,events,isOutlier)
% Makes a figure/UI for scrolling through and adjusting pupil/CR detection in an eye movie.
%
% h = CleanUpEyeVideo(video,pos_pup,rad_pup,pos_cr,rad_cr,times,events)
%
% The dot represents the subject's eye position.  The dot's size represents
% the reported pupil size.  The big rectangle is the limits of the screen.
%
% Inputs:
%   - video is a qxrxn matrix, where n is the number of video frames.
%   - pos_pup is an nx2 matrix, where each row is the (x,y) pos of
%   the subject's pupil (in pixels).
%   - rad_pup is an n-element vector, where each row is the radius of the
%   subject's pupil (in pixels). 
%   - pos_cr is an nx2 matrix, where each row is the (x,y) pos of
%   the subject's corneal reflection (in pixels).
%   - rad_cr is an n-element vector, where each row is the radius of the
%   subject's corneal reflection (in pixels). 
%   - times is an n-element vector of the corresponding times (in ms).
%   - events is an optional struct including saccade and display fields. In
%   the display field, subfields should be 'time' (in same units as 'times'
%   input),'name' (string), 'type' (optional, for grouping images in bottom
%   timeplot), and 'image' (optional, for display below eye pos... must be
%   image in current path, with same size as screen_res)  
%
% Outputs:
%   - h is a struct containing the handles for various items on the
% figure.  It can be used to get or change properties of the figures.  For 
% example, type 'get(h.Plot)' to get the properties of the main movie.
%
% Created 2/9/16 by DJ based on MakeEyeMovie_video.

% -------- INPUTS -------- %
if ~exist('rad_pup','var') || isempty(rad_pup)
    rad_pup=ones(1,length(pos_pup));
end
if ~exist('times','var') || isempty(times)
    times=1:length(pos_pup);
end
if ~exist('events','var') || isempty(events);    
    events = struct('display',struct('time',[],'name',{{}}),'saccade',struct('time_start',zeros(0,1),'time_end',zeros(0,1),'position_start',zeros(0,2),'position_end',zeros(0,2)));
end
if ~isfield(events,'display')
    events.display = struct('time',[],'name',{{}});
end
if ~isfield(events,'saccade')
    events.saccade = struct('time_start',zeros(0,1),'time_end',zeros(0,1),'position_start',zeros(0,2),'position_end',zeros(0,2));
end
if ~exist('isOutlier','var') || isempty(isOutlier)
    isOutlier = (isnan(rad_pup) | isnan(rad_cr));
end
% -------- SETUP -------- %
% normalize inputs
ps_reg = 50/nanmax(rad_pup); % factor we use to regularize pupil size
t_start = times(1);
times = (times-t_start)/1000;

% Get saccade info
saccade_times = ([events.saccade.time_start, events.saccade.time_end]-t_start)/1000; %[start end] in s

% -------- INITIAL PLOTTING -------- %
disp('Setting up figure...');
figure; % make a new figure
% [~,iTime] = min(abs(time-t_start)); % the global index of the current time point - this is used throughout all functions
iTime = 1;

% main eye video plot
h.VideoPlot = axes('Units','normalized','Position',[0.13 0.3 0.475 0.65],'ydir','reverse'); % set position
hold on;
h.Video = imagesc(video(:,:,iTime));
set(h.Video,'ButtonDownFcn',@videoclick_callback);
colormap gray
h.Circle_pup = viscircles(pos_pup(iTime,:),rad_pup(iTime),'EdgeColor','b');
h.Circle_cr = viscircles(pos_cr(iTime,:),rad_cr(iTime),'EdgeColor','r');
set(h.Circle_pup,'ButtonDownFcn',@videoclick_callback);
set(h.Circle_cr,'ButtonDownFcn',@videoclick_callback);
xlim([0 size(video,2)]+0.5);
ylim([0 size(video,1)]+0.5);

title(sprintf('t = %.3f s',times(iTime)));

% -------- TIME SELECTION PLOT SETUP -------- %
% 'Time plot' for selecting and observing current time
h.Time = axes('Units','normalized','Position',[0.13 0.1 0.775 0.1],'Yticklabel',''); % set position
hold on
% get event info
event_times = (events.display.time-t_start)/1000;
event_names = events.display.name;
if isfield(events.display,'type')
    event_types = events.display.type;
else
    event_types = repmat({'event'},size(events.display.name));
end
if isfield(events.display,'image')
    event_images = events.display.image;
else
    event_images = repmat({''},size(events.display.name));
end
event_categories = unique(event_types);
% assemble timeplot matrix
timeplot = cat(2,pos_pup,pos_cr);
timeplotlabel = {'pup_y';'pup_x';'cr_y';'cr_x'};

% get colors
nTimeplots = size(timeplot,2);
nEventCats = numel(event_categories); 
colors = distinguishable_colors(nTimeplots + nEventCats, {'w','k'});
% plot timeplots
for i=1:nTimeplots
    h.Timeplot{i} = plot(h.Time,times,timeplot(:,i),'ButtonDownFcn',@time_callback);
end
% Make event lines
hEventsCell = cell(nEventCats,1);
% plot colors for legend
for i=1:nEventCats
    plot(-1,-1,'color',colors(i+nTimeplots,:));
end
% plot events for real
for i=1:nEventCats
    hEventsCell{i} = PlotVerticalLines(event_times(strcmp(event_types,event_categories{i})),colors(i+nTimeplots,:));
end
h.Events = cat(2,hEventsCell{:});
set(h.Events,'ButtonDownFcn',@time_callback)

% % Plot saccade times
% plot(saccade_times,ones(size(saccade_times))*0.5,'k+','ButtonDownFcn',@time_callback);
% % Plot eye position
% normalized_samples = nan(size(samples));
% normalized_samples(:,1) = samples(:,1)/screen_res(1);
% normalized_samples(:,2) = samples(:,2)/screen_res(2);
% plot(times,normalized_samples,'g','ButtonDownFcn',@time_callback); % plot eye position

% Make time selection bar
h.Line = plot(times([iTime iTime]), get(gca,'YLim'),'k','linewidth',2); % Line indicating current time
set(h.Time,'ButtonDownFcn',@time_callback) % this must be called after plotting, or it will be overwritten

% Annotate plot
plot([0 times(end)],[0 0],'k','ButtonDownFcn',@time_callback); % plot separation between plots
% ylim(h.Time,[0 1]);
xlim(h.Time,[times(1) times(end)]);
xlabel('time (s)');
ylabel('data/events'); % Top section is object visibility, bottom section is eye x position
legend([timeplotlabel(:);event_categories(:)],'interpreter','none');

% -------- GUI CONTROL SETUP -------- %
disp('Making GUI controls...')
h.Play = uicontrol('Style','togglebutton',...
                'String','Play',...
                'Units','normalized','Position',[.45 .2 .1 .05],...
                'Callback',@play_callback); % play button
h.Speed = uicontrol('Style','slider',...
                'Min',1,'Max',100,'Value',1,'SliderStep',[.05 .2],...
                'Units','normalized','Position',[.45 .25 .1 .025]); % speed slider
h.OutBack = uicontrol('Style','pushbutton',...
                'String','Outlier <',...
                'Units','normalized','Position',[.25 .2 .1 .05],...
                'Callback',@outback_callback); % back-to-last-saccade button
h.Back = uicontrol('Style','pushbutton',...
                'String','<',...
                'Units','normalized','Position',[.38 .2 .05 .05],...
                'Callback',@back_callback); % back button
h.Fwd = uicontrol('Style','pushbutton',...
                'String','>',...
                'Units','normalized','Position',[.57 .2 .05 .05],...
                'Callback',@fwd_callback); % forward button            
h.OutFwd = uicontrol('Style','pushbutton',...
                'String','> Outlier',...
                'Units','normalized','Position',[.65 .2 .1 .05],...
                'Callback',@outfwd_callback); % fwd-to-next-saccade button
h.Save = uicontrol('Style','pushbutton',...
                'String','SAVE',...
                'Units','normalized','Position',[.78 .2 .1 .05],...
                'Callback',@save_callback); % save-results button
              
disp('Done!')
    
% -------- KEYBOARD CONTROL SETUP -------- %
% Declare keypress function
set(gcf,'KeyPressFcn', @assign_keypress);
% declare other global variables
h.iSac = [];
show_circles = true;
move_pup = true;
redraw;

% -------- SUBFUNCTIONS -------- %
function redraw() % Update the line and topoplot
    % Check that iTime is within allowable bounds
    if iTime<1, iTime=1;
    elseif iTime>numel(times), iTime = numel(times);
    end
    % Adjust plots
    set(h.Video,'CData',video(:,:,iTime));
    set(h.Line,'XData',times([iTime iTime]));
    axes(h.VideoPlot);
    delete(h.Circle_pup);
    delete(h.Circle_cr);
    if move_pup
        h.Circle_pup = viscircles(pos_pup(iTime,:),rad_pup(iTime),'EdgeColor','b','DrawBackgroundCircle',false,'LineWidth',1,'LineStyle','--');
        h.Circle_cr = viscircles(pos_cr(iTime,:),rad_cr(iTime),'EdgeColor','r','DrawBackgroundCircle',false,'LineWidth',1,'LineStyle',':');    
    else
        h.Circle_pup = viscircles(pos_pup(iTime,:),rad_pup(iTime),'EdgeColor','b','DrawBackgroundCircle',false,'LineWidth',1,'LineStyle',':');
        h.Circle_cr = viscircles(pos_cr(iTime,:),rad_cr(iTime),'EdgeColor','r','DrawBackgroundCircle',false,'LineWidth',1,'LineStyle','--');    
    end
    if ~show_circles
        set(h.Circle_pup,'visible','off');
        set(h.Circle_cr,'visible','off');
    end
    
    % update timeplots
    timeplot = cat(2,pos_pup,pos_cr);
    for iPlot=1:nTimeplots
        set(h.Timeplot{iPlot},'ydata',timeplot(:,iPlot));
    end
    
    
    % Find Saccade
    axes(h.VideoPlot);
    iSaccade = find(times(iTime)>saccade_times(:,1) & times(iTime)<saccade_times(:,2),1);
    if ~isequal(iSaccade,h.iSac)
        h.iSac = [];
    end
    if ~isempty(iSaccade) && isempty(h.Saccade)
        h.iSac = iSaccade;    
    end    
    
    % Find event name
    iEvent = find(event_times<=times(iTime),1,'last'); 
    if isempty(iEvent)
        iEvent=0;
        thisEventName = 'None';
    else
        thisEventName = event_names{iEvent};
        % display image
        if isempty(event_images{iEvent})
            set(h.Image,'visible','off')
        else
            cdata = imread(event_images{iEvent});
            set(h.Image,'xdata',linspace(imTopLeft(1),imBotRight(1),size(cdata,2)),...
                'ydata',linspace(imTopLeft(2),imBotRight(2),size(cdata,1)),...
                'cdata',cdata,'visible','on')
        end
    end
    
    % Update title
    title(sprintf('t = %.3f s\n Event #%d: %s, Saccade #%d',times(iTime),...
        iEvent,thisEventName,iSaccade),'interpreter','none'); 
    drawnow;
end

% HANDLE KEYPRESSES
function assign_keypress(hObject,eventdata)
    handles = guidata(hObject);            
    
    % display key (for debugging)
%     disp(eventdata.Key)
    
    % remove 'numpad'
    if strncmp(eventdata.Key,'numpad',6)
        keyname = eventdata.Key(7:end);
    else
        keyname = eventdata.Key;
    end
    
    % time point
    if strcmp(keyname,'1') || strcmp(keyname,'comma')
        back_callback(hObject, eventdata);
        return;
    elseif strcmp(keyname,'3') || strcmp(keyname,'space') || strcmp(keyname,'period')
        fwd_callback(hObject, eventdata);
        return;
    % move pupil
    elseif strcmp(keyname,'leftarrow') || strcmp(keyname,'4')
        if move_pup, pos_pup(iTime,1) = pos_pup(iTime,1) - 1;
        else pos_cr(iTime,1) = pos_cr(iTime,1) - 1; end
    elseif strcmp(keyname,'rightarrow')  || strcmp(keyname,'6')
        if move_pup, pos_pup(iTime,1) = pos_pup(iTime,1) + 1;
        else pos_cr(iTime,1) = pos_cr(iTime,1) + 1; end
    elseif strcmp(keyname,'uparrow')  || strcmp(keyname,'8')
        if move_pup, pos_pup(iTime,2) = pos_pup(iTime,2) - 1;
        else pos_cr(iTime,2) = pos_cr(iTime,2) - 1; end
    elseif strcmp(keyname,'downarrow')  || strcmp(keyname,'2')
        if move_pup, pos_pup(iTime,2) = pos_pup(iTime,2) + 1;
        else pos_cr(iTime,2) = pos_cr(iTime,2) + 1; end
    % resize pupil
    elseif strcmp(keyname,'equal') || strcmp(keyname,'add')
        if move_pup, rad_pup(iTime) = rad_pup(iTime) + 1;
        else rad_cr(iTime) = rad_cr(iTime) + 1; end
    elseif strcmp(keyname,'hyphen') || strcmp(keyname,'subtract')
        if move_pup, rad_pup(iTime) = rad_pup(iTime) - 1;
        else rad_cr(iTime) = rad_cr(iTime) - 1; end
    elseif strcmp(keyname,'return') && iTime<size(pos_pup,1)
        if move_pup
            pos_pup(iTime+1,:) = pos_pup(iTime,:);
            rad_pup(iTime+1) = rad_pup(iTime);
        else
            pos_cr(iTime+1,:) = pos_cr(iTime,:);
            rad_cr(iTime+1) = rad_cr(iTime);
        end
        fwd_callback(hObject, eventdata);
        return;
    elseif strcmp(keyname,'0') && iTime>1
        if move_pup
            pos_pup(iTime,:) = pos_pup(iTime-1,:);
            rad_pup(iTime) = rad_pup(iTime-1);
        else
            pos_cr(iTime,:) = pos_cr(iTime-1,:);
            rad_cr(iTime) = rad_cr(iTime-1);
        end
    elseif strcmp(keyname,'clear')
        show_circles = ~show_circles;
    elseif strcmp(keyname,'slash') || strcmp(keyname,'divide')
        move_pup = ~move_pup;
    elseif strcmp(keyname,'n')
        if move_pup
            if isnan(rad_pup(iTime)), rad_pup(iTime) = 1;
            else rad_pup(iTime) = nan; end
        else
            if isnan(rad_cr(iTime)), rad_cr(iTime) = 1;
            else rad_cr(iTime) = nan; end
        end
    end
    
    % update plot
    redraw;

    % Update handles structure
    guidata(hObject, handles);

end

% HANDLE MOUSE CLICKS
function videoclick_callback(hObject,eventdata) % First mouse click on the Time plot brings us here
    cp = get(h.VideoPlot,'CurrentPoint'); % get the point(s) (x,y) where the person just clicked
    x = cp(1,1); % choose the x value of one point (the x values should all be the same).
    y = cp(1,2);
    if move_pup
        pos_pup(iTime,:) = round([x y]); % find closest pixel to the click
    else
        pos_cr(iTime,:) = round([x y]); % find closest pixel to the click
    end
    redraw; % update line and topoplot
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
        iTime=iTime+floor(get(h.Speed,'Value'));
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

function outback_callback(hObject,eventdata)
    iOutlier = find(isOutlier(1:iTime-1),1,'last');
    if ~isempty(iOutlier)
        iTime = iOutlier;
        redraw; % update displays
    end
end

function outfwd_callback(hObject,eventdata)
    iOutlier = iTime + find(isOutlier(iTime+1:end),1,'first');
    if ~isempty(iOutlier)
        iTime = iOutlier;
        redraw; % update displays
    end
end

function save_callback(hObject,eventdata)
    [file,path] = uiputfile('*.mat','Save Workspace As');
    if isempty(file)
        disp('Saving was canceled!')
    else
        fprintf('Saving as %s...\n',file);
        save([path file],'pos_pup','pos_cr','rad_pup','rad_cr');
        disp('Saved!');
    end
end

end %function MakeEyeMovie



