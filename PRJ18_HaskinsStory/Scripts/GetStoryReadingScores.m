function [readScores, weights,weightNames,IQs,ages] = GetStoryReadingScores(subjects)

% [readScores, weights,weightNames,IQs,ages] = GetStoryReadingScores(subjects)
%
% Created 2/5/19 by DJ.
% Updated 7/8/19 by DJ - added ages output, reordered outputs

%% Set up
info = GetStoryConstants;

% Read behavior file
behFile = [info.PRJDIR '/A182IncludedSubjectBehavior_2019-01-04.xlsx'];
behTable = readtable(behFile);

%% Use all subjects to get first PC
% Append all reading scores
allReadScores = [behTable.TOWREVerified__SWE_SS,behTable.TOWREVerified__PDE_SS,behTable.TOWREVerified__TWRE_SS,...
    behTable.WoodcockJohnsonVerified__BscR_SS, behTable.WoodcockJohnsonVerified__LW_SS, behTable.WoodcockJohnsonVerified__WA_SS];
weightNames = {'TOWRE_SWE_SS','TOWRE_PDE_SS','TOWRE_TWRE_SS','WJ3_BscR_SS','WJ3_LW_SS','WJ3_WA_SS'};
isOkSubj = all(~isnan(allReadScores),2);

% normalize
nSubj = size(allReadScores,1);
meanScores = mean(allReadScores(isOkSubj,:),1);
stdScores = std(allReadScores(isOkSubj,:),[],1);
allReadScores = (allReadScores-repmat(meanScores,nSubj,1))./repmat(stdScores,nSubj,1);
% get SVD
[U,S,V] = svd(allReadScores(isOkSubj,:),0);

% Ensure that higher PC indicates higher scores
if sum(V(:,1))>=0
    weights = V(:,1);
else
    weights = -V(:,1);
end
% Declare reading score as 1st principal component
readScores_allSubj = allReadScores*weights;


%% Reorder
readSubj = behTable.haskinsID;
[readScores,IQs,ages] = deal(nan(size(subjects)));
for i=1:numel(subjects)
    readScores(i) = readScores_allSubj(strcmp(readSubj,subjects{i}));
    IQs(i) = behTable.WASIVerified__Perf_IQ(strcmp(readSubj,subjects{i}));
    ages(i) = behTable.MRIScans__ProfileAge(strcmp(readSubj,subjects{i}));
end

