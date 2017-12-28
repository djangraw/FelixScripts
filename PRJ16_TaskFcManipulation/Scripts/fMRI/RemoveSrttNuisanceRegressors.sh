#!/bin/bash

# RemoveSrttNuisanceRegressors.sh
#
# Regress out nuisance regressors like motion and polynomials.
#
# Created 8/16/17 by DJ.
# Update 12/27/17 by DJ - updated for srtt_v2 analysis (MNI space)

# parse inputs
subj=$1

# move into directory
cd /data/jangrawdc/PRJ16_TaskFcManipulation/RawData/$subj/$subj.srtt_v2

# run 3dDeconvolve
# TODO: include mot_deriv.1D? Separate motion by run?
# TODO: don't blur, but scale data?
3dDeconvolve -input pb04.$subj.r*.blur+tlrc.HEAD                         \
    -censor censor_${subj}_combined_2.1D                                 \
    -polort 3                                                            \
    -local_times                                                         \
    -num_stimts 6                                                       \
    -stim_file 1 motion_demean.1D'[0]' -stim_base 1 -stim_label 1 roll   \
    -stim_file 2 motion_demean.1D'[1]' -stim_base 2 -stim_label 2 pitch  \
    -stim_file 3 motion_demean.1D'[2]' -stim_base 3 -stim_label 3 yaw    \
    -stim_file 4 motion_demean.1D'[3]' -stim_base 4 -stim_label 4 dS  \
    -stim_file 5 motion_demean.1D'[4]' -stim_base 5 -stim_label 5 dL  \
    -stim_file 6 motion_demean.1D'[5]' -stim_base 6 -stim_label 6 dP  \
    -jobs 10                                                          \
    -fout -tout -x1D_uncensored X_nuisance.nocensor.xmat.1D           \
    -x1D_stop                                                         \
    -overwrite

# regress out the nuisance factors
3dTproject -polort 0 -input pb04.$subj.r*.blur+tlrc.HEAD                    \
           -censor censor_${subj}_combined_2.1D -cenmode ZERO                 \
           -ort X_nuisance.nocensor.xmat.1D \
           -overwrite -prefix rm.all_runs_nonuisance.$subj+tlrc.HEAD

# scale results
3dTstat -mean -overwrite -prefix rm.mean_all_runs.${subj} all_runs.${subj}+tlrc.
3dcalc -a rm.all_runs_nonuisance.${subj}+tlrc -b rm.mean_all_runs.${subj}+tlrc \
       -c mask_anat.${subj}+tlrc                            \
       -expr 'c * min(200, a/b*100)'       \
       -overwrite \
       -prefix all_runs_nonuisance.${subj}.scale

# Clean up
rm rm.all_runs_nonuisance.$subj+tlrc*
