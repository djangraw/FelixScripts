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
# Updated 3/4/19 by DJ - new R script and mean/ttest filenames
# Updated 4/2/19 by DJ - added 1-group R script call, many comments

# ---declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh # creates variables dataDir, scriptDir, okSubj (subject list)
outstarter="storyISC_"                  # the beginning of the output files you'll create
outDir=${dataDir}/IscResults/Pairwise   # folder where the correlation files should go
swarmFile=${scriptDir}/IscSwarmCommand  # file where the swarm command should be written
rScript1=${scriptDir}/IscRCommand_1Grp  # file where the 1-group R sbatch command should be written
rScript2=${scriptDir}/IscRCommand_2Grps # file where the 2-group R sbatch command should be written
iscTable=${outDir}/StoryPairwiseIscTable.txt # file where the ISC table (used as input to the R scripts) should be written
AFNI_HOME=`which afni`    # Get AFNI directory
AFNI_HOME=${AFNI_HOME%/*} # remove afni (and last slash)

# handle directories
cd $dataDir # go where the data sit
mkdir -p $outDir # create the output directory if it doesn't exist yet

# get file list
nFiles=${#okSubj[@]}
for (( i=0; i<$nFiles; i++ ))
do
  fileList[$i]="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor+tlrc" # use the residuals file with motion and anaticor timecourses regressed out
done

# Make EPI-res mask
3dAutomask -overwrite -prefix ${outDir}/MNI_mask.nii ${AFNI_HOME}/MNI152_T1_2009c+tlrc # create a mask of the template brain you registered subjects to
3dfractionize -overwrite -prefix ${outDir}/MNI_mask_epiRes.nii -template ${fileList[0]} -input ${outDir}/MNI_mask.nii # resample this mask to EPI resolution
mask=${outDir}/MNI_mask_epiRes.nii

# Display info about files
echo "$nFiles files given as input."
# echo fileList = ${fileList[*]}
echo mask = $mask

# Main Loop: correlation
rm -f $swarmFile $iscTable $rScript
echo -e "Subj\tSubj2\tInputFile">>$iscTable # write header to ISC results table
echo === Getting ISCs across files...
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echo ===File $iFile/$nFiles
    for (( jFile=$iFile+1; jFile<$nFiles; jFile++ ))
    do
      echo "   ...vs. file $jFile"
      # declare input/output files
      file1=${dataDir}/${fileList[$iFile]} # correlate with
      file2=${dataDir}/${fileList[$jFile]} # correlate with
      tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story+tlrc # unmasked output of 3dTcorrelate
      iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story+tlrc # masked output of 3dTcorrelate+3dcalc

      # Write correlation and mask commands to swarm file in one line
      # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
      echo "3dTcorrelate -polort -1 -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile
      # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile # us this line to do masking only

      # add line recording this subject pair's file to table for follow-up R script
      echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable
    done
done

# run swarm command (batching 20 commands per job)
jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile --partition=norm --module=afni --time=0:10:00 --job-name=Isc --logdir=logsDJ`

# Make sbatch file to run 1-group 3dLME R script
echo "#!/bin/bash" >> $rScript1
echo "module load R" >> $rScript1
echo "nohup R CMD BATCH 3dLME_ISC_1Grp_n$nFiles.R 3dLME_ISC_2Grps_readScoreMedSplit_n$nFiles.diary" >> $rScript1

# Make sbatch file to run 2-group 3dLME R script
echo "#!/bin/bash" >> $rScript2
echo "module load R" >> $rScript2
echo "nohup R CMD BATCH 3dLME_ISC_2Grps_readScoreMedSplit_n$nFiles.R 3dLME_ISC_2Grps_readScoreMedSplit_n$nFiles.diary" >> $rScript2

# run R jobs (requesting lots of memory)
sbatch --partition=norm --mem=100g --time=8:00:00 -dependency=afterok:$jobid $rScript1
sbatch --partition=norm --mem=100g --time=8:00:00 -dependency=afterok:$jobid $rScript2


# take mean across files
#echo === Getting mean across ISC results...
# outFiles=($(ls $outDir/ISC_h*.HEAD))`
# 3dMean -prefix ${outDir}/${outstarter}Mean${nFiles}files+tlrc ${outFiles[@]}

# Run t-test against 0
# echo === Getting t-test results across ISC results...
# 3dttest++ -overwrite -mask $mask -toz -prefix ${outDir}/${outstarter}Ttest${nFiles}files+tlrc -setA ${outFiles[@]} #-DAFNI_AUTOMATIC_FDR=NO #don't apply FDR correction #>/dev/null # suppress stdout # output z scores instead of t values

echo === DONE! ===
