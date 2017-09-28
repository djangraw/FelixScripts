#!/bin/tcsh

# TEMP_RemoveDriftAndMotionFromEcho2Data.tcsh
#
# Created 9/27/17 by DJ.

set subj = $1
set outFolder = AfniProc_MultiEcho_2016-09-22

# assign base directory
set PRJDIR = /data/jangrawdc/PRJ03_SustainedAttention

# assign output directory name
set output_dir = ${PRJDIR}/Results/${subj}/${outFolder}

# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $output_dir

# find nRuns automatically if it was not given as input
set nRuns = (`ls pb05.$subj.r*.meica.nii | wc -w`)

if ( $nRuns == 3 ) then
  # Declare number of nuisance regressors, excluding stimulus regressors
  set iLastNuisanceReg = 50 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based)

else if ( $nRuns == 4 ) then
  set iLastNuisanceReg = 67 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based)

else if ( $nRuns == 5 ) then
  set iLastNuisanceReg = 84 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based)

else if ( $nRuns == 6 ) then
  set iLastNuisanceReg = 101 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based)

endif

# -- use 3dTproject to project out regression matrix WITHOUT STIM REGRESSORS --
# 3dTproject -polort 0 -input pb04.$subj.r*_e2.in.nii.gz                    \
#            -censor censor_${subj}_combined_2.1D -cenmode ZERO                 \
#            -ort X.nocensor.xmat.1D[0..${iLastNuisanceReg}] -prefix TEMP_e2.errts.${subj}.tproject

# -- use 3dTcat to combine the original runs into something AFNI-MATLAB can read.
3dTcat -prefix TEMP_e2.all pb04.$subj.r*_e2.in.nii.gz
