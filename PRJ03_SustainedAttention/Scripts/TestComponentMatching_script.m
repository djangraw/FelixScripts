% TestComponentMatching_script.m
%
% Created 7/28/16 by DJ.

subject = 13;
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
fcWinLength = 10;
nFirstRemoved = 3;
nTR = [];
hrfOffset = 6; % in seconds
alignment = 'mid';

% Load timeseries
[betas,acceptedComps] = deal(cell(1,nRuns));
for i=1:nRuns
    fprintf('Run %d/%d...\n',i,nRuns);
    % Get betas
    [betas_tmp,betaInfo] = BrikLoad(sprintf('TED.SBJ%02d.r%02d/betas_OC.nii',subject,i));
    % Crop to accepted comps
    acceptedComps{i} = csvread(sprintf('TED.SBJ%02d.r%02d/accepted.txt',subject,i))+1;
%     betas{i} = betas_tmp(:,:,:,acceptedComps{i});
    betas{i} = betas_tmp;
end
fprintf('Done!\n');

%% Match run 1 to all other runs
[matches,iBest,iBestIin1,doubleMatches] = deal(cell(1,nRuns));
for i=1:nRuns
    fprintf('---Run %d/%d...\n',i,nRuns);
    [iBest{i},matches{i}] = MatchAllComponents(betas{1},betas{i});
    [~,iBestIin1{i}] = max(abs(matches{i}));
    
    doubleMatches{i} = [];
    for j=1:numel(iBest{i})
        if iBestIin1{i}(iBest{i}(j))==j
            doubleMatches{i} = [doubleMatches{i}; j,iBest{i}(j)];
        end
    end
end

%% Get list of comps that are double-matches in all runs
okComps1 = doubleMatches{1}(:,1);
for i=1:nRuns
    okComps1 = intersect(okComps1,doubleMatches{i}(:,1));
end

okComps = zeros(numel(okComps1),nRuns);
for i=1:nRuns
    okComps(:,i) = doubleMatches{i}(ismember(doubleMatches{i}(:,1),okComps1),2);
end

%% Get timecourses of okComps
TR = 2;
nFirstRemoved = 3;
hrfOffset = 6;
[ts,varex] = deal(cell(1,nRuns));
for i=1:nRuns
    % Get timecourses 
    ts_tmp = Read_1D(sprintf('TED.SBJ%02d.r%02d/meica_mix.1D',subject,i));
    varex_tmp = Read_1D(sprintf('TED.SBJ%02d.r%02d/varex.txt',subject,i))';
    t = (1:size(ts,1))*TR + nFirstRemoved*TR - hrfOffset;
    % Crop to matched components
%     ts{i} = ts_tmp(:,acceptedComps{i}(okComps(:,i))); 
    ts{i} = ts_tmp(:,(okComps(:,i))); 
%     varex{i} = varex_tmp(acceptedComps{i}(okComps(:,i)))/sum(varex_tmp(acceptedComps{i}(okComps(:,i))));
    varex{i} = varex_tmp(okComps(:,i))/sum(varex_tmp(okComps(:,i)));
end
% combine across sessions
ts_all = cat(1,ts{:});
varex_all = cat(1,varex{:}); % row = run, col = component
nTR = size(ts{1},1) + nFirstRemoved;

% Get behavior
[~,~,eventSessions] = GetEventBoldSessionTimes(beh.data);
[iMagEventSample,iFcEventSample,eventTypes] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset, alignment);
eventCats = unique(eventTypes);

truth1 = strcmp(eventTypes,'whiteNoise');
truth2 = strcmp(eventTypes,'ignoredSpeech');

%% Reorder according to variance explained
varex_mean = mean(varex_all,1);
[varex_mean_ordered, order] = sort(varex_mean,'descend');
ts_all_ordered = ts_all(:,order);

%% Use the Mag/FC of these components to classify
fracVars = 0.1:0.1:1;
[AzLoo_WnVsSp_mag,AzLoo_WnVsSp_fc,AzLoo_IgVsAt_mag,AzLoo_IgVsAt_fc] = deal(zeros(1,numel(fracVars)));
% Get FC
FC = GetFcMatrices(ts_all','sw',fcWinLength);
FC_2dmat = VectorizeFc(FC);

% Declare classifier params
LRparams.regularize=1;
LRparams.lambda=1e-6;
LRparams.lambdasearch=true;
LRparams.eigvalratio=1e-4;
LRparams.vinit=[];
LRparams.show=0;
LRparams.LOO=false; %true; %  
LRparams.demean=false;
LRparams.LTO=false;%true;

% Reduce dimensionality, sample, and classify
for i=1:numel(fracVars);
    fracVarToKeep = fracVars(i);
    fprintf('---fracVarToKeep = %0.2f\n',fracVarToKeep);
%     % Reduce Dimensionality with SVD
%     magFeats_reduced = ReduceDimensionality(ts_all',fracVarToKeep);
%     fcFeats_reduced = ReduceDimensionality(FC_2dmat,fracVarToKeep);
    
    % Reduce dimensionality with varex
    lastToKeep = find(cumsum(varex_mean_ordered)<=fracVarToKeep,1,'last');
    if isempty(lastToKeep)
        lastToKeep = 1;
    end
    magFeats_reduced = ts_all_ordered(:,1:lastToKeep)';
    fcFeats_reduced = VectorizeFc(GetFcMatrices(magFeats_reduced,'sw',fcWinLength));
    if size(fcFeats_reduced,1)==0
        fcFeats_reduced = randn(size(magFeats_reduced));
    end
    fprintf('Keeping %d mag feats, %d FC feats\n',size(magFeats_reduced,1),size(fcFeats_reduced,1));
        
    % Sample at trial times
    isOkTrial1 = ~isnan(iFcEventSample);
    magFeats1 = magFeats_reduced(:,iMagEventSample(isOkTrial1));
    fcFeats1 = fcFeats_reduced(:,iFcEventSample(isOkTrial1));
    fcTruth1 = truth1(isOkTrial1);
    % Sample at speech trial times
    isOkTrial2 = truth1'==0 & ~isnan(iFcEventSample);
    magFeats2 = magFeats_reduced(:,iMagEventSample(isOkTrial2));
    fcFeats2 = fcFeats_reduced(:,iFcEventSample(isOkTrial2));
    fcTruth2 = truth2(isOkTrial2);

% %     Classify
%     [Az,AzLoo_WnVsSp_mag(i),stats] = RunSingleLR(permute(magFeats1,[1 3 2]),fcTruth1,LRparams);
%     fprintf('White Noise vs. Speech with Mag feats: AzLoo = %.3f\n',AzLoo_WnVsSp_mag(i));
%     [Az,AzLoo_IgVsAt_mag(i),stats] = RunSingleLR(permute(magFeats2,[1 3 2]),fcTruth2,LRparams);
%     fprintf('Ignore Speech vs. Attend Speech with Mag feats: AzLoo = %.3f\n',AzLoo_IgVsAt_mag(i));
%     [Az,AzLoo_WnVsSp_fc(i),stats] = RunSingleLR(permute(fcFeats1,[1 3 2]),fcTruth1,LRparams);
%     fprintf('White Noise vs. Speech with FC feats: AzLoo = %.3f\n',AzLoo_WnVsSp_fc(i));
%     [Az,AzLoo_IgVsAt_fc(i),stats] = RunSingleLR(permute(fcFeats2,[1 3 2]),fcTruth2,LRparams);
%     fprintf('Ignore Speech vs. Attend Speech with FC feats: AzLoo = %.3f\n',AzLoo_IgVsAt_fc(i));

    % LORO classification
    nRuns = numel(beh.data);
    [y1_mag,y1_fc] = deal(nan(1,sum(isOkTrial1)));
    [y2_mag,y2_fc] = deal(nan(1,sum(isOkTrial2)));
    for j=1:nRuns
        isInRun1 = eventSessions(isOkTrial1)==j;
        [~,~,stats] = RunSingleSvm(permute(magFeats1(:,~isInRun1),[1 3 2]),fcTruth1(~isInRun1),LRparams);
        y1_mag(isInRun1) = stats.wts(1:end-1)*magFeats1(:,isInRun1) + stats.wts(end);
        [~,~,stats] = RunSingleSvm(permute(fcFeats1(:,~isInRun1),[1 3 2]),fcTruth1(~isInRun1),LRparams);
        y1_fc(isInRun1) = stats.wts(1:end-1)*fcFeats1(:,isInRun1) + stats.wts(end);
        isInRun2 = eventSessions(isOkTrial2)==j;
        [~,~,stats] = RunSingleSvm(permute(magFeats2(:,~isInRun2),[1 3 2]),fcTruth2(~isInRun2),LRparams);
        y2_mag(isInRun2) = stats.wts(1:end-1)*magFeats2(:,isInRun2) + stats.wts(end);
        [~,~,stats] = RunSingleSvm(permute(fcFeats2(:,~isInRun2),[1 3 2]),fcTruth2(~isInRun2),LRparams);
        y2_fc(isInRun2) = stats.wts(1:end-1)*fcFeats2(:,isInRun2) + stats.wts(end);
    end
    AzLoo_WnVsSp_mag(i) = rocarea(y1_mag,fcTruth1);
    AzLoo_WnVsSp_fc(i) = rocarea(y1_fc,fcTruth1);
    AzLoo_IgVsAt_mag(i) = rocarea(y2_mag,fcTruth2);
    AzLoo_IgVsAt_fc(i) = rocarea(y2_fc,fcTruth2);
end

%% Plot results
cla; hold on;
plot(fracVars,[AzLoo_WnVsSp_mag; AzLoo_IgVsAt_mag; AzLoo_WnVsSp_fc; AzLoo_IgVsAt_fc]','.-');
PlotHorizontalLines(0.5,'k--');
xlabel('fraction of variance kept')
ylabel('LORO AUC')
legend('white noise vs. speech (mag feats)','ignored vs. attended speech (mag feats)',...
    'white noise vs. speech (FC feats)','ignored vs. attended speech (FC feats)',...
    'Location','SouthEast')
title(sprintf('Subject SBJ%02d, Matched ICA features, LORO CV, SVM',subject));

%% Plot matched components

iComp = 6;
brainMask = any(betas{1}>0,4);
slicecoords = round(size(brainMask)/2);
% betas_this = betas{1}(:,:,:,okComps(iComp,1));
% [~, iMax] = max(betas_this(:));
% [slicecoords(1),slicecoords(2),slicecoords(3)] = ind2sub(size(brainMask),iMax);
betas_thisComp = zeros([size(brainMask), nRuns]);
legendstr = cell(1,nRuns);
subplot(4,1,4); cla; hold on;
for i=1:nRuns
    subplot(4,2,i); cla;
    iComp_thisRun = okComps(iComp,i);
    betas_thisComp(:,:,:,i) = betas{i}(:,:,:,iComp_thisRun);
    Plot3Planes(cat(4,betas{i}(:,:,:,iComp_thisRun)/50+brainMask/2,brainMask/2,brainMask/2),slicecoords);
%     title(sprintf('Run %i, comp %d',i,acceptedComps{i}(okComps(iComp,i))));
    title(sprintf('Run %i, comp %d',i,iComp_thisRun));
    axis([0 3 0 1]);
    set(gca,'xtick',[],'ytick',[]);
    subplot(4,1,4);
    plot(ts{i}(:,iComp));
    legendstr{i} = sprintf('Run %d',i);
end
legend(legendstr);
xlabel('time (TR)');
ylabel('BOLD signal (A.U.)')

% Plot with GUI_3View
GUI_3View(cat(4,mean(betas_thisComp,4)/50+brainMask/2,brainMask/2,brainMask/2),slicecoords);


%% Match runs 1 & 2

[iBest,matches] = MatchAllComponents(betas{1},betas{2});
[~,iBest2in1] = max(abs(matches));

doubleMatches = [];
for i=1:numel(iBest)
    if iBest2in1(iBest(i))==i
        doubleMatches = [doubleMatches; i,iBest(i)];
    end
end

%% Show matches
figure(4); clf; hold on;
imagesc(matches')
plot(iBest,'rs');
plot(iBest2in1,1:numel(iBest2in1),'k+');
plot(doubleMatches(:,1),doubleMatches(:,2),'md');
xlabel('component in run 1')
ylabel('component in run 2');
legend('comp2 that best matches this comp1','comp1 that best matches this comp2','double match','Location','southeast')
axis([0 size(betas{1},4),0,size(betas{2},4)]+0.5)
%% Plot matches
brainMask = any(betas{1}>0,4);
% brainMask(:) = 0;
slicecoords = round(size(brainMask)/2);
for i=1:6%numel(iBest)
    subplot(3,2,i); cla;
    Plot3Planes(cat(4,betas{1}(:,:,:,i)/50+brainMask/2,brainMask/2,betas{2}(:,:,:,iBest(i))/50+brainMask/2),slicecoords);
    title(sprintf('Run 1, comp %d; Run 2, comp %d',i,iBest(i)));
    axis([0 3 0 1]);
    set(gca,'xtick',[],'ytick',[]);
end