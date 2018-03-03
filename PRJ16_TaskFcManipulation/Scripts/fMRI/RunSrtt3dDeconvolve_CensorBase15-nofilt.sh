#!/bin/bash

# RunSrtt3dDeconvolve_CensorBase15-nofilt.sh
#
# Censor out baseline TRs, then regress out nuisance regressors (motion and WM/CSF timecourses).
#
# USAGE:
#   RunSrtt3dDeconvolve_CensorBase15-nofilt.sh $subj
# INPUTS:
# -subj is a string indicating the subject name, e.g., tb0065.
#
# Created 3/1/18 by DJ based on an afni_proc_srtt_v3 script and RemoveSrttNuisanceRegressors.sh.

# parse inputs
subj=$1

# move into directory
cd /data/jangrawdc/PRJ16_TaskFcManipulation/RawData/$subj/$subj.srtt_v3


# Add baseline blocks to censor files
# Use MATLAB script WriteBaselineCensorFiles.m to create censor_${subj}_combined_2_nobase.1D

# run 3dDeconvolve with WM/CSF regressors to get stats
3dDeconvolve -input pb05.$subj.r*.scale+tlrc.HEAD                            \
    -censor censor_${subj}_combined_2_nobase.1D                              \
    -polort 3                                                                \
    -local_times                                                             \
    -num_stimts 20                                                           \
    -stim_times_AM1 1 stimuli/bl1_c1_unstr.txt 'dmBLOCK(1)'                  \
    -stim_label 1 uns1                                                       \
    -stim_times_AM1 2 stimuli/bl2_c1_unstr.txt 'dmBLOCK(1)'                  \
    -stim_label 2 uns2                                                       \
    -stim_times_AM1 3 stimuli/bl3_c1_unstr.txt 'dmBLOCK(1)'                  \
    -stim_label 3 uns3                                                       \
    -stim_times_AM1 4 stimuli/bl1_c2_str.txt 'dmBLOCK(1)'                    \
    -stim_label 4 str1                                                       \
    -stim_times_AM1 5 stimuli/bl2_c2_str.txt 'dmBLOCK(1)'                    \
    -stim_label 5 str2                                                       \
    -stim_times_AM1 6 stimuli/bl3_c2_str.txt 'dmBLOCK(1)'                    \
    -stim_label 6 str3                                                       \
    -stim_file 7 motion_demean.1D'[0]' -stim_base 7 -stim_label 7 roll_01    \
    -stim_file 8 motion_demean.1D'[1]' -stim_base 8 -stim_label 8 pitch_01   \
    -stim_file 9 motion_demean.1D'[2]' -stim_base 9 -stim_label 9 yaw_01     \
    -stim_file 10 motion_demean.1D'[3]' -stim_base 10 -stim_label 10 dS_01   \
    -stim_file 11 motion_demean.1D'[4]' -stim_base 11 -stim_label 11 dL_01   \
    -stim_file 12 motion_demean.1D'[5]' -stim_base 12 -stim_label 12 dP_01   \
    -stim_file 13 motion_deriv.1D'[0]' -stim_base 13 -stim_label 13 roll_02  \
    -stim_file 14 motion_deriv.1D'[1]' -stim_base 14 -stim_label 14 pitch_02 \
    -stim_file 15 motion_deriv.1D'[2]' -stim_base 15 -stim_label 15 yaw_02   \
    -stim_file 16 motion_deriv.1D'[3]' -stim_base 16 -stim_label 16 dS_02    \
    -stim_file 17 motion_deriv.1D'[4]' -stim_base 17 -stim_label 17 dL_02    \
    -stim_file 18 motion_deriv.1D'[5]' -stim_base 18 -stim_label 18 dP_02    \
    -stim_file 19 WM_Timecourse.1D -stim_base 19 -stim_label 19 WM    \
    -stim_file 20 CSF_Timecourse.1D -stim_base 20 -stim_label 20 CSF    \
    -num_glt 10                                                              \
    -gltsym 'SYM: +uns1 +uns2 +uns3'                                         \
    -glt_label 1 unstructured                                                \
    -gltsym 'SYM: +str1 +str2 +str3'                                         \
    -glt_label 2 structured                                                  \
    -gltsym 'SYM: +str1 +str2 +str3 -uns1 -uns2 -uns3'                       \
    -glt_label 3 structured-unstructured                                     \
    -gltsym 'SYM: +str1 -uns1'                                               \
    -glt_label 4 'structured-unstructured BL1'                               \
    -gltsym 'SYM: +str2 -uns2'                                               \
    -glt_label 5 'structured-unstructured BL2'                               \
    -gltsym 'SYM: +str3 -uns3'                                               \
    -glt_label 6 'structured-unstructured BL3'                               \
    -gltsym 'SYM: +str1 +str2 +str3 +uns1 +uns2 +uns3'                       \
    -glt_label 7 task                                                        \
    -gltsym 'SYM: +uns1 +str1'                                               \
    -glt_label 8 'task BL1'                                                  \
    -gltsym 'SYM: +uns2 +str2'                                               \
    -glt_label 9 'task BL2'                                                  \
    -gltsym 'SYM: +uns3 +str3'                                               \
    -glt_label 10 'task BL3'                                                 \
    -jobs 10                                                                 \
    -fout -tout                                                              \
    -x1D_stop                                                                \
    -fitts fitts.censorbase15-nofilt.${subj}                                              \
    -errts errts.censorbase15-nofilt.${subj}                                              \
    -bucket stats.censorbase15-nofilt.${subj}
# NOTE: x1D_stop is included to stop 3dDeconvolve from running. 3dREMLfit should still run as before.

# if 3dDeconvolve fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
fi


# -- execute the 3dREMLfit script, written by 3dDeconvolve --
mv stats.REML_cmd stats.censorbase15-nofilt.REML_cmd
tcsh -x stats.censorbase15-nofilt.REML_cmd
mv 3dREMLfit.err 3dREMLfit.censorbase15-nofilt.err # to avoid confusing with old version
