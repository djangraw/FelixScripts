% SaveMeanTimecourses_TopBot.m
%
% Created 4/11/19 by DJ.

constants = GetStoryConstants();
[readScores, IQs,weights,weightNames] = GetStoryReadingScores(constants.okReadSubj);
[readScore_sorted,order] = sort(readScores,'ascend');
subj_sorted = constants.okReadSubj(order);

nSubj = numel(subj_sorted);
isTop = readScore_sorted>median(readScore_sorted);
[meanTopTs,meanBotTs] = deal(0);
for i=1:numel(subj_sorted)
    fprintf('Loading timecourse %d/%d...\n',i,numel(subj_sorted));
    tsFile = sprintf('%s/%s/%s.story/errts.%s.fanaticor+tlrc',constants.dataDir,subj_sorted{i},subj_sorted{i},subj_sorted{i});
    [ts,Info] = BrikLoad(tsFile);
    if isTop(i)
        meanTopTs = meanTopTs + ts;
    else
        meanBotTs = meanBotTs + ts;
    end
end
meanTopTs = meanTopTs/sum(isTop);
meanBotTs = meanBotTs/sum(~isTop);

%% Save results
filename = sprintf('%s/MeanErrtsFanaticor_top',constants.dataDir);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(meanTopTs,Info,Opt);

filename = sprintf('%s/MeanErrtsFanaticor_bot',constants.dataDir);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(meanBotTs,Info,Opt);