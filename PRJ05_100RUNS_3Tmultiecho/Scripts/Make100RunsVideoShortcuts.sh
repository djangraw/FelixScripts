#!/bin/bash

# Make100RunsVideoShortcuts.sh
#
# SAMPLE USAGE:
# bash Make100RunsVideoShortcuts.sh subject nSessions nRunsPerSession
#
# INPUTS:
# - subject is a string (e.g., SBJ01)
# - nSessions is a 1-digit integer (e.g., 9)
# - nRunsPerSession is a 1-digit integer (e.g., 2)
#
# Created 3/26/15 by DJ.
# Updated 3/31/15 by DJ - added middle echo & optimally combined files, existence catches.
# Updated 4/2/15 by DJ - added mask creation.
# Updated 5/1/15 by DJ - added inputs.

# stop if error
set -e

# declare constants
subject=$1 #"SBJ01"
nSessions=$2 #9
nRunsPerSession=$3 #2

# declare directories
basedir="/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/"
outdir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/"
# dirend="SBJ01_S02/D01_Version02.AlignByAnat.Cubic/Video01"
maskdir=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/CrossRunAnalyses.AnatAlign/"$subject"/RegistrationComparisons/

# Loop 1: mean across files
echo === Making Shortcuts...
for (( iSession=1; iSession<=$nSessions; iSession++ ))
do
	for (( iRun=1; iRun<=$nRunsPerSession; iRun++ ))
	do
		# Middle echo
		oldFilename="$basedir""$subject"_S0"$iSession"/D01_Version02.AlignByAnat.Cubic/Video0"$iRun"/p04."$subject"_S0"$iSession"_Video0"$iRun"_e2.align_clp+orig
		newFilename="$outdir""$subject"/"$subject"_S0"$iSession"_R0"$iRun"_Video_Echo2+orig
		[ -e "$oldFilename".BRIK ] && ln -s "$oldFilename".BRIK "$newFilename".BRIK || echo "$oldFilename".BRIK not found!
		[ -e "$oldFilename".HEAD ] && ln -s "$oldFilename".HEAD "$newFilename".HEAD || echo "$oldFilename".HEAD not found!
		# Optimally combined
		oldFilename="$basedir""$subject"_S0"$iSession"/D01_Version02.AlignByAnat.Cubic/Video0"$iRun"/TED/ts_OC.nii
		newFilename="$outdir""$subject"/"$subject"_S0"$iSession"_R0"$iRun"_Video_OptCom+orig.nii
		[ -e $oldFilename ] && ln -s $oldFilename $newFilename || echo $oldFilename not found!
		# MEICA denoised
		oldFilename="$basedir""$subject"_S0"$iSession"/D01_Version02.AlignByAnat.Cubic/Video0"$iRun"/TED/dn_ts_OC.nii
		newFilename="$outdir""$subject"/"$subject"_S0"$iSession"_R0"$iRun"_Video_MeicaDenoised+orig.nii
		[ -e $oldFilename ] && ln -s $oldFilename $newFilename || echo $oldFilename not found!
	done
done

# copy GM/WM/CSF masks
cd $maskdir
maskList=`ls *EPIRes+orig*`
for mask in $maskList
do
	oldFilename="$maskdir""$mask"
	newFilename="$outdir""$subject"/"$subject"_"$mask"
	[ -e "$oldFilename" ] && ln -s "$oldFilename" "$newFilename" || echo "$oldFilename" not found!
done

# Create full-brain mask
3dcalc -a "$maskdir"Gray_EPIRes+orig -b "$maskdir"White_EPIRes+orig -c "$maskdir"CSF_EPIRes+orig -expr 'step(a+b+c)' -prefix "$outdir""$subject"/"$subject"_FullBrain_EPIRes+orig

echo === Done!