#!/bin/bash

for aSub in $@
do
	echo "Subject $aSub: "

	cd $aSub

	afni_proc.py -subj_id MNI_${aSub} -script afni_story_MNI_${aSub}.tcsh -out_dir MNI_${aSub}.story \
	-dsets func_story/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3D*.nii.gz \
    -anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a \
	-volreg_tlrc_warp -tlrc_NL_warp \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 -volreg_align_to first -volreg_warp_dxyz 3 \
	-align_opts_aea -giant_move \
	-regress_stim_times stim_times/stim_times_story/c1*.txt stim_times/stim_times_story/c2*.txt \
	-regress_stim_labels c1 c2 \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_reml_exec \
	-regress_local_times \
	-regress_basis 'dmBLOCK(0)' \
	-regress_stim_types AM1 \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-stim_times_subtract 12 \
	-num_glt 5 \
	-gltsym 'SYM: +c1' -glt_label 1 'audio' \
	-gltsym 'SYM: +c2' -glt_label 2 'visual' \
	-gltsym 'SYM: +c1 -c2' -glt_label 3 'audio-visual' \
	-gltsym 'SYM: -c1 +c2' -glt_label 4 'visual-audio' \
	-jobs 12 \
	-bash -execute

	cd ../

done
