#!/bin/bash

# Run echo-difference analysis on 100-runs data.
# SubtractEchoes.sh
#
# SAMPLE USAGE:
# bash SubtractEchoes.sh echo1FileList ...
#
# INPUTS:
# 1. list of filenames (array of .BRIK files) e.g., files=( $(ls *_R*.BRIK) ); ${files[@]:0:y}
# 
# OUTPUTS:
# saves <echo1FileList[i][0:end-11]>_e2m1 (echo2 minus echo1) and _e3m2 to current directory
# 
# Created 8/3/15 by DJ.

# stop if error 
set -e

#parse inputs
echo1FileList=( "$@" )
nFiles=${#echo1FileList[@]}

# perform subtraction
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
	strLength=${#echo1FileList[$iFile]}
	let baseLength=$strLength-15 # 15 is the length of "echo1+orig.BRIK"
	thisFileBase=${echo1FileList[$iFile]:0:$baseLength}
	# echo $thisFileBase
	echo 3dcalc -a "$thisFileBase"Echo2+orig.BRIK -b "$thisFileBase"Echo1+orig.BRIK -expr \"a-b\" -prefix "$thisFileBase"e2m1
	echo 3dcalc -a "$thisFileBase"Echo3+orig.BRIK -b "$thisFileBase"Echo2+orig.BRIK -expr \"a-b\" -prefix "$thisFileBase"e3m2
	# do it!
	3dcalc -a "$thisFileBase"Echo2+orig.BRIK -b "$thisFileBase"Echo1+orig.BRIK -expr "a-b" -prefix -overwrite "$thisFileBase"e2m1
	3dcalc -a "$thisFileBase"Echo3+orig.BRIK -b "$thisFileBase"Echo2+orig.BRIK -expr "a-b" -prefix -overwrite "$thisFileBase"e3m2
done