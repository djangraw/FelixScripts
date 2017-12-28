#!/bin/bash
# RunGroupTtest.sh
#
# Analyze Group SRTT Contrasts using outputs of AfniProc
#
# USAGE:
#   bash RunGroupTtest.sh $outFolder ${iSubjects[@]}
#
# INPUTS:
#   - outFolder is a path (relative to the ${PRJDIR}/Results folder)
#     to the folder where you'd like the group results to save.
# 	- iSubjects is an array of the INDICES of subjects in the subjects
#     array that are deemed ok.
#
# OUTPUTS:
#	- Writes blurred output and normalized output for each subject, plus a group result.
#
# Created 12/19/17 by DJ based on PRJ03's 08_GroupAnalysis.sh.
# Updated 12/21/17 by DJ - remove normalization (it's already done now)
# Updated 12/27/17 by DJ - removed blur and coefOnly suffices, debugged.

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

for i in `seq 0 $iLastSubj`;
do
    # SET UP
    subj=${subjects[${iSubjects[$i]}]}
    folder=${folders[${iSubjects[$i]}]}
    echo "===Subject ${subj}..."
    cd ${PRJDIR}/RawData/${subj}/${folder}
    # EXTRACT COEF SUBBRICKS FROM STATS DATASET
    3dcalc -overwrite -prefix rm.coef.${subj} -a stats.${subj}_REML+tlrc'[1..$(3)]' -expr 'a' # only _Coef bricks
    # NORMALIZE
    3dTstat -mean -overwrite -prefix rm.mean_all_runs.${subj} all_runs.${subj}+tlrc.
    3dcalc -a rm.coef.${subj}+tlrc -b rm.mean_all_runs.${subj}+tlrc \
           -c mask_anat.${subj}+tlrc                            \
           -expr 'c * min(200, a/b*100)'       \
           -overwrite \
           -prefix coef.${subj}.scale
    # MASK BLURRED DATA
    3dcalc -a rm.coef.${subj}+tlrc \
       -b mask_anat.${subj}+tlrc \
       -expr 'a * b' \
       -overwrite \
       -prefix coef.${subj}.scale
    # CLEAN UP
    # rm rm.coef.${subj}+tlrc* rm.mean_all_runs.${subj}+tlrc*
    rm rm.coef.${subj}+tlrc*
    # RECORD OUTPUT NAME
    outName[$i]=coef.${subj}.scale+tlrc
    # MAKE SHORTCUT
    ln -sf ${PRJDIR}/RawData/${subj}/${folder}/${outName[$i]}* ${outPath}/

done

# BUILD 3DTTEST++ COMMAND
cd ${outPath}
echo "3dttest++ -toz -zskip -brickwise -overwrite -prefix ttest -setA ${outName[@]}"
3dttest++ -toz -zskip -brickwise -overwrite -prefix ttest -setA ${outName[@]}

# ADD ATLAS FILE
# ln -sf ${AFNI_HOME}/MNI_caez_N27+tlrc.* ./
