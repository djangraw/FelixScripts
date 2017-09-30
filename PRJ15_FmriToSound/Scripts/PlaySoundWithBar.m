function PlaySoundWithBar(soundVec,t_sound,t_range)

% PlaySoundWithBar(soundVec,t_play,t_range)
%
% Created 9/28/17 by DJ.
% Updated 9/29/17 by DJ - t_play,

% allow Fs as input
if length(t_sound)==1    
    Fs_sound = t_sound;
    t_sound = (1:numel(soundVec))/Fs_sound;
else
    Fs_sound = 1/median(diff(t_sound));
end
% allow end-time as input
if ~exist('t_range','var') || isempty(t_range)
    t_range = [t_sound(1) t_sound(end)];
elseif length(t_range)==1
    t_range = [0 t_range]+t_sound(1);
end

% Set up plot
hold on;
plot(t_sound,soundVec(:),'ButtonDownFcn',@time_callback);
h.Bar = PlotVerticalLines(0,'k-');
xlabel('time (s)');
ylabel('signal (raw)');
% xlim(t_range);

% create audioplayer and play
isInRange = (t_sound>=t_range(1) & t_sound<=t_range(2));
tAp = t_sound(isInRange);
ap = audioplayer(soundVec(isInRange),Fs_sound);

% Make it so that when you click somewhere it moves the bar/ap
set(gca,'ButtonDownFcn',@time_callback);


% Create play, pause, and stop buttons
playButton = uicontrol('Style', 'pushbutton', 'String', '>',...
        'Position', [20 20 20 20],...
        'Callback', @doPlay);    
pauseButton = uicontrol('Style', 'pushbutton', 'String', '||',...
        'Position', [50 20 20 20],...
        'Callback', @doPause);    
stopButton = uicontrol('Style', 'pushbutton', 'String', 'x',...
        'Position', [80 20 20 20],...
        'Callback', @doStop);    
    
function time_callback(varargin)
    cp = get(gca,'CurrentPoint'); % get the point(s) (x,y) where the person just clicked
    x = cp(1,1); % choose the x value of one point (the x values should all be the same).
    iTime = find(t_sound>=x,1); % find closest time to the click
    isPlaying = ap.isplaying;
    stop(ap);
    delete(ap);
    ap = audioplayer(soundVec(iTime:end),Fs_sound);
    tAp = t_sound(iTime:end);
    if isPlaying
        doPlay();
    else
        AdvanceBar(ap); % update line and topoplot
    end
end

function doPlay(varargin)
    resume(ap);
%     play(ap);
    while ap.isplaying
        AdvanceBar(ap);
    end
end

function doStop(varargin)
    stop(ap);
    AdvanceBar(ap);
end

function doPause(varargin)
    pause(ap);
end

% Helper function
function AdvanceBar(ap)
    tAudio = tAp(ap.CurrentSample);
    set(h.Bar,'XData',[NaN,1,1]*tAudio);
    drawnow;
end

end