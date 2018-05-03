#!/bin/bash

# GetMeanAcrossAllSubjects.sh
#
# Usage: bash GetMeanAcrossAllSubjects.sh <outFolder> <iSubj1> <iSubj2> ...
#
# Created 12/27/17 by DJ.
# Updated 1/2/18 by DJ - modified for _v3 analysis (removed scale suffix).
# Updated 2/26/18 by DJ - switched from all_runs_nonuisance to errts.nowmcsf

# Get subjects and folders arrays
source 00_CommonVariables.sh
AFNI_HOME='/data/jangrawdc/abin'

# Parse inputs
outFolder=$1
shift
iSubjects=( "$@" )
echo ${iSubjects[@]}

# Get path to output folder
outPath=${PRJDIR}/RawData/${outFolder}
mkdir -p $outPath

let nOkSubj=${#iSubjects[@]}
let iLastSubj=nOkSubj-1

# For each subject, write a link to the new folder
for i in `seq 0 $iLastSubj`;
do
  # SET UP
  subj=${subjects[${iSubjects[$i]}]}
  folder=${folders[${iSubjects[$i]}]}
  echo "===Subject ${subj}..."
  cd ${PRJDIR}/RawData/${subj}/${folder}

  # MAKE SHORTCUT
  # outName[$i]=all_runs_nonuisance.${subj}+tlrc
  # outName[$i]=errts.censorbase15-nofilt.${subj}_REML+tlrc
  outName[$i]=errts.PPI.${subj}_REML+tlrc
  ln -sf ${PRJDIR}/RawData/${subj}/${folder}/${outName[$i]}* ${outPath}/
done

# Average across subjects
cd $outPath
3dMean -non_zero -overwrite -prefix MEAN_all_runs_censorbase15-nofilt ${outName[@]}

# StdDev across subjects
3dMean -stdev -overwrite -prefix STD_all_runs_censorbase15-nofilt ${outName[@]}
