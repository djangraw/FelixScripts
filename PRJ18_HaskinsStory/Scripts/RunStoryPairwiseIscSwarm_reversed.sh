#!/bin/bash
set -e

# Run inter-subject connectivity analysis on Haskins Story data.
# RunStoryPairwiseIscSwarm_reversed.sh
#
# Created 8/21/19 by DJ based on RunStoryPairwiseIscSwarm.sh, for reversed subjects h1012 and h1120.

# ---declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh # creates variables dataDir, scriptDir, okSubj (subject list)
outstarter="storyISC_"                  # the beginning of the output files you'll create
outDir=${dataDir}/IscResults/Pairwise   # folder where the correlation files should go
swarmFile=${scriptDir}/IscSwarmCommand_rev  # file where the swarm command should be written
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

revSubj=("h1012" "h1120") # list of just reversed subjects

# Make EPI-res mask
#3dAutomask -overwrite -prefix ${outDir}/MNI_mask.nii ${AFNI_HOME}/MNI152_T1_2009c+tlrc # create a mask of the template brain you registered subjects to
#3dfractionize -overwrite -prefix ${outDir}/MNI_mask_epiRes.nii -template ${fileList[0]} -input ${outDir}/MNI_mask.nii # resample this mask to EPI resolution
mask=${outDir}/MNI_mask_epiRes.nii

# Display info about files
echo "$nFiles files given as input."
# echo fileList = ${fileList[*]}
echo mask = $mask

# Main Loop: correlation
rm -f $swarmFile
echo === Getting ISCs across files...
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echo ===File $iFile/$nFiles
    for (( jFile=$iFile+1; jFile<$nFiles; jFile++ ))
    do
      if [ ${okSubj[$iFile]} == ${revSubj[0]} ] || [ ${okSubj[$iFile]} == ${revSubj[1]} ] || [ ${okSubj[$jFile]} == ${revSubj[0]} ] || [ ${okSubj[$jFile]} == ${revSubj[1]} ]
      then

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
      fi
    done
done

# run swarm command (batching 20 commands per job)
jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile --partition=norm --module=afni --time=0:10:00 --job-name=Isc --logdir=logsDJ`
echo jobid = $jobid
