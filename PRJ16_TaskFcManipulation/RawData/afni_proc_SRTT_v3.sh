#!/bin/bash

# afni_proc_SRTT_v3.sh
#
# Run afni_proc.py on SRTT data from the given subj's
#
# Usage: bash afni_proc_SRTT_v3.sh $subj1 $subj2... $subjN
#
# Created 10/11/17 by DJ based on afni_A182.sh (from PM)
# Updated 12/11/17 by DJ - added -volreg_tlrc_warp flag
# Updated 1/2/18 by DJ - add scale. change blur, atlas base, mot deriv,
#    new GLTs, made _v3

srtt()
{
	cd $1

	afni_proc.py -subj_id ${1} -script afni_srtt_v3_${1}.tcsh -out_dir ${1}.srtt_v3 \
	-dsets func_srtt/ep2dbold*.nii.gz  \
	-blocks despike tshift align tlrc volreg blur mask scale regress \
	-copy_anat anat/Sag3D*.nii.gz \
	-anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -tlrc_NL_warp -volreg_tlrc_warp \
	-tlrc_base MNI152_T1_2009c+tlrc \
	-align_opts_aea -giant_move \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 6 \
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
	-regress_apply_mot_types demean deriv   \
	-regress_opts_3dD \
	-num_glt 10 \
	-gltsym 'SYM: +uns1 +uns2 +uns3' -glt_label 1 'unstructured' \
	-gltsym 'SYM: +str1 +str2 +str3' -glt_label 2 'structured' \
	-gltsym 'SYM: +uns1 +uns2 +uns3 -str1 -str2 -str3' -glt_label 3 'unstructured-structured' \
	-gltsym 'SYM: +uns1 -str1' -glt_label 4 'unstructured-structured BL1' \
	-gltsym 'SYM: +uns2 -str2' -glt_label 5 'unstructured-structured BL2' \
	-gltsym 'SYM: +uns3 -str3' -glt_label 6 'unstructured-structured BL3' \
	-gltsym 'SYM: +uns1 +uns2 +uns3 +str1 +str2 +str3' -glt_label 7 'task' \
	-gltsym 'SYM: +uns1 +str1' -glt_label 8 'task BL1' \
	-gltsym 'SYM: +uns2 +str2' -glt_label 9 'task BL2' \
	-gltsym 'SYM: +uns3 +str3' -glt_label 10 'task BL3' \
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
