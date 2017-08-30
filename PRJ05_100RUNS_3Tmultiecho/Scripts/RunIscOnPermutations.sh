#!/bin/bash

# Create directory and file variables in the workspace and run RunIscOn100RunsVideo.
# RunIscOnPermutations.sh
#
# SAMPLE USAGE:
# . RunIscOnPermutations.sh subject nPerms inputType
#
# INPUTS:
# 1. subject is a string indicating the subject (e.g., SBJ01)
# 2. nPerms is an integer indicating the number of permutations you'd like to run
# 3. inputType is a string
#
# Created 10/8/15 by DJ.

# stop if error (disable if we'll be sourcing this)
# set -e

# get inputs
subject=$1
nPerms=$2
inputType=$3

datadir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/$subject/"
scriptdir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Scripts/"
fbmask="$datadir""$subject"_FullBrain_EPIRes+orig.BRIK
outdir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/$subject/ISC/Perms${inputType}/"

# get path to data
datadir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/$subject/ICAtest/Perms/"

# run ISC
for (( iPerm=1; iPerm<=$nPerms; iPerm++ ))
do
	printf -v strPerm "%03d" $iPerm
	diaryfile=${outdir}${subject}_${inputType}_ISC_perm${strPerm}.diary
	permfiles=( $(ls ${datadir}*_${inputType}_perm${strPerm}+orig.BRIK) )
	nFiles=${#permfiles[@]}	
	outfile=${outdir}${subject}_${inputType}_ISC_perm${strPerm}_${nFiles}files+orig.BRIK
	# [ -e ${diaryfile} ] && continue
	[ -e ${outfile} ] && continue
	echo "===Running permutation ${strPerm}: $nFiles files"
        sbatch ${scriptdir}RunIscOn100RunsVideo_pairwise.sh $subject ${subject}_${inputType}_ISC_perm${strPerm}_ $fbmask ${permfiles[@]} 1>${diaryfile} 2>$1
	sleep 2
	
done