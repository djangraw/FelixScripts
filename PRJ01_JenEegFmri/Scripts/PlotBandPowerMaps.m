function [chanPower,chanPower_norm, power_common] = PlotBandPowerMaps(resultsFilename,chanlocs)

% [chanPower,chanPower_norm] = PlotBandPowerMaps(resultsFilename,chanlocs)
%
% INPUTS:
% -resultsFilename is a file saved with FindFigilance_script.
% -chanlocs is an nChan-element struct array of channel locations from eeglab, 
% where nChan is the number of channels.
%
% OUTPUTS:
% -chanPower is an nChan x nTasks x nBands cell array in which 
% chanPower(:,i,j) is the raw power values for task i and band j.
% -chanPower_norm is the same thing, but despiked, aligned, and normalized.
%
% Created 5/12/15 by DJ.
% Updated 5/15/15 by DJ - comments.

% resultsFilename = 'VigilanceResults_2015-01-14_1859.mat';
res = load(resultsFilename);

%% Plot raw power
fprintf('Getting power...\n');
% Set up
nBands = numel(res.bandNames)-1; % don't include wide-band (last band)
nTasks = numel(res.tasks);
nSubjects = numel(res.subjects);
lWindow = 219; % number of TRs in task
nChan = numel(chanlocs);
chanPower = nan(nChan,nTasks,nBands);
clims = [0.2 0.7];
% Get power in each band/task/channel
figure;
for iBand = 1:nBands
    for iTask = 1:nTasks
        % get for each subject
        allPower = nan(nChan,lWindow,nSubjects);
        for iSubj = 1:nSubjects
            if ~isempty(res.power{iSubj,iTask,iBand})
                allPower(:,:,iSubj) = (res.power{iSubj,iTask,iBand}(:,1:lWindow))./(res.power{iSubj,iTask,end}(:,1:lWindow));
            end
        end        
        % get mean across subjects
        chanPower(:,iTask,iBand) = nanmean(nanmean(allPower,2),3);
        % plot
        iPlot = (iTask-1)*nBands + iBand;
        subplot(nTasks,nBands,iPlot);
        topoplot(chanPower(:,iTask,iBand),chanlocs);
        set(gca,'clim',clims);
        colorbar;
        title(sprintf('Band %s, task %s',res.bandNames{iBand},res.tasks{iTask}));
    end
end
    
MakeFigureTitle(sprintf('Mean across %d subjects (raw)',nSubjects));

%% Process it a bit: DESPIKE
fprintf('Despiking data...\n');
power_despiked = res.power;
for iSubj = 1:nSubjects
    for iTask = 1:nTasks
        if isempty(res.filenames{iSubj,iTask}), fprintf('Skipping subj %d task %d...\n',iSubj,iTask); continue; end; % skip missing files
        tThis = res.tTR{iSubj,iTask}; % time vector
        for iBand = 1:nBands+1
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
            end
        end
    end
end

%% Standardize timing 
fprintf('Standardizing timing...\n');
% declare params
denominatorBand = 'wide';
iDenomBand = find(strcmp(res.bandNames,denominatorBand)); % index of denominator band
iNumBands = [1:iDenomBand-1, iDenomBand+1:(nBands+1)]; % index of all other bands
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
power_common = repmat({nan(nChan,length(t_common),nTasks,nSubjects)},1,nBands);

% standardize timing
for iNB = 1:nBands
    iBand = iNumBands(iNB);
    for iTask = 1:nTasks
        % get band ratios, interpolate to common space
        for iSubj = 1:nSubjects    
            if isempty(tTR{iSubj,iTask}), continue; end;
            % get ratio of numerator band to denominator band
            ratio = power_despiked{iSubj,iTask,iBand}./power_despiked{iSubj,iTask,iDenomBand};    
            % move ratio into common timing
            for iChan=1:nChan
                power_common{iBand}(iChan,:,iTask,iSubj) = interp1(tTR{iSubj,iTask},ratio(iChan,:),t_common,'nearest','extrap');
            end
        end  
    end
end

%% NOW PLOT

chanPowerCommon = nan(nChan,nTasks,nBands);
clims = [0.2 0.7];
% clims = [0 1];
figure;

for iBand = 1:nBands
    for iTask = 1:nTasks
        % pull out, average, and plot
        allPower = squeeze(power_common{iBand}(:,:,iTask,:));
        chanPowerCommon(:,iTask,iBand) = nanmean(nanmean(allPower,2),3);
        % plot
        iPlot = (iTask-1)*nBands + iBand;
        subplot(nTasks,nBands,iPlot);
        topoplot(chanPowerCommon(:,iTask,iBand),chanlocs);
        colorbar
        set(gca,'clim',clims);
        title(sprintf('%s band, %s task',res.bandNames{iBand},res.tasks{iTask}));
    end
end

MakeFigureTitle(sprintf('Mean across %d subjects (despiked/aligned)',nSubjects));

%% Normalize and plot
% set up
fprintf('Normalizing...\n');
clims = [-3 3];
chanPower_norm = nan(nChan,nTasks,nBands);
% plot
figure
for iBand = 1:nBands
    for iTask = 1:nTasks
        % normalize
        chanPower_norm(:,iTask,iBand) = (chanPowerCommon(:,iTask,iBand)-mean(chanPowerCommon(:,iTask,iBand)))/std(chanPowerCommon(:,iTask,iBand));
        % plot
        iPlot = (iTask-1)*nBands + iBand;
        subplot(nTasks,nBands,iPlot);
        topoplot(chanPower_norm(:,iTask,iBand),chanlocs);
        colorbar
        set(gca,'clim',clims);
        title(sprintf('%s band, %s task',res.bandNames{iBand},res.tasks{iTask}));
    end
end

MakeFigureTitle(sprintf('Mean across %d subjects (normalized)',nSubjects));

fprintf('Done!\n')
  

