#!/bin/bash
set -e

# Get ISC differencer between visual and auditory blocks for Haskins Story data.
# GetStoryIscAudVisDiff.sh
#
# Created 3/27/19 by DJ based on RunStoryPairwiseIscSwarm_VisAud.sh

# ---declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
# outstarter="storyISC_"
outDir=${dataDir}/IscResults/Pairwise

iscTable_diff=${outDir}/StoryPairwiseIscTable_aud-vis.txt

AFNI_HOME=`which afni` # Get AFNI directory
AFNI_HOME=${AFNI_HOME%/*} # remove afni (and last slash)

# handle directories
cd $outDir
rm -f $iscTable_diff
echo -e "Subj\tSubj2\tInputFile">>$iscTable_diff

nT_aud=`3dinfo -nT ${dataDir}/${okSubj[0]}/${okSubj[0]}.story/errts.${okSubj[0]}.fanaticor_aud+tlrc`
nT_vis=`3dinfo -nT ${dataDir}/${okSubj[0]}/${okSubj[0]}.story/errts.${okSubj[0]}.fanaticor_vis+tlrc`

nFiles=${#okSubj[@]}
echo "=== Getting ISCs across $nFiles files..."
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echo "===File $iFile/$nFiles"
    for (( jFile=$iFile+1; jFile<$nFiles; jFile++ ))
    do
      echo "   ...vs. file $jFile"
        visIsc=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_vis+tlrc # masked output of 3dTcorrelate+3dcalc
        audIsc=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud+tlrc # masked output of 3dTcorrelate+3dcalc
        tempZ=${outDir}/TEMP_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud-vis+tlrc
        iscDiff=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud-vis+tlrc
        3dcalc -a $audIsc -b $visIsc -overwrite -prefix $tempZ -expr "(0.5*(log(1+a)-log(1-a)) - 0.5*(log(1+b)-log(1-b))) / sqrt((1/($nT_aud-3)) + (1/($nT_vis-3)))"
        3dcalc -z $tempZ -overwrite -prefix $iscDiff -expr '(exp(2*z)-1)/(exp(2*z)+1)'
        echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscDiff}" >> $iscTable_diff
    done
done
