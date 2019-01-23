#!/bin/bash

# afni_A182fastloc_v2.0.sh
#
# Created 1/22/19 by DJ based on afni_A182.sh

module load afni

# Set top level directory structure
topdir=/data/NIMH_Haskins/a182_v2
# task=fastloc
# fsroot=$topdir/freesurfer
cd $topdir

for subj in $@
do
	cd $subj

	afni_proc.py -subj_id $subj -script afni_fastloc_${subj}.tcsh -out_dir $subj.fastloc \
	-dsets func_fastloc/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3D*.nii.gz \
	-anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -volreg_warp_dxyz 3 \
	-tlrc_opts_at -init_xform AUTO_CENTER \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 -volreg_align_to first  \
	-align_opts_aea -giant_move \
	-regress_stim_times stim_times/stim_times_fastloc/times* \
	-regress_stim_labels c1 c2 c3 c4 \
	-regress_local_times \
	-regress_basis 'GAM' \
	-regress_reml_exec \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-num_glt 13 \
	-gltsym 'SYM: +c1' -glt_label 1 'print' \
	-gltsym 'SYM: +c2' -glt_label 2 'speech' \
	-gltsym 'SYM: +c3' -glt_label 3 'false font' \
	-gltsym 'SYM: +c4' -glt_label 4 'vocod speech' \
	-gltsym 'SYM: +c1 -c3' -glt_label 5 'print-falsefont' \
	-gltsym 'SYM: +c2 -c4' -glt_label 6 'speech-vocod' \
	-gltsym 'SYM: +c1 -c2' -glt_label 7 'print-speech' \
	-gltsym 'SYM: +c3 -c4' -glt_label 8 'falsefont-vocod' \
	-gltsym 'SYM: +c1 +c2 -c3 -c4' -glt_label 9 'speech+print - falsefont+vocod' \
	-gltsym 'SYM: +c1 +c3 -c2 -c4' -glt_label 10 'print+falsefont - speech+vocod' \
	-gltsym 'SYM: +c1 -c2 -c3 +c4' -glt_label 11 'interaction' \
	-gltsym 'SYM: -c1 +c2' -glt_label 12 'speech-print' \
    -gltsym 'SYM: +c1 +c2' -glt_label 13 'speech+print' \
	-jobs 12 \
	-bash -execute

	cd ../
done
