#!/bin/bash

# RemoveSrttNuisanceRegressors.sh
#
# Regress out nuisance regressors like motion and polynomials.
#
# USAGE:
#   RemoveSrttNuisanceRegressors.sh $subj $remWmCsf
# INPUTS:
# -subj is a string indicating the subject name, e.g., tb0065.
# -remWmCsf is "true" if you want to remove the CSF and WM timecourses.
#   Otherwise, do not include these as nuisance regressors.
#
# Created 8/16/17 by DJ.
# Update 12/27/17 by DJ - updated for srtt_v2 analysis (MNI space)
# Update 1/2/18 by DJ - updated for srtt_v3 analysis (pb05, motion derivs, no scaling)
# Updated 1/29/18 by DJ - added remWmCsf input

# parse inputs
subj=$1
remWmCsf=$2

# move into directory
cd /data/jangrawdc/PRJ16_TaskFcManipulation/RawData/$subj/$subj.srtt_v3

if [ $remWmCsf == "true" ]; then
    # run 3dDeconvolve
    3dDeconvolve -input pb05.$subj.r*.scale+tlrc.HEAD                            \
        -censor censor_${subj}_combined_2.1D                                     \
        -polort 3                                                                \
        -local_times                                                             \
        -num_stimts 14                                                           \
        -stim_file 1 motion_demean.1D'[0]' -stim_base 1 -stim_label 1 roll_01    \
        -stim_file 2 motion_demean.1D'[1]' -stim_base 2 -stim_label 2 pitch_01   \
        -stim_file 3 motion_demean.1D'[2]' -stim_base 3 -stim_label 3 yaw_01     \
        -stim_file 4 motion_demean.1D'[3]' -stim_base 4 -stim_label 4 dS_01   \
        -stim_file 5 motion_demean.1D'[4]' -stim_base 5 -stim_label 5 dL_01   \
        -stim_file 6 motion_demean.1D'[5]' -stim_base 6 -stim_label 6 dP_01   \
        -stim_file 7 motion_deriv.1D'[0]' -stim_base 7 -stim_label 7 roll_02  \
        -stim_file 8 motion_deriv.1D'[1]' -stim_base 8 -stim_label 8 pitch_02 \
        -stim_file 9 motion_deriv.1D'[2]' -stim_base 9 -stim_label 9 yaw_02   \
        -stim_file 10 motion_deriv.1D'[3]' -stim_base 10 -stim_label 10 dS_02    \
        -stim_file 11 motion_deriv.1D'[4]' -stim_base 11 -stim_label 11 dL_02    \
        -stim_file 12 motion_deriv.1D'[5]' -stim_base 12 -stim_label 12 dP_02    \
        -stim_file 13 WM_Timecourse.1D -stim_base 13 -stim_label 13 WM    \
        -stim_file 14 CSF_Timecourse.1D -stim_base 14 -stim_label 14 CSF    \
        -jobs 10                                                          \
        -fout -tout -x1D_uncensored X_nuisance_wmcsf.nocensor.xmat.1D           \
        -x1D_stop                                                         \
        -overwrite

        # regress out the nuisance factors
        3dTproject -polort 0 -input pb05.$subj.r*.scale+tlrc.HEAD                    \
                   -censor censor_${subj}_combined_2.1D -cenmode ZERO                 \
                   -ort X_nuisance_wmcsf.nocensor.xmat.1D \
                   -overwrite -prefix all_runs_nonuisance_nowmcsf.$subj+tlrc.HEAD

else
  # run 3dDeconvolve
  3dDeconvolve -input pb05.$subj.r*.scale+tlrc.HEAD                            \
      -censor censor_${subj}_combined_2.1D                                     \
      -polort 3                                                                \
      -local_times                                                             \
      -num_stimts 12                                                           \
      -stim_file 1 motion_demean.1D'[0]' -stim_base 1 -stim_label 1 roll_01    \
      -stim_file 2 motion_demean.1D'[1]' -stim_base 2 -stim_label 2 pitch_01   \
      -stim_file 3 motion_demean.1D'[2]' -stim_base 3 -stim_label 3 yaw_01     \
      -stim_file 4 motion_demean.1D'[3]' -stim_base 4 -stim_label 4 dS_01   \
      -stim_file 5 motion_demean.1D'[4]' -stim_base 5 -stim_label 5 dL_01   \
      -stim_file 6 motion_demean.1D'[5]' -stim_base 6 -stim_label 6 dP_01   \
      -stim_file 7 motion_deriv.1D'[0]' -stim_base 7 -stim_label 7 roll_02  \
      -stim_file 8 motion_deriv.1D'[1]' -stim_base 8 -stim_label 8 pitch_02 \
      -stim_file 9 motion_deriv.1D'[2]' -stim_base 9 -stim_label 9 yaw_02   \
      -stim_file 10 motion_deriv.1D'[3]' -stim_base 10 -stim_label 10 dS_02    \
      -stim_file 11 motion_deriv.1D'[4]' -stim_base 11 -stim_label 11 dL_02    \
      -stim_file 12 motion_deriv.1D'[5]' -stim_base 12 -stim_label 12 dP_02    \
      -jobs 10                                                          \
      -fout -tout -x1D_uncensored X_nuisance.nocensor.xmat.1D           \
      -x1D_stop                                                         \
      -overwrite

      # regress out the nuisance factors
      3dTproject -polort 0 -input pb05.$subj.r*.scale+tlrc.HEAD                    \
                 -censor censor_${subj}_combined_2.1D -cenmode ZERO                 \
                 -ort X_nuisance.nocensor.xmat.1D \
                 -overwrite -prefix all_runs_nonuisance.$subj+tlrc.HEAD
fi
