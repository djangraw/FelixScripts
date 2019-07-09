function PlotGroupingsByAgeAndIq()
% PlotGroupingsByAgeAndIq()
%
% Show the relationships between age, IQ, and reading score, and how the 
% groupings change between these 3 measures.
%
% Created 7/8/19 by DJ.

info = GetStoryConstants();

[readScores, weights,weightNames,IQs,ages] = GetStoryReadingScores(info.okReadSubj);


%% Plot

figure(623);
set(gcf,'Position',[198 661 1520 403]);

subplot(1,3,1); cla; hold on;
lm = fitlm(readScores,ages);
plot(lm);
xlabel('reading score (1st PC)')
ylabel('age (years)')
% plot lines
PlotVerticalLines(nanmedian(readScores),'k--');
PlotHorizontalLines(nanmedian(ages),'k--');
title('')
legend('subject','fit','95% CI','','median')

subplot(1,3,2); cla; hold on;
lm = fitlm(readScores,IQs);
plot(lm);
xlabel('reading score (1st PC)')
ylabel('IQ')
% plot lines
PlotVerticalLines(nanmedian(readScores),'k--');
PlotHorizontalLines(nanmedian(IQs),'k--');
title(sprintf('Haskins Story Data, n=%d Subjects',numel(readScores)))
legend('subject','fit','95% CI','','median')

subplot(1,3,3); cla; hold on;
lm = fitlm(ages,IQs);
plot(lm);
xlabel('age (years)')
ylabel('IQ')
% plot lines
PlotVerticalLines(nanmedian(ages),'k--');
PlotHorizontalLines(nanmedian(IQs),'k--');
title('')
legend('subject','fit','95% CI','','median')

% Save figure
saveas(gcf,sprintf('%s/Results/BehaviorCorr.png',info.PRJDIR));
