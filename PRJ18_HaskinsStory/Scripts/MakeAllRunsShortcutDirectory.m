% MakeAllRunsShortcutDirectory.m
%
% Created 8/15/19 by DJ.

mkdir('/data/NIMH_Haskins/a182_v2/Timecourses')
cd('/data/NIMH_Haskins/a182_v2/Timecourses')
subjects = constants.okReadSubj;
for i=1:numel(subjects)
    system(sprintf('ln -s %s/%s/%s.story/all_runs.%s+tlrc.HEAD .',constants.dataDir,subjects{i},subjects{i},subjects{i}))
    system(sprintf('ln -s %s/%s/%s.story/all_runs.%s+tlrc.BRIK .',constants.dataDir,subjects{i},subjects{i},subjects{i}))
end