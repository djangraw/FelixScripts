#!/bin/bash
set -e

# Run inter-subject connectivity analysis on Haskins Story data.
# RunStoryPairwiseIscSwarm.sh
#
# INPUTS:
# 1. mask of voxels to include (.BRIK)
# 2. list of filenames (array of .BRIK files) e.g., files=( $(ls *_R*.BRIK) ); ${files[@]:0:y}
#
# OUTPUTS:
# saves ISC_<x>_<y>_story+tlrc and ISC_ttest<y>files+tlcr to outDir (defined in script)
#
# Created 5/17/18 by DJ based on RunIsc.sh (100-runs version).
# Updated 5/18/18 by DJ to do pairwise swarm.

# ---declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
outstarter="storyISC_"
outDir=${dataDir}/IscResults/Pairwise
swarmFile=${scriptDir}/IscSwarmCommand
rScript=${scriptDir}/IscRCommand
iscTable=${outDir}/StoryPairwiseIscTable.txt

cd $dataDir

# get mask
mask=${dataDir}/${okSubj[0]}/${okSubj[0]}.storyISC/mask_epi_anat.${okSubj[0]}+tlrc # mask filename for subj 1 (should be similar for all subjects)
# get file list
nFiles=${#okSubj[@]}
for (( i=0; i<$nFiles; i++ ))
do
  fileList[$i]="${okSubj[$i]}/${okSubj[$i]}.storyISC/errts.${okSubj[$i]}.fanaticor+tlrc" # or should it be .tproject+tlrc?
done

# Display info about files
echo "$nFiles files given as input."
# echo fileList = ${fileList[*]}
echo mask = $mask

# Loop 1: mean across files
rm -f $swarmFile $iscTable $rScript
echo "Subj Subj2 InputFile">>$iscTable
echo === Getting ISCs across files...
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echo ===File $iFile/$nFiles
    for (( jFile=$iFile+1; jFile<$nFiles; jFile++ ))
    do
      echo "   ...vs. file $jFile"
      # get ISCs
      echo Running ISC...
      file1=${dataDir}/${fileList[$iFile]} # correlate with
      file2=${dataDir}/${fileList[$jFile]} # correlate with
      iscfile="${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story"+tlrc # output of 3dTcorrelate
      # run 3dTcorrelate with automask to cut out small-value voxels
      echo "3dTcorrelate -automask -prefix $iscfile $file1 $file2" >> $swarmFile
      # make table for follow-up R script
      echo "${okSubj[$iFile]} ${okSubj[jFile]} ${iscfile}" >> $iscTable
    done
done

# Make R script to run after
echo "module load R" >> $rScript
echo "nohup R CMD BATCH 3dLME_ISC_2Grps_readScoreMedSplit_n42.R 3dLME_ISC_2Grps_readScoreMedSplit_n42.diary" >> $rScript

# run swarm command (batching 20 commands per job)
# jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile --partition=nimh,norm --module=afni --time=0:10:00 --job-name=Isc --logdir=logsDJ`

# run R job
# sbatch --partition=nimh,norm --mem=20g -dependency=afterok:$jobid $rScript

# take mean across files
#echo === Getting mean across ISFC results...
#3dMean -prefix "$outDir"ISC_Mean"$nFiles"files+tlrc ${outprefix[*]}

# Run t-test against 0
# echo === Getting t-test results across ISC results...
# 3dttest++ -overwrite -mask $mask -toz -prefix "$outDir""$outstarter""$nFiles"files+tlrc -setA ${outprefix[*]} #-DAFNI_AUTOMATIC_FDR=NO #don't apply FDR correction #>/dev/null # suppress stdout # output z scores instead of t values

echo === DONE! ===
