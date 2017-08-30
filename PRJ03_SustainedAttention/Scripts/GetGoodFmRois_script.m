% GetGoodFmRois_script.m
%
% Created 3/16/16 by DJ.

% Set up
cd /spin1/users/jangrawdc/PRJ03_SustainedAttention/Results
load('SBJ09-16_FwdModels_NOTdemeaned_2016-03-01.mat');
atlas = BrikLoad('craddock_2011_parcellations/CraddockAtlas_200Rois_tta+tlrc.BRIK');

% Get Mag FMs
FwdModel_bold_all = cat(1,FwdModel_bold{:});
meanFwdModel_bold = mean(FwdModel_bold_all,1);
[~,order] = sort(meanFwdModel_bold,'ascend');

for i=1:15
    fprintf('ROI %d: %g\n',order(i),meanFwdModel_bold(order(i)));
end

%% show atlas regions
iRegion = 66;
atlasR = atlas/(nanmax(atlas(:))*2);
% Create green overlay  
atlasG = atlasR;
atlasG(atlas==iRegion) = 1;
% Create blue overlay
atlasB = atlasR;    
% Get position
roiPos = GetAtlasRoiPositions(atlas);
% Plot result
GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iRegion,:)));

%% Plot epoch timecourses for individual regions
% Go to GetBoldEpochs_scripts

%% Get FC FMs
FwdModel_fc_3d = cat(3,FwdModel_fc{:});
% Turn into vector
nROIs = size(FwdModel_fc_3d,1);
nPairs = nROIs*(nROIs-1)/2;
[FwdModel_fc_all,i_fc_all,j_fc_all] = deal(zeros(size(FwdModel_fc_3d,3),nPairs));
iPair = 0;
for i=1:nROIs
    for j=i+1:nROIs
        iPair = iPair+1;
        FwdModel_fc_all(:,iPair) = squeeze(FwdModel_fc_3d(i,j,:));
        i_fc_all(iPair) = i;
        j_fc_all(iPair) = j;
    end
end

meanFwdModel_fc = mean(FwdModel_fc_all,1);
[~,order] = sort(abs(meanFwdModel_fc),'descend');

for i=1:15
    fprintf('ROI pair (%d,%d): %g\n',i_fc_all(order(i)),j_fc_all(order(i)),meanFwdModel_fc(order(i)));
end

%% Display ROI pair
% iRoi = 5; jRoi = 193;
% iRoi = 22; jRoi = 56;
% iRoi = 93; jRoi = 141;
iROI = 67; jROI = 77;
% Create atlas for vis
atlasR = atlas/(nROIs*2);
% Create green overlay  
atlasG = atlasR;
atlasG(atlas==iROI) = 1;
% Create blue overlay
atlasB = atlasR;
atlasB(atlas==jROI) = 1;   
% Get position
roiPos = GetAtlasRoiPositions(atlas);
% Plot result
GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iROI,:)));

%% Get FM for each subject
figure(827); clf;
iROI = 67; jROI = 77;
bar(squeeze(FwdModel_fc_3d(iROI,jROI,:)));
subjects = 9:16;
legendstr = cell(1,numel(subjects));
for i=1:numel(subjects)
    legendstr{i}=sprintf('SBJ%02d',subjects(i));
end
set(gca,'xtick',1:numel(subjects),'xticklabel',legendstr);
xlabel('subject')
ylabel('Fwd Model')
title(sprintf('ignoredSpeech - attendedSpeech Fwd Models for ROI pair (%d,%d)',iROI,jROI));