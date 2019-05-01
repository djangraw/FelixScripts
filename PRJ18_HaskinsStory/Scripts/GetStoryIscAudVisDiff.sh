#!/bin/bash
set -e

# Get ISC differencer between visual and auditory blocks for Haskins Story data.
# GetStoryIscAudVisDiff.sh
#
# Created 3/27/19 by DJ based on RunStoryPairwiseIscSwarm_VisAud.sh
# Updated 4/30/19 by DJ - removed nT division, conversion back z-->r (per Gang's suggestion), added TransAud and TransVis diffs

# Declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
outDir=${dataDir}/IscResults/Pairwise
# Declare output filenames
iscTable_diff=${outDir}/StoryPairwiseIscTable_aud-vis.txt
iscTable_transaud=${outDir}/StoryPairwiseIscTable_trans-aud.txt
iscTable_transvis=${outDir}/StoryPairwiseIscTable_trans-vis.txt

# (re)create directories & tables
cd $outDir
rm -f $iscTable_diff $iscTable_transaud $iscTable_transvis
echo -e "Subj\tSubj2\tInputFile">>$iscTable_diff
echo -e "Subj\tSubj2\tInputFile">>$iscTable_transaud
echo -e "Subj\tSubj2\tInputFile">>$iscTable_transvis

nFiles=${#okSubj[@]}
echo "=== Getting ISCs across $nFiles files..."
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echo "===File $iFile/$nFiles"
    for (( jFile=$iFile+1; jFile<$nFiles; jFile++ ))
    do
        echo "   ...vs. file $jFile"
        # Define inputs
        visIsc=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_vis+tlrc # masked output of 3dTcorrelate+3dcalc
        audIsc=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud+tlrc # masked output of 3dTcorrelate+3dcalc
        transIsc=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_trans+tlrc # masked output of 3dTcorrelate+3dcalc
        # Define output files
        iscDiff=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_aud-vis+tlrc
        iscTransAud=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_trans-aud+tlrc
        iscTransVis=${outDir}/ISC_${okSubj[$iFile]}_${okSubj[$jFile]}_story_trans-vis+tlrc
        # fisher z transform correlation coefficients and subtract resulting z's
        3dcalc -a $audIsc -b $visIsc -overwrite -prefix $iscDiff -expr "(0.5*(log(1+a)-log(1-a)) - 0.5*(log(1+b)-log(1-b)))"
        3dcalc -a $transIsc -b $audIsc -overwrite -prefix $iscTransAud -expr "(0.5*(log(1+a)-log(1-a)) - 0.5*(log(1+b)-log(1-b)))"
        3dcalc -a $transIsc -b $visIsc -overwrite -prefix $iscTransVis -expr "(0.5*(log(1+a)-log(1-a)) - 0.5*(log(1+b)-log(1-b)))"
        # Add results to isc tables
        echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscDiff}" >> $iscTable_diff
        echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscTransAud}" >> $iscTable_transaud
        echo -e "${okSubj[$iFile]}\t${okSubj[jFile]}\t${iscTransVis}" >> $iscTable_transvis
    done
done
