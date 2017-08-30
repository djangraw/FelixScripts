#!/bin/bash
########
# DetrendAndAddBackMean.sh
#
# Remove polynomial trends from files, then add back their mean.
#
# USAGE:
# >> DetrendAndAddBackMean polort mask outsuffix file1 file2... fileN
#
# INPUTS:
# -polort is the input of 3dDetrend. 1 = linear detrending, 2 = quadratic, 3 = cubic
# -mask is a 3d AFNI file of equal size to file. Any samples in mask that are 0 will not be used.
# -outsuffix will be appended to the filename where you'd like to save the mask (.BRIK/.HEAD)
# -file1, file2... fileN are 3d+t AFNI files.
#
# Created 9/1/15 by DJ.
########

# Stop if error 
set -e

# Parse inputs
polort=$1
shift
mask=$1
shift
outsuffix=$1
shift
files=( "$@" )

# display properties
nFiles=${#files[@]}
echo "nFiles=$nFiles"

# Main loop
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
	# remove temporary files
	echo 'rm TEMP*'
	rm TEMP*

	# get mean
	echo "3dTstat -mean -prefix TEMP_mean ${files[$iFile]}"
	3dTstat -mean -prefix TEMP_mean ${files[$iFile]}

	# run 3dDetrend
	echo "3dDetrend -polort $polort -prefix TEMP_detrended ${files[$iFile]}"
	3dDetrend -polort $polort -prefix TEMP_detrended ${files[$iFile]} 

	# add mean back
	echo "iPlus=\`expr index "${files[$iFile]}" ""\+""\`"
	let iPlus=`expr index "${files[$iFile]}" "\+"`
	echo "let iPlus-=1"
	let iPlus-=1
	echo "outprefix=""${files[$iFile]:0:$iPlus}"""
	outprefix="${files[$iFile]:0:$iPlus}"
	echo "outfile=""${outprefix}${outsuffix}"""
	outfile="${outprefix}${outsuffix}"
	echo "3dcalc -a TEMP_detrended+orig -b TEMP_mean+orig -expr 'a+b' -prefix $outfile"
	3dcalc -a TEMP_detrended+orig -b TEMP_mean+orig -expr 'a+b' -prefix $outfile
done