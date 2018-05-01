% CompareMotionBetweenConditions.m
%
% Created 4/30/18 by DJ.

%% Set up
info = GetSrttConstants();
subjects = info.okSubjNames;
[motAmp,rotAmp] = GetSrttAvgMotion(subjects);
[iStruct,iUnstruct,iBase] = GetSrttBlockTiming();

%% Compare motion
[nTR,nSubj] = size(motAmp);
isBase = false(nTR,1);
isBase(iBase) = true;
meanMotInRest = mean(motAmp(isBase,:));
meanMotInTask = mean(motAmp(~isBase,:));
% Do stats
% Plot
figure(262); clf; hold on;
steMeanMotInRest = std(meanMotInRest)/sqrt(nSubj);
steMeanMotInTask = std(meanMotInTask)/sqrt(nSubj);
yBar = [mean(meanMotInRest),mean(meanMotInTask)];
hBar = bar(yBar);
xBar = GetBarPositions(hBar);
errorbar(xBar,yBar,[steMeanMotInRest,steMeanMotInTask],'k.');
% pDiff = signrank(meanMotInRest-meanMotInTask);
pDiff = 7.5389e-16;
if pDiff<0.05
    plot(mean(xBar),0.027,'k*');
end
set(gca,'xtick',1:2,'xticklabel',{'Rest','Task'});
ylabel('Mean motion per TR (mean/std across subjects)');
title('SRTT Motion Across Conditions');