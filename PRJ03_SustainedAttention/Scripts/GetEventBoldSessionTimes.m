function [pageStartTimes,pageEndTimes,eventSessions,eventTypes] = GetEventBoldSessionTimes(data)
% GetEventBoldTimes: find the times when trials began (in the BOLD data's clock).
%
% [pageStartTimes,pageEndTimes,eventTypes] = GetEventBoldSessionTimes(data)%
%
% INPUTS:
% - data is an N-element vector of distraction task data structs with
% fields events.soundstart and events.display.
%
% OUTPUTS:
% - pageStartTimes is an M-element vector in which pageStartTime(i) the
% time when page #i started (relative to the start of BOLD data collection
% in its session), where M is the number of page events in all sessions.
% -pageEndTimes is an M-element vector of the corresponding end times of
% those pages.
% - eventSessions is an M-element vector of the session in which each event
% occurred. 
% - eventTypes is an M-element cell array of strings in which eventTypes{i}
% indicates which type of sound was played during the page
% ('whiteNoise, 'ignoredSpeech', or 'attendedSpeech'). 
%
% Created 3/11-14/16 by DJ.

%% Get event times (RELATIVE TO FIRST TR WITH NO REMOVAL)
[pageStartTimes,pageEndTimes,eventTypes,eventSessions] = deal(cell(1,numel(data)));
for i=1:numel(data)
    % Get offsets
    startTime = data(i).events.key.time(1)/1000; % this key is a T... the first fMRI trigger.    
    % Get start and end times of events in this session
    iPageStartEvent = find(strncmpi(data(i).events.display.name,'Page',length('Page')));
    iPageEndEvent = iPageStartEvent+1;
    pageStartTimes{i} = (data(i).events.display.time(iPageStartEvent)/1000 - startTime); % time of event relative to first kept TR    
    pageEndTimes{i} = (data(i).events.display.time(iPageEndEvent)/1000 - startTime); % time of event relative to first kept TR    
    % Get names of events in this session
    isPageSound = ismember(data(i).events.soundstart.name,{'whiteNoiseSound','ignoreSound','attendSound','pageSound'});    
    eventTypes{i} = data(i).events.soundstart.name(isPageSound);
    % Convert names to standard values
    if data(i).params.subject<9 % for backward compatibility
        if strcmp(data(i).params.promptType,'AttendReading')
            eventTypes{i}(strcmp(eventTypes{i},'pageSound')) = {'ignoredSpeech'};
        else
            eventTypes{i}(strcmp(eventTypes{i},'pageSound')) = {'attendedSpeech'};
        end
    else
        eventTypes{i}(strcmp(eventTypes{i},'ignoreSound')) = {'ignoredSpeech'};
        eventTypes{i}(strcmp(eventTypes{i},'attendSound')) = {'attendedSpeech'};        
    end
    eventTypes{i}(strcmp(eventTypes{i},'whiteNoiseSound')) = {'whiteNoise'};
    % make vector of session number for each event in this session
    eventSessions{i} = repmat(i,size(eventTypes{i}));
end
% Convert outputs into vectors
pageStartTimes = cat(1,pageStartTimes{:});
pageEndTimes = cat(1,pageEndTimes{:});
eventTypes = cat(1,eventTypes{:});
eventSessions = cat(1,eventSessions{:});