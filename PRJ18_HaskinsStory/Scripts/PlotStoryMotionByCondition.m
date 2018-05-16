function PlotStoryMotionByCondition(subjects)

% PlotStoryMotionByCondition(subjects)
% 
% Created 5/15/18 by DJ based on PlotSrttMotionByCondition.

motAmp = GetStoryAvgMotion(subjects);
[iAud,iVis,iBase] = GetStoryBlockTiming();

medBaseMot = median(motAmp(iBase,:),1);
medVisMot = median(motAmp(iVis,:),1);
medAudMot = median(motAmp(iAud,:),1);

xHist = linspace(0,0.05,10);
nBase = hist(medBaseMot,xHist);
nVis = hist(medVisMot,xHist);
nAud = hist(medAudMot,xHist);

figure(2); clf;
subplot(2,1,1);
plot(xHist,[nBase;nVis;nAud]');
xlabel('median motion');
ylabel('# subjects');
legend('Baseline','Visual','Auditory');

subplot(2,1,2);
xHistDiff = linspace(-.025,.025,101);
nHistDiff = hist(0.5*(medVisMot+medAudMot)-medBaseMot,xHistDiff);
nSubj = size(motAmp,2);
plot(xHistDiff,cumsum(nHistDiff)/nSubj*100);
title('cumulative histogram')
xlabel('median motion diff (task-baseline)')
ylabel('% subjects');

