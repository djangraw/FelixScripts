% PlotRoiTimecourseByReadingScore.m
%
% Created 5/22/18 by DJ.

roiFile = '3dLME_3Grps_readScoreMedSplit_n42_Automask_clusters+tlrc';
iRoi = 6;
roiName = 'rpSTG';

[subj_sorted,readScore_sorted] = GetStoryReadingScores();
tcInRoi = GetTcInRoi(subj_sorted,roiFile,iRoi);

%% Plot
isTop = readScore_sorted>median(readScore_sorted);
meanTc_bot = mean(tcInRoi(:,~isTop),2);
meanTc_top = mean(tcInRoi(:,isTop),2);
figure(562); clf; hold on;
plot([meanTc_bot,meanTc_top]);
title(sprintf('mean timecourse in ROI %d (%s)',iRoi,roiName));

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
iGap = find(diff(iVis)>1);
iVisStart = iVis([1 iGap+1]);
iVisEnd = iVis([iGap, end]);
iVisAll = [iVisStart;iVisEnd;nan(size(iVisStart))];
plot(iVisAll(:),yMax*ones(numel(iVisAll),1),'c-','linewidth',2)

% annotate
PlotHorizontalLines(0,'k');
xlim([0 info.nT]);
legend('bottom half of readers','top half of readers','Auditory blocks','Visual blocks');
xlabel('time (samples)');
ylabel('BOLD (% signal change)');