function [iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset, alignment)

% Get the sample number for each Distraction task page event in a multi-session fMRI dataset.
% 
% [iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset, alignment)
%
% INPUTS:
% -data is an n-element vector of structs containing data from a
% Distraction task, where each element represents a run. 
% -fcWinLength is a scalar indicating how long the functional connectivity
% window will be (in samples). This will be used to offset the FC sample 
% numbers.
% -TR is a scalar indicating the length of one fMRI sample (TR) in seconds.
% -nFirstRemoved is a scalar indicating how many samples were removed
% during preprocessing. This will be used to offset all the sample numbers.
% -nTR is a scalar indicating the number of TRs per run (before any
% were removed).
% -hrfOffset is a scalar indicating the HRF delay (in seconds) that will be
% used to shift the sample numbers.
% -alignment is a string indicating how the chosen samples should be
% aligned with the reading pages. Options are 'start' (align mag sample and
% start of FC window with start of page), 'mid' (align mag sample and
% middle of FC window with middle of page, or 'end' (align mag sample and
% end of FC window with end of page). [default: 'mid']
%
% OUTPUTS:
% -iTcEventSample is an m-element vector in which iTcEventSample(i) is the
% sample that the magnitude timecourse that corresponds to event i.
% -iFcEventSample is an m-element vector in which iFcEventSample(i) is the
% sample that the funnctional connectivity timecourse that corresponds to
% event i. 
% -eventNames is an m-element cell array of strings in which eventNames{i}
% is the event type of event i (e.g., 'whiteNoise').
%
% Created 4/5/16 by DJ.
% Updated 6/9/16 by DJ - added comments, fixed bugs.

% Declare defaults
if ~exist('alignment','var') || isempty(alignment)
    alignment='mid';
end

%% Get event times (RELATIVE TO FIRST TR AFTER REMOVAL)
[pageStartTimes,pageEndTimes,eventRuns,eventNames] = GetEventBoldSessionTimes(data); % get page start and end times
eventTimes = nan(size(pageStartTimes));
for i=1:numel(data)
    % Get offsets
    runOffset = (i-1)*nTR*TR; % time (s) of first TR (before removal) in fMRI data
    % Adjust times    
    switch alignment
        case 'start'
            eventTimes(eventRuns==i) = pageStartTimes(eventRuns==i) + runOffset; % time of page start relative to first TR (before removal)
        case 'mid'
            eventTimes(eventRuns==i) = mean([pageStartTimes(eventRuns==i), pageEndTimes(eventRuns==i)],2) + runOffset; 
        case 'end'
            eventTimes(eventRuns==i) = pageEndTimes(eventRuns==i) + runOffset; 
    end
end

%% Get time of event
% get timing of each TR
nRuns = numel(data);
% tTC = ((nFirstRemoved+1):nTR*nRuns)*TR; % time of TR (s)
[tTC,tTC_run] = deal(nan(1,(nTR-nFirstRemoved)*nRuns));
for i=1:nRuns
    iOffset = (i-1)*(nTR-nFirstRemoved);
    tTC(iOffset+(1:nTR-nFirstRemoved)) = ((nFirstRemoved:nTR-1) + (i-1)*nTR)*TR;
    tTC_run(iOffset+(1:nTR-nFirstRemoved))=i;
end
% adjust for HRF offset (this is the time when the event window is centered if the HRF peaks now)
tTC_adj = tTC - hrfOffset; 

% Get time of each FC window's START
[tFC_winStart,tFC_run] = deal(nan(1,(nTR-nFirstRemoved)*nRuns));
for i=1:numel(data)
    iOffset = (i-1)*(nTR-nFirstRemoved);
    tFC_run(iOffset+(1:nTR-nFirstRemoved-fcWinLength+1))=i;
    tFC_winStart(iOffset+(1:nTR-nFirstRemoved)) = ((nFirstRemoved:nTR-1) + (i-1)*nTR)*TR;
end
fcWinDur = fcWinLength*TR; % length of FC window (seconds)
switch alignment
    case 'start'
        tFC_adj = tFC_winStart - hrfOffset;
    case 'mid'
        tFC_adj = tFC_winStart + fcWinDur/2 - hrfOffset;
    case 'end'
        tFC_adj = tFC_winStart + fcWinDur - hrfOffset; 
end
    
%% Get FC and tc event sample numbers
% Set up
iFcEventSample = nan(1,numel(eventTimes));
iTcEventSample = nan(1,numel(eventTimes));
for i=1:numel(eventTimes)
    if eventTimes(i)<tFC_winStart(end)
        % find TR sample times that best match the event sample times.
        iTC = find(tTC_adj <= eventTimes(i) & tTC_run==eventRuns(i),1,'last');
        if ~isempty(iTC) && eventTimes(i)-tTC_adj(iTC)<TR
            iTcEventSample(i) = iTC;
        end
        % Get indices of FC window that ends at the end of a page            
        iFC = find(tFC_adj <= eventTimes(i) & tFC_run==eventRuns(i),1,'last');
        if ~isempty(iFC) && eventTimes(i)-tFC_adj(iFC)<TR
            iFcEventSample(i) = iFC;                        
        end
    end
end