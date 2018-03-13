% TEMP_PrepareConnV5Input.m
%
% Created 3/7-12/18 by DJ.

info = GetSrttConstants();
PRJDIR = info.PRJDIR;
subjects = info.okSubjNames;

%% Main loop for deleting old version of data
for i=1:numel(subjects)
    cd(sprintf('%s/RawData/%s/%s.srtt_v3',PRJDIR,subjects{i},subjects{i}));
    fprintf('%s...\n',subjects{i});
    system(sprintf('rm *.censorbase15-nofilt.%s*',subjects{i}));
end

%% Run swarm to get new version

system('bash /data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI/RunSrtt3dDeconvolve_CensorBase15-nofilt_swarm.sh');

%% Run T tests and group means

system('source 00_CommonVariables.sh');
system('bash /data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI/RunGroupTtest.sh GROUP_TTEST_v3_CensorBase15-nofilt NONE ${iOkSubjects[@]}');
system('bash GetMeanAcrossAllSubjects.sh GROUP_MEAN_v3_CensorBase15-nofilt ${iOkSubjects[@]}');

%% Copy new data to conn directory
CopyRawSrttDataToPrcsData_AfniConn(subjects);

%% BEND CONN TO YOUR WILL!

