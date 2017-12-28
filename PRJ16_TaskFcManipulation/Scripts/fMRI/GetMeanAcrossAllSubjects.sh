#!/bin/bash

# GetMeanAcrossAllSubjects.sh
#
# Usage: bash GetMeanAcrossAllSubjects.sh <outFolder> <iSubj1> <iSubj2> ...
#
# Created 12/27/17 by DJ.

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
  outName[$i]=all_runs_nonuisance.${subj}.scale+tlrc
  ln -sf ${PRJDIR}/RawData/${subj}/${folder}/${outName[$i]}* ${outPath}/
done

# Average across subjects
cd $outPath
3dMean -non_zero -overwrite -prefix MEAN_all_runs_nonuisance ${outName[@]}
