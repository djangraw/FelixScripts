#!/bin/bash
/usr/local/apps/Matlab/R2017a/bin/matlab -nodesktop -nodisplay -nosplash -singleCompThread -logfile '/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180312165706171/node.0030180312165706171.stdlog' -r "addpath /gpfs/gsfs8/users/jangrawdc/MATLAB/Toolboxes/spm12/spm12; addpath /gpfs/gsfs8/users/jangrawdc/MATLAB/Toolboxes/conn17f/conn; cd /gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180312165706171; conn_jobmanager('rexec','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d5.qlog/180312165706171/node.0030180312165706171.mat'); exit"
echo _NODE END_
