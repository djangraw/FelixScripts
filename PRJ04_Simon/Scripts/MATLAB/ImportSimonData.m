function data = ImportSimonData(filename)

% ImportAllSimonData(filename)
%
% INPUTS:
% -filename is a string indicating the name of the data file you want to
% import. Most Simon files are in the format
% Simon-<subject>-<session>-<date>.log.
%
% OUTPUTS:
% -data is a struct with subfields params, events, performance, and state.
%
% Created 3/11/15 by DJ - adapted from ImportBopItData.m.

% Handle defaults
if nargin==0
    filename = 'Simon-1-1-DEMO.log'; % demo
end

% Read in parameters & events
fprintf('Importing parameters & events from %s...\n',filename);
params = PsychoPy_ParseParams(filename,'START PARAMETERS','END PARAMETERS');
events = PsychoPy_ParseEvents(filename,{'block','soundstart','key','display','sequence'},'START EXPERIMENT');

% put response keys in a cell array of strings
if iscell(params.respKeys)
    respKeys_cell = params.respKeys;
else
    respKeys_cell = mat2cell(params.respKeys',ones(1,length(params.respKeys)));
end

fprintf('Extracting performance metrics...\n');
% set up performance metrics
nBlocks = numel(events.block.time);
tBlocks = events.block.time;
[nTrials,tTrialStart,tTrialEnd,tBeeps,performance.iResponse,performance.iCorrect,performance.isCorrect,performance.RT] = deal(cell(1,nBlocks));
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
    [performance.iResponse{j}, performance.iCorrect{j}, performance.isCorrect{j}, ...
        performance.RT{j}] = deal(cell(nTrials{j},1));
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
        % use trailing digit of names to find correct response index
        for k=1:numel(iBeeps)
            performance.iCorrect{j}{i}(k) = str2double(events.soundstart.name{iBeeps(k)}(end));
        end
        % find times when beeps occurred (for plotting)
        tBeeps{j}{i} = events.soundstart.time(iBeeps);
        
        % find indeces of keypresses from this trial
        iKeys = find(events.key.time > tTrialStart{j}(i) ...
                & events.key.time <= tTrialEnd{j}(i) & ismember(events.key.char, respKeys_cell));
        % find response index and time
        performance.iResponse{j}{i} = zeros(1,i);
        performance.RT{j}{i} = nan(1,i);
        for k=1:length(iKeys)
            if k>i
                performance.extraKeys{j}{i}(k-i) = find(strcmp(respKeys_cell,events.key.char{iKeys(k)}));
                performance.extraRT{j}{i}(k-i) = events.key.time(iKeys(k)) - tTrialStart{j}(i);
            else
                performance.iResponse{j}{i}(k) = find(strcmp(respKeys_cell,events.key.char{iKeys(k)}));
                performance.RT{j}{i}(k) = events.key.time(iKeys(k)) - tTrialStart{j}(i);
            end
        end
        % assess whether each response is correct
        performance.isCorrect{j}{i} = performance.iResponse{j}{i}==performance.iCorrect{j}{i};

    end
end
performance.tTrialStart = tTrialStart;
performance.tTrialEnd = tTrialEnd;

% get wandering catch presses
state.tWanders = events.key.time(strcmp(params.wanderKey,events.key.char));

% prepare output
data.params = params;
data.events = events;
data.performance = performance;
data.state = state;


% ==== BEGIN PLOTTING ==== %
fprintf('Plotting results...\n');
%% Set up plot
clf;
MakeFigureTitle(filename);
% --- 1. Plot Time-course of session
subplot(3,1,1); hold on;
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

% --- 2. Plot RTs for each block
% Get middle row plot handles, length of sequence when error occurred, 
% and index within sequence where subject made an error.
[hMid, maxLength, iError] = deal(zeros(1,nBlocks)); 
deadlines = params.tRespRoundOff * ceil((1:max([nTrials{:}])).*params.tRespPerItem./params.tRespRoundOff);
for j=1:nBlocks    
    hMid(j) = subplot(3,nBlocks,nBlocks+j); hold on;
    maxLength(j) = max(cellfun(@length,performance.RT{j}));
    RTs = nan(nTrials{j},maxLength(j));
    for i=1:nTrials{j}
        for k=1:length(performance.RT{j}{i})
            RTs(i,k) = performance.RT{j}{i}(k);
        end
    end
    % plot results
    plot(RTs,'.-');
    iError_temp = find(~performance.isCorrect{j}{i},1);
    if isempty(iError_temp)
        iError(j) = NaN;
    else
        iError(j) = iError_temp;
        plot(nTrials{j},performance.RT{j}{i}(iError(j)),'ko');
    end
    plot(1:nTrials{j},deadlines(1:nTrials{j}),'k.-')
    title(sprintf('Block %d',j));
    xlabel('sequence length')
    ylabel('RT (s)')
end
% set & standardize plot limits
linkaxes(hMid);
xlim([0,max(maxLength)])
ylim([0,max(deadlines)]);
        
% --- 3. Compile when errors were made
subplot(3,3,7); hold on
plot(maxLength,iError,'.'); % error at index y within sequence of length x
plot([0 max(maxLength)],[0 max(maxLength)],'k:'); % 1:1 line
% Annotate plot
xlabel('length of sequence')
ylabel('index of error');
title('Error Indices')

% --- 4. Look for blind spots or biases
subplot(3,3,8);
% Create 2D histo between correct and actual response buttons
[iErrorResp,iTrueResp] = deal(zeros(1,nBlocks));
respMatrix = zeros(5); % 4 responses + 1 'too slow'
for j=1:nBlocks
    if ~isnan(iError(j))
        iErrorResp(j) = performance.iResponse{j}{end}(iError(j));
        iTrueResp(j) = performance.iCorrect{j}{end}(iError(j));
    end
    if iErrorResp(j)==0
        iErrorResp(j) = 5;
    end    
    if iTrueResp(j)==0
        iTrueResp(j) = 5;
    end
    % increment the combination of correct and actual responses
    respMatrix(iErrorResp(j),iTrueResp(j)) = respMatrix(iErrorResp(j),iTrueResp(j)) + 1;
end
% Plot results and annotate
imagesc(respMatrix);
ytickstr = cell(1,4);
xtickstr = cell(1,4);
stimPos = {'top','right','bottom','left'};
for iResp=1:4
    ytickstr{iResp} = sprintf('%s (%s %s%s)',stimPos{iResp},params.stimColors{iResp},params.beepNotes{iResp},params.beepOctaves{iResp});
    xtickstr{iResp} = stimPos{iResp};
end
set(gca,'ytick',1:5,'yticklabel',[ytickstr,{'too slow'}],'xtick',1:5,'xticklabel',[xtickstr,{'unknown'}]);
xlabel('Correct response')
ylabel('Actual response')
title('Error Biases')
colorbar

% --- 5. Make RT scatter plot
subplot(3,3,9); hold on;
% Get time to completion and corresponding length of sequence (within each trial, not block)
[TTC,seqLength] = deal([]); 
for j=1:nBlocks
    for i=1:nTrials{j}
        TTC_temp = performance.RT{j}{i}(end);
        if ~isnan(TTC_temp)
            TTC = [TTC, TTC_temp];
            seqLength = [seqLength, i];
        end
    end
end
% boxplot(TTC,seqLength); % for box plot
plot(seqLength,TTC,'.'); % for scatter plot
% Make trendline
% fit data
coeffs = polyfit(seqLength, TTC, 1);
% define x range of line
xFitting = 0:max(seqLength); % Or wherever...
yFitted = polyval(coeffs, xFitting);
% plot fitted line 
plot(xFitting, yFitted, 'r-');
% plot deadlines
plot(1:numel(deadlines),deadlines,'k.-')
% Annotate
legend('Original Data', sprintf('Fit (y=%.2fx + %.2f)',coeffs(1),coeffs(2)),'deadlines','Location','NorthWest');
xlabel('length of sequence')
ylabel('time to completion (s)')
title('Sequence Completion Times')

% Alert user that we're done
disp('DONE!');