#!/bin/bash


story()
{
	cd $1

	afni_proc.py -subj_id ${1} -script afni_storyrest2_${1}.tcsh -out_dir ${1}.storyrest2 \
	-dsets func_story/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3D*.nii.gz \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -tlrc_opts_at -init_xform AUTO_CENTER \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 -volreg_align_to first -volreg_warp_dxyz 3 \
	-align_opts_aea -giant_move \
	-regress_stim_times stim_times/stim_times_story2/c0*.txt stim_times/stim_times_story2/c1*.txt stim_times/stim_times_story2/c2*.txt \
	-regress_stim_labels c0 c1 c2 \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_reml_exec \
	-regress_local_times \
	-regress_basis 'dmBLOCK(0)' \
	-regress_stim_types AM1 \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-num_glt 7 \
	-gltsym 'SYM: +c0' -glt_label 1 'rest' \
	-gltsym 'SYM: +c1' -glt_label 2 'audio' \
	-gltsym 'SYM: +c2' -glt_label 3 'visual' \
	-gltsym 'SYM: +c1 -c2' -glt_label 4 'audio-visual' \
	-gltsym 'SYM: -c1 +c2' -glt_label 5 'visual-audio' \
	-gltsym 'SYM: +c1 -c0' -glt_label 6 'audio-rest' \
	-gltsym 'SYM: -c0 +c2' -glt_label 7 'visual-rest' \
	-jobs 12 \
	-bash -execute
	
	cd ../
}


for aSub in $@
do
	echo "Subject $aSub: "
		
	if [ -e $aSub/func_story ]; then
		echo "Running Story"
		story $aSub;
	fi
	
	

	#sh gen_snapshots.sh $aSub

done

