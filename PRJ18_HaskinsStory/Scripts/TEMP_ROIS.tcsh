#!/bin/tcsh -e

# Created 08-Jul-2019 14:39:49 by MATLAB function SetUpSumaMontage_4view.m

set data_dir = "/data/NIMH_Haskins/a182_v2/atlasRois/"
set cmd_file = "TEMP_ROIS.tcsh"
set afni_ulay = "MNI152_2009_SurfVol.nii"
set afni_olay = "8Rois+tlrc"
set suma_spec = "suma_MNI152_2009/MNI152_2009_both.spec"
set suma_sv = "MNI152_2009_SurfVol.nii"
set beta_ind = "0"
set thresh_ind = "0"
set image_dir = "./SUMA_IMAGES"
set image_pre = "suma_images"
set image_fin = "SUMA_IMAGES/8Rois.jpg"
set suma_pos = "50 50 500 425"
set func_range = "8"
set thr_thresh = "0"
set my_cbar = "ROI_i32"

# run script
cd $data_dir
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/MakeSumaMontage_8view.tcsh
