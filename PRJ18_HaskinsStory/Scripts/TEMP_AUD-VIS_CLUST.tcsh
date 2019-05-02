#!/bin/tcsh -e

# Created 01-May-2019 14:09:21 by MATLAB function SetUpSumaMontage_4view.m

set data_dir = "/data/NIMH_Haskins/a182_v2/IscResults/Group"
set cmd_file = "TEMP_AUD-VIS_CLUST.tcsh"
set afni_ulay = "MNI152_2009_SurfVol.nii"
set afni_olay = "3dLME_2Grps_readScoreMedSplit_n69_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz"
set suma_spec = "suma_MNI152_2009/MNI152_2009_both.spec"
set suma_sv = "MNI152_2009_SurfVol.nii"
set beta_ind = "0"
set thresh_ind = "0"
set image_dir = "./SUMA_IMAGES"
set image_pre = "suma_images"
set image_fin = "SUMA_IMAGES/suma_8view_ISC_top-bot_lim0p1_p01_a05.jpg"
set suma_pos = "50 50 500 425"
set func_range = "0.1"
set thr_thresh = "0"
set my_cbar = "Reds_and_Blues_w_Green"

# run script
cd $data_dir
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/MakeSumaMontage_8view.tcsh
