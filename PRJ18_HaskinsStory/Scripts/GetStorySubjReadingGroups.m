function [subj_topHalf,subj_botHalf,readScore_top,readScore_bot] = GetStorySubjReadingGroups(cenCutoff)

% [subj_topHalf,subj_botHalf,readScore_top,readScore_bot] = GetStorySubjReadingGroups(cenCutoff)
%
% Created 5/18/18 by DJ.
% Updated 5/23/18 by DJ - added motion exclusion criterion and censorFraction input

if ~exist('censorFraction','var') || isempty(cenCutoff)
    cenCutoff = 0.15;
%     censorFraction = inf; % don't remove any subjects for motion
end
info = GetStoryConstants();

% load behavior table
behFilename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
behTable = ReadSrttBehXlsFile(behFilename);
% get subject names
behSubj = cellfun(@(x) sprintf('tb%04d',str2num(x)), behTable.Properties.RowNames,'UniformOutput',false);
% Calculate reading scores
[readScore_beh,isOkSubj_beh] = GetFirstReadingScorePc(behTable);
% readScore_beh = behTable.TOWRE_TWRE_SS;
% readScore_beh = behTable.WJ3_LW_SS;
% isOkSubj_beh = ~isnan(readScore_beh);

%% Get for Story okSubjects

[isBehSubj,iSubj] = ismember(info.okSubj,behSubj);
readScore_story = nan(size(info.okSubj));
isOkSubj_story = false(size(info.okSubj));
readScore_story(isBehSubj) = readScore_beh(iSubj(isBehSubj));
isOkSubj_story(isBehSubj) = isOkSubj_beh(iSubj(isBehSubj));

%% Limit to subjects with all reading data
subj_allOk = info.okSubj(isOkSubj_story);
readScore_story_allOk = readScore_story(isOkSubj_story);

% Remove high-motion subjects
fprintf('===Removing high-motion subjects...\n')
[~,subj_allOk_new,readScore_story_allOk_new] = RemoveHighMotionSubjects(subj_allOk,readScore_story_allOk,cenCutoff);

% Median split
isTop = readScore_story_allOk_new>median(readScore_story_allOk_new);
subj_topHalf = subj_allOk_new(isTop);
subj_botHalf = subj_allOk_new(~isTop);
readScore_top = readScore_story_allOk_new(isTop);
readScore_bot = readScore_story_allOk_new(~isTop);
% display results for easy input into R script
fprintf('===FOR TWO-GROUP R SCRIPT:===\n');
fprintf('# list labels for Group 1 - ReadScore <= MEDIAN(ReadScore)\n')
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
fprintf('''%s'',', subj_allOk_new{:});
fprintf('\b)\n\n');
