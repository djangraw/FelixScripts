% auto-generated by conn_jobmanager
% this script can be used to run this process from Matlab locally on this machine (or in a Matlab parallel toolbox environment)

addpath /gpfs/gsfs8/users/jangrawdc/MATLAB/Toolboxes/spm12/spm12;
addpath /gpfs/gsfs8/users/jangrawdc/MATLAB/Toolboxes/conn17f/conn;
cd /gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504;

jobs={'/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0001180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0002180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0003180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0004180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0005180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0006180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0007180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0008180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0009180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0010180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0011180316110529504.mat','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180316110529504/node.0012180316110529504.mat'};
% runs individual jobs
parfor n=1:numel(jobs)
  conn_jobmanager('exec',jobs{n});
end

% merges job outputs with conn project
conn load '/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.mat';
conn save;