% TEMP_CompareFirstAndLastIterWeights
%
% Created 9/25/12 by DJ.

rlP = resplockedPrior;
rlX = resplockedX.*repmat(rlP',1,60);
rlX(sum(rlX,2)==0,:) = [];
rlT = repmat(resplockedTimes,1,71);
rlT(ismember(resplockedX,stimlockedX,'rows'))
rlT(rlP~=0)

%%
jitterrange = [-1 1]; jlrWinOffset = 191;
% jitterrange = [-323 323]; jlrWinOffset = -400;
foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d',subject,jitterrange(1),jitterrange(2));
JLR = load([foldername '/results_10fold']);
JLP = load([foldername '/params_10fold']);


%%
fwdModel = mean(cat(3,JLR.fwdmodels{:}),3);
% [post,~,postTimes,jitter] = GetFinalPosteriors_gaussian(foldername,'10fold',subject);
% avgPost = mean(cat(3,post{:}),3);
postTimes = (1000/JLP.ALLEEG(1).srate*(jitterrange(1):jitterrange(2)));
vFirstIter = mean(cat(3,JLR.vFirstIter{:}),3);
vout = mean(cat(3,JLR.vout{:}),3);

% v00 = vFirstIter;
% v01 = vout;
% v10 = vFirstIter;
% v11 = vout;

%% 
figure(8); clf;
subplot(3,2,1);
topoplot(v00(1:end-1),JLP.ALLEEG(1).chanlocs);
title(sprintf('Not Demeaned\n First Iteration Weights'));
colorbar
subplot(3,2,2);
topoplot(v01(1:end-1),JLP.ALLEEG(1).chanlocs);
title(sprintf('Not Demeaned\n Final Weights'));
colorbar
% MakeFigureTitle('Stimulus Locked');
%
subplot(3,2,3);
topoplot(vFirstIter(1:end-1),JLP.ALLEEG(1).chanlocs);
title(sprintf('Demeaned\n First Iteration Weights'));
colorbar
subplot(3,2,4);
topoplot(vout(1:end-1),JLP.ALLEEG(1).chanlocs);
title(sprintf('Demeaned\n Final Weights'));
colorbar
% MakeFigureTitle('Response Locked');
%
subplot(3,2,5);
topoplot(vFirstIter(1:end-1)-v00(1:end-1),JLP.ALLEEG(1).chanlocs);
title(sprintf('Demeaned - Not\n First Iteration Weights'));
colorbar
subplot(3,2,6);
topoplot(vout(1:end-1)-v01(1:end-1),JLP.ALLEEG(1).chanlocs);
title(sprintf('Demeaned - Not\n Final Weights'));
colorbar
% MakeFigureTitle('Resp-Stimulus Locked');