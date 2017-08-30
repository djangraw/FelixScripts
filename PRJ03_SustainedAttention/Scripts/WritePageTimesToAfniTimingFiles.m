function WritePageTimesToAfniTimingFiles(data,filePrefix,TR,nFirstTRsRemoved,nTRsPerSession,doRound)

% WritePageTimesToAfniTimingFiles(data,filePrefix,TR,nFirstTRsRemoved,nTRsPerSession,doRound)
%
% INPUTS:
% - data is an N-element vector of distraction task data structs with
% fields events.soundstart and events.display.
% -filePrefix is a string indicating the start of the file you'd like to
% write to. Files called <filePrefix>_<eventType>.1D will be saved for
% event types whiteNoise, attendedSpeech, ignoredSpeech, and fixation.
% -TR is a scalar indicating the duration of each fMRI acquisition in
% seconds.
% -nFirstTRsRemoved is a scalar indicating how many TRs were removed from
% the beginning of the session during preprocessing.
% -nTRsPerSession is a scalar indicating how many TRs are found in each
% session (AFTER removing the first TRs). 
% -doRound is a boolean value indicating whether the times should be
% rounded to the nearest index or left as decimals.
%
% Created 3/14/16 by DJ.
% Updated 3/15/16 by DJ - fixed fixation duration bug
% Updated 5/19/16 by DJ - modified event types to split noise into
% ignored/attended blocks (assumes they're split into 1st and 2nd half of 
% each 30-pg run)

% Declare defaults
if ~exist('TR','var') || isempty(TR)
    TR = 2;
end
if ~exist('nFirstTRsRemoved','var') || isempty(nFirstTRsRemoved)
    nFirstTRsRemoved = 3;
end
if ~exist('nTRsPerSession','var') || isempty(nTRsPerSession)
    nTRsPerSession = 243;
end
if ~exist('doRound','var') || isempty(doRound)
    doRound = false;
end

fprintf('Getting page start & end times...\n')
[pageStartTimes,pageEndTimes,eventSessions,eventTypes] = GetEventBoldSessionTimes(data);
% Split white noise trials into those in attend/ignore blocks
isNoise = strcmp(eventTypes,'whiteNoise');
for i=1:numel(data)
    iInSession = find(eventSessions==i);
    iFirstHalf = iInSession(1:15);    
    iSecondHalf = iInSession(16:end);
    if strncmpi(data(i).params.promptType,'AttendReadingFirst',length('AttendReadingFirst'))
        eventTypes(iFirstHalf(isNoise(iFirstHalf))) = repmat({'ignoredNoise'},sum(isNoise(iFirstHalf)),1);
        eventTypes(iSecondHalf(isNoise(iSecondHalf))) = repmat({'attendedNoise'},sum(isNoise(iSecondHalf)),1);
    else
        eventTypes(iFirstHalf(isNoise(iFirstHalf))) = repmat({'attendedNoise'},sum(isNoise(iFirstHalf)),1);
        eventTypes(iSecondHalf(isNoise(iSecondHalf))) = repmat({'ignoredNoise'},sum(isNoise(iSecondHalf)),1);
    end
end
% get indices of start times
fprintf('Converting to TR indices...\n')
iPageStart_combo = ConvertBoldSessionTimeToComboTime(pageStartTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
% get indices of fixation events
iPageEnd_combo = ConvertBoldSessionTimeToComboTime(pageEndTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
% Get event types
uniqueEventTypes = unique(eventTypes);
nEventTypes = numel(uniqueEventTypes);

% Write to files
fprintf('Writing to files...\n')
filenames = cell(1,nEventTypes+1);
amplitudes = ones(size(iPageEnd_combo));
durations = iPageEnd_combo - iPageStart_combo; % in TRs
for i=1:nEventTypes
    % construct filename
    filenames{i} = sprintf('%s_%s.1D',filePrefix,uniqueEventTypes{i});
    fprintf('   --> %s...\n',filenames{i})
    % Find events of this type
    isThisType = strcmp(eventTypes,uniqueEventTypes{i});
    isOk = isThisType & ~isnan(iPageStart_combo);
    % write to file
    WriteAfniDmblockTimingFile(filenames{i},iPageStart_combo(isOk)*TR,amplitudes(isOk),durations(isOk)*TR)
end
% Write page end to file
filenames{nEventTypes+1} = sprintf('%s_fixation.1D',filePrefix);
fprintf('   --> %s...\n',filenames{nEventTypes+1})
fixDurations = [iPageStart_combo(2:end) - iPageEnd_combo(1:end-1); mean(iPageStart_combo(2:end) - iPageEnd_combo(1:end-1))];
isOk = (~isnan(iPageEnd_combo) & ~isnan(fixDurations));
WriteAfniDmblockTimingFile(filenames{nEventTypes+1},iPageEnd_combo(isOk)*TR,[],fixDurations(isOk)*TR);

% Display 3dDeconvolve lines that would use these files properly
fprintf('To use in a 3dDeconvolve call, use/modify the following sample lines...\n=====\n');
for i=1:nEventTypes
    fprintf('-stim_times_AM2 %d %s ''dmBLOCK4(1)''    \\ \n',i,filenames{i});
end
fprintf('-stim_times_AM2 %d %s ''dmBLOCK4(1)''    \n',nEventTypes+1,filenames{nEventTypes+1});
fprintf('=====\n');