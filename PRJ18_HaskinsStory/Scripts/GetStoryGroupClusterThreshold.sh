#!/bin/bash
set -e

# GetStoryGroupClusterThreshold.sh
#
# Created 5/25/18 by DJ.
# Updated 3/5/19 by DJ - adjusted paths for a182_v2 version
# Updated 3/6/19 by DJ - use minu12 group results
# Updated 8/21/19 by DJ - more complete list of grpFiles

# declare variables
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
sbjBlurFile=$dataDir/ClustSimFiles/AllBlurEstimates.1D # all subjects concatenated
meanBlurFile=$dataDir/ClustSimFiles/MeanBlurEstimate.1D # mean across $sbjBlurFile
grpMask=$dataDir/GROUP_block_tlrc/MNI_mask_epiRes.nii
grpFiles="`ls $dataDir/IscResults/Group/3dLME*n68*.HEAD` `ls $dataDir/GROUP_block_tlrc/ttest_allSubj_*_minus12+tlrc.HEAD`" # all files with group stats

# set up
mkdir -p $dataDir/ClustSimFiles
rm -f $sbjBlurFile $meanBlurFile

# concatenate all blur estimates
for subj in ${okReadSubj[@]}
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
           -cmd 3dClustSim.grpACF.cmd -overwrite -prefix ClustSim.grpACF

# run 3drefit to attach 3dClustSim results to stats
cmd=`cat 3dClustSim.grpACF.cmd`
$cmd $grpFiles
