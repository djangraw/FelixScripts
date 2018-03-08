info = GetSrttConstants();
PRJDIR = info.PRJDIR;
subjects = info.okSubjNames;

%% Main loop for deleting old version of data
for i=1:numel(subjects)
    cd(sprintf('%s/RawData/%s/%s.srtt_v3',PRJDIR,subjects{i},subjects{i}));
    fprintsf('%s...\n',subjects{i});
    system(sprintf('rm *.censorbase15-nofilt.%s*',subjects{i}));
end

%% Run swarm to get new version

system('bash /data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI/RunSrtt3dDeconvolve_CensorBase15-nofilt_swarm.sh');
%% Copy new data to conn directory
CopyRawSrttDataToPrcsData_AfniConn(subjects);

%% BEND CONN TO YOUR WILL!
