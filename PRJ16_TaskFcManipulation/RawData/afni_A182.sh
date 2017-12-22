#!/bin/bash


srtt()
{
	cd $1

	afni_proc.py -subj_id ${1} -script afni_srtt_${1}.tcsh -out_dir ${1}.srtt \
	-dsets func_srtt/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3D*.nii.gz \
	-anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -tlrc_NL_warp \
	-align_opts_aea -giant_move \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 \
	-volreg_align_to first -volreg_warp_dxyz 3 \
	-regress_stim_times stim_times/stim_times_srtt/bl?_c1*.txt stim_times/stim_times_srtt/bl?_c2*.txt \
	-regress_stim_labels uns1 uns2 uns3 str1 str2 str3  \
	-regress_local_times \
	-regress_est_blur_errts \
	-regress_basis 'dmBLOCK(1)' \
	-regress_stim_types AM1 \
	-regress_reml_exec \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-num_glt 10 \
	-gltsym 'SYM: +uns1 +uns2 +uns3' -glt_label 1 'unstructured' \
	-gltsym 'SYM: +str1 +str2 +str3' -glt_label 2 'structured' \
	-gltsym 'SYM: +uns1 +uns2 +uns3 -str1 -str2 -str3' -glt_label 3 'unstructured-structured' \
	-gltsym 'SYM: +str1 -uns1' -glt_label 4 'structured-unstructured BL1' \
	-gltsym 'SYM: +str2 -uns2' -glt_label 5 'structured-unstructured BL2' \
	-gltsym 'SYM: +str3 -uns3' -glt_label 6 'structured-unstructured BL3' \
	-jobs 10 \
	-bash -execute

	cd ../
}



for aSub in $@
do
	echo "Subject $aSub: "

	if [ -e $aSub/func_srtt ]; then
		echo "Running SRTT"
		srtt $aSub;
	fi
done
