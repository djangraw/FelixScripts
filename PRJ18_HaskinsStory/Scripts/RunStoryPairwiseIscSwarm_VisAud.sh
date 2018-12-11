#!/bin/bash
set -e

# Run inter-subject connectivity analysis on Haskins Story data.
# RunStoryPairwiseIscSwarm_VisAud.sh
#
# Created 5/17/18 by DJ based on RunIsc.sh (100-runs version).
# Updated 5/18/18 by DJ to do pairwise swarm.
# Updated 5/22/18 by DJ - storyISC_d2 directory/output, fanaticor
# Updated 5/23/18 by DJ - used MNI mask instead of automask option
# Updated 12/10/18 by DJ - Vis-only and Aud-only versions

# ---declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
# outstarter="storyISC_"
outDir=${dataDir}/IscResults_d3/Pairwise

swarmFile=${scriptDir}/IscSwarmCommand
swarmFile_vis=${scriptDir}/IscSwarmCommand_vis
swarmFile_aud=${scriptDir}/IscSwarmCommand_aud

rScript=${scriptDir}/IscRCommand
rScript_vis=${scriptDir}/IscRCommand_vis
rScript_aud=${scriptDir}/IscRCommand_aud

iscTable=${outDir}/StoryPairwiseIscTable.txt
iscTable_vis=${outDir}/StoryPairwiseIscTable_vis.txt
iscTable_aud=${outDir}/StoryPairwiseIscTable_aud.txt

AFNI_HOME=`which afni` # Get AFNI directory
AFNI_HOME=${AFNI_HOME%/*} # remove afni (and last slash)
# handle directories
cd $dataDir
mkdir -p $outDir

# get file list
nFiles=${#okSubj[@]}
for (( i=0; i<$nFiles; i++ ))
do
  fileIn="${okSubj[$i]}/${okSubj[$i]}.storyISC_d2/errts.${okSubj[$i]}.fanaticor+tlrc" # or should it be .tproject+tlrc?
  visOut="${okSubj[$i]}/${okSubj[$i]}.storyISC_d2/errts.${okSubj[$i]}.fanaticor_vis+tlrc"
  audOut="${okSubj[$i]}/${okSubj[$i]}.storyISC_d2/errts.${okSubj[$i]}.fanaticor_aud+tlrc"

  # 3dTcat -prefix $visOut $fileIn'[31..54, 89..117, 244..268, 301..327]'
  # 3dTcat -prefix $audOut $fileIn'[57..88, 120..149, 212..242, 271..299]'

  fileList[$i]=$fileIn
  fileList_vis[$i]=$visOut
  fileList_aud[$i]=$audOut

done
# Make EPI-res mask
3dAutomask -overwrite -prefix ${outDir}/MNI_mask.nii ${AFNI_HOME}/MNI152_T1_2009c+tlrc
3dfractionize -overwrite -prefix ${outDir}/MNI_mask_epiRes.nii -template ${fileList[0]} -input ${outDir}/MNI_mask.nii
mask=${outDir}/MNI_mask_epiRes.nii

# Display info about files
echo "$nFiles files given as input."
# echo fileList = ${fileList[*]}
echo mask = $mask

# Loop 1: mean across files
rm -f $swarmFile $swarmFile_aud $swarmFile_vis $iscTable $iscTable_aud $iscTable_vis $rScript $rScript_aud $rScript_vis
echo -e "Subj\tSubj2\tInputFile">>$iscTable
echo -e "Subj\tSubj2\tInputFile">>$iscTable_vis
echo -e "Subj\tSubj2\tInputFile">>$iscTable_aud

echo === Getting ISCs across files...
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echo "===File $iFile/$nFiles"
    for (( jFile=$iFile+1; jFile<$nFiles; jFile++ ))
    do
      echo "   ...vs. file $jFile"
      # get ISCs
      echo Running ISC...
      file1=${dataDir}/${fileList[$iFile]} # correlate with
      file2=${dataDir}/${fileList[$jFile]} # correlate with
      tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story+tlrc # unmasked output of 3dTcorrelate
      iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story+tlrc # masked output of 3dTcorrelate+3dcalc
      # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
      echo "3dTcorrelate -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile
      # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile
      # make table for follow-up R script
      echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable

      file1=${dataDir}/${fileList_vis[$iFile]} # correlate with
      file2=${dataDir}/${fileList_vis[$jFile]} # correlate with
      tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story_vis+tlrc # unmasked output of 3dTcorrelate
      iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_vis+tlrc # masked output of 3dTcorrelate+3dcalc
      # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
      echo "3dTcorrelate -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_vis
      # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_vis
      # make table for follow-up R script
      echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable_vis


      file1=${dataDir}/${fileList_aud[$iFile]} # correlate with
      file2=${dataDir}/${fileList_aud[$jFile]} # correlate with
      tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud+tlrc # unmasked output of 3dTcorrelate
      iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud+tlrc # masked output of 3dTcorrelate+3dcalc
      # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
      echo "3dTcorrelate -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_aud
      # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_aud
      # make table for follow-up R script
      echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable_aud

    done
done

# Make R script to run after
# echo "module load R" >> $rScript
# echo "nohup R CMD BATCH 3dLME_ISC_2Grps_readScoreMedSplit_n42.R 3dLME_ISC_2Grps_readScoreMedSplit_n42.diary" >> $rScript

# run swarm command (batching 20 commands per job)
# jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile --partition=nnorm --module=afni --time=0:10:00 --job-name=Isc --logdir=logsDJ`
# jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile_vis --partition=norm --module=afni --time=0:10:00 --job-name=IscV --logdir=logsDJ`
# jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile_aud --partition=norm --module=afni --time=0:10:00 --job-name=IscA --logdir=logsDJ`

# run R job
# sbatch --partition=nimh,norm --mem=20g -dependency=afterok:$jobid $rScript

# take mean across files
#echo === Getting mean across ISFC results...
#3dMean -prefix "$outDir"ISC_Mean"$nFiles"files+tlrc ${outprefix[*]}

# Run t-test against 0
# echo === Getting t-test results across ISC results...
# 3dttest++ -overwrite -mask $mask -toz -prefix "$outDir""$outstarter""$nFiles"files+tlrc -setA ${outprefix[*]} #-DAFNI_AUTOMATIC_FDR=NO #don't apply FDR correction #>/dev/null # suppress stdout # output z scores instead of t values

echo === DONE! ===
