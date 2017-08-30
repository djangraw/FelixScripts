function PlotReadingVsRtScores_SRTT(behTable)

% PlotReadingVsRtScores_SRTT(behTable)
%
% Created 8/28/17 by DJ.


%% Get reading scores
% readScore = behTable.TOWRE_TWRE_SS;
allReadScores = [behTable.TOWRE_SWE_SS,behTable.TOWRE_PDE_SS,behTable.TOWRE_TWRE_SS,...
    behTable.WJ3_BscR_SS, behTable.WJ3_LW_SS, behTable.WJ3_WA_SS, behTable.WASI_PIQ];
isOkSubj = all(~isnan(allReadScores),2);

% normalize
nSubj = size(allReadScores,1);
meanScores = mean(allReadScores(isOkSubj,:),1);
stdScores = std(allReadScores(isOkSubj,:),[],1);
allReadScores = (allReadScores-repmat(meanScores,nSubj,1))./repmat(stdScores,nSubj,1);
% get SVD
[U,S,V] = svd(allReadScores(isOkSubj,:),0);

% Declare reading score as 1st principal component
readScore = allReadScores*V(:,1);

%% Get RT scores
rtScore = behTable.RT_Final_UnsMinusStr;
% rtScore = mean([behTable.RT_R2B1_Uns,behTable.RT_R2B2_Uns,behTable.RT_R2B3_Uns,behTable.RT_R2B4_Uns],2) - ...
%     mean([behTable.RT_R2B1_Str,behTable.RT_R2B2_Str,behTable.RT_R2B3_Str],2);

% Get ok subjects
isOkSubj = ~isnan(readScore) & ~isnan(rtScore);

% Print
[r,p] = corr(readScore(isOkSubj),rtScore(isOkSubj));
fprintf('Reading Scores (1st PC) vs. Final Block RT diff (Uns-Str): r=%.3g, p=%.3g\n',r,p);

% Plot
lm = fitlm(readScore(isOkSubj),rtScore(isOkSubj),'VarNames',{'ReadingScore','RtDiff'});
lm.plot();
title(sprintf('Reading Scores (1st PC) vs. Final Block RT diff (Uns-Str):\n r=%.3g, p=%.3g\n',r,p));

