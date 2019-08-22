function PrintGroupingsByAgeAndIQ()

% Created 7/5/19 by DJ.

%% Set up
info = GetStoryConstants;

% Read behavior file
behFile = [info.PRJDIR '/A182IncludedSubjectBehavior_2019-01-04.xlsx'];
behTable = readtable(behFile);

%% crop to okReadSubj
behTable = behTable(ismember(behTable.haskinsID,info.okReadSubj),:);

%% get age
subjects = string(behTable.haskinsID);
age = behTable.MRIScans__ProfileAge;
cutoff = median(age);
subj_topAge = subjects(age>cutoff);
subj_botAge = subjects(age<=cutoff);

%% Get IQ
iq = behTable.WASIVerified__Perf_IQ;
cutoff = nanmedian(iq);
subj_topIq = subjects(iq>cutoff);
subj_botIq = subjects(iq<=cutoff);


%% Print for R script
% display results for easy input into R script

fprintf('===FOR AGE TWO-GROUP R SCRIPT:===\n');
fprintf('# list labels for Group 1 - age <= MEDIAN(age)\n')
fprintf('G1Subj <- c(''%s'')\n',join(subj_botAge,''','''));
fprintf('# list labels for Group 2 - age > MEDIAN(age)\n')
fprintf('G2Subj <- c(''%s'')\n',join(subj_topAge,''','''));

fprintf('===FOR IQ TWO-GROUP R SCRIPT:===\n');
fprintf('# list labels for Group 1 - IQ <= MEDIAN(IQ)\n')
fprintf('G1Subj <- c(''%s'')\n',join(subj_botIq,''','''));
fprintf('# list labels for Group 2 - IQ > MEDIAN(IQ)\n')
fprintf('G2Subj <- c(''%s'')\n',join(subj_topIq,''','''));
