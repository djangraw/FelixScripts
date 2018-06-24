function [alphaStage,stageNames] = GetAlphaStaging(resultsFilename,chanlocs)

% Perform "Alpha staging" (vigilance stagin) as described in Olbrich, 2009.
%
% [alphaStage,stageNames] = GetAlphaStaging(resultsFilename,chanlocs)
%
% INPUTS:
% -resultsFilename is a file saved with FindFigilance_script.
% -chanlocs is an nChan-element struct array of channel locations from eeglab, 
% where nChan is the number of channels.
%
% OUTPUTS:
% -alphaStage is an nT x nSubjects x nTasks matrix, where nT is the number
% of time points in a task (and the other two are what you'd expect). The
% values are between 1 and 5, indicating which stage the subject was in at
% a certain time point of a certain task.
% -stageNames is a 5-element cell array of strings, and indicates the
% meaning of each potential value in alphaStage. In descending order of
% vigilance, they are A1, A2, A3, B1, and B2/B3. See
% http://www.ncbi.nlm.nih.gov/pubmed/19110062 figure 1 for details.
%
% Created 5/15/15 by DJ.

% resultsFilename = 'VigilanceResults_2015-01-14_1859.mat';
res = load(resultsFilename);
% load VigilanceChanlocs.mat

%% Process power a bit: DESPIKE AND REALIGN

nBands = numel(res.bandNames); % include wide-band
nTasks = numel(res.tasks);
nSubjects = numel(res.subjects);
nChan = numel(chanlocs);

dt = 2; % define temporal resolution for both HRF and data
tTR = res.tTR; % time vectors
% get start/end times for each band/task
[tStart,tEnd] = deal(nan(size(tTR)));
for i=1:numel(tTR);
    if ~isempty(tTR{i})
        tStart(i) = tTR{i}(1);
        tEnd(i) = tTR{i}(end);
    end
end
% set up
t_common = ceil(max(tStart(:))) : dt : min(tEnd(:)); % find t common to all subjects/tasks, so that no extrapolation will be required
nT = length(t_common);
power_despiked = res.power;
power_common = repmat({nan(nChan,nT)},nSubjects,nTasks,nBands);
fprintf('Despiking and realigning data...\n');
for iSubj = 1:nSubjects
    for iTask = 1:nTasks
        if isempty(res.filenames{iSubj,iTask}), fprintf('Skipping subj %d task %d...\n',iSubj,iTask); continue; end; % skip missing files
        tThis = res.tTR{iSubj,iTask}; % time vector
        for iBand = 1:nBands
            % get band power
            pwrThis = res.power{iSubj,iTask,iBand};
            % get mean and std
            meanPwr = mean(pwrThis,2);
            stdPwr = std(pwrThis,[],2);
            % find spikes (samples >3 std above mean)
            isBadEgg = false(size(pwrThis));
            for iChan=1:nChan
                isBadEgg(iChan,:) = (pwrThis(iChan,:) > meanPwr(iChan) + 3*stdPwr(iChan));
            end
            % interpolate spikes
            fprintf('Subj%d, Task%d, Band%d: %d/%d samples are spikes\n',iSubj,iTask,iBand,sum(isBadEgg(:)),numel(isBadEgg));
            for iChan=1:nChan
                power_despiked{iSubj,iTask,iBand}(iChan,isBadEgg(iChan,:)) = interp1(tThis(~isBadEgg(iChan,:)),pwrThis(iChan,~isBadEgg(iChan,:)),tThis(isBadEgg(iChan,:)),'linear','extrap');
                power_common{iSubj,iTask,iBand}(iChan,:) = interp1(tTR{iSubj,iTask},power_despiked{iSubj,iTask,iBand}(iChan,:),t_common,'nearest','extrap');
            end
        end
    end
end



%% DO ALPHA STAGING

fprintf('Staging data...\n')
% find relevant bands & electrodes
isAlpha = strcmp('alpha',res.bandNames);
isWide = strcmp('wide',res.bandNames);
% isSsvep = strcmp('ssvep',res.bandNames);
iOccip = find(ismember({chanlocs.labels},{'O1','O2'}));
iFront = find(ismember({chanlocs.labels},{'F3','F4'}));
% Set up
[bandRatio, spatialRatio, pwrDiff, alphaStage] = deal(nan(nT,nSubjects,nTasks));
for iTask = 1:nTasks
    for iSubj = 1:nSubjects
        % get power (in uV^2) in bands
        alphaPwr = power_common{iSubj,iTask,isAlpha}.^2; % staging looks for power in uV^2, we have 'power' in V (RMS).
        widePwr = power_common{iSubj,iTask,isWide}.^2; % staging looks for power in uV^2, we have 'power' in V (RMS). 
        % (you could also exclude SSVEP band since it would normally be in alpha.)
        
        % get ratios that will determine stage
        bandRatio(:, iSubj, iTask) = max((alphaPwr([iOccip, iFront],:)./widePwr([iOccip, iFront],:)),[],1)';
        spatialRatio(:, iSubj, iTask) = (sum(alphaPwr(iOccip,:),1)./sum(alphaPwr([iOccip iFront],:),1))';
        pwrDiff(:,iSubj,iTask) = (sum(widePwr([iOccip, iFront],:),1) - sum(alphaPwr([iOccip, iFront],:),1))';
    end
end
% find stage
isAStage = bandRatio>0.5;
% A stages
alphaStage(isAStage & spatialRatio>0.55) = 1;
alphaStage(isAStage & spatialRatio<=0.55 & spatialRatio>=0.45) = 2;
alphaStage(isAStage & spatialRatio<0.45) = 3;
% B stages
alphaStage(~isAStage & pwrDiff<200) = 4;
alphaStage(~isAStage & pwrDiff>=200) = 5;

stageNames = {'A1','A2','A3','B1','B2/B3'};

%% PLOT RESULTS

fprintf('Plotting...\n');
figure(552); clf;
for iTask=1:nTasks
    subplot(nTasks,1,iTask);
    n = hist(alphaStage(:,:,iTask),1:5);
    bar(1:5, n/nT*100);
    set(gca,'xtick',1:5, 'xticklabel',stageNames);
    xlabel('stage')
    ylabel('% of TRs')
    title(sprintf('task %s',res.tasks{iTask}));    
end
legend(res.subjects);

figure(553); clf; 
for iTask = 1:nTasks
    subplot(nTasks,1,iTask);
    plot(t_common,bandRatio(:,:,iTask));
    hold on;
    plot(get(gca,'xlim'),[0.5 0.5],'k:');
    ylim([0 1]);
    xlabel('time (s)')
    ylabel('band ratio');
    title(sprintf('task %s',res.tasks{iTask}));
end
legend(res.subjects);

figure(554); clf;
for iTask = 1:nTasks
    subplot(nTasks,1,iTask);
    plot(t_common,spatialRatio(:,:,iTask));
    hold on;
    plot(get(gca,'xlim'),[0.45 0.45],'k:');
    plot(get(gca,'xlim'),[0.55 0.55],'k:');
    ylim([0 1]);
    xlabel('time (s)')
    ylabel('spatial ratio');
    title(sprintf('task %s',res.tasks{iTask}));
end
legend(res.subjects);

figure(555); clf;
for iTask = 1:nTasks
    subplot(nTasks,1,iTask);
    plot(t_common,pwrDiff(:,:,iTask));
    hold on;
    plot(get(gca,'xlim'),[200 200],'k:');
    xlabel('time (s)')
    ylabel('power difference');
    title(sprintf('task %s',res.tasks{iTask}));
end
legend(res.subjects);

fprintf('Done!\n');