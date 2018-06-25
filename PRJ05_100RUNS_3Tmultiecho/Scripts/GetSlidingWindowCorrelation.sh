#!/bin/bash
######
# GetSlidingWindowCorrelation.sh
#
# Find the voxelwise correlation between two datasets within a sliding time window
#
# USAGE:
# >> GetSlidingWindowCorrelation file1 file2 mask windowlength outfile
#
# INPUTS:
# -file1 and file2 are 3d+t AFNI files of equal size.
# -mask is a 3d AFNI file of equal size to file1 and file2. Any samples in mask that are 0 will not be used.
# -windowlength is a positive integer indicating the number of samples in the window.
# -outfile is the filename where you'd like to save the mask (.BRIK/.HEAD)
#
# Created 4/23/15 by DJ.
######

# stop if error 
set -e

# check nInputs
if [[ $# -ne 5 ]]; then
	echo "USAGE: GetSlidingWindowCorrelation file1 file2 mask windowlength outfile"
fi

# parse inputs
file1=$1
file2=$2
mask=$3
windowlength=$4
outfile=$5

#echo $1 $2 $3 $4 $5

# calculate end position
nt=`3dinfo -nt $file1`
TR=`3dinfo -tr $file1`
iStop=$(($nt-$windowlength))

# loop through time points
for (( i=0; i<$iStop; i++ )); 
do
	# get window limit
	iWinEnd=(($i+$windowlength))
	# get ISC value
	echo Running ISC...
	fullCorrFile=CorrNoMask_sample"$i"+orig
	3dTcorrelate -prefix $fullCorrFile ${file1[$i..$iWinEnd]} ${file2[$i..$iWinEnd]}	
	# apply mask
	echo Applying mask...
	maskedCorrFiles[$i]=CorrMasked_sample"$i"+orig
	3dcalc -overwrite -a $fullCorrFile -b $mask -expr 'a*notzero(b)' -prefix ${maskedCorrFiles[$i]}
	# clean up
	echo Deleting unmasked files...
	rm $fullCorrFile* # rm .HEAD and .BRIK
done

# combine across masked files
3dTcat -prefix $outfile -tr $TR ${maskedCorrFiles[*]}
# clean up
echo Deleting masked files...
rm ${maskedCorrFiles[*]}