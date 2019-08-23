function PlotReadScoreVsConfounds()

% PlotReadScoreVsConfounds()
% Plots each participant's composite reading score against their IQ, age,
% handedness, and avg. motion. Includes a fit line and significance test.
%
% Created 8/22/19 by DJ.

info = GetStoryConstants();

behTable = readtable(info.behFile);

behTable.readScores = GetStoryReadingScores(behTable.haskinsID);
behTable.subjMotion = GetStorySubjectMotion(behTable.haskinsID)';

behTable_cropped = behTable(ismember(behTable.haskinsID,info.okReadSubj),:);

%% Plot results

figure(823); clf;
set(gcf,'Position',[285  195 1000 800]);
subplot(2,2,1);
lm = fitlm(behTable_cropped.readScores,behTable_cropped.WASIVerified__Perf_IQ);
plot(lm);
xlabel('composite reading score')
ylabel('IQ')
title(sprintf('readScore vs. IQ\np=%.3g',lm.Coefficients.pValue(2)))

subplot(2,2,2);
lm = fitlm(behTable_cropped.readScores,behTable_cropped.MRIScans__ProfileAge);
plot(lm);
xlabel('composite reading score')
ylabel('age (years)')
title(sprintf('readScore vs. age\np=%.3g',lm.Coefficients.pValue(2)))

subplot(2,2,3);
lm = fitlm(behTable_cropped.readScores,behTable_cropped.EdinburghHandedness__LiQ);
plot(lm);
xlabel('composite reading score')
ylabel(sprintf('Edinburgh Handedness Score\n<--left  | right-->'))
title(sprintf('readScore vs. handedness\np=%.3g',lm.Coefficients.pValue(2)))

subplot(2,2,4);
lm = fitlm(behTable_cropped.readScores,behTable_cropped.subjMotion);
plot(lm);
xlabel('composite reading score')
ylabel(sprintf('subject motion\n(mean framewise displacement)'))
title(sprintf('readScore vs. motion\np=%.3g',lm.Coefficients.pValue(2)))

saveas(gcf,sprintf('%s/Results/readScoreVsConfounds.eps',info.PRJDIR),'epsc')

