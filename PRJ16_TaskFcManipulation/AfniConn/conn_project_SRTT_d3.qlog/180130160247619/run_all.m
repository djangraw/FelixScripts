% auto-generated by conn_jobmanager
% this script can be used to run this process from Matlab locally on this machine (or in a Matlab parallel toolbox environment)

addpath /gpfs/gsfs8/users/jangrawdc/MATLAB/Toolboxes/spm12/spm12;
addpath /gpfs/gsfs8/users/jangrawdc/MATLAB/Toolboxes/conn17f/conn;
cd /gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d3.qlog/180130160247619;

jobs={'/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d3.qlog/180130160247619/node.0001180130160247619.mat'};
% runs individual jobs
parfor n=1:numel(jobs)
  conn_jobmanager('exec',jobs{n});
end

% merges job outputs with conn project
conn load '/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d3.mat';
conn save;