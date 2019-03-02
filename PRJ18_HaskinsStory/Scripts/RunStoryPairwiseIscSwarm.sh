#!/bin/bash
set -e

# Run inter-subject connectivity analysis on Haskins Story data.
# RunStoryPairwiseIscSwarm.sh
#
# Created 5/17/18 by DJ based on RunIsc.sh (100-runs version).
# Updated 5/18/18 by DJ to do pairwise swarm.
# Updated 5/22/18 by DJ - storyISC_d2 directory/output, fanaticor
# Updated 5/23/18 by DJ - used MNI mask instead of automask option
# Updated 3/1/19 by DJ - new fileList structure, set 3dTcorrelate polort flag to -1 to avoid redundant detrending

# ---declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
outstarter="storyISC_"
outDir=${dataDir}/IscResults/Pairwise
swarmFile=${scriptDir}/IscSwarmCommand
rScript=${scriptDir}/IscRCommand
iscTable=${outDir}/StoryPairwiseIscTable.txt
AFNI_HOME=`which afni` # Get AFNI directory
AFNI_HOME=${AFNI_HOME%/*} # remove afni (and last slash)
# handle directories
cd $dataDir
mkdir -p $outDir

# get file list
nFiles=${#okSubj[@]}
for (( i=0; i<$nFiles; i++ ))
do
  # fileList[$i]="${okSubj[$i]}/${okSubj[$i]}.storyISC_d2/errts.${okSubj[$i]}.fanaticor+tlrc" # or should it be .tproject+tlrc?
  fileList[$i]="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor+tlrc" # or should it be .tproject+tlrc?
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
rm -f $swarmFile $iscTable $rScript
echo -e "Subj\tSubj2\tInputFile">>$iscTable
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
      tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story+tlrc # unmasked output of 3dTcorrelate
      iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story+tlrc # masked output of 3dTcorrelate+3dcalc
      # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
      echo "3dTcorrelate -polort -1 -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile
      # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile
      # make table for follow-up R script
      echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable
    done
done

# Make R script to run after
echo "#!/bin/bash" >> $rScript
echo "module load R" >> $rScript
echo "nohup R CMD BATCH 3dLME_ISC_2Grps_readScoreMedSplit_n42.R 3dLME_ISC_2Grps_readScoreMedSplit_n42.diary" >> $rScript

# run swarm command (batching 20 commands per job)
jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile --partition=norm --module=afni --time=0:10:00 --job-name=Isc --logdir=logsDJ`

# run R job
sbatch --partition=norm --mem=20g -dependency=afterok:$jobid $rScript

# take mean across files
#echo === Getting mean across ISC results...
#3dMean -prefix "$outDir"ISC_Mean"$nFiles"files+tlrc ${outprefix[*]}

# Run t-test against 0
# echo === Getting t-test results across ISC results...
# 3dttest++ -overwrite -mask $mask -toz -prefix "$outDir""$outstarter""$nFiles"files+tlrc -setA ${outprefix[*]} #-DAFNI_AUTOMATIC_FDR=NO #don't apply FDR correction #>/dev/null # suppress stdout # output z scores instead of t values

echo === DONE! ===
