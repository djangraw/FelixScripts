#!/bin/bash
# RunGroupTtest.sh
#
# Analyze Group SRTT Contrasts using outputs of AfniProc
#
# USAGE:
#   bash RunGroupTtest.sh $outFolder $covarFile ${iSubjects[@]}
#
# INPUTS:
#   - outFolder is a path (relative to the ${PRJDIR}/Results folder)
#     to the folder where you'd like the group results to save.
#   - covarFile is a filename where the covariates are saved. if 'NONE', skip that step.
# 	- iSubjects is an array of the INDICES of subjects in the subjects
#     array that are deemed ok.
#
# OUTPUTS:
#	- Writes blurred output and normalized output for each subject, plus a group result.
#
# Created 12/19/17 by DJ based on PRJ03's 08_GroupAnalysis.sh.
# Updated 12/21/17 by DJ - remove normalization (it's already done now)
# Updated 12/27/17 by DJ - removed blur and coefOnly suffices, debugged.
# Updated 1/2/18 by DJ - updated for _v3 (no blur/norm, mask during t test)
# Updated 1/9/18 by DJ - added covarFile input, covariates step.

# Get subjects and folders arrays
source 00_CommonVariables.sh
AFNI_HOME=`which afni` # Get AFNI directory
AFNI_HOME=${AFNI_HOME%/*} # remove afni (and last slash)

# Parse inputs
outFolder=$1
shift
covarFile=$1
shift
iSubjects=( "$@" )
echo ${iSubjects[@]}

# Get path to output folder
outPath=${PRJDIR}/RawData/${outFolder}
# rm -rf $outPath
mkdir -p $outPath

for i in ${!iSubjects[@]};
do
    # SET UP
    subj=${subjects[${iSubjects[$i]}]}
    folder=${folders[${iSubjects[$i]}]}
    echo "===Subject ${subj}..."
    cd ${PRJDIR}/RawData/${subj}/${folder}
    # EXTRACT COEF SUBBRICKS FROM STATS DATASET
    # 3dcalc -overwrite -prefix coef.${subj} -a stats.${subj}_REML+tlrc'[1..$(3)]' -expr 'a' # only _Coef bricks
    # 3dcalc -overwrite -prefix coef.censorbase15-nofilt.${subj} -a stats.censorbase15-nofilt.${subj}_REML+tlrc'[1..$(3)]' -expr 'a' # only _Coef bricks
    3dcalc -overwrite -prefix coef.PPI.${subj} -a stats.PPI.${subj}_REML+tlrc'[2..$(3)]' -expr 'a' # only _Coef bricks
    # RECORD OUTPUT NAME
    # outName[$i]=coef.${subj}+tlrc
    # outName[$i]=coef.censorbase15-nofilt.${subj}+tlrc
    outName[$i]=coef.PPI.${subj}+tlrc
    # MAKE SHORTCUT
    ln -sf ${PRJDIR}/RawData/${subj}/${folder}/${outName[$i]}* ${outPath}/

done

# Make EPI-res mask
3dAutomask -overwrite -prefix ${outPath}/MNI_mask.nii ${AFNI_HOME}/MNI152_T1_2009c+tlrc
3dfractionize -overwrite -prefix ${outPath}/MNI_mask_epiRes.nii -template ${outPath}/${outName[0]} -input ${outPath}/MNI_mask.nii

# BUILD 3DTTEST++ COMMAND (SIMPLE)
cd ${outPath}
echo "3dttest++ -zskip -brickwise -mask MNI_mask_epiRes.nii -overwrite -prefix ttest_allSubj -setA ${outName[@]}"
3dttest++ -zskip -brickwise -mask MNI_mask_epiRes.nii -overwrite -prefix ttest_allSubj -setA ${outName[@]}

# 3DTTEST++ COMMAND (WITH COVARIATES)
if [ "$covarFile" != "NONE" ]; then
  echo "Running covariates step"
  # nT=`3dinfo -nT ${outName[0]}`
  # let lastBrick=$nT-1
  # for i in `seq 0 $lastBrick`;
  # do
  #   echo "3dttest++ -mask MNI_mask_epiRes.nii -overwrite -prefix ttest_allSubj -setA coef.*.HEAD[$i] -covariates $covarFile"
  #   3dttest++ -mask MNI_mask_epiRes.nii -overwrite -prefix ttest_allSubj_brick${i} -setA coef.*.HEAD[$i] -covariates $covarFile
  # done
  # # combine the results
  # 3dTcat -prefix ttest_allSubj_withCovariates_allBricks -overwrite ttest_allSubj_brick*.HEAD\

  # Function version
  bash ${scriptDir}/RunGroupTtestWithCovariates.sh coef. $covarFile ttest_allSubj_withCovariates
else
  echo "Skipping covariates step"
fi

# ADD ATLAS AND SUMA FILES
ln -sf /data/jangrawdc/SUMA/suma_MNI_N27/MNI_N27_SurfVol.nii ./
ln -sf /data/jangrawdc/SUMA/suma_MNI_N27 ./
ln -sf ${AFNI_HOME}/MNI152_T1_2009c+tlrc.* ./
