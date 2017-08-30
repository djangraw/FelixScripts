% TEMP_SaveOutFwdModels.m
%
% Created 3/2/16 by DJ.

subjects = 9:16;
doPerms = true;
doPlots = false;

label1_bold = 'whiteNoise';
label0_bold = 'other';
label1_fc = 'ignoredSpeech';
label0_fc = 'attendedSpeech';

nRois = 200;
nPerms = 100;
nSubjects = numel(subjects);
dateString = '2016-03-01';

% FwdModel_bold = zeros(
[FwdModel_bold,FwdModel_fc,FwdModel_bold_perm,FwdModel_fc_perm] = deal(cell(1,numel(subjects)));
for i=1:numel(subjects)
    fprintf('===SUBJECT %d/%d...===\n',i,numel(subjects));
    subject = subjects(i);
    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject)); 
    % get AZ values
    filename = sprintf('SBJ%02d_MultimodalClassifier_whiteNoise-other_%s',subject,dateString);
    [FwdModel_bold{i},FwdModel_fc{i},FwdModel_bold_perm{i},FwdModel_fc_perm{i}] = CalculateDistractionFMs(subject,filename,doPerms,doPlots);
end


%% SAVE
save(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d-%02d_FwdModels_%s',subjects(1),subjects(end),dateString),'FwdModel_bold','FwdModel_fc','FwdModel_bold_perm','FwdModel_fc_perm');

%% Matrix-ize and mean
% Matirx-ize
FwdModel_bold_all = cat(1,FwdModel_bold{:})';
FwdModel_fc_all = cat(3,FwdModel_fc{:});
FwdModel_bold_perm_all = cat(3,FwdModel_bold_perm{:});
FwdModel_fc_perm_all = cat(4,FwdModel_fc_perm{:});

%% plot FC as matrices
meanFwdModel = mean(FwdModel_fc_all,3);
[~,order] = sort(mean(meanFwdModel,2),'ascend');
clim = [-.2 .2];
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

%% Get Perm significance
meanFwdModel_perm = mean(FwdModel_fc_perm_all,4);
meanFwdModel_pctPermBelow = zeros(200,200);
for i=1:200
    for j=1:200
        meanFwdModel_pctPermBelow(i,j) = mean(abs(meanFwdModel(i,j))>abs(meanFwdModel_perm(i,j,:)),3)*100;
    end
end
% threshold
meanFwdModel_thresh = meanFwdModel;
meanFwdModel_thresh(meanFwdModel_pctPermBelow<95) = nan;
figure(723); clf;
PlotFcMatrix(meanFwdModel_thresh(order,order),clim,atlas,nClusters);
title(sprintf('Mean FC Fwd Model (%s-%s) across %d subjects (thresholded)',label1_fc,label0_fc,numel(subjects)))


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
meanMeanFwdModel_perm = mean(meanFwdModel_perm,2);
meanMeanFwdModel_pctPermBelow = zeros(200,1);
for i=1:200
    meanMeanFwdModel_pctPermBelow(i) = mean(abs(meanMeanFwdModel(i))>abs(meanMeanFwdModel_perm(i,:,:)),3)*100;
end

% Get FDR correction
[~,meanMeanFwdModel_q] = mafdr((100-meanMeanFwdModel_pctPermBelow)/100);
meanMeanFwdModel_pctPermBelow_FDR = 100*(1-meanMeanFwdModel_q);


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
meanBoldFwdModel_perm = mean(FwdModel_bold_perm_all,3);
meanBoldFwdModel_pctPermBelow = zeros(200,1);
for i=1:200
    meanBoldFwdModel_pctPermBelow(i) = mean(abs(meanBoldFwdModel(i))>abs(meanBoldFwdModel_perm(i,:)),2)*100;
end

% Get FDR correction
[~,meanBoldFwdModel_q] = mafdr((100-meanBoldFwdModel_pctPermBelow)/100);
meanBoldFwdModel_pctPermBelow_FDR = 100*(1-meanBoldFwdModel_q);

%% Save result for plotting in AFNI
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations
[bigAtlas,Info] = BrikLoad('CraddockAtlas_200Rois_tta+tlrc.BRIK.gz');
cd /data/jangrawdc/PRJ03_SustainedAttention/Results

meanMeanFwdModel_atlas = MapValuesOntoAtlas(bigAtlas,meanMeanFwdModel);
meanMeanFwdModel_atlas(isnan(meanMeanFwdModel_atlas)) = 0;
meanMeanFwdModel_atlas_perm = MapValuesOntoAtlas(bigAtlas,meanMeanFwdModel_pctPermBelow);
meanMeanFwdModel_atlas_perm(isnan(meanMeanFwdModel_atlas_perm)) = 0;
meanMeanFwdModel_atlas_perm_FDR = MapValuesOntoAtlas(bigAtlas,meanMeanFwdModel_pctPermBelow_FDR);
meanMeanFwdModel_atlas_perm_FDR(isnan(meanMeanFwdModel_atlas_perm_FDR)) = 0;
Info.BRICK_TYPES = [3 3];
Info.BRICK_STATS = [min(meanBoldFwdModel(:)), max(meanBoldFwdModel(:)); ...
    min(meanMeanFwdModel_pctPermBelow), max(meanMeanFwdModel_pctPermBelow)];
Info.BRICK_LABS = 'MeanFcFwdModel~PctPermsBelow~PctPermsBelow_FDR';
Opt = struct('Prefix',sprintf('SBJ%02d-%02d_Craddock_%s-%s_FcFwdModels_TTA',subjects(1),subjects(end),label1_fc,label0_fc),'OverWrite','y');
% WriteBrik(meanMeanFwdModel_atlas,Info,Opt);
WriteBrik(cat(4,meanMeanFwdModel_atlas,meanMeanFwdModel_atlas_perm,meanMeanFwdModel_atlas_perm_FDR),Info,Opt);

meanBoldFwdModel_atlas = MapValuesOntoAtlas(bigAtlas,meanBoldFwdModel);
meanBoldFwdModel_atlas(isnan(meanBoldFwdModel_atlas)) = 0;
meanBoldFwdModel_atlas_perm = MapValuesOntoAtlas(bigAtlas,meanBoldFwdModel_pctPermBelow);
meanBoldFwdModel_atlas_perm(isnan(meanBoldFwdModel_atlas_perm)) = 0;
meanBoldFwdModel_atlas_perm_FDR = MapValuesOntoAtlas(bigAtlas,meanBoldFwdModel_pctPermBelow_FDR);
meanBoldFwdModel_atlas_perm_FDR(isnan(meanBoldFwdModel_atlas_perm_FDR)) = 0;

Info.BRICK_TYPES = [3 3];
Info.BRICK_STATS = [min(meanMeanFwdModel(:)), max(meanMeanFwdModel(:)); ...
    min(meanBoldFwdModel_pctPermBelow), max(meanBoldFwdModel_pctPermBelow)];
Info.BRICK_LABS = 'MeanBoldFwdModel~PctPermsBelow~PctPermsBelow_FDR';
Opt = struct('Prefix',sprintf('SBJ%02d-%02d_Craddock_%s-%s_BoldFwdModels_TTA',subjects(1),subjects(end),label1_bold,label0_bold),'OverWrite','y');
WriteBrik(cat(4,meanBoldFwdModel_atlas,meanBoldFwdModel_atlas_perm,meanBoldFwdModel_atlas_perm_FDR),Info,Opt);

%% check dependence
for i=1:numel(subjects)
    foo = mean(FwdModel_fc_all(order,order,i),2);
    linfit = fitlm((1:length(foo))',foo,'linear');
    CI = coefCI(linfit);
    fprintf('SBJ%02d: CI = [%.3g, %.3g]\n',subjects(i),CI(2,:));
end
    
