function SetUpClusterThreshMaskedStats(statsfolder,statsfile,statsfile_space,iMean,iThresh,cond_name,maskfile,cmd_file,csim_folder,csim_neigh,csim_NN,csim_sided,csim_pthr,csim_alpha,csim_pref)

% SetUpClusterThreshMaskedStats(statsfolder,statsfile,statsfile_space,iMean,iThresh,cond_name,maskfile,csim_folder,csim_neigh,csim_NN,csim_sided,csim_pthr,csim_alpha,csim_pref)
%
% Created 3/25/19 by DJ based on SetUpSumaMontage_4view.m.

%% Set defaults

% specify group stats files
d.statsfolder = "/data/NIMH_Haskins/a182_v2/IscResults/Group/";
d.statsfile   = "3dLME_2Grps_readScoreMedSplit_n69_Automask";      % output effect+stats filename
d.statsfile_space = "tlrc";
% indices of subbricks (0-based numbering)
d.iMean       = "8";                 % volume label (or index) for stat result
d.iThresh     = "9";
d.cond_name   = "bot-topbot";

% Specify other files
d.maskfile    = "MNI_mask_epiRes.nii";
d.cmd_file    = "ClustMaskCmd.tcsh"; % tcsh command created by this file

% Cluster parameters
d.csim_folder = "/data/NIMH_Haskins/a182_v2/ClustSimFiles";
d.csim_neigh  = 1;         % neighborhood; could be NN=1,2,3
d.csim_NN     = "NN${csim_neigh}";  % other form of neigh
d.csim_sided  = "bisided"; % test type; could be 1sided, 2sided or bisided
d.csim_pthr   = 0.01;     % voxelwise thr (was higher, 0.01, in orig study)
d.csim_alpha  = 0.05;      % nominal FWE
d.csim_pref   = "${statsfile}_${cond_name}_clust_p${csim_pthr}_a${csim_alpha}_${csim_sided}"; % prefix for outputting stuff


%% Override empty values by defaults
vars = fieldnames(d);
for i=1:numel(vars)
    if ~exist(vars{i},'var') || isempty(eval(vars{i}))
        eval(sprintf('%s = d.%s;',vars{i},vars{i}));
    end
end
fprintf('csim_pthr = %g\n',csim_pthr);
%% Write commands
fid = fopen(cmd_file,'w');
fprintf(fid,'#!/bin/tcsh -e\n\n');
fprintf(fid,'# Created %s by MATLAB function SetUpClusterThreshMaskedStats.m\n\n',datestr(now));
for i=1:numel(vars)
    var_value = eval(vars{i}); % get value of this variable
    fprintf(fid,'set %s = "%s"\n',vars{i},num2str(var_value));
end

fprintf(fid,'\n# run script\n');
% fprintf(fid,'cd $statsfolder\n');
fprintf(fid,'source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/GetClusterThreshMaskedStats.tcsh\n');
fclose(fid);

%% Run result
cmd = sprintf('tcsh %s',cmd_file);
fprintf('Running command >> %s...\n',cmd);
system(cmd);
