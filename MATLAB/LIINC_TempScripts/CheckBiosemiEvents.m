function [session_events, eye_events] = CheckBiosemiEvents(filenames,y_cell)

% [session_events, eye_events] = CheckBiosemiEvents(filenames,y_cell)
%
% Created 10/20/14 by DJ.

PAUSE_ON_CODE = 153;
PAUSE_OFF_CODE = 152;

session_events = cell(1,numel(filenames));
eye_events = cell(1,numel(filenames));
for i=1:numel(filenames)
    filename = filenames{i};

    % Get boundary events
    dat = sopen(filename);

    port_events = [dat.BDF.Trigger.POS dat.BDF.Trigger.TYP-16128]; 
    pauses = find(dat.BDF.Status.TYP==PAUSE_ON_CODE);
    pause_events = [dat.BDF.Status.POS(pauses) dat.BDF.Status.TYP(pauses)]; 
%     resumes = find(dat.BDF.Status.TYP==PAUSE_OFF_CODE);
%     resume_events = [dat.BDF.Status.POS(resumes) dat.BDF.Status.TYP(resumes)]; 
    
    % Add long-pause events
    timebetweenevents = diff(port_events(:,1));
    iStartPause = find(timebetweenevents>2500*2048/1000);
    for j=1:numel(iStartPause)
        if sum(pause_events(:,1) >= port_events(iStartPause(j),1) & pause_events(:,1) <= port_events(iStartPause(j)+1,1))==0
            pause_events = [pause_events; mean(port_events(iStartPause(j)+(0:1),1)),PAUSE_ON_CODE];
        end
    end
    pause_events = [sort(pause_events(:,1),'ascend'),pause_events(:,2)];
    sclose(dat);
    
    % Find events in each session
    for j=1:size(pause_events,1)
        tStart = pause_events(j,1);
        if j<size(pause_events,1)
            tEnd = pause_events(j+1,1);
        else
            tEnd = inf;
        end
        iThisSession = (port_events(:,1) >= tStart & port_events(:,1) < tEnd);
        session_events{i}{j} = port_events(iThisSession,:);
        eye_events{i}{j} = [y_cell{i}(j).events.port.time, y_cell{i}(j).events.port.number]; 
    end    
end