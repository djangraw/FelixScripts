% UseIcFcToPredictCondition.m
%
% Created 7/25/16 by DJ.
% Updated 7/26/16 by DJ - switched to new Behavior struct.
% Updated 7/27/16 by DJ - detect component automatically, classify, repeat
% for multiple subjects.

subjects = [9:11,13:19,22,24:25,28,30:34,36];
fcWinLength = 10;
doPlot = false;%true;%

[AzWn,AzIg] = deal(nan(1,numel(subjects)));
pPerm = cell(1,numel(subjects));
pDiff = nan(numel(subjects),6);
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

    if doPlot
        clf(146);
        clf(147);
    end
    [eventTypes, compStrength,nPerType] = deal(cell(1,nRuns));
    iAudComp = nan(1,nRuns);
    for i=1:nRuns

%         % Get best match
%         [betas,betaInfo] = BrikLoad(sprintf('TED.SBJ%02d.r%02d/betas_OC.nii',subject,i));
%         [iAudComp(i), match] = FindBestComponentMatch(betas,speechmap);
%         fprintf('Run %d: component %d was chosen.\n',i,iAudComp(i)); 
        % find accepted & ignored components
%         okComps = csvread(sprintf('TED.SBJ%02d.r%02d/accepted.txt',subject,i)) + 1;
        okComps = ReadAcceptedComps(subject,i);
            
        % Get timecourses 
        ts = Read_1D(sprintf('TED.SBJ%02d.r%02d/meica_mix.1D',subject,i));
        t = (1:size(ts,1))*TR + nFirstRemoved*TR - hrfOffset;
        
        % Crop to accepted components and get FC
        ts_ok = ts(:,okComps);
        FC_ok = VectorizeFc(GetFcMatrices(ts_ok','sw',fcWinLength));
        
        % Get regressors
        nTRsPerSession = size(ts,1);
        [stimTimecourse,stimTypes] = GetStimTimecourses(beh.data(i),TR,nFirstRemoved,nTRsPerSession);
        
        % Offset and trim
        iLast = size(FC_ok,2) - hrfOffset;
        stimTimecourse = [zeros(size(stimTimecourse,1),hrfOffset),stimTimecourse(:,1:iLast)];
        % Do any correlate with the stim timecourses?
        nFc = size(FC_ok,1);
        nStim = size(stimTimecourse,1);
        [r,p] = corr(FC_ok',stimTimecourse');
        
        % randomize for comparison
        nRand = 100;
        [r_rand, p_rand] = deal(nan(nFc,nStim,nRand));
        fprintf('Doing %d randomizations...\n',nRand);
        tic
        pPerm{iSubj}{i} = nan(nFc,nStim);
        parfor j=1:nRand
            ts_ok_rand = ts_ok(randperm(size(ts_ok,1)),:);
            FC_ok_rand = VectorizeFc(GetFcMatrices(ts_ok_rand','sw',fcWinLength));
            [r_rand(:,:,j),p_rand(:,:,j)] = corr(FC_ok_rand',stimTimecourse');
        end
        tExec = toc;
        fprintf('Done! Took %.1f seconds.\n',tExec);
        % Display results
        for j=1:nFc
            for k=1:nStim
                pPerm{iSubj}{i}(j,k) = mean(p_rand(j,k,:)<p(j,k),3);
            end
        end
        pDiff(iSubj,i) = ranksum(r(:),r_rand(:));
        fprintf('SBJ%02d, run %d: pDiff = %.3g\n',subject,i,pDiff(iSubj,i));
    end

end

%% Plot results
figure(623); clf;
hist(pDiff(:),.025:.05:1);
xlabel('p value, r(true) vs. r(rand)');
ylabel('# runs');

%% Look for consistent effects

% for iSubj=1:numel(subjects)
%     foo = sum(pPerm{iSubj}<0.05,3);
%     iSigAll = find(foo(:)==1);
%     fprintf('Subj %d: %d pairs significant in all runs\n',iSubj,numel(iSigAll));
% end

%% Visualize effects

iSubj = 1;
iRun = 1;
subject = subjects(iSubj);
% Load
cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject));
afniProcDirs = dir('AfniProc*');
cd(afniProcDirs(1).name);
[betas,betaInfo] = BrikLoad(sprintf('TED.SBJ%02d.r%02d/betas_OC.nii',subject,iRun));
okComps = ReadAcceptedComps(subject,iRun);
betas = betas(:,:,:,okComps);
%%
iStim = 1;
stimType = stimTypes{iStim};

% Get
pPerm_square = UnvectorizeFc(pPerm{iSubj}{iRun}(:,iStim));
[iFc,jFc] = find(pPerm_square<0.01);

% iBest = 
% FCthis = 

