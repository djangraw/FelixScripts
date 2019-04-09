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
# Updated 3/26/19 by DJ - updated to 69-subj version

# ---declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
# outstarter="storyISC_"
outDir=${dataDir}/IscResults/Pairwise

swarmFile=${scriptDir}/IscSwarmCommand_TEMP
swarmFile_vis=${scriptDir}/IscSwarmCommand_vis
swarmFile_aud=${scriptDir}/IscSwarmCommand_aud

rScript=${scriptDir}/IscRCommand_TEMP
rScript_vis=${scriptDir}/IscRCommand_vis
rScript_aud=${scriptDir}/IscRCommand_aud

iscTable=${outDir}/StoryPairwiseIscTable_TEMP.txt
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
  fileIn="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor+tlrc" # or should it be .tproject+tlrc?
  visOut="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor_vis+tlrc"
  audOut="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor_aud+tlrc"

  # 3dTcat -prefix $visOut $fileIn'[31..54, 89..117, 244..268, 301..327]'
  # 3dTcat -prefix $audOut $fileIn'[57..88, 120..149, 212..242, 271..299]'
  3dTcat -prefix $visOut $fileIn'[33..54, 91..117, 246..268, 303..327]' # in samples, with onsets delayed 6s for HRF ramp-up
  3dTcat -prefix $audOut $fileIn'[58..87, 121..148, 214..242, 272..299]' # in samples, with onsets delayed 6s for HRF ramp-up

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

# Set up: make headers
rm -f $swarmFile $swarmFile_aud $swarmFile_vis $iscTable $iscTable_aud $iscTable_vis $rScript $rScript_aud $rScript_vis
echo -e "Subj\tSubj2\tInputFile">>$iscTable
echo -e "Subj\tSubj2\tInputFile">>$iscTable_vis
echo -e "Subj\tSubj2\tInputFile">>$iscTable_aud

# Loop 1: ISC across files
echo "=== Getting ISCs across files..."
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
      echo "3dTcorrelate -polort -1 -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile
      # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile
      # make table for follow-up R script
      echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable

      file1=${dataDir}/${fileList_vis[$iFile]} # correlate with
      file2=${dataDir}/${fileList_vis[$jFile]} # correlate with
      tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story_vis+tlrc # unmasked output of 3dTcorrelate
      iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_vis+tlrc # masked output of 3dTcorrelate+3dcalc
      # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
      echo "3dTcorrelate -polort -1 -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_vis
      # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_vis
      # make table for follow-up R script
      echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable_vis


      file1=${dataDir}/${fileList_aud[$iFile]} # correlate with
      file2=${dataDir}/${fileList_aud[$jFile]} # correlate with
      tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud+tlrc # unmasked output of 3dTcorrelate
      iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud+tlrc # masked output of 3dTcorrelate+3dcalc
      # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
      echo "3dTcorrelate -polort -1 -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_aud
      # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_aud
      # make table for follow-up R script
      echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable_aud

    done
done

# Make R script to run after
echo "module load R" >> $rScript
echo "nohup R CMD BATCH 3dLME_ISC_2Grps_readScoreMedSplit_n42.R 3dLME_ISC_2Grps_readScoreMedSplit_n69.diary" >> $rScript
echo "#!/bin/bash" >> $rScript_vis
echo "module load R" >> $rScript_vis
echo "Rscript 3dLME_ISC_2Grps_readScoreMedSplit_n69.R StoryPairwiseIscTable_vis.txt 3dLME_2Grps_readScoreMedSplit_n69_Automask_vis" >> $rScript_vis
echo "#!/bin/bash" >> $rScript_aud
echo "module load R" >> $rScript_aud
echo "Rscript 3dLME_ISC_2Grps_readScoreMedSplit_n69.R StoryPairwiseIscTable_aud.txt 3dLME_2Grps_readScoreMedSplit_n69_Automask_aud" >> $rScript_aud

# run swarm command (batching 20 commands per job)
jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile --partition=nnorm --module=afni --time=0:10:00 --job-name=Isc --logdir=logsDJ`
jobid_vis=`swarm -g 2 -t 1 -b 20 -f $swarmFile_vis --partition=norm --module=afni --time=0:10:00 --job-name=IscV --logdir=logsDJ`
jobid_aud=`swarm -g 2 -t 1 -b 20 -f $swarmFile_aud --partition=norm --module=afni --time=0:10:00 --job-name=IscA --logdir=logsDJ`

# run R job
sbatch --partition=norm --mem=64g --time=8:00:00 -dependency=afterok:$jobid $rScript
sbatch --partition=norm --mem=64g --time=8:00:00 -dependency=afterok:$jobid_vis $rScript_vis
sbatch --partition=norm --mem=64g --time=8:00:00 -dependency=afterok:$jobid_aud $rScript_aud

# take mean across files
#echo === Getting mean across ISFC results...
#3dMean -prefix "$outDir"ISC_Mean"$nFiles"files+tlrc ${outprefix[*]}

# Run t-test against 0
# echo === Getting t-test results across ISC results...
# 3dttest++ -overwrite -mask $mask -toz -prefix "$outDir""$outstarter""$nFiles"files+tlrc -setA ${outprefix[*]} #-DAFNI_AUTOMATIC_FDR=NO #don't apply FDR correction #>/dev/null # suppress stdout # output z scores instead of t values

echo === DONE! ===
