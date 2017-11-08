#!/bin/bash

#  RunReadingRegAna.sh
#
# USAGE:
# bash RunReadingRegAna.sh $outFolder $iSubj1 $iSubj2 ... $iSubjN
#
# INPUTS:
# -outFolder is the ${PRJDIR}/Results/ subfolder where output files will be saved.
# -iSubjX is the index of a subject in the 'subjects' array found in 00_CommonVariables.sh.
#
# Created 10/16/17 by DJ.

# Set up
# Get subjects and folders arrays
source 00_CommonVariables.sh

# Parse inputs
outFolder=$1 # where results should be saved
shift
iSubjects=( "$@" )
echo "Subject Indices: ${iSubjects[@]}"

# Get path to output folder
outPath=${PRJDIR}/Results/${outFolder}
mkdir -p $outPath
cd $outPath

# Declare constants
let nOkSubj=${#iSubjects[@]}
let iLastSubj=nOkSubj-1

# START REGANA COMMAND
echo "3dRegAna -rows $nOkSubj -cols 1 \\" > ${outPath}/ReadingRegAnaCommand.sh

echo "=== BLURRING, MASKING, AND MAKING LINKS... ==="
for i in `seq 0 $iLastSubj`;
do
    # SET UP
    subj=${subjects[${iSubjects[$i]}]}
    folder=${folders[${iSubjects[$i]}]}
    echo "===Subject ${subj}..."
    # cd ${PRJDIR}/Results/${subj}/${folder}
    # # BLUR COEF SUB-BRICKS
    # 3dmerge -1blur_fwhm 4.0 -doall -overwrite -prefix rm.coef_ReadingGlt.${subj}.blur_fwhm4p0 stats_ReadingGlt.${subj}_REML+tlrc'[1..$(3)]' # only _Coef bricks
    # # MASK BLURRED DATA
    # 3dcalc -a rm.coef_ReadingGlt.${subj}.blur_fwhm4p0+tlrc \
    #    -b mask_anat.${subj}+tlrc                            \
    #    -expr 'a * b'       \
    #    -overwrite \
    #    -prefix coef_ReadingGlt.${subj}.blur_fwhm4p0.scale
    # # CLEAN UP
    # # rm rm.coef_ReadingGlt.${subj}.blur_fwhm4p0+tlrc* rm.mean_all_runs.${subj}+tlrc*
    # rm rm.coef_ReadingGlt.${subj}.blur_fwhm4p0+tlrc*
    # RECORD OUTPUT NAME
    outName[$i]=coef_ReadingGlt.${subj}.blur_fwhm4p0.scale+tlrc
    # MAKE SHORTCUT
    # ln -sf ${PRJDIR}/Results/${subj}/${folder}/${outName[$i]}* ${outPath}/
    # BUILD REGANA COMMAND
    echo "-xydata 1 ${outPath}/${outName[$i]} \\" >> ${outPath}/ReadingRegAnaCommand.sh
done
echo "-model 1:0 -rmsmin 0 -bucket 0 ReadingRegAnaOutput" >> ${outPath}/ReadingRegAnaCommand.sh

# BUILD & RUN 3DTTEST++ COMMAND
cd ${outPath}
echo "3dttest++ -toz -zskip -brickwise -overwrite -prefix ttest_ReadingGlt -setA ${outName[@]}"
# 3dttest++ -toz -zskip -brickwise -overwrite -prefix ttest_ReadingGlt -setA ${outName[@]}

# RUN 3dRegAna COMMAND
cat ${outPath}/ReadingRegAnaCommand.sh
# source ReadingRegAnaCommand.sh

# ADD ATLAS
# AFNI_HOME="/usr/local/apps/afni/current/linux_openmp_64"
# ln -sf ${AFNI_HOME}/MNI_caez_N27+tlrc.* ./
