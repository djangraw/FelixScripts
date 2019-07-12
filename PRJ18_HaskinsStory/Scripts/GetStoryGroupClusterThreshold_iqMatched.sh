#!/bin/bash
set -e

# GetStoryGroupClusterThreshold_iqMatched.sh
#
# Created 5/25/18 by DJ.
# Updated 3/5/19 by DJ - adjusted paths for a182_v2 version
# Updated 3/6/19 by DJ - use minu12 group results
# Updated 7/11/19 by DJ - moved to 40 iqMatched subjects

# declare variables
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
sbjBlurFile=$dataDir/ClustSimFiles/AllBlurEstimates_iqMatched.1D # all subjects concatenated
meanBlurFile=$dataDir/ClustSimFiles/MeanBlurEstimate_iqMatched.1D # mean across $sbjBlurFile
grpMask=$dataDir/GROUP_block_tlrc/MNI_mask_epiRes.nii

grpFiles="$dataDir/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n40-iqMatched_Automask+tlrc "\
"$dataDir/IscResults/Group/3dLME_2Grps_iqMedSplit_n40-readMatched_Automask+tlrc" # all files with group stats

# set up
mkdir -p $dataDir/ClustSimFiles
rm -f $sbjBlurFile $meanBlurFile

# concatenate all blur estimates
for subj in ${okReadSubj_iqMatched[@]}
do
  cd $dataDir/$subj/${subj}.story
  1dcat blur_est.$subj.1D[0..2]{3} >> $sbjBlurFile
done

# average
meanBlur=`3dTstat -prefix - $sbjBlurFile\'`
echo $meanBlur > $meanBlurFile

# call 3dClustSim
cd $dataDir/ClustSimFiles
3dClustSim -both -mask $grpMask -acf $meanBlur -LOTS  \
           -cmd 3dClustSim_iqMatched.grpACF.cmd -overwrite -prefix ClustSim_iqMatched.grpACF

# run 3drefit to attach 3dClustSim results to stats
cmd=`cat 3dClustSim_iqMatched.grpACF.cmd`
$cmd $grpFiles
