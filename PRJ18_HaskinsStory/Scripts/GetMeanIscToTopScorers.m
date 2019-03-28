function meanIscToTop = GetMeanIscToTopScorers(subjects,scores)

% meanIscToTop = GetMeanIscToTopScorers(subjects,scores)
%
% Created 3/27/19 by DJ.

info = GetStoryConstants();

nSubj = numel(subjects);
meanIscToTop = cell(1,nSubj);
for i=1:nSubj
    subj = subjects(i);
    otherSubj = subjects([1:i-1, i+1:end]);
    otherScores = scores([1:i-1, i+1:end]);
    isTop = otherScores>median(otherScores);
    topSubj = otherSubj(isTop);
    topBricks = cell(1,numel(topSubj));
    for j=1:numel(topSubj)
        iscFile = sprintf('%s/IscResults/Pairwise/ISC_%s_%s_story+tlrc.HEAD',info.dataDir,subj,topSubj(j));
        topBricks{j} = BrikLoad(iscFile);
    end
    topBricks = cat(4,topBricks{:});
    meanIscToTop{i} = mean(topBricks,4);
end
meanIscToTop = cat(4,meanIscToTop);
