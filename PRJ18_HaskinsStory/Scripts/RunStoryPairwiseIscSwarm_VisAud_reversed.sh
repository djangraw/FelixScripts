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
swarmFile_vis=${scriptDir}/IscSwarmCommand_vis_rev  # file where the swarm command should be written
swarmFile_aud=${scriptDir}/IscSwarmCommand_aud_rev  # file where the swarm command should be written
swarmFile_trans=${scriptDir}/IscSwarmCommand_trans_rev  # file where the swarm command should be written
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

# get file list
for (( i=0; i<$nFiles; i++ ))
do
  fileIn="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor+tlrc" # or should it be .tproject+tlrc?
  visOut="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor_vis+tlrc"
  audOut="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor_aud+tlrc"
  transOut="${okSubj[$i]}/${okSubj[$i]}.story/errts.${okSubj[$i]}.fanaticor_trans+tlrc"

  if [ ${okSubj[$i]} == ${revSubj[0]} ] || [ ${okSubj[$i]} == ${revSubj[1]} ]
  then
    echo Cropping for subject $i...
    # 3dTcat -prefix $visOut $fileIn'[31..54, 89..117, 244..268, 301..327]'
    # 3dTcat -prefix $audOut $fileIn'[57..88, 120..149, 212..242, 271..299]'
    # 3dTcat -prefix $visOut $fileIn'[33..54, 91..117, 246..268, 303..327]' # in samples, with onsets delayed 6s for HRF ramp-up
    # 3dTcat -prefix $audOut $fileIn'[58..87, 121..148, 214..242, 272..299]' # in samples, with onsets delayed 6s for HRF ramp-up
    # 3dTcat -prefix $transOut $fileIn'[29..33, 54..58, 87..91, 117..121, 148..152, 210..214, 242..246, 268..272, 299..303, 327..331]' # in samples, with onsets delayed 6s for HRF ramp-up
    3dTcat -prefix $visOut $fileIn'[35..54, 93..117, 248..268, 305..327]' # in samples, with onsets delayed 12s for HRF ramp-up
    3dTcat -prefix $audOut $fileIn'[60..87, 123..148, 216..242, 274..299]' # in samples, with onsets delayed 12s for HRF ramp-up
    3dTcat -prefix $transOut $fileIn'[30..34, 55..59, 88..92, 118..122, 149..153, 211..215, 243..247, 269..273, 300..304, 328..332]' # in samples, 2-10s after block offset
  fi

  # fileList[$i]=$fileIn
  fileList_vis[$i]=$visOut
  fileList_aud[$i]=$audOut
  fileList_trans[$i]=$transOut

done


# Make EPI-res mask
#3dAutomask -overwrite -prefix ${outDir}/MNI_mask.nii ${AFNI_HOME}/MNI152_T1_2009c+tlrc # create a mask of the template brain you registered subjects to
#3dfractionize -overwrite -prefix ${outDir}/MNI_mask_epiRes.nii -template ${fileList[0]} -input ${outDir}/MNI_mask.nii # resample this mask to EPI resolution
mask=${outDir}/MNI_mask_epiRes.nii

# Display info about files
echo "$nFiles files given as input."
# echo fileList = ${fileList[*]}
echo mask = $mask

# Main Loop: correlation
rm -f $swarmFile_vis $swarmFile_aud $swarmFile_trans
echo === Getting ISCs across files...
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echo ===File $iFile/$nFiles
    for (( jFile=$iFile+1; jFile<$nFiles; jFile++ ))
    do
      if [ ${okSubj[$iFile]} == ${revSubj[0]} ] || [ ${okSubj[$iFile]} == ${revSubj[1]} ] || [ ${okSubj[$jFile]} == ${revSubj[0]} ] || [ ${okSubj[$jFile]} == ${revSubj[1]} ]
      then

        echo "   ...vs. file $jFile"
        # VISUAL
        file1=${dataDir}/${fileList_vis[$iFile]} # correlate with
        file2=${dataDir}/${fileList_vis[$jFile]} # correlate with
        tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story_vis+tlrc # unmasked output of 3dTcorrelate
        iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_vis+tlrc # masked output of 3dTcorrelate+3dcalc
        # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
        echo "3dTcorrelate -polort -1 -overwrite -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_vis
        # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_vis
        # make table for follow-up R script
        #echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable_vis

        # AUDITORY
        file1=${dataDir}/${fileList_aud[$iFile]} # correlate with
        file2=${dataDir}/${fileList_aud[$jFile]} # correlate with
        tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud+tlrc # unmasked output of 3dTcorrelate
        iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud+tlrc # masked output of 3dTcorrelate+3dcalc
        # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
        echo "3dTcorrelate -polort -1 -overwrite -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_aud
        # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_aud
        # make table for follow-up R script
        #echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable_aud

        # TRANSITIONS
        file1=${dataDir}/${fileList_trans[$iFile]} # correlate with
        file2=${dataDir}/${fileList_trans[$jFile]} # correlate with
        tempfile=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story_trans+tlrc # unmasked output of 3dTcorrelate
        iscfile=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_trans+tlrc # masked output of 3dTcorrelate+3dcalc
        # run 3dTcorrelate WITHOUT automask to cut out small-value voxels... this did strange things last time.
        echo "3dTcorrelate -polort -1 -overwrite -prefix $tempfile $file1 $file2; 3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_trans
        # echo "3dcalc -a $tempfile -b $mask -overwrite -prefix $iscfile -expr 'a*step(b)'" >> $swarmFile_aud
        # make table for follow-up R script
        #echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscfile}" >> $iscTable_trans
      fi
    done
done

# run swarm command (batching 20 commands per job)
# jobid=`swarm -g 2 -t 1 -b 20 -f $swarmFile --partition=norm --module=afni --time=0:10:00 --job-name=Isc --logdir=logsDJ`
jobid_vis=`swarm -g 2 -t 1 -b 20 -f $swarmFile_vis --partition=norm --module=afni --time=0:10:00 --job-name=IscV --logdir=logsDJ`
jobid_aud=`swarm -g 2 -t 1 -b 20 -f $swarmFile_aud --partition=norm --module=afni --time=0:10:00 --job-name=IscA --logdir=logsDJ`
jobid_trans=`swarm -g 2 -t 1 -b 20 -f $swarmFile_trans --partition=norm --module=afni --time=0:10:00 --job-name=IscT --logdir=logsDJ`
echo $jobid_vis $jobid_aud $jobid_trans
