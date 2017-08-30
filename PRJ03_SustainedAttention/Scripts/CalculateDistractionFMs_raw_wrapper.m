subjects = [9:22 24:30];
homedir = '/spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/';

[FwdModel_bold,FwdModel_fc] = deal(cell(1,numel(subjects)));
label0_fc = 'attendedSpeech';
label1_fc = 'ignoredSpeech';
doPlots = false;

for i=1:numel(subjects) % [8 10 13 18 20]%
    subject = subjects(i);
    fprintf('Subject %d...\n',subject);
    cd(homedir)
    if subject<=16
        MagResultsFilename = sprintf('SBJ09-16_%s-%s_Mag_nestedLooCv',label1_fc,label0_fc);
        FcResultsFilename = sprintf('SBJ09-16_%s-%s_FC_nestedLooCv',label1_fc,label0_fc);
    elseif subject<=20
        MagResultsFilename = sprintf('SBJ17-20_%s-%s_Mag_nestedLooCv',label1_fc,label0_fc);
        FcResultsFilename = sprintf('SBJ17-20_%s-%s_FC_nestedLooCv',label1_fc,label0_fc);
    elseif subject<=30
        MagResultsFilename = sprintf('SBJ21-30_%s-%s_Mag_nestedLooCv',label1_fc,label0_fc);
        FcResultsFilename = sprintf('SBJ21-30_%s-%s_FC_nestedLooCv',label1_fc,label0_fc);
    else
        FcResultsFilename = '';
        continue;
    end
    % Get index of best 
    fprintf('Loading files...\n');
%     MagResults = load(MagResultsFilename,'subjects','y_best');
    FcResults = load(FcResultsFilename,'subjects','bestTcFrac','bestFcFrac','y_best');
    iSubj = find(FcResults.subjects==subject);
    bestTcFrac = median(FcResults.bestTcFrac{iSubj});
    bestFcFrac = median(FcResults.bestFcFrac{iSubj});
    fprintf('Best fracFcVarToKeep is %.2g\n',bestFcFrac);
    % Get classifier y's for this
%     yClassifier_Mag = MagResults.y_best{iSubj}';
%     yClassifier_FC = FcResults.y_best{iSubj}';
    % Get input data
    cd(sprintf('%sSBJ%02d',homedir,subject));
    beh = load(sprintf('Distraction-%d-QuickRun.mat',subject));
    % Load timecourses
    datadir = dir('AfniProc*');
    cd(datadir(1).name);
    [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
    % Get FMs
    fprintf('Calculating FMs...\n');
    [FwdModel_fc{i}] = CalculateDistractionFMs_raw(beh.data,beh.stats,beh.question,tc,bestTcFrac,bestFcFrac,label1_fc,label0_fc);
    
end
fprintf('Done!\n');

%% Matrix-ize and mean
% Matirx-ize
% FwdModel_bold_all = cat(1,FwdModel_bold{:})';
FwdModel_fc_all = cat(3,FwdModel_fc{:});
% FwdModel_bold_perm_all = cat(3,FwdModel_bold_perm{:});
% FwdModel_fc_perm_all = cat(4,FwdModel_fc_perm{:});
[err,atlas,atlasInfo,ErrMsg] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc');

%% plot FC as matrices
nSubjects = numel(subjects);
meanFwdModel = nanmean(FwdModel_fc_all,3);
[~,order] = sort(nanmean(meanFwdModel,2),'ascend');
clim = [-1 1]*3e-4;%*.02;
nClusters = [];
figure(3);
nRows = ceil(sqrt(nSubjects+1));
nCols = ceil((nSubjects+1)/nRows);

subplot(nRows,nCols,1);
PlotFcMatrix(meanFwdModel(order,order),clim/2,atlas,nClusters);
title(sprintf('Mean FC Fwd Model\n (%s-%s)\n across %d subjects',label1_fc,label0_fc,numel(subjects)))

for i=1:numel(subjects)
    subplot(nRows,nCols,i+1);
    PlotFcMatrix(FwdModel_fc_all(order,order,i),clim,atlas,nClusters);
    title(sprintf('SBJ%02d FC Fwd Model\n (%s-%s)',subjects(i),label1_fc,label0_fc))
end
colormap jet

%% Get signrank significance
FcFwdModel_meanAcrossRois = squeeze(mean(FwdModel_fc_all,2));
nRois = size(FcFwdModel_meanAcrossRois,1);
FcFwdModel_pval = zeros(1,nRois);
for i=1:nRois
    FcFwdModel_pval(i) = signrank(FcFwdModel_meanAcrossRois(i,:));
end

%% Save result for plotting in AFNI
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations
[bigAtlas,Info] = BrikLoad('CraddockAtlas_200Rois_tta+tlrc.BRIK.gz');
cd /data/jangrawdc/PRJ03_SustainedAttention/Results

meanMeanFwdModel_atlas = MapValuesOntoAtlas(bigAtlas,meanMeanFwdModel);
meanMeanFwdModel_atlas(isnan(meanMeanFwdModel_atlas)) = 0;
meanMeanFwdModel_atlas_pval = MapValuesOntoAtlas(bigAtlas,FcFwdModel_pval);
meanMeanFwdModel_atlas_pval(isnan(FcFwdModel_pval)) = 0;

% meanMeanFwdModel_atlas_perm = MapValuesOntoAtlas(bigAtlas,meanMeanFwdModel_pctPermBelow);
% meanMeanFwdModel_atlas_perm(isnan(meanMeanFwdModel_atlas_perm)) = 0;
% meanMeanFwdModel_atlas_perm_FDR = MapValuesOntoAtlas(bigAtlas,meanMeanFwdModel_pctPermBelow_FDR);
% meanMeanFwdModel_atlas_perm_FDR(isnan(meanMeanFwdModel_atlas_perm_FDR)) = 0;
% Info.BRICK_TYPES = [3 3];
% Info.BRICK_STATS = [min(meanMeanFwdModel(:)), max(meanMeanFwdModel(:)); ...
%     min(meanMeanFwdModel_pctPermBelow), max(meanMeanFwdModel_pctPermBelow)];
% Info.BRICK_LABS = 'MeanFcFwdModel~PctPermsBelow~PctPermsBelow_FDR';
% Opt = struct('Prefix',sprintf('SBJ%02d-%02d_Craddock_%s-%s_FcFwdModels_TTA',subjects(1),subjects(end),label1_fc,label0_fc),'OverWrite','y');
% WriteBrik(cat(4,meanMeanFwdModel_atlas,meanMeanFwdModel_atlas_perm,meanMeanFwdModel_atlas_perm_FDR),Info,Opt);
S
% Write version with signrank p values as 2nd Ssub-brick
Info.BRICK_TYPES = [3 3];
Info.BRICK_STATS = [min(meanMeanFwdModel(:)), max(meanMeanFwdModel(:)); ...
    min(FcFwdModel_pval), max(FcFwdModel_pval)];
Info.BRICK_LABS = 'MeanFcFwdModel~signrankPVal';
Opt = struct('Prefix',sprintf('SBJ%02d-%02d_Craddock_%s-%s_FcFwdModels_TTA_norm',subjects(1),subjects(end),label1_fc,label0_fc),'OverWrite','y');
WriteBrik(cat(4,meanMeanFwdModel_atlas,meanMeanFwdModel_atlas_pval),Info,Opt);
