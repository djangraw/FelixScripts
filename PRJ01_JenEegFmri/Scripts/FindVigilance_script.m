% FindVigilance_script.m

% subjects = {'05Aug13' '05May14' '07Apr14' '11Aug14' '12Aug13' '16Jul13' '16Sep13' '19Aug14' '21Apr14' '22Aug14' '24Mar14' '24May13' '28Apr14' '31Mar14'};
subjects = {'05May14' '07Apr14' '11Aug14' '19Aug14' '21Apr14' '22Aug14' '28Apr14' '31Mar14'}; % exclude 2013 subjects, 24Mar14
tasks = {'20pc','ramp','ramp2','rest'};

N = numel(subjects);
M = numel(tasks);
filenames = cell(N,M); % what's the name of the most preprocessed file?
proclevel = zeros(N,M); % how much preprocessing was done?
for i=1:N
    for j=1:M
        fn = sprintf('%s_%s_in_eeg_gac_r_cbc.mat',subjects{i},tasks{j});
        if exist(fn,'file')
            filenames{i,j} = fn;
            proclevel(i,j) = 2;
        else
            fn2 = sprintf('%s_%s_in_eeg_gac_r_clip.mat',subjects{i},tasks{j});
            if exist(fn2,'file')
                filenames{i,j} = fn2;
                proclevel(i,j) = 1;
            else
                fprintf('SBJ %s, Task %s: not found!\n',subjects{i},tasks{j})
            end
        end
    end
end

%% Get channel impedances
[chans,sbj,values] = deal(cell(1,M));
for j=1%:M
    fname = sprintf('%s_EEG-elecR.txt',tasks{j});
    wholefile = readtable(fname,'ReadRowNames',true,'Delimiter',' ');
    chans{j} = wholefile.Properties.VariableNames;
    sbj{j} = wholefile.Properties.RowNames;
    values{j} = wholefile{:,:};
end
chanlabels = chans{1};
impedances = values{1};
% load chanlocs
chanlocs = readlocs('mrcap32-besa.elp');



%% Calculate band powers for each subject/task
% declare params
bandNames = {'ssvep','alpha','theta','wide'};
P = numel(bandNames);
bandLimits = {[7.5 8.5], [9 12], [4 7], [1 12]};
bandChans = {{'O1','O2','Oz'}, {'O1','O2','Oz','P3','P4','POz'}, ...
            {'F3','F4','Fz','C3','C4','Cz'}, {chanlocs.labels}};
iBandChans = cell(1,P);
for i=1:P
    iBandChans{i} = find(ismember({chanlocs.labels},bandChans{i}));
end
impLimits = [0 30]; % reject channels with impedance outside these limits

% set up
[power, bpf, avgPower] = deal(cell(N,M,P));
tTR = cell(N,M);

for iSubj = 1:N
    fprintf('subject %d/%d...\n',iSubj,N);
    okchans = find(impedances(iSubj,:)>=impLimits(1) & impedances(iSubj,:)<=impLimits(2));

    
    for iTask = 1:M
        fprintf('task %d/%d...\n',iTask,M);
        if isempty(filenames{iSubj,iTask}), disp('Skipping!'); continue; end; % skip missing files

        % load
        foo = load(filenames{iSubj,iTask});
        fnames = fieldnames(foo);
        EEG = foo.(fnames{1});
        clear foo;
        for iBand = 1:P
            fprintf('band %d/%d...\n',iBand,P);
            iChans_subj = intersect(iBandChans{iBand},okchans);

            % filter
            [power{iSubj,iTask,iBand}, tTR{iSubj,iTask}, bpf{iSubj,iTask,iBand}] = GetBandPower(EEG,bandLimits{iBand});

            % get means 
            avgPower{iSubj,iTask,iBand} = mean(power{iSubj,iTask,iBand}(iChans_subj,:),1);
            
        end
    end
end
disp('Done!')

%% Despike (lineraly interpolate points 3 std above mean)

avgPower_despiked = avgPower;
for iSubj = 1:N
    for iTask = 1:M
        if isempty(filenames{iSubj,iTask}), disp('Skipping!'); continue; end; % skip missing files
        tThis = tTR{iSubj,iTask};
        for iBand = 1:P            
            pwrThis = avgPower{iSubj,iTask,iBand};
            meanPwr = mean(pwrThis);
            stdPwr = std(pwrThis);
            isBadEgg = (pwrThis > meanPwr + 3*stdPwr);
            fprintf('Subj%d, Task%d, Band%d: %d/%d samples are spikes\n',iSubj,iTask,iBand,sum(isBadEgg),length(isBadEgg));
            avgPower_despiked{iSubj,iTask,iBand}(isBadEgg) = interp1(tThis(~isBadEgg),pwrThis(~isBadEgg),tThis(isBadEgg),'linear','extrap');
        end
    end
end

%% Standardize timing and convolve with HRF

% declare params
denominatorBand = 'wide';
iDenomBand = find(strcmp(bandNames,denominatorBand));
iNumBands = [1:iDenomBand-1, iDenomBand+1:P];
dt = 2; % define temporal resolution for both HRF and data
% Create the HRF (equation borrowed from AFNI docs)
q = 4; % exponent, duration
t=-20:dt:20;
HRF = (t).^q .* exp(-t) / (q^q*exp(-q));
HRF(t<0) = 0;
HRF = HRF/sum(HRF); % normalize

% get times
[tStart,tEnd] = deal(nan(size(tTR)));
for i=1:numel(tTR);
    if ~isempty(tTR{i})
        tStart(i) = tTR{i}(1);
        tEnd(i) = tTR{i}(end);
    end
end
t_common = ceil(max(tStart(:))) : dt : min(tEnd(:)); % find t common to all subjects/tasks, so that no extrapolation will be required
% set up
avgPower_common = repmat({nan(length(t_common),M,N)},1,P);
avgPower_hrf = avgPower_common;

% standardize timing, convolve with HRF
for iNB = 1:P-1
    iBand = iNumBands(iNB);
    for iTask = 1:M
        % get band ratios, interpolate to common space
        for iSubj = 1:N    
            if isempty(tTR{iSubj,iTask}), plot(0,0); continue; end;
%             ratio = avgPower{iSubj,iTask,iBand}./avgPower{iSubj,iTask,iDenomBand};    
            ratio = avgPower_despiked{iSubj,iTask,iBand}./avgPower_despiked{iSubj,iTask,iDenomBand};    
            avgPower_common{iBand}(:,iTask,iSubj) = interp1(tTR{iSubj,iTask},ratio,t_common,'nearest','extrap');
            avgPower_hrf{iBand}(:,iTask,iSubj) = conv(avgPower_common{iBand}(:,iTask,iSubj),HRF,'same');
        end  
    end
end



%% plot across subjects

figure(7); clf;
% run loop
for iNB = 1:P-1
    iBand = iNumBands(iNB);
    for iTask = 1:M
        % get alpha band ratios, interpolate to common space
        subplot(M,P-1,(iTask-1)*(P-1)+iNB); hold on;
        % plot HRF-smoothed data
        plot(t_common,squeeze(avgPower_hrf{iBand}(:,iTask,:))); % individual subjects
        plot(t_common,nanmean(avgPower_hrf{iBand}(:,iTask,:),3),'k','linewidth',2); % mean across subjects
        % Plot unsmoothed data
%         plot(t_common,squeeze(avgPower_common{iBand}(:,iTask,:))); % individual subjects
%         plot(t_common,nanmean(bandpwr_common{iBand}(:,iTask,:),3),'k','linewidth',2);
        xlabel('time (s)');
        ylabel(tasks{iTask});
        title(sprintf('%s band (%.1f-%.1f Hz)',bandNames{iBand},bandLimits{iBand}(1),bandLimits{iBand}(2)));
        xlim([t_common(1),t_common(end)])
        ylim([0 1])

    end    
end
% subplot(M,2,3);
legend([subjects {'mean'}]);

%% plot across tasks

figure(8); clf;
% run loop
for iNB = 1:P-1
    iBand = iNumBands(iNB);
    for iSubj = 1:N
        % get alpha band ratios, interpolate to common space
        subplot(N+1,P-1,(iSubj-1)*(P-1)+iNB); hold on;
%         plot(t_common,squeeze(avgPower_common{iBand}(:,:,iSubj))); % individual subjects
        plot(t_common,squeeze(avgPower_hrf{iBand}(:,:,iSubj))); % individual subjects
        xlabel('time (s)');
        ylabel(subjects{iSubj});
        title(sprintf('%s band (%.1f-%.1f Hz)',bandNames{iBand},bandLimits{iBand}(1),bandLimits{iBand}(2)));
        xlim([t_common(1),t_common(end)])
%         ylim([0 1])
    end    
    subplot(N+1,P-1,N*(P-1)+iNB); hold on;
%         plot(t_common,nanmean(avgPower_common{iBand},3)); % individual subjects
        plot(t_common,nanmean(avgPower_hrf{iBand},3)); % individual subjects
        xlabel('time (s)');
        ylabel('SUBJECT MEAN');
        title(sprintf('%s band (%.1f-%.1f Hz)',bandNames{iBand},bandLimits{iBand}(1),bandLimits{iBand}(2)));
        xlim([t_common(1),t_common(end)])
%         ylim([0 1])
end
% subplot(M,2,3);
legend(tasks);

%% Realign for group average
peakEvents = {'S170'};
rampEvents = cell(1,10);
for i=1:length(rampEvents)
    rampEvents{i} = sprintf('S %d',51-i);
end
tRamp = nan(N,M);
for iSubj = 1:N
    for iTask = 1:M-1        
        fprintf('subj %d/%d, task %d/%d...\n',iSubj,N,iTask,M);
        if isempty(filenames{iSubj,iTask}), disp('Skipping!'); continue; end; % skip missing files

        % load
        foo = load(filenames{iSubj,iTask});
        fnames = fieldnames(foo);
        EEG = foo.(fnames{1});
        clear foo;        
        
        % Find times                
        iRamp = find(ismember({EEG.event.type},rampEvents),1);
%         iRamp = find(ismember({EEG.event.type},peakEvents),1,'last'); % for end of trial
        tRamp(iSubj,iTask) = EEG.event(iRamp).latency/EEG.srate;
    end
end
tRamp(:,end) = min(tRamp(:)); % no alignment


%% Standardize timing and convolve with HRF (REALIGNED TO RAMP)

% set up
avgPower_common_rampaligned = repmat({nan(length(t_common),M,N)},1,P);
avgPower_hrf_rampaligned = avgPower_common_rampaligned;

% run loop
for iNB = 1:P-1
    iBand = iNumBands(iNB);
    for iTask = 1:M
        % get band ratios, interpolate to common space
        for iSubj = 1:N    
            if isempty(tTR{iSubj,iTask}), plot(0,0); continue; end;
%             ratio = avgPower{iSubj,iTask,iBand}./avgPower{iSubj,iTask,iDenomBand};    
            ratio = avgPower_despiked{iSubj,iTask,iBand}./avgPower_despiked{iSubj,iTask,iDenomBand};    
            avgPower_common_rampaligned{iBand}(:,iTask,iSubj) = interp1(tTR{iSubj,iTask} - tRamp(iSubj,iTask) + min(tRamp(:)),ratio,t_common,'nearest','extrap');
            avgPower_hrf_rampaligned{iBand}(:,iTask,iSubj) = conv(avgPower_common_rampaligned{iBand}(:,iTask,iSubj),HRF,'same');
        end  
    end
end



%% Plot realigned group average (REALIGNED TO RAMP)

includeErrorBars = true;
figure(9); clf;
colors = get(groot,'defaultAxesColorOrder');
% run loop
for iNB = 1:P-1
    iBand = iNumBands(iNB);

    subplot(P-1,1,iNB); hold on;
%         plot(t_common,nanmean(avgPower_common_rampaligned{iBand},3)); % mean across subjects
    nInAvg = sum(~isnan(avgPower_hrf_rampaligned{iBand}(1,1,:)));
    meanPwr = nanmean(avgPower_hrf_rampaligned{iBand},3);
    stdPwr = nanstd(avgPower_hrf_rampaligned{iBand},[],3);
    plot(t_common,nanmean(avgPower_hrf_rampaligned{iBand},3),'linewidth',2); % mean across subjects
    % include errorbars
    if includeErrorBars
        for iTask = 1:M
            ErrorPatch(t_common,meanPwr(:,iTask)',stdPwr(:,iTask)'/sqrt(nInAvg),colors(iTask,:),colors(iTask,:));
            plot(t_common,nanmean(avgPower_hrf_rampaligned{iBand}(:,iTask,:),3),'linewidth',2,'color',colors(iTask,:)); % mean across subjects
        end
    end
    grid on
    xlabel('time (s)');
    ylabel(sprintf('Mean +/- stderr (N=%d subjects)',N));
    title(sprintf('%s band (%.1f-%.1f Hz)',bandNames{iBand},bandLimits{iBand}(1),bandLimits{iBand}(2)));
    xlim([t_common(1),t_common(end)])
end
% subplot(M,2,3);
legend(tasks);



%% Save results (use ConvertVigilanceResults to make variable names more intuitive)
outfile = sprintf('VigilanceResults_%s',datestr(now,'yyyy-mm-dd_HHMM'));
save(outfile, 'band*','iBandChans','impLimits','tTR','power','bpf','avgPower*','*_common','filenames','impedances', 'subjects', 'tasks', 'chanlabels', 'HRF', 'tRamp');
% save VigilanceResults_Jan09_v3 *limits iChans* *Imp ssvep alpha wide tTR *bpf avg* *_common filenames impedances subjects tasks chanlabels


