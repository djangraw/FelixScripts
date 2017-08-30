#!/bin/bash

# Create directory and file variables in the workspace and run RunIscOn100RunsVideo.
# GetIscVariables.sh
#
# SAMPLE USAGE:
# . GetIscVariables.sh subject
#
# INPUTS:
# 1. subject is a string indicating the subject (e.g., SBJ01)
#
# Created 3/30/15 by DJ.
# Updated 3/31/15 by DJ - added meicafiles, optcomfiles, echofiles
# Updated 4/2/15 by DJ - added full-brain mask fbmask
# Updated 5/1/15 by DJ - added subject input.

# stop if error
# set -e

# get inputs
subject=$1

# get path to data
datadir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/$subject/"
meicafiles=( $(ls $datadir*_MeicaDenoised.nii) )
optcomfiles=( $(ls $datadir*_OptCom.nii) )
echofiles=( $(ls $datadir*_Echo2+orig.BRIK) )
nFiles=${#echofiles[@]}
# remove file extensions (good for .BRIK, but not for .nii)
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echofiles[$iFile]=${echofiles[$iFile]%.*} # remove everything after first .
done

# get gray matter mask
maskdir="/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/CrossRunAnalyses.AnatAlign/$subject/RegistrationComparisons/"
maskfile="$maskdir"Gray_EPIRes+orig.BRIK

# get full-brain mask
fbmask="$datadir""$subject"_FullBrain_EPIRes+orig.BRIK

# get output directory
outdir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/$subject/ISC/"

# navigate to scripts directory
scriptdir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Scripts/"
cd $scriptdir

# run script
#bash ./RunIscOn100RunsVideo.sh $subject ISC_Echo2_${subject}_ $maskfile ${echofiles[@]:0:16}
#bash ./RunIscOn100RunsVideo.sh $subject ISC_OptCom_${subject}_ $maskfile ${optcomfiles[@]:0:16}
#bash ./RunIscOn100RunsVideo.sh $subject ISC_MEICA_${subject}_ $maskfile ${meicafiles[@]:0:16}

#bash ./RunIscOn100RunsVideo_pairwise.sh $subject ISCpw_Echo2-fb_${subject}_ $fbmask ${echofiles[@]:0:16}
#bash ./RunIscOn100RunsVideo_pairwise.sh $subject ISCpw_OptCom-fb_${subject}_ $fbmask ${optcomfiles[@]:0:16}
#bash ./RunIscOn100RunsVideo_pairwise.sh $subject ISCpw_MEICA-fb_${subject}_ $fbmask ${meicafiles[@]:0:16}
