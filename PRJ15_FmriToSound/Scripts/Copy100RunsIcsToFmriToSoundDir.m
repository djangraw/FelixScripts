function Copy100RunsIcsToFmriToSoundDir(subject,session,task)

% Copy100RunsIcsToFmriToSoundDir(subject,session,task)
%
% Created 12/20/17 by DJ.

targetDir = '/data/jangrawdc/PRJ15_FmriToSound/TestData/100RUNS_3Tmultiecho';
% Move to directory with MEICA results
cd(sprintf('/data/SFIM_100RUNS/100RUNS_3Tmultiecho/PrcsData/SBJ%02d_S%02d/D01_MeicaAnalysis/Task%02d/meica.SBJ%02d_S%02d_Task%02d_e1/TED',subject,session,task,subject,session,task));
% % Copy the component weights
% copyfile('meica_mix.1D',sprintf('%s/SBJ%02d_S%02d_Task%02d_meica_mix.1D',targetDir,subject,session,task));
% % Copy the component timecourses
% copyfile('betas_OC.nii',sprintf('%s/SBJ%02d_S%02d_Task%02d_betas_OC.nii',targetDir,subject,session,task));
% % Copy list of accepted timecourses
% copyfile('accepted.txt',sprintf('%s/SBJ%02d_S%02d_Task%02d_accepted.txt',targetDir,subject,session,task));
% % Copy variance explained
% copyfile('varex.txt',sprintf('%s/SBJ%02d_S%02d_Task%02d_varex.txt',targetDir,subject,session,task));
% Copy denoised timecourse
copyfile('dn_ts_OC.nii',sprintf('%s/SBJ%02d_S%02d_Task%02d_dn_ts_OC.nii',targetDir,subject,session,task));

% % Move to directory with Response results
% cd(sprintf('/data/SFIM_100RUNS/100RUNS_3Tmultiecho/PrcsData/SBJ%02d_S%02d/D00_OriginalData/Task%02d/',subject,session,task));
% % Copy response log
% respFile = dir('*ResponseLog*.txt');
% copyfile(respFile.name,sprintf('%s/SBJ%02d_S%02d_Task%02d_respLog.txt',targetDir,subject,session,task));

cd(targetDir);