% CheckCogStatesTs.m
%
% Created 11/23/16 by DJ.

%% Load timecourses
subjects = [6:13,16:27];
demeanTs = false; % DO NOT DEMEAN!
separateTasks = true;
nSubj = numel(subjects);
% Get FC
[FCtmp,~,TStmp] = GetFcForCogStateData(subjects(1),separateTasks,demeanTs);
% FC = nan([size(FCtmp),nSubj]);
TS = nan([size(TStmp),nSubj]);
% winInfo_cell = cell(1,nSubj);
for i=1:nSubj
    [~,~,TS(:,:,i)] = GetFcForCogStateData(subjects(i),separateTasks,demeanTs);
end

%% Remove any bad ROIs

isBadRoi = any(all(isnan(TS),1),3);
TS_nanBadRois = TS;
TS_nanBadRois(:,isBadRoi,:) = NaN;

%% Get mean across TS, find each ROI's corr with mean
TS_meanRoi = nanmean(TS_nanBadRois,2);

roiCorr = nan(size(TS,2),nSubj);
for i=1:nSubj
    roiCorr(:,i) = corr(TS_nanBadRois(:,:,i),TS_meanRoi(:,:,i));   
end
% reorder
meanRoiCorr = mean(roiCorr,2);
[meanRoiCorr_ordered, order] = sort(meanRoiCorr,'descend');
figure(235); clf;
subplot(2,1,1);
hold on;
plot(roiCorr(order,:));
plot(meanRoiCorr_ordered,'k','linewidth',2);
xlabel('ROI (sorted)')
ylabel('correlation with global mean TS')
title('Subject-wise ROI correlation with global mean timeseries');

isPosEdge = (rosePos - roseNeg)>0;
isNegEdge = nanmean(rosePos - roseNeg)<0;
rosePos_ordered = rosePos(order,order);
roseNeg_ordered = roseNeg(order,order);
subplot(2,2,3);
PlotFcMatrix(rosePos_ordered-roseNeg_ordered,[-1 1],shenAtlas,0,true,shenLabelColors,false);
subplot(2,2,4);
shenAtlas_ordered = shenAtlas;
for i=1:numel(order)
    shenAtlas_ordered(shenAtlas==order(i)) = i;
    
end
shenLabels_ordered = shenLabels(order);
PlotFcMatrix(rosePos_ordered-roseNeg_ordered,[-1 1]*.1,shenAtlas_ordered,shenLabels_ordered,true,shenLabelColors,false);


