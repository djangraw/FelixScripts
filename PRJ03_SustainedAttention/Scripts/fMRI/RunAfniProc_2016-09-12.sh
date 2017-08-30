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
# Updated 9/12/16 by DJ - removed bandpass & volreg_tlrc_warp (stay in orig space until very end), switch to MNI, add in stim regression & reml option
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

# set up GLM
stimFiles="${PRJDIR}/stimuli/${SBJ}_attendedSpeech.1D ${PRJDIR}/stimuli/${SBJ}_ignoredSpeech.1D ${PRJDIR}/stimuli/${SBJ}_attendedNoise.1D ${PRJDIR}/stimuli/${SBJ}_ignoredNoise.1D ${PRJDIR}/stimuli/${SBJ}_fixation.1D" # stimulus (or eye position?) .1D files
stimLabels="attendedSpeech ignoredSpeech attendedNoise ignoredNoise fixation"
stimTypes="AM1 AM1 AM1 AM1 AM1" # (options: times AM1 AM2 IM file)
stimBases="dmBLOCK4(1)" # the required single quotes will be inserted automatically by afni_proc
# Maybe use stimBases="dmUBLOCK" for betas that can be used in group analysis (see help file and/or Gang)



# CONSTRUCT SCRIPT
afni_proc.py -subj_id ${SBJ} \
	-dsets ${echo2runs} \
	-out_dir ${PRJDIR}/Results/${SBJ}/AfniProc \
	-blocks despike tshift align volreg mask scale regress tlrc \
	-copy_anat ${AnatomyFile} \
	-anat_has_skull no \
	-tcat_remove_first_trs ${TRsToRemove} \
	-align_opts_aea -giant_move \
	-volreg_base_dset ${AlignFile}+orig'[0]' \
	-mask_segment_anat yes \
	-regress_motion_per_run \
	-regress_censor_motion 0.2 \
	-regress_censor_outliers 0.1 \
	-regress_apply_mot_types demean deriv \
	-regress_est_blur_errts \
    -regress_stim_times $stimFiles \
    -regress_stim_labels $stimLabels \
    -regress_stim_types $stimTypes \
    -regress_basis $stimBases \
    -regress_global_times \
    -test_stim_files no \
    -regress_3dD_stop \
    -regress_reml_exec \
    -regress_opts_3dD \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -tlrc_base MNI_caez_N27+tlrc \
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