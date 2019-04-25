#!/bin/tcsh -e

# Created 24-Apr-2019 09:28:08 by MATLAB function SetUpClusterThreshMaskedStats.m

set statsfolder = "/data/NIMH_Haskins/a182_v2/IscResults/Group/"
set statsfile = "3dLME_2Grps_readScoreMedSplit_n69_Automask_trans"
set statsfile_space = "tlrc"
set iMean = "8"
set iThresh = "9"
set cond_name = "top-topbot"
set maskfile = "MNI_mask_epiRes.nii"
set cmd_file = "TEMP_TOP-TOPBOT.tcsh"
set csim_folder = "/data/NIMH_Haskins/a182_v2/ClustSimFiles"
set csim_neigh = "1"
set csim_NN = "NN${csim_neigh}"
set csim_sided = "bisided"
set csim_pthr = "0.01"
set csim_alpha = "0.05"
set csim_pref = "${statsfile}_${cond_name}_clust_p${csim_pthr}_a${csim_alpha}_${csim_sided}"

# run script
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/GetClusterThreshMaskedStats.tcsh
