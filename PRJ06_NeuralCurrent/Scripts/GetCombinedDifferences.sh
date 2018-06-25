#!/bin/bash

# Run echo-difference analysis on 100-runs data.
# GetCombinedDifferences.sh
#
# SAMPLE USAGE:
# bash GetCombinedDifferences.sh echo1FileList ...
#
# INPUTS:
# 1. list of filenames (array of .BRIK files) e.g., files=( $(ls *_R*.BRIK) ); ${files[@]:0:y}
# 
# OUTPUTS:
# saves <echo1FileList[i][0:end-15]>absdiff to current directory
# 
# Created 8/10/15 by DJ.

# stop if error 
set -e

#parse inputs
echo1FileList=( "$@" )
nFiles=${#echo1FileList[@]}

# get clip level

# clip=99999
#
# for (( iFile=0; iFile<$nFiles; iFile++ ))
# do
# 	cur=`3dClipLevel $echo1FileList[$iFile]`
# 	if [ `echo "$cur < $clip" | bc` = 1 ]; then
# 	    clip=$cur
# 	fi
# done
# echo clip = "$clip"

# perform subtraction
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
	echo iFile="$iFile"/"$nFiles"...
	strLength=${#echo1FileList[$iFile]}
	let baseLength=$strLength-15 # 15 is the length of "Echo1+orig.BRIK"
	thisFileBase=${echo1FileList[$iFile]:0:$baseLength}
	
	# CROP
	# if it's from the first session, use 0-150, otherwise 4-154.
	echo ${thisFileBase:0:9}
	if [ "${thisFileBase:0:9}" = "SBJ01_S01" ]; then
		iStart=0
	else
		iStart=4
	fi
	let iEnd=iStart+150
	
	for (( iEcho=1; iEcho<=3; iEcho++ ))
	do		
		echo iEcho="$iEcho"/3...
		filename="$thisFileBase"Echo"$iEcho"+orig.BRIK
		
		# CLEAN UP
		# rm -f tmp*
		
		# (ADJUST)
		# slice time correction and motion correction were done previously in the align_clp files.
	
		# CROP AND NORMALIZE
		# convert to percent signal change	
		# echo 3dTstat -mean -prefix tmp.01.mean "$filename"[$iStart..$iEnd]
		# 3dTstat -mean -prefix tmp.01.mean "$filename"[$iStart..$iEnd]
		# echo 3dcalc -a "$filename"[$iStart..$iEnd] -b tmp.01.mean+orig.BRIK -expr \"\(\(a-b\)/b*100\)*step\(b-$clip\)\" -prefix tmp.02.norm
		# 3dcalc -a "$filename"[$iStart..$iEnd] -b tmp.01.mean+orig.BRIK -expr "((a-b)/b*100)*step(b-$clip)" -prefix tmp.02.norm
		
		# CROP AND DETREND
		# run 3rd-order detrending on each echo.
		# echo 3dDetrend -overwrite -prefix "$thisFileBase"Echo"$iEcho"_detrend -polort 3 tmp.02.norm+orig.BRIK
# 		3dDetrend -overwrite -prefix "$thisFileBase"Echo"$iEcho"_detrended -polort 3 tmp.02.norm+orig.BRIK
		echo 3dDetrend -overwrite -prefix "$thisFileBase"Echo"$iEcho"_detrend -polort 3 "$filename"[$iStart..$iEnd]
		3dDetrend -overwrite -prefix "$thisFileBase"Echo"$iEcho"_detrended -polort 3 "$filename"[$iStart..$iEnd]
	
		
	done
	
	# COMBINE
	# echo 3dcalc -a "$thisFileBase"Echo1_detrended+orig.BRIK -b "$thisFileBase"Echo2_detrended+orig.BRIK -c "$thisFileBase"Echo3_detrended+orig.BRIK -expr \"abs\(a-b\)+abs\(b-c\)+abs\(c-a\)\" -prefix -overwrite "$thisFileBase"absdiff
	# combine echoes
	# 3dcalc -a "$thisFileBase"Echo1_detrended+orig.BRIK -b "$thisFileBase"Echo2_detrended+orig.BRIK -c "$thisFileBase"Echo3_detrended+orig.BRIK -expr "abs(a-b)+abs(b-c)+abs(c-a)" -prefix -overwrite "$thisFileBase"absdiff
	echo 3dcalc -a "$thisFileBase"Echo1_detrended+orig.BRIK -b "$thisFileBase"Echo2_detrended+orig.BRIK -c "$thisFileBase"Echo3_detrended+orig.BRIK -expr \"a-b\" -prefix "$thisFileBase"e1m2 -overwrite
	echo 3dcalc -a "$thisFileBase"Echo1_detrended+orig.BRIK -b "$thisFileBase"Echo2_detrended+orig.BRIK -c "$thisFileBase"Echo3_detrended+orig.BRIK -expr \"b-c\" -prefix "$thisFileBase"e2m3 -overwrite
	echo 3dcalc -a "$thisFileBase"Echo1_detrended+orig.BRIK -b "$thisFileBase"Echo2_detrended+orig.BRIK -c "$thisFileBase"Echo3_detrended+orig.BRIK -expr \"a-c\" -prefix "$thisFileBase"e1m3 -overwrite
	
	3dcalc -a "$thisFileBase"Echo1_detrended+orig.BRIK -b "$thisFileBase"Echo2_detrended+orig.BRIK -c "$thisFileBase"Echo3_detrended+orig.BRIK -expr "a-b" -prefix "$thisFileBase"e1m2 -overwrite
	3dcalc -a "$thisFileBase"Echo1_detrended+orig.BRIK -b "$thisFileBase"Echo2_detrended+orig.BRIK -c "$thisFileBase"Echo3_detrended+orig.BRIK -expr "b-c" -prefix "$thisFileBase"e2m3 -overwrite
	3dcalc -a "$thisFileBase"Echo1_detrended+orig.BRIK -b "$thisFileBase"Echo2_detrended+orig.BRIK -c "$thisFileBase"Echo3_detrended+orig.BRIK -expr "a-c" -prefix "$thisFileBase"e1m3 -overwrite

	
done