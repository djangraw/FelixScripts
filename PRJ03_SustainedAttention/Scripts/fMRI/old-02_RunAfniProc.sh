#!/bin/bash
# 02_RunAfniProc.sh
# ===============================================================   
# Usage:
#   02_RunAfniProc SubjectID
#
# Inputs:
#   * SubjectID, e.g., SBJ01
#
# Outputs:
#   * Construct and run Run afni_proc.py script
#
# Created 11/2/15 by DJ
# Updated 11/16/15 by DJ - specify blocks instead of do_block
# ===============================================================   

set -e # stop if error
source ./00_CommonVariables.sh

# USE THIS TO TAKE SUBJECT AS INPUT
SBJ=$1

# GET RUNS (KLUGE FOR NOW)
# echo2runs="${SBJ}_Run01_e2+orig.HEAD ${SBJ}_Run02_e2+orig.HEAD ${SBJ}_Run03_e2+orig.HEAD ${SBJ}_Run04_e2+orig.HEAD"
echo2runs=${SBJ}_Run*_e2+orig.HEAD
AlignFile=${SBJ}_Run01_e2+orig'[0]'
AnatomyFile=../D01_Anatomical/${SBJ}_Anat_bc_ns # leave off extension to include +orig and +tlrc
# stimFiles="${SBJ}_AllRuns_isotimes.1D ${SBJ}_AllRuns_foctimes.1D ${SBJ}_AllRuns_distimes.1D ${SBJ}_AllRuns_xpos.1D ${SBJ}_AllRuns_ypos.1D" # stimulus (or eye position?) .1D files
# stimTypes="times times times AM2 AM2" # (options: times AM1 AM2 IM file)
# move to directory
cd ${PRJDIR}/PrcsData/${SBJ}/D00_OriginalData/

# set options
TRsToRemove=3
blurFwhm=0
timestamp=$(date +%m%d_%H%M)
scriptname=proc_${SBJ}_${timestamp}

# CONSTRUCT SCRIPT
afni_proc.py -subj_id ${SBJ} \
	-dsets ${echo2runs} \
	-out_dir ${PRJDIR}/Results/${SBJ}/AfniProc \
	-blocks despike tshift align tlrc volreg mask regress \
	-copy_anat ${AnatomyFile} \
	-anat_has_skull no \
	-tcat_remove_first_trs ${TRsToRemove} \
	-align_opts_aea -giant_move \
	-volreg_base_dset ${AlignFile}+orig'[0]' \
	-volreg_tlrc_warp \
	-mask_segment_anat yes \
	-regress_motion_per_run \
	-regress_censor_motion 0.2 \
	-regress_censor_outliers 0.1 \
	-regress_bandpass 0.01 0.1 \
	-regress_apply_mot_types demean deriv \
	-regress_est_blur_errts \
	-script ${scriptname} \
	-bash
	
	
# regress_bandpass: DON'T do this before MEICA, but after should be ok

# -do_block align despike tlrc \ # includes blur and scale blocks, which we don't want for single-subject meica.
# -blur_size ${blurFwhm} \
	
# -regress_stim_files ${stimFiles} \
# -regress_stim_types ${stimTypes} \
	
# -dsets ${echo2runs[@]} \ # if using array
# -do_block ricor
# -volreg_align_e2a \ # align EPI to anat instead of other way around
# -ricor_regress_method per-run #(or across-runs?)
# -ricor_regs_nfirst ${TRsToRemove} \
# -ricor_regs ${SBJ}/RICOR/r*.slibase.1D \ # run RetroTs.m first?
# -tlrc_anat # run @auto_tlrc on anat dataset
# -tlrc_no_ss # don't include skull stripping in tlrc step?
# -anat_uniform_method none \
# -mask_apply anat # by default, the 'extents' mask is applied.
# -regress_3dD_stop # stop after generating the X-matrix
# -regress_anaticor_fast # use Hang Joon's anaticor method
# -regress_apply_ricor yes # apply ricor regs in final regression
# -regress_run_clustsim no \ # don't get clusters