#!/bin/bash

# Make100RunsTaskShortcuts.sh
#
# SAMPLE USAGE:
# Make100RunsTaskShortcuts.sh subject nSessions nRunsPerSession
#
# INPUTS:
# - subject is a string (e.g., SBJ01)
# - nSessions is a 1-digit integer (e.g., 9)
# - nRunsPerSession is a 1-digit integer (e.g., 2)
#
# Created 8/3/15 by DJ based on Make100RunsVideoShortcuts.sh.
# Updated 8/14/15 by DJ - allow 2-digit sessions and runs
# Updated 8/17/15 by DJ - specify 5-echo files and allow them in.

# stop if error 
set -e

# declare constants
subject=$1 #"SBJ01"
nSessions=$2 #9
nRunsPerSession=$3 #2

# declare directories
basedir="/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/"
outdir="/data/jangrawdc/PRJ06_NeuralCurrent/PrcsData/100RUNS_3Tmultiecho/"
# dirend="SBJ01_S02/D01_Version02.AlignByAnat.Cubic/Video01"
maskdir=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/CrossRunAnalyses.AnatAlign/"$subject"/RegistrationComparisons/

# Loop 1: mean across files
echo === Making Shortcuts...
for (( iSession=1; iSession<=$nSessions; iSession++ ))
do
	sesID=`printf %02d ${iSession}`
	for (( iRun=1; iRun<=$nRunsPerSession; iRun++ ))
	do
		# exclude final 4 files, which have 5 echoes.
		if [ $iSession -eq 9 ] && [ $iRun -gt 7 ];	then
			nEchoes=5
			suffix="of5"
		else
			nEchoes=3
			suffix=""
		fi
		
		runID=`printf %02d ${iRun}`
		for (( iEcho=1; iEcho<=${nEchoes}; iEcho++))
		do
			# This echo
			oldFilename="$basedir""$subject"_S"$sesID"/D01_Version02.AlignByAnat.Cubic/Task"$runID"/p04."$subject"_S"$sesID"_Task"$runID"_e"$iEcho".align_clp+orig
			newFilename="$outdir""$subject"/"$subject"_S"$sesID"_R"$runID"_Task_Echo"$iEcho""$suffix"+orig
			[ -e "$oldFilename".BRIK ] && ln -s "$oldFilename".BRIK "$newFilename".BRIK || echo "$oldFilename".BRIK not found!
			[ -e "$oldFilename".HEAD ] && ln -s "$oldFilename".HEAD "$newFilename".HEAD || echo "$oldFilename".HEAD not found!
		done
		
		# Optimally combined
		oldFilename="$basedir""$subject"_S"$sesID"/D01_Version02.AlignByAnat.Cubic/Task"$runID"/TED/ts_OC.nii
		newFilename="$outdir""$subject"/"$subject"_S"$sesID"_R"$runID"_Task_OptCom+orig.nii
		[ -e $oldFilename ] && ln -s $oldFilename $newFilename || echo $oldFilename not found!
		# MEICA denoised
		oldFilename="$basedir""$subject"_S"$sesID"/D01_Version02.AlignByAnat.Cubic/Task"$runID"/TED/dn_ts_OC.nii
		newFilename="$outdir""$subject"/"$subject"_S"$sesID"_R"$runID"_Task_MeicaDenoised+orig.nii
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

# Copy mask
ln -s /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/"$subject"/"$subject"_MaskAllTaskRuns+orig.BRIK "$outdir""$subject"/"$subject"_MaskAllTaskRuns+orig.BRIK
ln -s /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/"$subject"/"$subject"_MaskAllTaskRuns+orig.HEAD "$outdir""$subject"/"$subject"_MaskAllTaskRuns+orig.HEAD

echo === Done!