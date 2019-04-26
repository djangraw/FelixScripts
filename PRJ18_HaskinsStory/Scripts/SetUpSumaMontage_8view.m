function SetUpSumaMontage_8view(data_dir,cmd_file,afni_ulay,afni_olay,suma_spec,suma_sv,beta_ind,thresh_ind,image_dir,image_pre,image_fin,suma_pos,func_range,thr_thresh,my_cbar)

% SetUpSumaMontage_8view(data_dir,afni_ulay,afni_olay,suma_spec,suma_sv,beta_ind,thr_ind,image_dir,image_pre,image_fin,suma_pos,func_range,thr_thresh,my_cbar)
%
% Created 5/29/18 by DJ.
% Updated 4/25/19 by DJ - 4-view -> 8-view

%% Set defaults
% folder
d.data_dir = "/data/NIMH_Haskins/a182/"; % where the data lives
d.cmd_file = "SumaMontageCmd.tcsh"; % tcsh command created by this file

% datasets
d.afni_ulay = "MNI_N27_SurfVol.nii";    % can be struc or whatev
d.afni_olay = "ttest_allSubj+tlrc";    % has betas and ts
d.suma_spec = "suma_MNI_N27/MNI_N27_both.spec";    % created somehow
d.suma_sv   = d.afni_ulay;    % created somehow

% indices
% user chooses which betas are selected for olay, and thr volumes are
% presently assumed to be at +1 relative to each of these indices
d.beta_ind = 114; % index of betas in afni_olay
d.thresh_ind = d.beta_ind+1; % index of threshold in afni olay

% image properties
d.image_dir = "./SUMA_IMAGES";        % store jpgs here
d.image_pre = "suma_images";        % ... with this prefix
d.image_fin = sprintf("%s/Suma4view_%s.jpg",d.image_dir,datestr(now,'yyyy-mm-dd_HH:MM:SS')); % final movie name (with suffix)

% size of the image window, given as:
% leftcorner_X  leftcorner_Y  windowwidth_X  windowwith_Y
d.suma_pos = "50 50 500 425";

% values for things in driven AFNI
d.func_range = 0.2; %1
d.thr_thresh = '0.01 *q'; 
%d.thr_thresh = 2.576; % z corresponding to p=0.01
% d.thr_thresh = 1.96 % z value corresponding to p=0.05
% d.my_cbar    = "Spectrum:red_to_blue" % "Viridis"
d.my_cbar = "Reds_and_Blues_w_Green"; % add FLIP to flip sign of normal colorbar
% d.my_cbar = "ROI_i32" % For Conjunction Analysis

%% Override empty values by defaults
vars = fieldnames(d);
for i=1:numel(vars)
    if ~exist(vars{i},'var') || isempty(eval(vars{i}))
        eval(sprintf('%s = d.%s;',vars{i},vars{i}));
    end
end

%% Copy files if necessary


%% Write commands
fid = fopen(cmd_file,'w');
fprintf(fid,'#!/bin/tcsh -e\n\n');
fprintf(fid,'# Created %s by MATLAB function SetUpSumaMontage_4view.m\n\n',datestr(now));
for i=1:numel(vars)
    var_value = eval(vars{i}); % get value of this variable
    fprintf(fid,'set %s = "%s"\n',vars{i},num2str(var_value));
end

fprintf(fid,'\n# run script\n');
fprintf(fid,'cd $data_dir\n');
fprintf(fid,'source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/MakeSumaMontage_8view.tcsh\n');
fclose(fid);

%% Run result
cmd = sprintf('tcsh %s',cmd_file);
fprintf('Running command >> %s...\n',cmd);
system(cmd);
