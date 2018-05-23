function [subj_sorted,readScore_sorted] = GetStoryReadingScores()

% Created 5/22/18 by DJ.

%% Set up
fprintf('Setting up...\n');
[subj_topHalf,subj_botHalf,readScore_top, readScore_bot] = GetStorySubjReadingGroups();
fprintf('Done!\n');

%% Reorder according to reading score
subj_all = [subj_topHalf,subj_botHalf];
readScore_all = [readScore_top,readScore_bot];
[readScore_sorted, order] = sort(readScore_all);
subj_sorted = subj_all(order); % in ASCENDING ORDER
