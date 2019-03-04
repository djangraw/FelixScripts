#!/bin/bash
set -e

# RunStoryGroupTtest_block_tlrc.sh
#
# Created 5/22/18 by DJ.
# Updated 5/23/18 by DJ -switched to _d2, MNI mask
# Updated 3/4/19 by DJ - a182_v2 version of filenames

# set up
source ./00_CommonVariables.sh
grpFolder=$dataDir/GROUP_block_tlrc
AFNI_HOME=`which afni` # Get AFNI directory
AFNI_HOME=${AFNI_HOME%/*} # remove afni (and last slash)
# make directory for output
mkdir -p $grpFolder

# Get file for each subject WITH COMPLETE READING PHENOTYPING
for subj in ${okReadSubj[@]}; do
    ln -s $dataDir/$subj/$subj.story/stats.block.${subj}_REML+tlrc.* $grpFolder/
done

# Make EPI-res mask
3dAutomask -overwrite -prefix ${grpFolder}/MNI_mask.nii ${AFNI_HOME}/MNI152_T1_2009c+tlrc
3dfractionize -overwrite -prefix ${grpFolder}/MNI_mask_epiRes.nii -template ${grpFolder}/stats.block.${okSubj[0]}_REML+tlrc -input ${grpFolder}/MNI_mask.nii

# Run Group T-Test on data
cd $grpFolder
unset topFile botFile
for i in ${!okReadSubj_top[@]}; do
  topFile[$i]="stats.block.${okReadSubj_top[$i]}_REML+tlrc"
done
unset botFile
for i in ${!okReadSubj_bot[@]}; do
  botFile[$i]="stats.block.${okReadSubj_bot[$i]}_REML+tlrc"
done

# Run T Test
echo "3dttest++ -zskip -brickwise -mask MNI_mask_epiRes.nii -overwrite -prefix ttest_allSubj_2grp -setA ${topFile[@]} -setB ${botFile[@]}"
3dttest++ -zskip -brickwise -mask MNI_mask_epiRes.nii -overwrite -prefix ttest_allSubj_2grp -setA ${topFile[@]} -setB ${botFile[@]}

echo "3dttest++ -zskip -brickwise -mask MNI_mask_epiRes.nii -overwrite -prefix ttest_allSubj_1grp -setA ${topFile[@]} ${botFile[@]}"
3dttest++ -zskip -brickwise -mask MNI_mask_epiRes.nii -overwrite -prefix ttest_allSubj_1grp -setA ${topFile[@]} ${botFile[@]}
