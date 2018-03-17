% PlotSrttMotionByCondition.m
% 
% Created 3/16/18 by DJ.

nT = 450;
[iStruct,iUnstruct,iBase] = GetSrttBlockTiming();
iCond = zeros(1,nT);
iCond(iUnstruct)=1;
iCond(iStruct)=2;

medBaseMot = median(motAmp(iBase,:),1);
medUnsMot = median(motAmp(iUnstruct,:),1);
medStrMot = median(motAmp(iStruct,:),1);

xHist = linspace(0,0.05,10);
nBase = hist(medBaseMot,xHist);
nUns = hist(medUnsMot,xHist);
nStr = hist(medStrMot,xHist);

figure(2); clf;
subplot(2,1,1);
plot(xHist,[nBase;nUns;nStr]');
xlabel('median motion');
ylabel('# subjects');
legend('Baseline','Unstructured','Structured');

subplot(2,1,2);
xHistDiff = linspace(-.025,.025,101);
nHistDiff = hist(medBaseMot-0.5*(medUnsMot+medStrMot),xHistDiff);
plot(xHistDiff,cumsum(nHistDiff)/nSubj*100);
title('cumulative histogram')
xlabel('median motion diff (task-baseline)')
ylabel('% subjects');

