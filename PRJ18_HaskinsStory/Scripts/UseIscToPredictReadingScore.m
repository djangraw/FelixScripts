% UseIscToPredictReadingScore.m
%
% Created 5/22/18 by DJ.

roiFile = '3dLME_3Grps_readScoreMedSplit_n42_Automask_clusters+tlrc';
iRoi = 6;
roiName = 'rpSTG';

fprintf('Getting Reading Scores...\n');
[subj_sorted,readScore_sorted] = GetStoryReadingScores();
fprintf('Getting ISC in ROI %d (%s)...\n',iRoi,roiName);
iscInRoi = GetIscInRoi(subj_sorted,roiFile,iRoi);
fprintf('Done!\n');

%% Group
nSubj = numel(subj_sorted);
isTopHalf = readScore_sorted>=median(readScore_sorted);

%% Predict
iscInRoi = UpperTriToSymmetric(iscInRoi,nan);
meanIsc = nanmean(iscInRoi);
meanIscWithTopHalf = nanmean(iscInRoi(isTopHalf,:));
meanIscWithBotHalf = nanmean(iscInRoi(~isTopHalf,:));
[r,p] = corr(readScore_sorted', meanIsc');

figure(653); clf; hold on;
lm = fitlm(readScore_sorted,meanIsc,'Linear','VarNames',{'readScore','meanIscWithAllSubj'}); % least squares
lm.plot; % plot line & CI
% plot median split
plot(readScore_sorted(isTopHalf),meanIsc(isTopHalf),'o');

% Display p values
fprintf('---Linear fit---\n');
fprintf('r = %.3g, p = %.3g\n',r,p);
% Display AUCs
fprintf('---AUCs---\n');
AUC = rocarea(meanIsc,isTopHalf);
fprintf('Mean ISC in %s with all subjects: AUC = %.3f\n',roiName,AUC);
AUC = rocarea(meanIscWithTopHalf,isTopHalf);
fprintf('Mean ISC in %s with top 1/2 of subjects: AUC = %.3f\n',roiName,AUC);
AUC = rocarea(meanIscWithBotHalf,isTopHalf);
fprintf('Mean ISC in %s with bottom 1/2 of subjects: AUC = %.3f\n',roiName,AUC);
AUC = rocarea(meanIscWithTopHalf - meanIscWithBotHalf,isTopHalf);
fprintf('Mean ISC in %s with top - bottom 1/2 of subjects: AUC = %.3f\n',roiName,AUC);