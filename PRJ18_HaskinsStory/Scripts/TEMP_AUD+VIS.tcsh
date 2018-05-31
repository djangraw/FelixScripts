#!/bin/tcsh -e

# Created 30-May-2018 12:06:29 by MATLAB function SetUpSumaMontage_4view.m

set data_dir = "/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2"
set cmd_file = "TEMP_AUD+VIS.tcsh"
set afni_ulay = "MNI152_2009_SurfVol.nii"
set afni_olay = "ttest_allSubj_1grp+tlrc"
set suma_spec = "suma_MNI152_2009/MNI152_2009_both.spec"
set suma_sv = "MNI152_2009_SurfVol.nii"
set beta_ind = "14"
set thresh_ind = "15"
set image_dir = "./SUMA_IMAGES"
set image_pre = "suma_images"
set image_fin = "SUMA_IMAGES/suma_4view_1grp_aud+vis_lim1p5_q01.jpg"
set suma_pos = "50 50 500 425"
set func_range = "1.5"
set thr_thresh = "0.01 *q"
set my_cbar = "Reds_and_Blues_w_Green"

# run script
cd $data_dir
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/MakeSumaMontage_4view.tcsh
