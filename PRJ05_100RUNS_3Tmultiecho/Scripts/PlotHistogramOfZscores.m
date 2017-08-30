function PlotHistogramOfZscores(subject)

% Created 10/14/15 by DJ.
% Updated 3/15/16 by DJ - added OptCom to cumulative histos

Opt = struct('Frames',2);
switch subject
    case 'SBJ01'
        [err,V1,Info1,errMsg] = BrikLoad('SBJ01_Echo2_ISC_16files+orig.BRIK',Opt);
        [err,V2,Info2,errMsg] = BrikLoad('SBJ01_MEICA_ISC_16files+orig.BRIK',Opt);
        [err,V3,Info3,errMsg] = BrikLoad('SBJ01_OptCom_ISC_16files+orig.BRIK',Opt);
        [err,mask,InfoM,errMsg] = BrikLoad('SBJ01_FullBrain_EPIRes+orig.BRIK');
        figure(601);
        set(gcf,'Position',[213   558   560   420]);
    case 'SBJ02'
        [err,V1,Info1,errMsg] = BrikLoad('SBJ02_Echo2_ISC_17files+orig.BRIK',Opt);
        [err,V2,Info2,errMsg] = BrikLoad('SBJ02_MeicaDenoised_ISC_17files+orig.BRIK',Opt);
        [err,V3,Info3,errMsg] = BrikLoad('SBJ02_OptCom_ISC_17files+orig.BRIK',Opt);
        [err,mask,InfoM,errMsg] = BrikLoad('SBJ02_FullBrain_EPIRes+orig.BRIK');
        figure(602);
        set(gcf,'Position',[786   553   560   420]);
end

clf;
xHist = linspace(-3,8.1,100);
% isInBrain = mask~=0;
isInBrain = V1~=0 & V2~=0;
n1 = hist(V1(isInBrain),xHist);
n2 = hist(V2(isInBrain),xHist);
n3 = hist(V3(isInBrain),xHist);
nVoxels = sum(isInBrain(:));
% pctAbove = (1 - cumsum([n1;n2]',1)/nVoxels)*100;
pctAbove = (1 - cumsum([n1;n3;n2]',1)/nVoxels)*100;
xhold on;
plot(xHist,pctAbove);
PlotVerticalLines(norminv(0.95),'g--'); %one-tailed t-test
PlotVerticalLines(0,'k-')
grid on
xlim([-4 8])
xlabel('Z score')
ylabel('% voxels above Z')
title(subject)
% legend('Echo2','MEICA','p<0.05','Location','NorthEast')
legend('Echo2','OptCom','MEICA','p<0.05','Location','NorthEast')

%%
switch subject
    case 'SBJ01'
        figure(603);
    case 'SBJ02'
        figure(604);
end
[~,h] = Plot2DHist([V1(isInBrain),V2(isInBrain)],xHist,xHist);
set(h(1),'clim',[0 0.2]);
set(h(2),'ylim',[0 4]);
set(h(3),'xlim',[0 4]);
axes(h(1)); hold('on'); title('Z scores of all voxels in brain')
plot(h(1),xHist,xHist,'r--');
plot(h(1),xHist,xHist*0,'k');
plot(h(1),xHist*0,xHist,'k');
plot(h(1), [min(xHist), max(xHist)], norminv(0.95)*[1 1], 'g');
plot(h(1), norminv(0.95)*[1 1], [min(xHist), max(xHist)], 'g');
axes(h(2)); xlabel('Echo2');
plot(h(2),norminv(0.95)*[1 1],get(h(2),'ylim'),'g');
axes(h(3)); ylabel('MEICA');
plot(h(3),get(h(3),'xlim'),norminv(0.95)*[1 1],'g');
set(h([1 3]),'ydir','normal');

