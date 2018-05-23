% PlotPairwiseIscMatrices.m
%
% Created 5/21/18 by DJ.

%% Set up
roiFile = '3dLME_3Grps_readScoreMedSplit_n42_Automask_clusters+tlrc';
iRoi = 6;
roiName = 'lpSTG';

fprintf('Getting Reading Scores...\n');
[subj_sorted,readScore_sorted] = GetStoryReadingScores();
fprintf('Getting ISC in ROI %d (%s)...\n',iRoi,roiName);
iscInRoi = GetIscInRoi(subj_sorted,roiFile,iRoi);
fprintf('Done!\n');

%% Group files
nSubj = numel(subj_sorted);
isTopHalf = readScore_sorted>=median(readScore_sorted);
[isTopTop,isBotBot,isBotTop] = deal(false(nSubj));
isTopTop(isTopHalf,isTopHalf) = true;
isBotBot(~isTopHalf,~isTopHalf) = true;
isBotTop(~isTopHalf,isTopHalf) = true;
isTopTop = triu(isTopTop);
isBotBot = triu(isBotBot);

%% Plot results

figure(334); clf;
subplot(2,2,1);
imagesc(3*isTopTop + 2*isBotTop + isBotBot);
text(nSubj*.35,nSubj*.15,'Bottom vs. Bottom','HorizontalAlignment','center');
text(nSubj*.75,nSubj*.25,'Bottom vs. Top','HorizontalAlignment','center');
text(nSubj*.85,nSubj*.65,'Top vs. Top','HorizontalAlignment','center');
set(gca,'ydir','normal')
title('Legend');
xlabel('Participant')
ylabel('Participant');
axis('square')

subplot(2,2,2); hold on;
imagesc(iscInRoi);
nBot = sum(isTopHalf);
plot([0,nBot,nBot,0]+0.5,[0,nBot,0,0]+0.5,'b-','LineWidth',2);
plot([nBot,nSubj,nSubj,nBot]+0.5,[nBot,nSubj,nBot,nBot]+0.5,'y-','LineWidth',2);
plot([nBot,nBot,nSubj,nSubj,nBot]+0.5,[0,nBot,nBot,0,0]+0.5,'g-','LineWidth',2);
set(gca,'ydir','normal');
colormap('default');
xlim([0 nSubj]+0.5);
ylim([0 nSubj]+0.5);
colorbar;
axis('square')
title(sprintf('Pairwise ISC in ROI %d (%s)',iRoi,roiName))
set(gca,'xtick',[],'ytick',[]);
xlabel('<--Worse Readers   Better Readers -->');
ylabel('<--Worse Readers   Better Readers -->');

subplot(2,1,2); hold on;
xHist = linspace(min(iscInRoi(:)),max(iscInRoi(:)),20);
nTopTop = hist(iscInRoi(isTopTop),xHist);
nTopBot = hist(iscInRoi(isBotTop),xHist);
nBotBot = hist(iscInRoi(isBotBot),xHist);
plot(xHist,nBotBot,'b');
plot(xHist,nTopBot,'g');
plot(xHist,nTopTop,'y');
PlotVerticalLines(0,'k--');
xlabel(sprintf('Mean Pairwise ISC in ROI %d (%s)',iRoi,roiName));
ylabel('# Participants');
legend('Bottom vs. Top','Bottom vs. Bottom','Top vs. Top');