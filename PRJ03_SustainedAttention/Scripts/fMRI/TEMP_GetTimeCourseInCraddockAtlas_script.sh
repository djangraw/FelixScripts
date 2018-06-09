#!/bin/bash
source /data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI/00_CommonVariables.sh

for subj in ${okSubjects[@]}; do
  epiFile="${PRJDIR}/Results/${subj}/AfniProc_MultiEcho_2016-09-22/errts.${subj}.tproject+tlrc"
  atlasFile=${PRJDIR}/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc
  outFile=${subj}_CraddockAtlas_200Rois_ts.1D
  echo "bash GetTimeCoursesInAtlas.sh $subj $epiFile $atlasFile $outFile"
done
