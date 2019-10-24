% GetSingleTestReadScores

info = GetStoryConstants();
subjects = info.okReadSubj;
% get standard reading scores
[readScores, weights,weightNames,IQs,ages] = GetStoryReadingScores(subjects);

% Read behavior file
behTable = readtable(info.behFile);

%% Use all subjects to get first PC
% Append all reading scores
allReadScores = [behTable.TOWREVerified__SWE_SS,behTable.TOWREVerified__PDE_SS,behTable.TOWREVerified__TWRE_SS,...
    behTable.WoodcockJohnsonVerified__BscR_SS, behTable.WoodcockJohnsonVerified__LW_SS, behTable.WoodcockJohnsonVerified__WA_SS,...
    behTable.WASIVerified__Perf_IQ,behTable.EdinburghHandedness__LiQ,behTable.MRIScans__ProfileAge];
% weightNames = {'TOWRE_SWE_SS','TOWRE_PDE_SS','TOWRE_TWRE_SS','WJ3_BscR_SS','WJ3_LW_SS','WJ3_WA_SS'};
weightNames = {'TOWRE Sight-Word','TOWRE Phoenetic Decoding','TOWRE Total Word Reading','WJ3 Basic Reading','WJ3 Letter-Word ID','WJ3 Word Attack','WASI Performance IQ','Edinburgh Handedness LiQ','Age (years)'};
isOkSubj = all(~isnan(allReadScores),2);

%% Reorder
readSubj = behTable.haskinsID;
[IQs,ages] = deal(nan(size(subjects)));
readSubscores = nan(numel(subjects),size(allReadScores,2));
for i=1:numel(subjects)
    readSubscores(i,:) = allReadScores(strcmp(readSubj,subjects{i}),:);
%     IQs(i) = behTable.WASIVerified__Perf_IQ(strcmp(readSubj,subjects{i}));
%     ages(i) = behTable.MRIScans__ProfileAge(strcmp(readSubj,subjects{i}));
end

%% Plot
figure(521); clf;
set(gcf,'Position',[70 297 1082 700]);
readHistEdges = linspace(min(min(readSubscores(:,1:6))),max(max(readSubscores(:,1:6))),20);
isTop = readScores > median(readScores);
colors = {[1 0 0],[112 48 160]/255};
nTests = size(readSubscores,2);
nCols = 3;
nRows = 3;
for i=1:nTests
    subplot(nRows,nCols,i);
    if i<7
        histEdges = readHistEdges;
    else
        histEdges = linspace(min(readSubscores(:,i)),max(readSubscores(:,i)),20);
    end
    nTop = histcounts(readSubscores(isTop,i),histEdges);
    nBot = histcounts(readSubscores(~isTop,i),histEdges);
    ctrs = (histEdges(1:end-1)+histEdges(2:end))/2; % Calculate the bin centers
    hBar = bar(ctrs, [nBot' nTop'],1,'stacked');
    set(hBar(1),'FaceColor',colors{1});
    set(hBar(1),'FaceColor',colors{2});
    xlabel(weightNames{i},'interpreter','none');
    ylabel('participants');
end
legend('poor readers','good readers','location','northwest');
MakeFigureTitle('Behavioral Test Distributions');
saveas(gcf,sprintf('%s/Results/ReadingSubtestDistributions.png',info.PRJDIR));

%% Print mean, std, range of each
fprintf('========================\n');
fprintf('Test: mean ± std, range min-max\n');
for i=1:nTests
    fprintf('%s: %.0f ± %.0f, range %.0f-%.0f\n',...
        weightNames{i},nanmean(readSubscores(:,i)),nanstd(readSubscores(:,i)),...
        min(readSubscores(:,i)),max(readSubscores(:,i)));
    % test good-poor
    [p,h] = ranksum(readSubscores(~isTop,i),readSubscores(isTop,i));
    fprintf('   top>bot: p=%.3g\n',p)
end
fprintf('========================\n');
