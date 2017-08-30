function PlotSimonTimecourse(events,performance)

% Created 4/16/15 by DJ.

fprintf('Extracting performance metrics...\n');
% set up performance metrics
nBlocks = numel(events.block.time);
tBlocks = events.block.time;
[nTrials,tTrialStart,tTrialEnd,tBeeps] = deal(cell(1,nBlocks));
tTrialStart_all = events.sequence.time_end; % trial starts when sequence ends
tTrialEnd_all = events.sequence.time_start; % trial ends when next sequence starts
% tEndEvents = events.soundstart.time(ismember(events.soundstart.name,{'beep1','beep2','beep3','beep4','buzz'}));
isFixEvent = strncmp('Fix',events.display.name,3);
fixTimes = events.display.time(isFixEvent);
% get performance metrics
for j=1:nBlocks
    % get time when trial (execution of sequence) begins
    if j<nBlocks
        tTrialStart_block = tTrialStart_all(tTrialStart_all>tBlocks(j) & tTrialStart_all<tBlocks(j+1));        
    else
        tTrialStart_block = tTrialStart_all(tTrialStart_all>tBlocks(j));
    end
    % set up inner loop
    nTrials{j} = numel(tTrialStart_block);
    % get performance within each trial of this block
    for i=1:nTrials{j}
        % find end time of this trial
        tTrialStart{j}(i) = fixTimes(find(fixTimes>tTrialStart_block(i),1));
        thisTEnd = tTrialEnd_all(find(tTrialEnd_all>tTrialStart{j}(i),1));    
        if isempty(thisTEnd)
            tTrialEnd{j}(i) = Inf; 
        else
            tTrialEnd{j}(i) = thisTEnd;
        end
        
        % find indices of beeps from this trial
        if i>1
            iBeeps = find(events.soundstart.time >= tTrialEnd{j}(i-1) ...
                & events.soundstart.time <= tTrialStart{j}(i));
        else
            iBeeps = find(events.soundstart.time > tBlocks(j) ...
                & events.soundstart.time <= tTrialStart{j}(i));
        end        
        % find times when beeps occurred (for plotting)
        tBeeps{j}{i} = events.soundstart.time(iBeeps);
    end
end


% --- 1. Plot Time-course of session
cla; hold on;
% plot encoding and recall timecourses
for j=1:nBlocks
    for i=1:nTrials{j}
        plot(tBeeps{j}{i},1:length(tBeeps{j}{i}),'g');
        plot(performance.RT{j}{i}+tTrialStart{j}(i), 1:length(performance.RT{j}{i}),'r')        
    end
end
% plot block (and trial?) start times
PlotVerticalLines(tBlocks,'b');
% PlotVerticalLines(cat(1,tTrialStart{:}),'c');
% annotate plot
MakeLegend({'b','g','r'},{'blocks','playback','responses'},[],[0.88,0.9]);
xlabel('time on task (s)')
ylabel('sequence length')
grid on