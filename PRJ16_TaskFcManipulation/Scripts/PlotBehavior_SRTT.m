function PlotBehavior_SRTT(behTable)

% PlotReadingVsRtScores_SRTT(behTable)
%
% Created 8/28/17 by DJ.


%% Get reading scores
figure(62); clf;
lm = fitlm(behTable,'PredictorVars',{'TOWRE_SWE_SS'},'ResponseVar','TOWRE_PDE_SS');
subplot(2,2,1);
lm.plot();
[r,p] = corr(behTable.TOWRE_SWE_SS,behTable.TOWRE_PDE_SS,'rows','complete');
title(sprintf('Timed  Fluency vs. Timed Decoding:\n r=%.3g, p=%.3g',r,p));

lm = fitlm(behTable,'PredictorVars',{'WJ3_LW_SS'},'ResponseVar','WJ3_WA_SS');
subplot(2,2,2);
lm.plot();
[r,p] = corr(behTable.WJ3_LW_SS,behTable.WJ3_WA_SS,'rows','complete');
title(sprintf('Untimed  Fluency vs. Untimed Decoding:\n r=%.3g, p=%.3g',r,p));

lm = fitlm(behTable,'PredictorVars',{'TOWRE_SWE_SS'},'ResponseVar','WJ3_LW_SS');
subplot(2,2,3);
lm.plot();
[r,p] = corr(behTable.TOWRE_SWE_SS,behTable.WJ3_LW_SS,'rows','complete');
title(sprintf('Timed  Fluency vs. Untimed Fluency:\n r=%.3g, p=%.3g',r,p));

lm = fitlm(behTable,'PredictorVars',{'TOWRE_PDE_SS'},'ResponseVar','WJ3_WA_SS');
subplot(2,2,4);
lm.plot();
[r,p] = corr(behTable.TOWRE_PDE_SS,behTable.WJ3_WA_SS,'rows','complete');
title(sprintf('Timed  Decoding vs. Untimed Decoding:\n r=%.3g, p=%.3g',r,p));


%% Get 1st PC
% Append all reading scores
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


%% Use IQ to predict reading score

figure(63); clf;
lm = fitlm(behTable,'PredictorVars',{'WASI_PIQ'},'ResponseVar','RT_Final_UnsMinusStr');
subplot(1,2,1);
lm.plot();
[r,p] = corr(behTable.WASI_PIQ,behTable.RT_Final_UnsMinusStr,'rows','complete');
title(sprintf('IQ vs. RT diff in final block (Uns-Str):\n r=%.3g, p=%.3g',r,p));

lm = fitlm(behTable.WASI_PIQ,readScore,'VarNames',{'IQ','readScore'});
subplot(1,2,2);
lm.plot();
[r,p] = corr(behTable.WASI_PIQ,readScore,'rows','complete');
title(sprintf('IQ vs. 1st PC of reading scores:\n r=%.3g, p=%.3g',r,p));

%% Plot RT in first and last runs

iR1uns = find(~cellfun('isempty',regexp(behTable.Properties.VariableNames,'RT_R1B[1-9]_Uns')));
iR1str = find(~cellfun('isempty',regexp(behTable.Properties.VariableNames,'RT_R1B[1-9]_Str')));
iR3uns = find(~cellfun('isempty',regexp(behTable.Properties.VariableNames,'RT_R3B[1-9]_Uns')));
iR3str = find(~cellfun('isempty',regexp(behTable.Properties.VariableNames,'RT_R3B[1-9]_Str')));

RT_R1_uns = mean(behTable{:,iR1uns},2);
RT_R1_str = mean(behTable{:,iR1str},2);
RT_R3_uns = mean(behTable{:,iR3uns},2);
RT_R3_str = mean(behTable{:,iR3str},2);
rtCatAll = [RT_R1_uns, RT_R1_str, RT_R3_uns, RT_R3_str];

rtCatMean = reshape(mean(rtCatAll(~any(isnan(rtCatAll),2),:))', [2 2]);
rtCatStd = reshape(std(rtCatAll(~any(isnan(rtCatAll),2),:))',[2 2]);

figure(64); clf; hold on;
% hBar = bar(rtCatMean');
% xBar = GetBarPositions(hBar);
% errorbar(xBar',rtCatMean',rtCatStd,'k-');
errorbar([1 2; 1 2]',rtCatMean',rtCatStd,'.-');
legend('unstructured','structured')
xlim([0.5 2.5]);
xlabel('run')
ylabel('mean RT');
set(gca,'xtick',[1 2],'xticklabel',{'First','Last'});

