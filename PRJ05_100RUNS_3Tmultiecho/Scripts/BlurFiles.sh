#!/bin/bash
# BlurFiles.sh
#
# SAMPLE USAGE:
# bash BlurFiles.sh mask file1 file2 ... fileN
#
# INPUTS:
# 1. mask is the filename of an AFNI mask.
# 2. file1, file2, ... is a list of files you want to blur.
#
# Created 4/27/15 by DJ.
# Updated 4/20/15 by DJ - cleanup, added Echo2 (TO DO: CHECK ECHO2 LINES!)
# Updated 5/4/15 by DJ - changed inputs, found cleaner way to find namestart

set -e

#cd /data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ01/
mask=$1 #SBJ01_FullBrain_EPIRes+orig
shift
fileList=( "$@" )
		
# files=($(ls -d *Echo2+orig.BRIK)) 

for file in ${fileList[@]}
do
	namestart=${file%+*} # remove everything after first +
	# namestart=`echo $file | cut -c1-$cutoff`
	# namestart=`echo $file | cut -c1-25`	
	3dBlurInMask -overwrite -FWHM 6 -mask $mask -prefix ${namestart}_blur6+orig $file 
done
	