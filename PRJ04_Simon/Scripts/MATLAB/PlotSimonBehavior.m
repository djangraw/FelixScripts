function PlotSimonBehavior(y)

% Created 3/13/15 by DJ.

% Aggregate info across sessions
fprintf('Extracting info...\n');
performance = y(1).performance;
fields = fieldnames(performance);
performance.iSession = ones(1,numel(y(1).performance.iResponse));
for i=2:numel(y)
    for j=1:numel(fields)
        performance.(fields{j}) = [performance.(fields{j}), y(i).performance.(fields{j})];        
    end    
    performance.iSession = [performance.iSession, repmat(i,1,numel(y(i).performance.iResponse))];
end
nBlocks = numel(performance.tTrialStart);
nTrials = zeros(1,nBlocks);
for j=1:nBlocks
    nTrials(j) = numel(performance.tTrialStart{j});
end
params = y(1).params;
    

%%
% ==== BEGIN PLOTTING ==== %
fprintf('Plotting results...\n');
% Set up plot
clf;
MakeFigureTitle(sprintf('Subject %d, %d sessions',y(1).params.subject, numel(y)));
% --- 1. Plot Time-course of session
subplot(3,2,1); hold on;
% plot block success timecourse
plot(nTrials,'r.-');
PlotVerticalLines(find(diff(performance.iSession)>0)-0.5,'b--');
grid on
xlabel('Blocks')
ylabel('length of sequence')
title('Timecourse of accuracy')
legend('length','sessions')

% --- 1.2. Plot histograms
subplot(3,2,2); hold on;
xHist = 1:max(nTrials);
foo = hist(nTrials,xHist);
bar(xHist,foo/sum(foo)*100);
PlotVerticalLines(mean(nTrials),'r--');
grid on
xlabel('length of sequence');
ylabel('frequency (%)');
title('Accuracy histogram')
legend(sprintf('n=%d',nBlocks),sprintf('mean = %.1f',mean(nTrials)))

%% --- 2.1. Plot mean/ste RTs across blocks
% Get length of sequence when error occurred and index within sequence where subject made an error.
subplot(3,3,4); cla; hold on;
maxLength = max(nTrials);
deadlines = params.tRespRoundOff * ceil((1:maxLength).*params.tRespPerItem./params.tRespRoundOff);
RTs = nan(maxLength,maxLength,nBlocks);
for j=1:nBlocks        
    for i=1:nTrials(j)
        for k=1:length(performance.RT{j}{i})
            RTs(i,k,j) = performance.RT{j}{i}(k);
        end
    end
end
% plot results
plot(nanmean(RTs,3),'.-');
steRTs = nan(size(RTs,1),size(RTs,2));
for i=1:size(RTs,1)
    for k=1:size(RTs,2)
        nEntries = sum(~isnan(RTs(i,k,:)));
        if nEntries>0
            steRTs(i,k) = nanstd(RTs(i,k,:),[],3)/sqrt(nEntries);
        end
    end
end
colors = get(gca,'colororder');
colors = repmat(colors,ceil(size(RTs,2)/size(colors,1)),1);
for i=1:size(RTs,2)
    ErrorPatch(i:size(RTs,1),nanmean(RTs(i:end,i,:),3)',steRTs(i:end,i)',colors(i,:),colors(i,:));
end

plot(1:maxLength,deadlines(1:maxLength),'k.-')
grid on
title('Reaction Times (all trials)')
xlabel('sequence length')
ylabel('RT (s)')
legend('mean +/- stderr','Location','NorthWest');

xlim([0,maxLength])
ylim([0,max(deadlines)]);


%% --- 2.2. Plot mean/ste RTs for correct vs. error trials
% Get length of sequence when error occurred and index within sequence where subject made an error.
subplot(3,3,5); cla; hold on;
maxLength = max(nTrials);
deadlines = params.tRespRoundOff * ceil((1:maxLength).*params.tRespPerItem./params.tRespRoundOff);
RTs = nan(maxLength,maxLength,nBlocks);
RTerr = nan(maxLength,maxLength,nBlocks);
for j=1:nBlocks        
    for i=1:nTrials(j)-1
        RTs(i,1:length(performance.RT{j}{i}),j) = performance.RT{j}{i};
    end
    RTerr(nTrials(j),1:length(performance.RT{j}{nTrials(j)}),j) = performance.RT{j}{nTrials(j)};
end
% plot mean RT for correct trials
plot(nanmean(RTs,3),'.-'); % correct
% cycle back to beginning of color order
numberofcolors=size(get(gca,'ColorOrder'),1);
plot(nan(numberofcolors-mod(maxLength,numberofcolors)))
% plot mean RT across error trials
plot(nanmean(RTerr,3),'.--'); % errors
% get stderr
steRTs = nan(size(RTs,1),size(RTs,2));
for i=1:size(RTs,1)
    for k=1:size(RTs,2)
        nEntries = sum(~isnan(RTs(i,k,:)));
        if nEntries>0
            steRTs(i,k) = nanstd(RTs(i,k,:),[],3)/sqrt(nEntries);
        end
    end
end
colors = get(gca,'colororder');
colors = repmat(colors,ceil(size(RTs,2)/size(colors,1)),1);
for i=1:size(RTs,2)
    ErrorPatch(i:size(RTs,1),nanmean(RTs(i:end,i,:),3)',steRTs(i:end,i)',colors(i,:),colors(i,:));
end

plot(1:maxLength,deadlines(1:maxLength),'k.-')
grid on
title('Reaction Times (correct vs. error)')
xlabel('sequence length')
ylabel('RT (s)')
MakeLegend({'b.-','b.--','k.-'},{'correct','error','deadline'},[2,1,1],[.46 .6]);
%legend('mean +/- stderr','Location','NorthWest');

xlim([0,maxLength])
ylim([0,max(deadlines)]);

%% --- 2.3. Plot mean/ste RTs relative to error trials
% Get length of sequence when error occurred and index within sequence where subject made an error.
subplot(3,3,6); cla; hold on;
RTs = nan(maxLength,maxLength,nBlocks);
for j=1:nBlocks        
    for i=1:nTrials(j)  
        nResp = length(performance.RT{j}{i});
        RTs(end-nTrials(j)+i,1:nResp,j) = performance.RT{j}{i};
    end
end
% RTs = permute(RTs,[2,1,3]);
% plot results
xRTs = (-size(RTs,1)+1):0;
plot(xRTs,nanmean(RTs,3),'.-');
steRTs = nan(size(RTs,1),size(RTs,2));
for i=1:size(RTs,1)
    for k=1:size(RTs,2)
        nEntries = sum(~isnan(RTs(i,k,:)));
        if nEntries>0
            steRTs(i,k) = nanstd(RTs(i,k,:),[],3)/sqrt(nEntries);
        end
    end
end
colors = get(gca,'colororder');
colors = repmat(colors,ceil(size(RTs,2)/size(colors,1)),1);
for i=1:size(RTs,2)
    ErrorPatch(xRTs(i:end),nanmean(RTs(i:end,i,:),3)',steRTs(i:end,i)',colors(i,:),colors(i,:));
end

% plot(1:maxLength,deadlines(1:maxLength),'k.-')
grid on
title('RTs relative to error length')
xlabel('length relative to error')
ylabel('RT (s)')
legend('mean +/- stderr','Location','NorthWest');

xlim([-maxLength+1,0])
ylim([0,max(deadlines)]);





%% --- 3. Compile when errors were made
subplot(3,3,7); hold on
errhist = zeros(maxLength);
iError = deal(zeros(1,nBlocks)); 
for j=1:nBlocks
    iError_temp = find(~performance.isCorrect{j}{end},1);
    if isempty(iError_temp)
        iError(j) = NaN;
    else
        iError(j) = iError_temp;
        errhist(iError(j),nTrials(j)) = errhist(iError(j),nTrials(j)) + 1;
    end    
end
imagesc(errhist);
colorbar;
% plot(maxLength,iError,'.'); % error at index y within sequence of length x
plot([0 maxLength],[0 maxLength],'r--'); % 1:1 line
% Annotate plot
xlabel('length of sequence')
ylabel('index of error');
title('Error Indices histogram')
axis([0 maxLength 0 maxLength]+0.5)

%% --- 4. Look for blind spots or biases
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

%% --- 5. Make RT scatter plot
subplot(3,3,9); hold on;
% Get time to completion and corresponding length of sequence (within each trial, not block)
[TTC,seqLength] = deal([]); 
for j=1:nBlocks
    for i=1:nTrials(j)
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
PlotHorizontalLines(0,'k--');
grid on
% Annotate
legend('Original Data', sprintf('Fit (y=%.2fx + %.2f)',coeffs(1),coeffs(2)),'deadlines','Location','NorthWest');
xlabel('length of sequence')
ylabel('time to completion (s)')
title('Sequence Completion Times')
xlim([0 maxLength])

% Alert user that we're done
disp('DONE!');