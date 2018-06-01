#!/bin/bash
set -e

# GetStoryGroupClusterThreshold.sh
#
# Created 5/25/18 by DJ.

# declare variables
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
sbjBlurFile=$dataDir/ClustSimFiles/AllBlurEstimates_d2.1D # all subjects concatenated
meanBlurFile=$dataDir/ClustSimFiles/MeanBlurEstimate_d2.1D # mean across $sbjBlurFile
grpMask=$dataDir/GROUP_block_tlrc_d2/MNI_mask_epiRes.nii
grpFiles="$dataDir/IscResults_d2/Pairwise/3dLME_2Grps_readScoreMedSplit_n42_Automask+tlrc "\
"$dataDir/IscResults_d2/Pairwise/3dLME_OneGroup_n42_Automask+tlrc "\
"$dataDir/GROUP_block_tlrc_d2/ttest_allSubj_2grp+tlrc "\
"$dataDir/GROUP_block_tlrc_d2/ttest_allSubj_1grp+tlrc" # all files with group stats

# set up
mkdir -p $dataDir/ClustSimFiles
rm -f $sbjBlurFile $meanBlurFile

# concatenate all blur estimates
for subj in ${okReadSubj[@]}
do
  cd $dataDir/$subj/${subj}.storyISC_d2
  1dcat blur_est.$subj.1D[0..2]{3} >> $sbjBlurFile
done

# average
meanBlur=`3dTstat -prefix - $sbjBlurFile\'`
echo $meanBlur > $meanBlurFile

# call 3dClustSim
cd $dataDir/ClustSimFiles
3dClustSim -both -mask $grpMask -acf $meanBlur -LOTS  \
           -cmd 3dClustSim.grpACF.cmd -prefix ClustSim.grpACF

# run 3drefit to attach 3dClustSim results to stats
cmd=`cat 3dClustSim.grpACF.cmd`
$cmd $grpFiles
