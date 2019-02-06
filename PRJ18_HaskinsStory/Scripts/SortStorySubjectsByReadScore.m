function [subj_sorted,readScore_sorted,iq_sorted,isTop_sorted] = SortStorySubjectsByReadScore()

info = GetStoryConstants;
[readScores,IQs,weights,weightNames] = GetStoryReadingScores(info.okReadSubj);

%% Sort
[readScore_sorted,order] = sort(readScores,'descend');
subj_sorted = info.okReadSubj(order);
iq_sorted = IQs(order);
isTop_sorted = readScore_sorted>median(readScore_sorted);

%% Print
fprintf('okReadSubj_top="');
fprintf('%s ',subj_sorted{isTop_sorted});
fprintf('\b"\n');

fprintf('okReadSubj_bot="');
fprintf('%s ',subj_sorted{~isTop_sorted});
fprintf('\b"\n');

%% Plot
figure(1); clf;
bar(weights);
set(gca,'xtick',1:numel(weights),'xticklabel',show_symbols(weightNames));
xticklabel_rotate([],45)
ylabel('Weight in Reading PC1')

figure(2); clf;
plot(readScores,IQs,'.');
xlabel('Reading PC1')
ylabel('WASI PIQ')
lsline
[r,p] = corr(readScores',IQs','rows','complete');
legend('subjects',sprintf('linear fit (r=%.3g, p=%.3g',r,p))

figure(3); clf;
subjMotion = GetStorySubjectMotion(info.okReadSubj);
plot(readScores,subjMotion,'.');
xlabel('Reading PC1')
ylabel('Subject Motion')
lsline
[r,p] = corr(readScores',subjMotion','rows','complete');
legend('subjects',sprintf('linear fit (r=%.3g, p=%.3g',r,p))