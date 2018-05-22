function [subj_topHalf,subj_botHalf,readScore_top,readScore_bot] = GetStorySubjReadingGroups()

% [subj_topHalf,subj_botHalf,readScore_top,readScore_bot] = GetStorySubjReadingGroups()
% Created 5/18/18 by DJ.

info = GetStoryConstants();

% load behavior table
behFilename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
behTable = ReadSrttBehXlsFile(behFilename);
% get subject names
behSubj = cellfun(@(x) sprintf('tb%04d',str2num(x)), behTable.Properties.RowNames,'UniformOutput',false);
% Calculate reading scores
[readScore_beh,isOkSubj_beh] = GetFirstReadingScorePc(behTable);

%% Get for Story okSubjects

[isBehSubj,iSubj] = ismember(info.okSubj,behSubj);
readScore_story = nan(size(info.okSubj));
isOkSubj_story = false(size(info.okSubj));
readScore_story(isBehSubj) = readScore_beh(iSubj(isBehSubj));
isOkSubj_story(isBehSubj) = isOkSubj_beh(iSubj(isBehSubj));

%% Limit to subjects with all reading data
subj_allOk = info.okSubj(isOkSubj_story);
readScore_story_allOk = readScore_story(isOkSubj_story);
% Median split
isTopHalf = readScore_story_allOk>median(readScore_story_allOk);
subj_topHalf = subj_allOk(isTopHalf);
subj_botHalf = subj_allOk(~isTopHalf);
readScore_top = readScore_story_allOk(isTopHalf);
readScore_bot = readScore_story_allOk(~isTopHalf);
% display results for easy input into R script
fprintf('===FOR TWO-GROUP R SCRIPT:===\n');
fprintf('# list labels for Group 1 - ReadScore <= MsEDIAN(ReadScore)\n')
fprintf('G1Subj <- c(');
fprintf('''%s'',', subj_botHalf{:});
fprintf('\b)\n\n');
fprintf('# list labels for Group 2 - ReadScore > MEDIAN(ReadScore)\n')
fprintf('G2Subj <- c(');
fprintf('''%s'',', subj_topHalf{:});
fprintf('\b)\n');
fprintf('\n');
fprintf('===FOR ONE-GROUP R SCRIPT:===\n');
fprintf('# list all the subject or session labels\n')
fprintf('G1Subj <- c(');
fprintf('''%s'',', subj_allOk{:});
fprintf('\b)\n\n');
