#!/bin/bash

# Run echo-difference analysis on 100-runs data.
# GetMeanCombinedDifference.sh
#
# SAMPLE USAGE:
# bash GetMeanCombinedDifference.sh outPrefix fileList ...
#
# INPUTS:
# 1. prefix used to name output files
# 1. list of filenames (array of .BRIK files) e.g., files=( $(ls *_R*.BRIK) ); ${files[@]:0:y}
# 
# OUTPUTS:
# saves <outputPrefix>+orig.BRIK and .HEAD to current directory
# 
# Created 8/10/15 by DJ based on SingleRun_detrend_123.

# stop if error 
set -e

# parse inputs
fileList=( "$@" )
nFiles=${#fileList[@]}

# get subject and mask prefix
SBJ=${fileList[0]:0:5}
maskPrefix=${SBJ}_MaskAllTaskRuns
scanname=e1m3

echo $nFiles files found.

for (( run=1; run<=${nFiles}; run++ ))
do
	iRun=$((run-1))
  # Set up
  runID=`printf %03d ${run}`
  echo Run $runID
  # Remove files
  if [ -f ${SBJ}_${scanname}_Run${runID}.xmat.1D ]; then rm ${SBJ}_${scanname}_Run${runID}.xmat.1D; fi
  if [ -f ${SBJ}_${scanname}_Run${runID}.REML_cmd ]; then rm ${SBJ}_${scanname}_Run${runID}.REML_cmd; fi
  if [ -f ${SBJ}_${scanname}_Run${runID}.errts_REML+orig.HEAD ]; then rm ${SBJ}_${scanname}_Run${runID}.errts_REML+orig.*; fi
  if [ -f ${SBJ}_${scanname}_Run${runID}.bucket_REML+orig.HEAD ]; then rm ${SBJ}_${scanname}_Run${runID}.bucket_REML+orig.*; fi
  if [ -f ${SBJ}_${scanname}_Run${runID}.bucket_REMLvar+orig.HEAD ]; then rm ${SBJ}_${scanname}_Run${runID}.bucket_REMLvar+orig.*; fi

	  echo 1
  # Get motion/censor file  
  censorLoc=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/CrossRunAnalyses.AnatAlign/${SBJ}/MotionAndCensorFiles
  # Run GLM
  3dDeconvolve -overwrite -jobs 32 -mask ${maskPrefix}+orig -float -polort 3 -input ${fileList[$iRun]} \
     -censor ${censorLoc}/${SBJ}_Run${runID}_e2_Censor.1D \
     -num_stimts 1 \
     -stim_times 1 '1D: 2 62 122 182 242' 'TENT(0,58,30)' -stim_label 1 Task \
     -bucket ${SBJ}_${scanname}_Run${runID}.bucket \
     -errts ${SBJ}_${scanname}_Run${runID}.errts \
     -x1D_stop 
  chmod ug+x ${SBJ}_${scanname}_Run${runID}.REML_cmd 
  ./${SBJ}_${scanname}_Run${runID}.REML_cmd

  echo 2
  3dTstat -overwrite -mask ${maskPrefix}+orig -sigma -prefix ${SBJ}_${scanname}_Run${runID}.errts.sigma ${SBJ}_${scanname}_Run${runID}.errts_REML+orig
  
  echo 3
  outFile[$iRun]=${SBJ}_${scanname}_Run${runID}.bucket_REML+orig[1..30]
done

# get mean across runs
3dMean -overwrite -prefix ${SBJ}_${scanname}_${nFiles}runsMean.bucket_REML+orig ${outFile[@]}