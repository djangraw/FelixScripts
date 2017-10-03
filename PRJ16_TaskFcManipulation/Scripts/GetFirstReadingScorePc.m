function [readScore,isOkSubj] = GetFirstReadingScorePc(behTable)

% Get 1st PC of all reading scores
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
% readSubj = behTable.MRI_ID(isOkSubj);
% for i=1:numel(readSubj)
%     readSubj{i} = sprintf('tb%04d',str2double(readSubj{i}));
% end
