function tcInRoi = PlotRoiTimecourseByReadingScore(subj_sorted,readScore_sorted,roiFile,iRoi,roiName)
% tcInRoi = PlotRoiTimecourseByReadingScore(subj_sorted,readScore_sorted,roiFile,iRoi,roiName)
%           PlotRoiTimecourseByReadingScore(tcInRoi,readScore_sorted,roiFile,iRoi,roiName)
%
% Created 5/22/18 by DJ.

info = GetStoryConstants();
% cd(sprintf('%s/IscResults_d2/Group',info.dataDir));
if ~exist('roiFile','var') || isempty(roiFile)
    roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
end
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi = 1;
end
if ~exist('roiName','var') || isempty(roiName)
    roiName = sprintf('roi%d',iRoi);
end
% Accept either tcInRoi or subj_sorted as input
if ismatrix(subj_sorted)
    tcInRoi = subj_sorted;
else
    % [subj_sorted,readScore_sorted] = GetStoryReadingScores();
    tcInRoi = GetTcInRoi(subj_sorted,roiFile,iRoi);
end

%% Plot
[nT,nSubj] = size(tcInRoi);
isTop = readScore_sorted>median(readScore_sorted);
meanTc_bot = nanmean(tcInRoi(:,~isTop),2);
meanTc_top = nanmean(tcInRoi(:,isTop),2);
steTc_bot = nanstd(tcInRoi(:,~isTop),[],2)/sqrt(nSubj);
steTc_top = nanstd(tcInRoi(:,isTop),[],2)/sqrt(nSubj);
figure(562); clf; hold on;
ErrorPatch((1:nT)',meanTc_bot,steTc_bot,'b','b');
ErrorPatch((1:nT)',meanTc_top,steTc_top,'r','r');
title(sprintf('mean timecourse in ROI %d (%s)',iRoi,roiName));
% MakeLegend({'r','b'},{'Good Readers','Poor Readers'},[2 2],[.23 .22]);
% Show task blocks
yLimits = get(gca,'YLim');
yMax = yLimits(2);
[iAud,iVis,iBase] = GetStoryBlockTiming();
% iAud = iAud-6; iVis = iVis-6; % subtract removed TRs
iGap = find(diff(iAud)>1);
iAudStart = iAud([1 iGap+1]);
iAudEnd = iAud([iGap, end]);
iAudAll = [iAudStart;iAudEnd;nan(size(iAudStart))];
plot(iAudAll(:),yMax*ones(numel(iAudAll),1),'m-','linewidth',2)
for i=1:numel(iAudStart)
    text(mean([iAudStart(i),iAudEnd(i)]),yMax*0.9,'Aud','HorizontalAlignment','center');
end

iGap = find(diff(iVis)>1);
iVisStart = iVis([1 iGap+1]);
iVisEnd = iVis([iGap, end]);
iVisAll = [iVisStart;iVisEnd;nan(size(iVisStart))];
plot(iVisAll(:),yMax*ones(numel(iVisAll),1),'c-','linewidth',2)
for i=1:numel(iAudStart)
    text(mean([iVisStart(i),iVisEnd(i)]),yMax*0.9,'Vis','HorizontalAlignment','center');
end

% annotate
PlotHorizontalLines(0,'k');
xlim([0 info.nT]);
% legend('bottom half of readers','top half of readers','Auditory blocks','Visual blocks');
xlabel('time (samples)');
ylabel('BOLD (% signal change)');