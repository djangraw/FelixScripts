#!/bin/bash
/usr/local/apps/Matlab/R2017a/bin/matlab -nodesktop -nodisplay -nosplash -singleCompThread -logfile '/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d3.qlog/180213163443244/node.0004180213163443244.stdlog' -r "addpath /gpfs/gsfs8/users/jangrawdc/MATLAB/Toolboxes/spm12/spm12; addpath /gpfs/gsfs8/users/jangrawdc/MATLAB/Toolboxes/conn17f/conn; cd /gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d3.qlog/180213163443244; conn_jobmanager('rexec','/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d3.qlog/180213163443244/node.0004180213163443244.mat'); exit"
echo _NODE END_
