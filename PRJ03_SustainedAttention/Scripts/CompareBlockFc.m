function CompareBlockFc(subjects,atlasType)

% Created 9/8/16 by DJ.

%%    
% subjects = [9:11,13:19,22,24:25,28,30:34,36];
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
doRandTc = true;
nRand = 100;

for i=1:numel(subjects)
    fprintf('===SUBJECT %d/%d...\n',i,numel(subjects));
    subject = subjects(i);
    %% Set up
    cd(homedir)
    fprintf('Loading files...\n');
    % Get input data
    cd(sprintf('%sSBJ%02d',homedir,subject));
    beh = load(sprintf('Distraction-SBJ%02d-Behavior.mat',subject));
    datadir = dir('AfniProc*');
    cd(datadir(1).name);
    % Get data 
    switch atlasType
        case 'Craddock'
            [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
        case 'Craddock_e2'
            [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts_e2.1D',subject));
        case 'Shen'
            [~,tc] = Read_1D(sprintf('shen268_withSegTc_SBJ%02d_ROI_TS.1D',subject));
        otherwise
            tcFile = sprintf('%s_SBJ%02d_ROI_TS.1D',atlasType,subject);
            if exist(tcFile,'file')
                [~,tc] = Read_1D(tcFile);
            else
                error('Altas not recognized!');
            end
    end
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;

    % Get block start and end times
    nFirstRemoved = 3;
    TR = 2;
    HrfOffset = 6;
    fcWinLength = 1; % placeholder
    nRuns = numel(beh.data);
    nT = size(tc,2);
    nTR = nT/nRuns + nFirstRemoved;
    iTcEventSample_start = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset,'start');
    [iTcEventSample_end,~,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset,'end');
    iBlockStart = iTcEventSample_start(1:15:end);
    iBlockEnd = iTcEventSample_end(15:15:end);
    nBlocks = numel(iBlockStart);
    nRois = size(tc,1);
    
    % Get FC in each block
    FC = nan(nRois,nRois,nBlocks);
    isAttBlock = false(1,nBlocks);
    for j=1:nBlocks
        iThis = (1:15)+(j-1)*15;
        if any(strcmp(eventNames(iThis),'attendedSpeech'))
            isAttBlock(j) = true;
        else
            isAttBlock(j) =false;
        end
        tcThis = tc(:,iBlockStart(j):iBlockEnd(j));
        tcGood = tcThis(:,~any(isnan(tcThis),1));
        FC(:,:,j) = GetFcMatrices(tcGood,'sw',size(tcGood,2));
    end
    % Set up
    if i==1
        [meanAttFc, meanIgnFc] = deal(nan(nRois,nRois,numel(subjects)));
        [meanAttFc_rand, meanIgnFc_rand] = deal(nan(nRois,nRois,numel(subjects),nRand));
    end
    meanAttFc(:,:,i) = mean(FC(:,:,isAttBlock),3);
    meanIgnFc(:,:,i) = mean(FC(:,:,~isAttBlock),3);
    
    for iRand = 1:nRand
        fprintf('===RANDOMIZATION %d/%d...\n',iRand,nRand);
        % scramble TC
        if doRandTc
            tc = tc(:,randperm(size(tc,2)));
        end

        % Get FC in each block
        FC = nan(nRois,nRois,nBlocks);
        for j=1:nBlocks
            tcThis = tc(:,iBlockStart(j):iBlockEnd(j));
            tcGood = tcThis(:,~any(isnan(tcThis),1));
            FC(:,:,j) = GetFcMatrices(tcGood,'sw',size(tcGood,2));
        end
        % Get mean across blocks
        meanAttFc_rand(:,:,i,iRand) = mean(FC(:,:,isAttBlock),3);
        meanIgnFc_rand(:,:,i,iRand) = mean(FC(:,:,~isAttBlock),3);

    end

end

%% Compare actual FC to random
meanFcDiff = mean(meanIgnFc-meanAttFc,3);
meanFcDiff_rand = mean(meanIgnFc_rand-meanAttFc_rand,3);
pFcDiff=nan(nRois);
for i=1:nRois
    for j=1:nRois
        pFcDiff(i,j) = mean(abs(meanFcDiff(i,j))>abs(meanFcDiff_rand(i,j,:,:)),4);
    end
end
meanFcDiff_clipped = meanFcDiff;
meanFcDiff_clipped(pFcDiff<.95) = 0;
% Load atlas
switch atlasType
    case {'Craddock','Craddock_e2'}
        atlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc');    
        atlasLabels = 5; % nClusters
        colors = [];
    case 'Shen'
        atlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc');        
        [atlasLabels,labelNames,colors] = GetAttnNetLabels();
    otherwise            
        if exist(atlasType,'file')
            atlas = BrikLoad(atlasType);
            atlasLabels = 5; %nClusters
            colors = [];
        else
            error('Altas not recognized!');
        end
end
% Plot result
figure(6); clf;
[~,order,idx_ordered] = PlotFcMatrix(meanFcDiff_clipped,[-1 1]*0.04,atlas,atlasLabels,true,colors);
title(sprintf('Ignore - Attend Blocks: Mean across %d subjects\n(thresholded at p<0.05)',numel(subjects)));

%% Do same with grouping
figure(67); clf;
PlotFcMatrix(meanFcDiff,[-1 1]*0.02,atlas,atlasLabels,true,colors,true);
title(sprintf('Ignore - Attend Blocks: Mean across %d subjects\n(no thresholding)',numel(subjects)));


%% Get difference on subject-by-subject basis

clim = [-1 1]*.6;
climdiff = [-1 1]*.2;
idx = nan(size(idx_ordered));
idx(order) = idx_ordered;
doAvgInCluster = false;
fcDiff = meanIgnFc-meanAttFc;
fcDiff_rand = meanIgnFc_rand-meanAttFc_rand;
pFcDiff = nan(nRois,nRois,numel(subjects));

% nRows = ceil((numel(subjects)+1)/2);
nRows = 6;
nCols = 6;
for i=1:numel(subjects)
    if mod(i-1,11)==0
        figure(197+(i-1)/11); clf;
    end
    iPlot = mod(i-1,11)+1;
    fprintf('Plotting Subject %d/%d...\n',i,numel(subjects))
    subplot(nRows,nCols,(iPlot-1)*3+1); cla;
    PlotFcMatrix(meanIgnFc(:,:,i),clim,atlas,idx,true,colors,doAvgInCluster);
    title(sprintf('SBJ%02d ignore',subjects(i)));
    subplot(nRows,nCols,(iPlot-1)*3+2); cla;
    PlotFcMatrix(meanAttFc(:,:,i),clim,atlas,idx,true,colors,doAvgInCluster);
    title(sprintf('SBJ%02d attend',subjects(i)));
    for j=1:nRois
        for k=j:nRois
            pFcDiff(j,k,i) = mean(abs(fcDiff(j,k,i))>abs(fcDiff_rand(j,k,i,:)),4);
            pFcDiff(k,j,i) = pFcDiff(j,k,i);
        end
    end
    fcDiff_clipped = fcDiff(:,:,i);
    fcDiff_clipped(pFcDiff(:,:,i)<0.95) = 0;
    subplot(nRows,nCols,(iPlot-1)*3+3); cla;
    PlotFcMatrix(fcDiff_clipped,climdiff,atlas,idx,true,colors,doAvgInCluster);
    title(sprintf('SBJ%02d ignore-attend',subjects(i)));
end
fprintf('Plotting mean...\n')
subplot(nRows,nCols,(iPlot)*3+1); cla;
PlotFcMatrix(mean(meanIgnFc,3),clim,atlas,idx,true,colors,doAvgInCluster);
title('MEAN ignore');
subplot(nRows,nCols,(iPlot)*3+2); cla;
PlotFcMatrix(mean(meanAttFc,3),clim,atlas,idx,true,colors,doAvgInCluster);
title('MEAN attend');
subplot(nRows,nCols,(iPlot)*3+3); cla;
PlotFcMatrix(mean(meanIgnFc-meanAttFc,3),climdiff/4,atlas,idx,true,colors,doAvgInCluster);
title('MEAN ignore-attend');
fprintf('Done!\n')

%%
figure(3);
meanDiffFc_vec = VectorizeFc(meanAttFc-meatlasanIgnFc);
meanDiffFc_corr = corr(meanDiffFc_vec);
imagesc(meanDiffFc_corr);
xlabel('subject');
ylabel('subject');
title('Correlation between ignore-attend FC')
set(gca,'clim',[-.5 .5]);
colorbar;



