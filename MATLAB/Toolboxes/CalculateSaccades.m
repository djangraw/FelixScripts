function [s] = CalculateSaccades(hpos,vpos,hvel,vvel,acrit,vcrit,events,fignum,docurve)

%   [s] = CalculateSaccades(hpos, vpos, hvel, vvel, acrit, vcrit, fignum, docurve)
%
%   acrit = minumum amplitude to be considered as a saccade
%
%   vcrit = velocity criterion for saccade onset 
%
%   events = the temporal limits for the recorded segments of the trial
%
%   figure window is opened if fignum > 0
%
%   docurve = calculate curvature
%
% Detection criteria (for GDS1):
% 1) for amplitude - avoid detecting micro-saccaddes
%    acrit = (0.5 - 1 or 2) deg;
%    acrit = (5% - 10%)*Amax for this experiment
% 2) for velocity - avoid detecting smooth pursuit
%    vcrit = 20 deg/2 (you are expecting to have velocities of 100 deg/s
%    vcrit = 20%*Vmax
% 3) for acceleration:
%    acccrit = 500 deg/s2;
%
% Created 9/14/10 by DJ, based on the Gottlieb Lab's program 'saccade'.


% ---HANDLE INPUTS---
if nargin == 2
    hvel = [diff(hpos) 0];
    vvel = [diff(vpos) 0];
    acrit = 1;
    vcrit = 50;
    events = [];
    fignum = 0;
    docurve = 0;
if nargin == 4
    acrit = 1;
    vcrit = 50;
    events = [];
    fignum = 0;
    docurve = 0;
elseif nargin == 5
    vcrit = 50;
    events = [];
    fignum = 0;
    docurve = 0;
elseif nargin == 6
    events = [];
    fignum = 0;
    docurve = 0;
elseif nargin == 7
    fignum = 0;
    docurve = 0;
elseif nargin == 8
    docurve = 0;
end;

% ---DECLARE VARIABLES/CONSTANTS---
samprt = 2; % time between samples of eye tracker (ms)

%global ssnum snum rvel s0 s1 nsamp;
% s = struct('onset',[],'offset',[],'peakvel',[],'peakt',[],'amp',[],'ecc',[],'endx',[],'endy',[],'curv',[]);
s = [];
maxsaccades = 100;
delta = 6;
nsamp = length(hpos);
tt = [1:nsamp]*samprt; % time in ms from start of tracking
rpos = sqrt(hpos.^2 + vpos.^2); % magnitude of position vector (polar coordinate position)
rvel = sqrt(hvel.^2 + vvel.^2); % magnitude of velocity vector
[maxvelind maxvel] = getpeaks(rvel); % maximum velocity
[minvelind minvel] = getvalleys(rvel); % minimum velocity


% find first saccade, if any
snum = 0;
j = find(rvel > vcrit);
if ~isempty(j)
    snum = snum + 1;
    s0(snum) = min(j); %first velocity sample above criterion
    j = find(rvel(s0(snum):nsamp) < vcrit);
    if ~isempty(j)
        s1(snum) = s0(snum) + min(j);%first sample that falls below criterion, after the above-criterion point
    else
        s1(snum) = min([s0(snum)+50 nsamp]);
    end;
    
    % Check if velocity drops more than 50% of peak during saccade
    % If so, break into two saccades
    
    kn = find(maxvelind > s0(snum) & maxvelind < s1(snum));
    if ~isempty(kn)
        jn = find(minvelind > s0(snum) & minvelind < s1(snum));
        newcrit = 0.5 * mean(maxvel(kn));
        if ~isempty(j)
            for i = 1:length(jn)
                if (minvel(jn(i)) < newcrit)
                    s1(snum + 1) = s1(snum);
                    s0(snum + 1) = minvelind(jn(i));
                    s1(snum) = minvelind(jn(i));
                    snum = snum + 1;
                end;
            end;
        end;
    end;
end;


% find up to maxsaccades saccades
while ~isempty(j) & snum < maxsaccades
    j = find(rvel(s1(snum):nsamp) > vcrit);
    if ~isempty(j)
        snum = snum + 1;
        s0(snum) = s1(snum - 1) + min(j);
        j = find(rvel(s0(snum):nsamp) < vcrit);
        if ~isempty(j)
            s1(snum) = s0(snum) + min(j);
        else
            s1(snum) = min([s0(snum)+40 nsamp]);
        end;
        % Check if velocity drops more than 50% of peak during saccade
        % If so, break into two saccades
        
        kn = find(maxvelind >= s0(snum) & maxvelind <= s1(snum));
        if ~isempty(kn)
            newcrit = 0.5 * mean(maxvel(kn));
            jn = find(minvelind >= s0(snum) & minvelind <= s1(snum));
            if ~isempty(jn)
                for i = 1:length(jn)
                    if (minvel(jn(i)) < newcrit)
                        s1(snum + 1) = s1(snum);
                        s0(snum + 1) = minvelind(jn(i));
                        s1(snum) = minvelind(jn(i));
                        snum = snum + 1;
                    end;
                end;
            end;
        end;
    end;
    %check if the index riched the limits PFB 02/20/03
    if s0(snum)>nsamp
        snum=snum-1;
        break;
    end;
    if (s1(snum)>nsamp)&(s0(snum)<nsamp)
        s1(snum)=nsamp;
        break;
    end;
end;

%go thru each of the sacs identified based on velocity and add them to the
%output struct only if they pass amplitude criterion. 
ssnum = 0;
for i = 1:snum 
    dx = hpos(min(s1(i), nsamp)) - hpos(min(s0(i), nsamp));
    dy = vpos(min(s1(i), nsamp)) - vpos(min(s0(i), nsamp));
    amp = (dx.*dx + dy.*dy).^0.5;
    aph=(180/pi)*atan2(dy,dx); %PFB 02/20/03
    
    if amp > acrit
        ssnum = ssnum + 1;
        s(ssnum).onset = samprt*(s0(i) - delta);
        s(ssnum).offset = samprt*s1(i);
        [s(ssnum).peakvel peaki] = max(rvel(s0(i):s1(i)));
        s(ssnum).peakt = samprt*(s0(i) + peaki);
        s(ssnum).amp = amp;
        s(ssnum).aph = aph; %PFB 02/20/03
        ex = hpos(min(s1(i), nsamp));
        ey = vpos(min(s1(i), nsamp));
        s(ssnum).endx = ex;
        s(ssnum).endy = ey;
        s(ssnum).ecc = (ex.*ex+ey.*ey).^0.5;
    end;
end;



%-------------------------------------------------------------------------
events=events/2;
ii=1;
if fignum > 0
    
    % position-time plot
    
    ypmin = 0;
    ypmax = max(1.0, max(rpos));
    figure(fignum); clf;
    subplot(2,2,1);
    hold on;
    plot(tt,rpos);
    for i = 1:ssnum
        plot([s(i).onset s(i).onset], [ypmin ypmax], 'g-');
        plot([s(i).offset s(i).offset], [ypmin ypmax], 'm-');
    end;
    for k=1:length(events)
        plot([events(k) events(k)],[ypmin ypmax],'y:');
    end;
    axis([0 length(tt) ypmin ypmax]);
    xlabel('timestamps');
    ylabel('R (deg)');
    hold off;
    
    % position x-y plot
    
    subplot(2,2,2);
    hold on;
    plot(hpos,vpos, 'm-', 'markersize', 2);
    axis([-ypmax ypmax -ypmax ypmax]);
    axis square;
    hl=line([0 0],[-ypmax ypmax]);
    set(hl,'LineStyle',':','Color','k');
    hl=line([-ypmax ypmax],[0 0]);
    set(hl,'LineStyle',':','Color','k');    
    xlabel('X (deg)');
    ylabel('Y (deg)');
    hold off;
    ii=ii+1;
    % velocity-time plot    
    
    yvmin = -10;
    yvmax = max([max(rvel) 1.0]);
    subplot(2,2,3);
    hold on;
    plot(tt,rvel);
    for i = 1:ssnum
        plot([s(i).onset s(i).onset], [yvmin yvmax], 'g-');
        plot([s(i).offset s(i).offset], [yvmin yvmax], 'm-');
        plot([s(i).peakt s(i).peakt], [yvmin yvmax], 'c:');
    end;   
    plot([0 nsamp], [vcrit vcrit], 'r-');
    axis([0 length(tt) yvmin yvmax]);
    for k=1:length(events)
        plot([events(k) events(k)],[yvmin yvmax],'y:');
    end;    
    xlabel('timestamps');
    ylabel('V (deg/s)');   
    hold off;
    
    if docurve
        
        % curvature plot hpos vs. vpos for each sacc w/ regression
        
        subplot(2,2,4);
        %colrs = ['w', 'g', 'y', 'c', 'r', 'b', 'm'];
        colrs = ['k', 'g', 'y', 'c', 'r', 'b', 'm'];
        hold on;
        for i = 1:min(length(colrs),ssnum)
            s0 = max(1, s(i).onset);
            s1 = min(nsamp, s(i).offset);
            x = hpos(s0:s1);
            y = vpos(s0:s1);
            plot(x,y, strcat(colrs(i), '.'));
            [p, q] = polyfit(x,y,1);
            xn = length(x);
            plot([x(1) x(xn)], p(2)+p(1)*[x(1) x(xn)], strcat(colrs(i),'--'));
            
        end;
        axis equal;
        xlabel('hpos for each saccade')
        ylabel('vpos for each saccade')        
        hold off;
        
    else
        
        % velocity x-y plot
        
        subplot(2,2,4);
        hold on;
        plot(hvel,vvel, 'y.', 'markersize', 1);
        axis([-yvmax yvmax -yvmax yvmax]);
        xlabel('V_X')
        ylabel('V_Y');
        hold off
        
    end;
    
end;

