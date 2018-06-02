% UseIscToPredictReadingScore.m
%
% Created 5/22/18 by DJ.

roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
iRoi = 4;
roiName = roiNames{iRoi};

% fprintf('Getting Reading Scores...\n');
% [subj_sorted,readScore_sorted] = GetStoryReadingScores();
% fprintf('Getting ISC in ROI %d (%s)...\n',iRoi,roiName);
% iscInRoi = GetIscInRoi(subj_sorted,roiFile,iRoi);
% fprintf('Done!\n');

%% Group
nSubj = numel(subj_sorted);
isTopHalf = readScore_sorted>=median(readScore_sorted);

%% Predict
iRoi = 4;
iscInRoi = UpperTriToSymmetric(iscInRoi,nan);
meanIsc = nanmean(iscInRoi);
meanIscWithTopHalf = nanmean(iscInRoi(isTopHalf,:));
meanIscWithBotHalf = nanmean(iscInRoi(~isTopHalf,:));
[r,p] = corr(readScore_sorted', meanIsc');
[r_top,p_top] = corr(readScore_sorted', meanIscWithTopHalf');
[r_bot,p_bot] = corr(readScore_sorted', meanIscWithBotHalf');
[r_diff,p_diff] = corr(readScore_sorted', meanIscWithTopHalf'-meanIscWithBotHalf');

figure(653); clf; hold on;
meanIscDiff = meanIscWithTopHalf-meanIscWithBotHalf;
lm = fitlm(readScore_sorted,meanIscDiff,'Linear','VarNames',{'readScore','MeanIscInRoi'}); % least squares
lm.plot; % plot line & CI
% plot median split
plot(readScore_sorted(isTopHalf),meanIscDiff(isTopHalf),'o');

% Display p values
fprintf('---Linear fit---\n');
fprintf('Mean ISC in %s with all subjects: r = %.3g, p = %.3g\n',roiName,r,p);
fprintf('Mean ISC in %s with top 1/2 of subjects: r = %.3g, p = %.3g\n',roiName,r_top,p_top);
fprintf('Mean ISC in %s with bottom 1/2 of subjects: r = %.3g, p = %.3g\n',roiName,r_bot,p_bot);
fprintf('ean ISC in %s with top - bottom 1/2 of subjects: r = %.3g, p = %.3g\n',roiName,r_diff,p_diff);
% Display AUCs
fprintf('---AUCs---\n');
AUC = rocarea(meanIsc,isTopHalf);
fprintf('Mean ISC in %s with all subjects: AUC = %.3f\n',roiName,AUC);
AUC = rocarea(meanIscWithTopHalf,isTopHalf);
fprintf('Mean ISC in %s with top 1/2 of subjects: AUC = %.3f\n',roiName,AUC);
AUC = rocarea(meanIscWithBotHalf,isTopHalf);
fprintf('Mean ISC in %s with bottom 1/2 of subjects: AUC = %.3f\n',roiName,AUC);
AUC = rocarea(meanIscDiff,isTopHalf);
fprintf('Mean ISC in %s with top - bottom 1/2 of subjects: AUC = %.3f\n',roiName,AUC);