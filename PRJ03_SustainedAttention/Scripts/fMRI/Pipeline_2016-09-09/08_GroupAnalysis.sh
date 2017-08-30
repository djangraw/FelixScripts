#!/bin/bash
# 08_GroupAnalysis.sh
#
# Analyze Group Contrasts using outputs of 05p2_RunStimRegression.tcsh
#  
# USAGE:
#   bash 08_GroupAnalysis.sh $outFolder ${iSubjects[@]}
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
# Created 2/8/16 by DJ.

# Get subjects and folders arrays
source 00_CommonVariables.sh

# Parse inputs
outFolder=$1
shift
iSubjects=( "$@" )
echo ${iSubjects[@]}

# Get path to output folder
outPath=${PRJDIR}/Results/${outFolder}
mkdir -p $outPath

let nOkSubj=${#iSubjects[@]}
let iLastSubj=nOkSubj-1

for i in `seq 0 $iLastSubj`;
do
    # SET UP
    subj=${subjects[${iSubjects[$i]}]}
    folder=${folders[${iSubjects[$i]}]}
    echo "===Subject ${subj}..."
    cd ${PRJDIR}/Results/${subj}/${folder}
    # BLUR COEF SUB-BRICKS
    3dmerge -1blur_fwhm 4.0 -doall -overwrite -prefix rm.coef_stimOnly.${subj}.blur_fwhm4p0 stats_stimOnly.${subj}+tlrc'[1..$(3)]' # only _Coef bricks
    # NORMALIZE
    3dTstat -mean -overwrite -prefix rm.mean_all_runs.${subj} all_runs.${subj}+tlrc.
    3dcalc -a rm.coef_stimOnly.${subj}.blur_fwhm4p0+tlrc -b rm.mean_all_runs.${subj}+tlrc \
           -c mask_anat.${subj}+tlrc                            \
           -expr 'c * min(200, a/b*100)'       \
           -overwrite \
           -prefix coef_stimOnly.${subj}.blur_fwhm4p0.scale
    # CLEAN UP
    rm rm.coef_stimOnly.${subj}.blur_fwhm4p0+tlrc* rm.mean_all_runs.${subj}+tlrc*
    # RECORD OUTPUT NAME
    outName[$i]=coef_stimOnly.${subj}.blur_fwhm4p0.scale+tlrc
    # MAKE SHORTCUT
    ln -sf ${PRJDIR}/Results/${subj}/${folder}/${outName[$i]}* ${outPath}/
    
done

# BUILD 3DTTEST++ COMMAND
cd ${outPath}
echo "3dttest++ -toz -zskip -brickwise -overwrite -prefix ttest_stimOnly -setA ${outName[@]}"
3dttest++ -toz -zskip -brickwise -overwrite -prefix ttest_stimOnly -setA ${outName[@]}

# ADD ATLAS
ln -sf ${AFNI_HOME}/TT_N27+tlrc.* ./
