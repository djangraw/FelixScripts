#!/bin/tcsh -e

# Created 01-May-2019 14:08:15 by MATLAB function SetUpSumaMontage_4view.m

set data_dir = "/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc"
set cmd_file = "TEMP_VIS_CLUST.tcsh"
set afni_ulay = "MNI152_2009_SurfVol.nii"
set afni_olay = "ttest_allSubj_2grp_minus12_vis_clust_p0.01_a0.05_bisided_EE.nii.gz"
set suma_spec = "suma_MNI152_2009/MNI152_2009_both.spec"
set suma_sv = "MNI152_2009_SurfVol.nii"
set beta_ind = "0"
set thresh_ind = "0"
set image_dir = "./SUMA_IMAGES"
set image_pre = "suma_images"
set image_fin = "SUMA_IMAGES/suma_8view_2grp_vis_lim0.3_p0.01_a0.05.jpg"
set suma_pos = "50 50 500 425"
set func_range = "0.3"
set thr_thresh = "0"
set my_cbar = "Reds_and_Blues_w_Green"

# run script
cd $data_dir
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/MakeSumaMontage_8view.tcsh
