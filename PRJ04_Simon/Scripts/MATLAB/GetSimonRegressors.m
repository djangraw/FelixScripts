function [tReg,regressors,regressornames] = GetSimonRegressors(events,performance)

% Created 4/22/15 by DJ.

%% Get performance metrics
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


%% Produce regressors
disp('Getting regressors...')
tReg = 0:.1:(events.display.time(end)+15);

regressornames = {'wait','task','cogload','error'};

regressors = zeros(length(regressornames),length(tReg));
% WAIT regressor
for i=1:numel(events.block.time)
    tBlockStart = events.block.time(i);
    tSeqStart = events.soundstart.time(find(events.soundstart.time>tBlockStart,1));
    regressors(1,tReg>tBlockStart & tReg<tSeqStart) = 1;
end
% TASK regressor
regressors(2,:) = 1-regressors(1,:);
regressors(2,tReg>events.display.time(end)) = 0;
% COGLOAD regressor
tBuzz = events.soundstart.time(strcmp('buzz',events.soundstart.name));
for j=1:nBlocks
    for i=1:nTrials{j}-1        
        regressors(3,tReg>=tBeeps{j}{i}(end) & tReg<tBeeps{j}{i+1}(end)) = i;
    end
    tThisBuzz = tBuzz(find(tBuzz>tBeeps{j}{end}(end),1));
    if isempty(tThisBuzz)
        tThisBuzz = events.display.time(end);
    end
    regressors(3,tReg>=tBeeps{j}{end}(end) & tReg<tThisBuzz) = nTrials{j};
end
        

% ERROR regressor
tBuzz = events.soundstart.time(strcmp('buzz',events.soundstart.name));
iReg_tBuzz = interp1(tReg,1:length(tReg),tBuzz,'nearest');
regressors(4,iReg_tBuzz) = 1;    
    
disp('Done!')
    