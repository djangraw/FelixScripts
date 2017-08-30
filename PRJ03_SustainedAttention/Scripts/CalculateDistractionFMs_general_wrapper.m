% CalculateDistractionFMs_general_wrapper.m
%
% Created 5/25/15 by DJ based on TEMP_SaveOutFwdModels.m.

subjects = [9:22 24:30];
homedir = '/spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/';

[FwdModel_bold,FwdModel_fc] = deal(cell(1,numel(subjects)));
label0_fc = 'attendedSpeech';
label1_fc = 'ignoredSpeech';
doPlots = false;

for i=1:numel(subjects)
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
    MagResults = load(MagResultsFilename,'subjects','y_best');
    FcResults = load(FcResultsFilename,'subjects','y_best');
    iSubj = find(FcResults.subjects==subject);
%     bestFcFrac = median(results.bestFcFrac{iSubj});
    % Get classifier y's for this
    yClassifier_Mag = MagResults.y_best{iSubj}';
    yClassifier_FC = FcResults.y_best{iSubj}';
    % Get FMs
    fprintf('Calculating FMs...\n');
    cd(sprintf('%sSBJ%02d',homedir,subject));
    [FwdModel_bold{i},FwdModel_fc{i}] = CalculateDistractionFMs_general(subject,label0_fc,label1_fc,yClassifier_Mag,yClassifier_FC,doPlots);
    
end
fprintf('Done!\n');

%% Matrix-ize and mean
% Matirx-ize
FwdModel_bold_all = cat(1,FwdModel_bold{:})';
FwdModel_fc_all = cat(3,FwdModel_fc{:});
% FwdModel_bold_perm_all = cat(3,FwdModel_bold_perm{:});
% FwdModel_fc_perm_all = cat(4,FwdModel_fc_perm{:});
[err,atlas,atlasInfo,ErrMsg] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc');

%% plot FC as matrices
nSubjects = numel(subjects);
meanFwdModel = mean(FwdModel_fc_all,3);
[~,order] = sort(mean(meanFwdModel,2),'ascend');
clim = [-.02 .02];
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

%% Get Perm significance
% meanFwdModel_perm = mean(FwdModel_fc_perm_all,4);
% meanFwdModel_pctPermBelow = zeros(200,200);
% for i=1:200
%     for j=1:200
%         meanFwdModel_pctPermBelow(i,j) = mean(abs(meanFwdModel(i,j))>abs(meanFwdModel_perm(i,j,:)),3)*100;
%     end
% end
% % threshold
% meanFwdModel_thresh = meanFwdModel;
% meanFwdModel_thresh(meanFwdModel_pctPermBelow<95) = nan;
% figure(723); clf;
% PlotFcMatrix(meanFwdModel_thresh(order,order),clim,atlas,nClusters);
% title(sprintf('Mean FC Fwd Model (%s-%s) across %d subjects (thresholded)',label1_fc,label0_fc,numel(subjects)))


%% plot on circle
% figure(4);
% subplot(2,3,2);
% % idx = ones(1,max(atlas(:)));
% PlotConnectivityOnCircle(atlas,1,meanFwdModel,GetValueAtPercentile(abs(meanFwdModel(:)),99.5));
% title(sprintf('Mean FC Fwd Model (%s-%s) across %d subjects',label1_fc,label0_fc,numel(subjects)))
% 
% 
% for i=1:3
%     subplot(2,3,3+i);
%     PlotConnectivityOnCircle(atlas,1,FwdModel_fc_all(:,:,i),GetValueAtPercentile(abs(FwdModel_fc_all(:,:,i)),99.5));
%     title(sprintf('SBJ%02d FC Fwd Model (%s-%s)',subjects(i),label1_fc,label0_fc))
% end

%% plot FC fwd models on atlas
% split into pos and neg
meanMeanFwdModel = mean(meanFwdModel,2);
maxColor = GetValueAtPercentile(abs(meanMeanFwdModel),98);
chanR = MapValuesOntoAtlas(atlas,meanMeanFwdModel(meanMeanFwdModel>0),find(meanMeanFwdModel>0))/maxColor;
chanR(isnan(chanR)) = 0;
chanR(chanR>1) = 1;
chanG = atlas*0;
chanB = -MapValuesOntoAtlas(atlas,meanMeanFwdModel(meanMeanFwdModel<0),find(meanMeanFwdModel<0))/maxColor;
chanB(isnan(chanB)) = 0;
chanB(chanB>1) = 1;
% plot
GUI_3View(cat(4,chanR,chanG,chanB));

%% get rank of true FM among permutations
% meanMeanFwdModel_perm = mean(meanFwdModel_perm,2);
% meanMeanFwdModel_pctPermBelow = zeros(200,1);
% for i=1:200
%     meanMeanFwdModel_pctPermBelow(i) = mean(abs(meanMeanFwdModel(i))>abs(meanMeanFwdModel_perm(i,:,:)),3)*100;
% end
% 
% % Get FDR correction
% [~,meanMeanFwdModel_q] = mafdr((100-meanMeanFwdModel_pctPermBelow)/100);
% meanMeanFwdModel_pctPermBelow_FDR = 100*(1-meanMeanFwdModel_q);


%% Plot BOLD fwd models on atlas
% split into pos and neg
meanBoldFwdModel = mean(FwdModel_bold_all,2);
maxColor = GetValueAtPercentile(abs(meanBoldFwdModel),98);
chanR = MapValuesOntoAtlas(atlas,meanBoldFwdModel(meanBoldFwdModel>0),find(meanBoldFwdModel>0))/maxColor;
chanR(isnan(chanR)) = 0;
chanR(chanR>1) = 1;
chanG = atlas*0;
chanB = -MapValuesOntoAtlas(atlas,meanBoldFwdModel(meanBoldFwdModel<0),find(meanBoldFwdModel<0))/maxColor;
chanB(isnan(chanB)) = 0;
chanB(chanB>1) = 1;

GUI_3View(cat(4,chanR,chanG,chanB));

%% get rank of true FM among permutations
% meanBoldFwdModel_perm = mean(FwdModel_bold_perm_all,3);
% meanBoldFwdModel_pctPermBelow = zeros(200,1);
% for i=1:200
%     meanBoldFwdModel_pctPermBelow(i) = mean(abs(meanBoldFwdModel(i))>abs(meanBoldFwdModel_perm(i,:)),2)*100;
% end
% 
% % Get FDR correction
% [~,meanBoldFwdModel_q] = mafdr((100-meanBoldFwdModel_pctPermBelow)/100);
% meanBoldFwdModel_pctPermBelow_FDR = 100*(1-meanBoldFwdModel_q);

%% Save result for plotting in AFNI
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations
[bigAtlas,Info] = BrikLoad('CraddockAtlas_200Rois_tta+tlrc.BRIK.gz');
cd /data/jangrawdc/PRJ03_SustainedAttention/Results

meanMeanFwdModel_atlas = MapValuesOntoAtlas(bigAtlas,meanMeanFwdModel);
meanMeanFwdModel_atlas(isnan(meanMeanFwdModel_atlas)) = 0;
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

Info.BRICK_TYPES = [3];
Info.BRICK_STATS = [min(meanMeanFwdModel(:)), max(meanMeanFwdModel(:))];
Info.BRICK_LABS = 'MeanFcFwdModel';
Opt = struct('Prefix',sprintf('SBJ%02d-%02d_Craddock_%s-%s_FcFwdModels_TTA',subjects(1),subjects(end),label1_fc,label0_fc),'OverWrite','y');
WriteBrik(meanMeanFwdModel_atlas,Info,Opt);

%% Do the same for BOLD
meanBoldFwdModel_atlas = MapValuesOntoAtlas(bigAtlas,meanBoldFwdModel);
meanBoldFwdModel_atlas(isnan(meanBoldFwdModel_atlas)) = 0;
% meanBoldFwdModel_atlas_perm = MapValuesOntoAtlas(bigAtlas,meanBoldFwdModel_pctPermBelow);
% meanBoldFwdModel_atlas_perm(isnan(meanBoldFwdModel_atlas_perm)) = 0;
% meanBoldFwdModel_atlas_perm_FDR = MapValuesOntoAtlas(bigAtlas,meanBoldFwdModel_pctPermBelow_FDR);
% meanBoldFwdModel_atlas_perm_FDR(isnan(meanBoldFwdModel_atlas_perm_FDR)) = 0;
% Info.BRICK_TYPES = [3 3];
% Info.BRICK_STATS = [min(meanBoldFwdModel(:)), max(meanBoldFwdModel(:)); ...
%     min(meanBoldFwdModel_pctPermBelow), max(meanBoldFwdModel_pctPermBelow)];
% Info.BRICK_LABS = 'MeanBoldFwdModel~PctPermsBelow~PctPermsBelow_FDR';
% Opt = struct('Prefix',sprintf('SBJ%02d-%02d_Craddock_%s-%s_BoldFwdModels_TTA',subjects(1),subjects(end),label1_bold,label0_bold),'OverWrite','y');
% WriteBrik(cat(4,meanBoldFwdModel_atlas,meanBoldFwdModel_atlas_perm,meanBoldFwdModel_atlas_perm_FDR),Info,Opt);

Info.BRICK_TYPES = [3];
Info.BRICK_STATS = [min(meanBoldFwdModel(:)), max(meanBoldFwdModel(:))];
Info.BRICK_LABS = 'MeanBoldFwdModel';
Opt = struct('Prefix',sprintf('SBJ%02d-%02d_Craddock_%s-%s_BoldFwdModels_TTA',subjects(1),subjects(end),label1_bold,label0_bold),'OverWrite','y');
WriteBrik(meanBoldFwdModel_atlas,Info,Opt);


%% check dependence
for i=1:numel(subjects)
    foo = mean(FwdModel_fc_all(order,order,i),2);
    linfit = fitlm((1:length(foo))',foo,'linear');
    CI = coefCI(linfit);
    fprintf('SBJ%02d: CI = [%.3g, %.3g]\n',subjects(i),CI(2,:));
end





