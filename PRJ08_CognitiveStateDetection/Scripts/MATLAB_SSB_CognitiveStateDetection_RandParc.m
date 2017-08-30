% #!/bin/bash
% #
% #PBS -N SSB_DET
% #OBS -j oe
%  
% date
% echo "Subject=${SBJ}, WL${WL}, VK=${VK}, NROI=${NROI}" 
% matlab -nosplash -nodesktop << EOF 

% This script does the whole analysis for a single subject, single window
% length and single dimensionality reduction case
% close all
% clear all
addpath('/data/jangrawdc/PRJ08_CognitiveStateDetection/Scripts/JavierScripts/MatlabAddOns/');
addpath('/data/jangrawdc/PRJ08_CognitiveStateDetection/Scripts/JavierScripts/MatlabAddOns/NCestimation/');
addpath('/data/jangrawdc/PRJ08_CognitiveStateDetection/Scripts/JavierScripts');
addpath('/data/jangrawdc/PRJ08_CognitiveStateDetection/Scripts/JavierScripts/CSD_Toolbox/');
addpath('/data/jangrawdc/PRJ08_CognitiveStateDetection/Scripts/JavierScripts/MatlabAddOns/Clustering/');

% Declare params that would have come from bash
% SBJ=7;
NROI=200;
VK=97.5;
WL=30;
WS=0;

% declare randomization params
% iRand = 0;

% Subject & Run Information
  Subject = char(strcat('SBJ',num2str(SBJ,'%02d'))); %'SBJ06';%char(strcat('SBJ',num2str($SBJ,'%02d')));
  NumAcq  = 1017;
  TR      = 1.5;
% Data Location
  PrjDir    = '/data/jangrawdc/PRJ08_CognitiveStateDetection';
  TaskID    = 'CTask001';
  DirPrefix = 'D02';
% Atlas Info
  NumROIsAtlas = NROI;
  if isnan(iRand)
      AtlasID        = char(strcat('Craddock_T2Level_',num2str(NumROIsAtlas,'%04d')));
      isSorted = 1;
  else
      AtlasID        = sprintf('Craddock_RandParc_%03dROIs_%d_10VoxelMin',NumROIsAtlas,iRand);
      isSorted = 0;
  end
  sortMetric   = 5;
% PCA/Dim. Reduction
  VarToKeep       = VK; %97.5; %$VK;
  ROIConnMetric   = 2; % 1 = Pearson (don't use) | 2 = Fisher | 3 = Fisher + Feature Rand | 4 = Fisher + Phase Rand
  DimRed_Method   = 1 ;  % 1 = PCA | 2 = MDS 
  DimRed_Methods  = {'PCA','MDS'};
% Window Analysis Configuration
  winLength_inTR       = WL; %40;%$WL;
  winStep_inTR         = WS; %0; % Use the partitioning by task
% Flags
  doOnlyPureWins    = 0;
  doIBClassif       = 1;
  doSBClassif       = 1;
  doVis             = 0;
% Classification Options
  Kmeans_Opt.nClusters  = 4;
  Kmeans_Opt.metric     = 'correlation';
  Kmeans_Opt.nIter      = 1000;
  HClust_Opt.nClusters = 4;
  HClust_Opt.metric    = 'euclidean';
  HClust_Opt.method    = 'ward';
  HClust_Opt.do        = 1;
% ==============================================================================================================================

%% BASIC PARAMETER CONTROL
%  -----------------------
if (ROIConnMetric == 1) || (ROIConnMetric > 4); disp('ERROR: Wrong selection of metric'); return; end
%if (winStep_inTR == 0); doOnlyPureWins    = 1; end

%% LOAD TIME-SERIES (Sorted/Not Sorted) && (ROI Summary Method) && (Pre-processing Pipeline)
%  -----------------------------------------------------------------------------------------
fprintf(char(strcat( '(1) LOAD TIMESERIES: ', Subject, ', WL=', num2str(floor(winLength_inTR*TR)), 's, VarToKeep=', num2str(VarToKeep),' ....'))); 
% fileDir    = char(strcat(PrjDir,'/PrcsData/',Subject,'/',DirPrefix,'_',TaskID,'/DXX_NROIS',num2str(NumROIsAtlas,'%04d')));
fileDir    = char(strcat(PrjDir,'/PrcsData/',Subject,'/',DirPrefix,'_',TaskID)); % for RandPerm data
filePrefix = char(strcat(Subject,'_',TaskID,'.',AtlasID,'.lowSigma.'));
fileSuffix = char(strcat('.WL',num2str(floor(winLength_inTR*TR),'%03d'),'.1D'));
if (isSorted ==1);
    rankedROIsFilename = char(strcat(PrjDir,'/PrcsData/SALL/SALL_',AtlasID,'.MNI.ROIList_sort',num2str(sortMetric),'.1D'));
    [ROIrank, NumRankedROIs] = func_CSD_loadROIranks(rankedROIsFilename);
    [~,~,origTS] = func_CSD_Load_Timeseries(fileDir,filePrefix,fileSuffix,ROIrank);
else
    % /data/SFIMJGC/PRJ_CognitiveStateDetection01/PrcsData/SBJ06/D02_CTask001/DXX_NROIS0200/SBJ06_CTask001.Craddock_RandParc_200ROIs_0_10VoxelMin.lowSigma.WL045.1D
    tsFilename = sprintf('%s/%s%s',fileDir,filePrefix(1:end-1),fileSuffix); % end-1 is to avoid double .
    [err, origTS] = Read_1D(tsFilename);
end
cprintf('Blue','[DONE]\n');

%% GENERATE WINDOWS AND TEMPLATES
%  ------------------------------
fprintf(char(strcat('(2) GENERATE WINDOW INFORMATION: WL= ', num2str(floor(winLength_inTR*TR)), 'TRs, WS= ', num2str(winStep_inTR), 'TRs .... ')));
[~,~,winInfo] = func_CSD_GetWinInfo_Experiment01(winLength_inTR,winStep_inTR);
cprintf('Blue',char(strcat('[DONE - #Windows=',num2str(winInfo.numWins),']\n')));

%% TIME-SERIES ORTHOGONALIZATION
%  ----------------------------
fprintf(char(strcat('(3) TIME-SERIES ORTOGONALIZATION...')));
[err, errMsg, PCARes] = func_CSD_PCA(origTS, VarToKeep);
cprintf('Blue',char(strcat('[DONE - Num Dimensions= ' , num2str(PCARes.numPCAs),']\n')));

%% DIMENSIONALITY REDUCTION
%  ------------------------
switch DimRed_Method
    case 1  % PCA
        fprintf('(4) DIMENSIONALITY REDCUTION WITH PCA...');
        dimRedTS = PCARes.pcaTS;
        cprintf('Blue','[DONE]\n');
    case 2  % MDS
        fprintf('(4) DIMENSIONALITY REDUCTION WITH MDS...');
        [err, errMsg, MDSRes ] = func_CSD_MDS(origTS, PCARes.numPCAs);
        dimRedTS = MDS.mdsTS;
        cprintf('Blue','[DONE]\n');
end

%% SNAPSHOT COMPUTATION PER WINDOW
%  -------------------------------
fprintf('(5) COMPUTING SNAPSHOTS PER WINDOW...');
ALL       = ones(PCARes.numPCAs, PCARes.numPCAs);
topTriIdx = find(triu(ALL,1)==1);
for win = [1:winInfo.numWins]
    aux_TS = dimRedTS(winInfo.onsetTRs(win):winInfo.offsetTRs(win),:);
    % Time-series randomization on a window-by-window basis
    if (ROIConnMetric == 4);  
        if (win == 1); fprintf('\n    INFO: Timeseries phase randomization on win-by-win basis selected.');end
        [~,~,aux_TS] = func_CSD_PhaseRand_TS(aux_TS); 
    end
    aux_CM =  corr(aux_TS);
    aux_FM = atanh(aux_CM);
    IB.snapshots(win,:) = mean(aux_TS);
    SB.snapshots(win,:) =  std(aux_TS);
    switch ROIConnMetric
        case 1
            CB.snapshots(win,:) = aux_CM(topTriIdx);
        otherwise
            CB.snapshots(win,:) = aux_FM(topTriIdx);
    end
    clear aux_TS aux_CM aux_FM
end
%Feature Randomization if selected
if (ROIConnMetric == 3)
   fprintf('\n    INFO: Feature Vector randomization on win-by-win basis selected.');
   [~,~,CB.snaphots] = func_CSD_Randomize_Features(CB.snapshots);
end
clear ALL topTriIdx

if (doOnlyPureWins  == 1)
    CB.snapshots = CB.snapshots(winInfo.isValid==1,:);   IB.snapshots = IB.snapshots(winInfo.isValid==1,:); SB.snapshots = SB.snapshots(winInfo.isValid==1,:);
    CB.template  = winInfo.template(winInfo.isValid==1); IB.template  = CB.template;                        SB.template  = CB.template;
    CB.color     = winInfo.color(winInfo.isValid==1,:);  IB.color     = CB.color;                           SB.color     = CB.color;
else
    CB.template  = winInfo.template; IB.template = CB.template; SB.template =  CB.template;
    CB.color     = winInfo.color;    IB.color    = CB.color;    SB.color    =  CB.color;
end
CB.numSnaps = size(CB.snapshots,1);
cprintf('Blue',char(strcat('[DONE - #Snapshots=',num2str(CB.numSnaps),']\n')));
%% CLUSTERING
%  ----------
fprintf('(6) CLUSTERING...\n');
fprintf('    CB K-means:');
tic();[~, ~, CB.Kmeans.Res] = func_CSD_Classify_kmeans(CB.snapshots, Kmeans_Opt);wallTime=toc();cprintf('Blue',char(strcat(' [DONE Time=',num2str(wallTime,'%5.2f'),'s]\n')));
if (doIBClassif == 1); fprintf('    IB K-means:');tic();[~, ~, IB.Kmeans.Res] = func_CSD_Classify_kmeans(IB.snapshots, Kmeans_Opt);wallTime=toc();cprintf('Blue',char(strcat(' [DONE Time=',num2str(wallTime,'%5.2f'),'s]\n')));end;
if (doSBClassif == 1); fprintf('    SB K-means:');tic();tic();[~, ~, SB.Kmeans.Res] = func_CSD_Classify_kmeans(SB.snapshots, Kmeans_Opt);wallTime=toc();cprintf('Blue',char(strcat(' [DONE Time=',num2str(wallTime,'%5.2f'),'s]\n')));end;
if (HClust_Opt.do == 1)
    fprintf('    CB H-Clust:');
    [~, ~, CB.HClust.Res] = func_CSD_Classify_hclust(CB.snapshots, HClust_Opt);cprintf('Blue',' [DONE]\n');
    if (doIBClassif == 1); fprintf('    IB K-means:');[~, ~, IB.HClust.Res] = func_CSD_Classify_hclust(IB.snapshots, HClust_Opt);cprintf('Blue',' [DONE]\n');end;
    if (doSBClassif == 1); fprintf('    SB K-means:');[~, ~, SB.HClust.Res] = func_CSD_Classify_hclust(SB.snapshots, HClust_Opt);cprintf('Blue',' [DONE]\n');end;
end

%% VISUALIZATION
%  -------------
if (doVis == 1)
    fprintf('(7) VISUALIZATION...\n');
    resFig = figure('Name',['Results - ' Subject ' - ' num2str(VarToKeep) ],'Color',[1 1 1]);
    plotMusic = subplot(2,1,2);
    plotDist  = subplot(2,1,1);
    
    func_CSD_Vis_MusicPlot(CB, Kmeans_Opt.nClusters, CB.Kmeans.Res.clusters,plotMusic);
    func_CSD_Vis_DistPlot(CB, Kmeans_Opt.nClusters, CB.Kmeans.Res.D, plotDist);
end
%% QUANTITATIVE EVALUTION (Only on pure windows - by definition)
%  -------------------------------------------------------------
fprintf('(7) EVALUATION...\n');
switch doOnlyPureWins
    case 1    
        fprintf('    CB K-means:');
        [~,~,CB.Kmeans.Eval] = func_CSD_Validate_ARI(CB.Kmeans.Res.clusters, CB.template);cprintf('Blue',char(strcat(' [DONE ARI=',num2str(CB.Kmeans.Eval.ARI,'%5.2f'),']\n')));
        if (doIBClassif == 1); fprintf('    IB K-means:');[~,~,IB.Kmeans.Eval] = func_CSD_Validate_ARI(IB.Kmeans.Res.clusters, IB.template);cprintf('Blue',char(strcat(' [DONE ARI=',num2str(IB.Kmeans.Eval.ARI,'%5.2f'),']\n')));end;
        if (doSBClassif == 1); fprintf('    SB K-means:');[~,~,SB.Kmeans.Eval] = func_CSD_Validate_ARI(SB.Kmeans.Res.clusters, SB.template);cprintf('Blue',char(strcat(' [DONE ARI=',num2str(SB.Kmeans.Eval.ARI,'%5.2f'),']\n')));end;
        if (HClust_Opt.do == 1)
            fprintf('    CB H-Clust:');
            [~,~,CB.HClust.Eval] = func_CSD_Validate_ARI(CB.HClust.Res.clusters, CB.template);cprintf('Blue',char(strcat(' [DONE ARI=',num2str(CB.HClust.Eval.ARI,'%5.2f'),']\n')));
            if (doIBClassif == 1); fprintf('    IB K-means:');[~,~,IB.HClust.Eval] = func_CSD_Validate_ARI(IB.HClust.Res.clusters, IB.template);cprintf('Blue',char(strcat(' [DONE ARI=',num2str(IB.HClust.Eval.ARI,'%5.2f'),']\n')));end;
            if (doSBClassif == 1); fprintf('    SB K-means:');[~,~,SB.HClust.Eval] = func_CSD_Validate_ARI(SB.HClust.Res.clusters, SB.template);cprintf('Blue',char(strcat(' [DONE ARI=',num2str(SB.HClust.Eval.ARI,'%5.2f'),']\n')));end;
        end
    case 0
        fprintf('    CB K-means:');
        [~,~,CB.Kmeans.Eval] = func_CSD_Validate_ARI(CB.Kmeans.Res.clusters(winInfo.isValid==1), winInfo.template(winInfo.isValid==1));cprintf('Blue',char(strcat(' [DONE ARI=',num2str(CB.Kmeans.Eval.ARI,'%5.2f'),']\n')));
        if (doIBClassif == 1); fprintf('    IB K-means:');[~,~,IB.Kmeans.Eval] = func_CSD_Validate_ARI(IB.Kmeans.Res.clusters(winInfo.isValid==1), winInfo.template(winInfo.isValid==1));cprintf('Blue',char(strcat(' [DONE ARI=',num2str(IB.Kmeans.Eval.ARI,'%5.2f'),']\n')));end;
        if (doSBClassif == 1); fprintf('    SB K-means:');[~,~,SB.Kmeans.Eval] = func_CSD_Validate_ARI(SB.Kmeans.Res.clusters(winInfo.isValid==1), winInfo.template(winInfo.isValid==1));cprintf('Blue',char(strcat(' [DONE ARI=',num2str(SB.Kmeans.Eval.ARI,'%5.2f'),']\n')));end;
        if (HClust_Opt.do == 1)
            fprintf('    CB H-Clust:');
            [~,~,CB.HClust.Eval] = func_CSD_Validate_ARI(CB.HClust.Res.clusters(winInfo.isValid==1), winInfo.template(winInfo.isValid==1));cprintf('Blue',char(strcat(' [DONE ARI=',num2str(CB.HClust.Eval.ARI,'%5.2f'),']\n')));
            if (doIBClassif == 1); fprintf('    IB K-means:');[~,~,IB.HClust.Eval] = func_CSD_Validate_ARI(IB.HClust.Res.clusters(winInfo.isValid==1), winInfo.template(winInfo.isValid==1));cprintf('Blue',char(strcat(' [DONE ARI=',num2str(IB.HClust.Eval.ARI,'%5.2f'),']\n')));end;
            if (doSBClassif == 1); fprintf('    SB K-means:');[~,~,SB.HClust.Eval] = func_CSD_Validate_ARI(SB.HClust.Res.clusters(winInfo.isValid==1), winInfo.template(winInfo.isValid==1));cprintf('Blue',char(strcat(' [DONE ARI=',num2str(SB.HClust.Eval.ARI,'%5.2f'),']\n')));end;
        end
        
end

%% CLEAN-UP/SAVE TO DISK
%  ---------------------
if (isSorted == 0 )
   filename=char(strcat(fileDir,'/',Subject,'_',DimRed_Methods(DimRed_Method),'_NROI',num2str(NumROIsAtlas,'%04d'),'_WL',num2str(floor(winLength_inTR),'%04d'),'_WS',num2str(winStep_inTR,'%04d'),'_VK',num2str(VarToKeep,'%06.02f'),'_RandParc',num2str(iRand),'.UNSORTED')); 
else
   filename=char(strcat(fileDir,'/',Subject,'_',DimRed_Methods(DimRed_Method),'_NROI',num2str(NumROIsAtlas,'%04d'),'_WL',num2str(floor(winLength_inTR),'%04d'),'_WS',num2str(winStep_inTR,'%04d'),'_VK',num2str(VarToKeep,'%06.02f'),'.SORTED',num2str(sortMetric,'%02d')));
end
switch ROIConnMetric
    case 1; filename = char(strcat(filename,'.corr.mat'));
    case 2; filename = char(strcat(filename,'.mat'));
    case 3; filename = char(strcat(filename,'VectRand.mat'));
    case 4; filename = char(strcat(filename,'PhaseRand.mat'));
end
clear err errMsg win PrjDir DirPrefix winLength_inTR winStep_inTR wallTime resFig plotDist plotMusic ans
save(filename)

% exit
% EOF
