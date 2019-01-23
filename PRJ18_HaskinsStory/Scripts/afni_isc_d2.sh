#!/bin/bash

# afni_isc_d2.sh
#
# Created 5/22/18 by DJ based on afni_isc(_d1).sh - switched to MNI and added scale block.

module load afni

# Set top level directory structure
topdir=/data/NIMH_Haskins/a182
task=story
fsroot=$topdir/freesurfer
cd $topdir

for subj in $@
do
	cd $subj
	# run afni_proc.py to create a single subject processing script
	afni_proc.py -subj_id $subj                                                 \
		-script $subj.isc_d2 -scr_overwrite                                   \
		-out_dir ${subj}.storyISC_d2                                    \
		-blocks despike tshift align tlrc volreg blur mask scale regress                \
		-copy_anat ${fsroot}/$subj/SUMA/${subj}_SurfVol.nii  \
		-anat_has_skull yes \
		-anat_follower_ROI aaseg anat ${fsroot}/$subj/SUMA/aparc.a2009s+aseg_rank.nii        \
		          -anat_follower_ROI aeseg epi ${fsroot}/$subj/SUMA/aparc.a2009s+aseg_rank.nii        \
		          -anat_follower_ROI FSvent epi ${fsroot}/$subj/SUMA/FSmask_vent.nii                  \
		          -anat_follower_ROI FSWMe epi ${fsroot}/$subj/SUMA/FSmask_WM.nii                   \
		          -anat_follower_erode FSvent FSWMe                           \
		-tlrc_base MNI152_T1_2009c+tlrc 				\
		-dsets func_story/*ep2dbold*        				    										\
		-tcat_remove_first_trs 6                                            	\
		-align_opts_aea -giant_move 					    										\
		-tshift_opts_ts -tpattern alt+z2 				    										\
	   	-tlrc_NL_warp                                                       \
	    	-volreg_align_to MIN_OUTLIER                                        \
	    	-volreg_align_e2a                                                   \
	    	-volreg_tlrc_warp                                                   \
		-blur_size 6						 	    										\
	    	-regress_ROI_PC FSvent 3                                            \
	    	-regress_make_corr_vols aeseg FSvent                                \
	    	-regress_anaticor_fast                                              \
	    	-regress_anaticor_label FSWMe                                       \
	    	-regress_censor_motion 0.3                                          \
	    	-regress_censor_outliers 0.1                                        \
	    	-regress_apply_mot_types demean deriv                               \
	    	-regress_est_blur_epits                                             \
	    	-regress_est_blur_errts                                             \
	    	-regress_run_clustsim no					    										\
		-bash -execute

	cd $topdir

done
