% SaveMeanTimecourses_TopBot.m
%
% Created 4/11/19 by DJ.
% Updated 4/17/19 by DJ - fixed censoring

constants = GetStoryConstants();
[readScores, IQs,weights,weightNames] = GetStoryReadingScores(constants.okReadSubj);
[readScore_sorted,order] = sort(readScores,'ascend');
subj_sorted = constants.okReadSubj(order);

nSubj = numel(subj_sorted);
isTop = readScore_sorted>median(readScore_sorted);
% [meanTopTs,meanBotTs] = deal(0);
%%
allTs = cell(1,numel(subj_sorted));
for i=1:numel(subj_sorted)
    fprintf('Loading timecourse %d/%d...\n',i,numel(subj_sorted));
    tsFile = sprintf('%s/%s/%s.story/errts.%s.fanaticor+tlrc',constants.dataDir,subj_sorted{i},subj_sorted{i},subj_sorted{i});
    [ts,Info] = BrikLoad(tsFile);
    ts2d = reshape(ts,numel(ts)/size(ts,4),size(ts,4));
    isCensored = all(ts2d==0,1);
    isMasked = all(ts2d==0,2);
    ts2d(:,isCensored) = NaN;
    ts2d(isMasked,:) = NaN;
    allTs{i} = reshape(ts2d,size(ts));
%     if isTop(i)
%         meanTopTs = meanTopTs + ts;
%     else
%         meanBotTs = meanBotTs + ts;
%     end
end
fprintf('Concatenating...\n')
allTs = cat(5,allTs{:});
fprintf('Done!\n')
%%
fprintf('Calculating means & std errs...\n')
% meanTopTs = meanTopTs/sum(isTop);
% meanBotTs = meanBotTs/sum(~isTop);

meanTopTs = nanmean(allTs(:,:,:,:,isTop),5);
meanBotTs = nanmean(allTs(:,:,:,:,~isTop),5);

nSubjTopTs = sum(~isnan(allTs(:,:,:,:,isTop)),5);
nSubjBotTs = sum(~isnan(allTs(:,:,:,:,~isTop)),5);
steTopTs = nanstd(allTs(:,:,:,:,isTop),[],5)./sqrt(nSubjTopTs);
steBotTs = nanstd(allTs(:,:,:,:,~isTop),[],5)./sqrt(nSubjBotTs);

fprintf('Done!\n')

%% Save results
fprintf('Writing results to files...\n')

filename = sprintf('%s/MeanErrtsFanaticor_top',constants.dataDir);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(meanTopTs,Info,Opt);

filename = sprintf('%s/MeanErrtsFanaticor_bot',constants.dataDir);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(meanBotTs,Info,Opt);

filename = sprintf('%s/SteErrtsFanaticor_top',constants.dataDir);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(steTopTs,Info,Opt);

filename = sprintf('%s/SteErrtsFanaticor_bot',constants.dataDir);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(steBotTs,Info,Opt);

filename = sprintf('%s/nSubjErrtsFanaticor_top',constants.dataDir);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(nSubjTopTs,Info,Opt);

filename = sprintf('%s/nSubjErrtsFanaticor_bot',constants.dataDir);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(nSubjBotTs,Info,Opt);

fprintf('Done!\n')