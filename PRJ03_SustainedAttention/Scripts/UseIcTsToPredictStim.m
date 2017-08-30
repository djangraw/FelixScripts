% UseIcTsToPredictStim.m
%
% Created 7/25/16 by DJ.
% Updated 7/26/16 by DJ - switched to new Behavior struct.
% Updated 7/27/16 by DJ - detect component automatically, classify, repeat
% for multiple subjects.

subjects = [9:11,13:19,22,24:25,28,30:34,36];
doPlot = false;%true;%
[speechmap,speechmapInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth_speechperception_pFgA_z_FDR_0.01_EpiRes+tlrc');
% [speechmap,speechmapInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth_defaultmode_pFgA_z_FDR_0.01_EpiRes+tlrc');
% [speechmap,speechmapInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth_dorsalattention_pFgA_z_FDR_0.01_EpiRes+tlrc');

[AzWn,AzIg] = deal(nan(1,numel(subjects)));

for iSubj = 1:numel(subjects)
    subject = subjects(iSubj);
    fprintf('===SUBJECT %d===\n',subject);

    % Go to directory
    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject));
    afniProcDirs = dir('AfniProc*');
    cd(afniProcDirs(1).name);

    % Load behavior
    % beh = load(sprintf('../Distraction-%d-QuickRun.mat',subject));
    beh = load(sprintf('../Distraction-SBJ%02d-Behavior.mat',subject));
    nRuns = numel(beh.data);
    TR = 2;
    nFirstRemoved = 3;
    hrfOffset = 6; % in seconds
    % hrfOffset = 15; % in seconds

    % Load timeseries
    clear hAxes

    % if subject==10
    %     iAudComp = [2 2 5 1];
    % elseif subject==13
    %     iAudComp = [2 6 3 3 3]; 
    % elseif subject==18
    %     iAudComp = [1 1 2 3 2 4]; 
    % else
    %     iAudComp = ones(1,nRuns);
    % end
    if doPlot
        clf(146);
        clf(147);
    end
    [eventTypes, compStrength,nPerType] = deal(cell(1,nRuns));
    iAudComp = nan(1,nRuns);
    
    for i=1:nRuns

        % Get best match
        [betas,betaInfo] = BrikLoad(sprintf('TED.SBJ%02d.r%02d/betas_OC.nii',subject,i));
        [iAudComp(i), match] = FindBestComponentMatch(betas,speechmap);
        fprintf('Run %d: component %d was chosen.\n',i,iAudComp(i));
        % Get timecourses 
        ts = Read_1D(sprintf('TED.SBJ%02d.r%02d/meica_mix.1D',subject,i));
        t = (1:size(ts,1))*TR + nFirstRemoved*TR - hrfOffset;
        % Get behavior
        [pageStartTimes,pageEndTimes,eventSessions,eventTypes{i}] = GetEventBoldSessionTimes(beh.data(i));
        eventCats = unique(eventTypes{i});
        eventColors = [1 0 0; 1 .75 0; 0 1 0];

        % plot
        if doPlot
            figure(146);
            subplot(3,2,i); cla; hold on;
            ylim([0 70]);
            for j=1:6
                h = plot(t,ts(:,j)+10*j);
                if j==iAudComp(i)
                    set(h,'linewidth',2);
                end
            end
            for k=1:numel(eventCats)
                isThisType = strcmp(eventTypes{i},eventCats{k});
                PlotVerticalLines(pageStartTimes(isThisType),eventColors(k,:));
            end
            xlabel(sprintf('time (with %ds offset)',hrfOffset));
            ylabel('component activity');
            title(sprintf('SBJ%02d, run %d',subject,i));
        end

        % get trial-by-trial component strength
        compStrength{i} = zeros(numel(eventTypes{i}),1);
        for j=1:numel(eventTypes{i})
            compStrength{i}(j) = mean(ts(t>=pageStartTimes(j) & t<=pageEndTimes(j),iAudComp(i)));
        end
        % get and plot histos
        if doPlot
            figure(147);
            subplot(3,2,i); cla; hold on;
            xHist = -3:.5:3;
            nPerType{i} = zeros(numel(eventCats),numel(xHist));
            for k=1:numel(eventCats)
                isThisType = strcmp(eventTypes{i},eventCats{k});
                nPerType{i}(k,:) = hist(compStrength{i}(isThisType),xHist);
                plot(xHist,nPerType{i}(k,:),'color',eventColors(k,:));
            end
            % annotate plot
            title(sprintf('SBJ%02d, run %d',subject,i));
            xlabel('Auditory Component Activity');
            ylabel('# pages');
            legend(eventCats);     
        end

    end
    % Make legend
    if doPlot
        figure(146);
        MakeLegend(eventColors,eventCats,[],[.5 .9]);
    end
    disp('Done!')

    %% Classify
    eventTypes_all = cat(1,eventTypes{:});
    compStrength_all = cat(1,compStrength{:});
    truthWn = strcmpi(eventTypes_all,'whiteNoise');
    truthIg = strcmpi(eventTypes_all,'ignoredSpeech');
    % Classify wn vs sp
    AzWn(iSubj) = rocarea(-compStrength_all,truthWn);
    AzIg(iSubj) = rocarea(-compStrength_all(truthWn==0),truthIg(truthWn==0));
    fprintf('WnVsSp: AUC = %.3f\n',AzWn(iSubj));
    fprintf('IgVsAt: AUC = %.3f\n',AzIg(iSubj));

end

%% Make AUC barplot
nSubj = numel(subjects);
subjStr = cell(1,nSubj);
for iSubj=1:nSubj
    subjStr{iSubj} = sprintf('SBJ%02d',subjects(iSubj));
end
figure(213); clf; hold on;
% bar([AzWn',AzIg' ; mean(AzWn),mean(AzIg)])
bar([AzWn'; mean(AzWn)])
set(gca,'xtick',1:(nSubj+1),'xticklabel',[subjStr, {'Mean'}])
% errorbar(nSubj+0.875,mean(AzWn),std(AzWn)/sqrt(nSubj),'k.');
% errorbar(nSubj+1.125,mean(AzIg),std(AzIg)/sqrt(nSubj),'k.');
errorbar(nSubj+1,mean(AzWn),std(AzWn)/sqrt(nSubj),'k.');
PlotHorizontalLines(0.5,'k:');
xlim([0 nSubj+2])
ylim([0 1]);
xlabel('Subject')
ylabel('AUC');
% legend('White Noise vs. Speech','Attend vs. Ignore Speech','Location','SouthWest');
title('Classification Using IC Best Matching "Speech Perception" on NeuroSynth')

%% Get cross-run histogram
nPerType_all = sum(cat(3,nPerType{:}),3);
figure(148); clf; hold on;
xHist = 0:100;
for k=1:numel(eventCats)
    plot(xHist,nPerType_all(k,:),'color',eventColors(k,:));
end
title(sprintf('SBJ%02d, %d runs',subject,nRuns));
xlabel('Auditory Component Activity');
ylabel('# pages');
legend(eventCats);     
    
%% Plot these components
figure(149); clf;
[anatBrick,anatInfo] = BrikLoad(sprintf('SBJ%02d_Anat_bc_ns_al_keep+tlrc',subject));
anatBrick = anatBrick/max(anatBrick(:));
[I,J,K] = meshgrid(1:size(anatBrick,2),1:size(anatBrick,1),1:size(anatBrick,3));
ijkToDicom = reshape(anatInfo.IJK_TO_DICOM_REAL,4,3);
Xanat = I*ijkToDicom(1,1) + J*ijkToDicom(2,1) + K*ijkToDicom(3,1) + ijkToDicom(4,1); 
Yanat = I*ijkToDicom(1,2) + J*ijkToDicom(2,2) + K*ijkToDicom(3,2) + ijkToDicom(4,2); 
Zanat = I*ijkToDicom(1,3) + J*ijkToDicom(2,3) + K*ijkToDicom(3,3) + ijkToDicom(4,3); 
for i=1:nRuns
    [betas,betaInfo] = BrikLoad(sprintf('TED.SBJ%02d.r%02d/betas_OC.nii',subject,i));
    [I,J,K] = meshgrid(1:size(betas,2),1:size(betas,1),1:size(betas,3));
    ijkToDicom = reshape(betaInfo.IJK_TO_DICOM_REAL,4,3);
    Xbeta = I*ijkToDicom(1,1) + J*ijkToDicom(2,1) + K*ijkToDicom(3,1) + ijkToDicom(4,1); 
    Ybeta = I*ijkToDicom(1,2) + J*ijkToDicom(2,2) + K*ijkToDicom(3,2) + ijkToDicom(4,2); 
    Zbeta = I*ijkToDicom(1,3) + J*ijkToDicom(2,3) + K*ijkToDicom(3,3) + ijkToDicom(4,3); 
    % Get Overlay
    betaThis = betas(:,:,:,iAudComp(i));
    betaInterp = interp3(Xbeta,Ybeta,Zbeta,betaThis,Xanat,Yanat,Zanat);
    betaInterp = betaInterp/max(betaInterp(:));
    % Get ctr
    [~,iMax] = max(betaInterp(:));
    slicecoords = nan(1,3);
    [slicecoords(1),slicecoords(2),slicecoords(3)] = ind2sub(size(betaInterp),iMax);
%     slicecoords=round(size(
    % Plot
    subplot(3,2,i); cla;
    Plot3Planes(cat(4,anatBrick+betaInterp,anatBrick,anatBrick),slicecoords);
%     Plot3Planes(betaThis{i}/max(betaThis{i}(:)));
    axis([0 3 0 1]);
    set(gca,'xtick',[],'ytick',[]);
    title(sprintf('SBJ%02d, run %d, component %d',subject,i,iAudComp(i)));
end
