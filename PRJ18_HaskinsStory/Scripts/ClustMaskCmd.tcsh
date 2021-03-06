#!/bin/tcsh -e

# Created 25-Mar-2019 11:34:12 by MATLAB function SetUpClusterThreshMaskedStats.m

set statsfolder = "/data/NIMH_Haskins/a182_v2/IscResults/Group/"
set statsfile = "3dLME_2Grps_readScoreMedSplit_n69_Automask"
set statsfile_space = "tlrc"
set iMean = "6"
set iThresh = "7"
set cond_name = "top-bot"
set maskfile = "MNI_mask_epiRes.nii"
set cmd_file = "ClustMaskCmd.tcsh"
set csim_folder = "TEMP_TOP-BOT.tcsh"
set csim_neigh = "1"
set csim_NN = "NN${csim_neigh}"
set csim_sided = "bisided"
set csim_pthr = "0.01"
set csim_alpha = "0.05"
set csim_pref = "${statsfile}_${cond_name}_clust_p${csim_pthr}_a${csim_alpha}_${csim_sided}"

# run script
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/GetClusterThreshMaskedStats.tcsh
