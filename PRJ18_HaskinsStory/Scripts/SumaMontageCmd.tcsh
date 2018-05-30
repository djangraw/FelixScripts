#!/bin/tcsh -e

# Created 29-May-2018 16:12:42 by MATLAB function SetUpSumaMontage_4view.m

set data_dir = "/data/jangrawdc/PRJ18_HaskinsStory/"
set cmd_file = "SumaMontageCmd.tcsh"
set afni_ulay = "MNI_N27_SurfVol.nii"
set afni_olay = "ttest_allSubj+tlrc"
set suma_spec = "suma_MNI_N27/MNI_N27_both.spec"
set suma_sv = "MNI_N27_SurfVol.nii"
set beta_ind = "114"
set thresh_ind = "115"
set image_dir = "./SUMA_IMAGES"
set image_pre = "suma_images"
set image_fin = "./SUMA_IMAGES/Suma4view_2018-05-29_16:12:42.jpg"
set suma_pos = "50 50 500 425"
set func_range = "0.2"
set thr_thresh = "2.576"
set my_cbar = "Reds_and_Blues_w_Green"

# run script
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/MakeSumaMontage_4view.tcsh
