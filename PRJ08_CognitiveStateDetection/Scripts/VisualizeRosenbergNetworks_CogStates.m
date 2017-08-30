% VisualizeRosenbergNetworks_CogStates.m
%
% Created 11/23/16 by DJ.


%% Get FC matrices
% Set up
subjects = [6:13,16:27];
demeanTs = true;
separateTasks = true;
nSubj = numel(subjects);
% Get FC
FCtmp = GetFcForCogStateData(subjects(1),separateTasks,demeanTs);
FC = nan([size(FCtmp),nSubj]);
winInfo_cell = cell(1,nSubj);
for i=1:nSubj
    [FC(:,:,:,i),winInfo_cell{i}] = GetFcForCogStateData(subjects(i),separateTasks,demeanTs);
end

%% Get atlas & attention networks
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);
% Get Rosenberg Hi/Low-Attn matrices
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_model_268.mat');


%% Plot FC
fcTasks = {'REST','BACK','VIDE','MATH'};

FCavg = GetAvgFcAcrossTasks(FC,fcTasks,taskNames);

% Plot for each subject
nRows = ceil(sqrt(nSubj));
nCols = ceil(nSubj/nRows);
figure(236); clf;
for i=1:nSubj
    subplot(nRows,nCols,i);
    PlotFcMatrix(FCavg(:,:,i),[-1 1],shenAtlas,shenLabels,true,shenLabelColors,false);
    title(sprintf('subject %d',subjects(i)));
end
MakeLegend(shenLabelColors,shenLabelNames,2,[.5 .5]);

%% Plot FC for each task
nTasks = numel(fcTasks);
nRows = ceil(sqrt(nTasks));
nCols = ceil(nTasks/nRows);
figure(237); clf;
for i=1:nTasks
    FCavg = GetAvgFcAcrossTasks(FC,fcTasks,taskNames{i});
    subplot(nRows,nCols,i);
    PlotFcMatrix(mean(FCavg,3),[-1 1],shenAtlas,shenLabels,true,shenLabelColors,false);
    title(sprintf('task %s',fcTasks{i}));
end
MakeLegend(shenLabelColors,shenLabelNames,2,[.5 .5]);

%% Plot Shen Atlas with missing ROIs
isBadRoi = all(isnan(FCavg(:,:,1)));
rosePos = attnNets.pos_overlap;
rosePos(isBadRoi,:) = nan;
rosePos(:,isBadRoi) = nan;
roseNeg = attnNets.neg_overlap;
roseNeg(isBadRoi,:) = nan;
roseNeg(:,isBadRoi) = nan;
figure(238); clf;
subplot(1,2,1)
PlotFcMatrix(rosePos-roseNeg,[-1 1],shenAtlas,shenLabels,true,shenLabelColors,false);
title('Rosenberg High-Attn - Low-Attn Network');
subplot(1,2,2)
PlotFcMatrix(rosePos-roseNeg,[-1 1]*.4,shenAtlas,shenLabels,true,shenLabelColors,true);
title('Rosenberg High-Attn - Low-Attn Network');
MakeLegend(shenLabelColors,shenLabelNames,2,[.5 .5]);

%% Plot as 3D barbells
figure(239); clf;
VisualizeFcIn3d(rosePos-roseNeg,shenAtlas,shenLabels,shenLabelColors,shenLabelNames);

%% Plot mean push/pull
scaleFactor = max([nanmean(rosePos,2); nanmean(roseNeg,2)]);
meanPos = nanmean(rosePos,2);
meanNeg = nanmean(roseNeg,2);
tmpBrick = MapColorsOntoAtlas(shenAtlas,cat(2,meanPos/scaleFactor,shenLabels/max(shenLabels),meanNeg/scaleFactor));
GUI_3View(tmpBrick);

%% Plot as a function of A-P position
roiPos = GetAtlasRoiPositions(shenAtlas);
figure(240); clf;
dimNames = {'L-R','P-A','V-D'};
xHist = linspace(min(roiPos(:)),max(roiPos(:)),20);
yHist = unique([meanPos(~isnan(meanPos)); meanNeg(~isnan(meanNeg))]);
for i=1:3
    subplot(2,3,i); hold on;
    plot(roiPos(:,i),meanPos,'r.');
    plot(roiPos(:,i),meanNeg,'b.');
    xlabel(dimNames{i})
    ylabel('# connections')
    legend('High-attn','Low-attn');
    subplot(2,3,3+i);
    nPos = hist3([roiPos(:,i),meanPos],{xHist,yHist});
    nNeg = hist3([roiPos(:,i),meanNeg],{xHist,yHist});
    imagesc(xHist,yHist,cat(3,nPos,nPos*0,nNeg)/max([nPos(:);nNeg(:)]));
    set(gca,'YDir','normal');
    xlabel(dimNames{i})
    ylabel('# connections')
end
MakeFigureTitle('Rosenberg Matrices, Cog States ROIs');


