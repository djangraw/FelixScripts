%% SubsampleToMatchGroupIqs.m
% Created 7/11/19 by DJ.

isTopIq = IQs>nanmedian(IQs);
isTopRead = readScores>nanmedian(readScores);

nRand = 5000;

coef = nan(1,nRand);
pVal = nan(1,nRand);
iKeep_all = cell(1,nRand);
tic();
for i=1:nRand

    iKeep = cell(1,4);
    iThis = find(isTopIq & isTopRead & ~isnan(IQs));
    iKeep{1} = randsample(iThis,10);
    iThis = find(isTopIq & ~isTopRead & ~isnan(IQs));
    iKeep{2} = randsample(iThis,10);
    iThis = find(~isTopIq & isTopRead & ~isnan(IQs));
    iKeep{3} = randsample(iThis,10);
    iThis = find(~isTopIq & ~isTopRead & ~isnan(IQs));
    iKeep{4} = randsample(iThis,10);
    iKeep_all{i} = [iKeep{:}];

    IQs_ok = IQs(iKeep_all{i});
    readScores_ok = readScores(iKeep_all{i});

    lm = fitlm(readScores_ok,IQs_ok);
    coef(i) = lm.Coefficients.Estimate(2);
    pVal(i) = lm.Coefficients.pValue(2);
end
fprintf('Done! Took %.1f seconds.\n',toc());
%%
[~,iBest] = min(coef);
fprintf('Best selection: coef=%.3g, p=%.3g\n',coef(iBest),pVal(iBest));
IQs_ok = IQs(iKeep_all{iBest});
readScores_ok = readScores(iKeep_all{iBest});

figure(634); clf;
subplot(1,2,1);
cla; hold on;
lm = fitlm(readScores,IQs);
plot(lm);
xlabel('reading score (1st PC)')
ylabel('IQ')
% plot lines
PlotVerticalLines(nanmedian(readScores),'k--');
PlotHorizontalLines(nanmedian(IQs),'k--');
title(sprintf('Haskins Story Data, n=%d Subjects',numel(readScores)))
legend('subject','fit','95% CI','','median')

subplot(1,2,2);
cla; hold on;
lm = fitlm(readScores_ok,IQs_ok);
plot(lm);
xlabel('reading score (1st PC)')
ylabel('IQ')
% link axes to make median lines plot fully
linkaxes(GetSubplots(gcf),'xy');
% plot lines
PlotVerticalLines(nanmedian(readScores_ok),'k--');
PlotHorizontalLines(nanmedian(IQs_ok),'k--');
title(sprintf('Haskins Story Data, n=%d Subjects',numel(readScores_ok)))
legend('subject','fit','95% CI','','median')





%% Get new readScore & IQ groupings
subjects = string(info.okReadSubj(iKeep_all{iBest}));
cutoff = nanmedian(readScores_ok);
subj_topRead = subjects(readScores_ok>cutoff);
subj_botRead = subjects(readScores_ok<=cutoff);

cutoff = nanmedian(IQs_ok);
subj_topIq = subjects(IQs_ok>cutoff);
subj_botIq = subjects(IQs_ok<=cutoff);


%% Print for R script
% display results for easy input into R script

fprintf('===FOR READSCORE TWO-GROUP R SCRIPT:===\n');
fprintf('# list labels for Group 1 - readScore <= MEDIAN(readScore)\n')
fprintf('G1Subj <- c(''%s'')\n',join(subj_botRead,''','''));
fprintf('# list labels for Group 2 - readScore > MEDIAN(readScore)\n')
fprintf('G2Subj <- c(''%s'')\n',join(subj_topRead,''','''));

fprintf('===FOR IQ TWO-GROUP R SCRIPT:===\n');
fprintf('# list labels for Group 1 - IQ <= MEDIAN(IQ)\n')
fprintf('G1Subj <- c(''%s'')\n',join(subj_botIq,''','''));
fprintf('# list labels for Group 2 - IQ > MEDIAN(IQ)\n')
fprintf('G2Subj <- c(''%s'')\n',join(subj_topIq,''','''));
