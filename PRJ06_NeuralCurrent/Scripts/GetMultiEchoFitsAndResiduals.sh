#!/bin/bash
########
# GetMultiEchoFitsAndResiduals.sh
#
# Find the least-squares fit for each voxel and time point to an exponential function.
#
# USAGE:
# >> GetMultiEchoFitsAndResiduals echoTimes mask outfile file1 file2 ... fileN
#
# INPUTS:
# -echoTimes is a 1D filename containing a single-column list of values for the times of each echo.
# -mask is a 3d AFNI file of equal size to file1 and file2. Any samples in mask that are 0 will not be used.
# -outfile is the filename where you'd like to save the mask (.BRIK/.HEAD)
# -file1 and file2 are 3d+t AFNI files of equal size.
#
# Created 9/1/15 by DJ.
# Updated 9/2-4/14 by DJ - debugging, switched from T2 files to R2
########

# stop if error 
set -e

# Parse inputs
echoTimes=$1
shift
mask=$1
shift
outfile=$1
shift
files=( "$@" )
nFiles=${#files[@]}

# display properties
nT=`3dinfo -nT ${files[0]}`
TR=`3dinfo -tr ${files[0]}`
echo "nFiles=$nFiles"
echo "nT=$nT"
echo "TR=$TR"

# remove output files if they exist
if [ -e "${outfile}_S0+orig.BRIK" ]
then
	rm ${outfile}_S0+orig.*
fi
if [ -e "${outfile}_R2+orig.BRIK" ]
then
	rm ${outfile}_R2+orig.*
fi


# main loop
for (( iT=0; iT<$nT; iT++ ))
do
	echo "===iT = ${iT}..."
	argString=""
	# make string for 3dtcat argument
	for (( iFile=0; iFile<$nFiles; iFile++ ))
	do
		argString="$argString ${files[$iFile]}[$iT]"
	done
	
	# combine across echoes
	echo "rm TEMP*"
	rm TEMP*
	echo "3dTcat -prefix TEMP $argString"
	3dTcat -prefix TEMP $argString
	
	# Run 3dNLfim
	# timeID=`printf %03d ${iT}`
# 	bucketName="${outfile}_time${timeID}.bucket"
# 	echo "3dNLfim -input TEMP+orig -mask ""$mask"" -ignore 0 -noise Zero -signal Exp -nrand 100 -nbest 5 -fdisp 100.0 -bucket 0 ""$bucketName"" -time ""$echoTimes"""
# 		-bucket 0 "$bucketName" \
	3dNLfim \
		-input TEMP+orig \
		-mask "$mask" \
		-ignore 0 \
		-noise Zero \
		-signal Exp \
		-nrand 100 \
		-nbest 5 \
		-sconstr 0 0 10000 \
		-sconstr 1 -0.1 0 \
		-fdisp 9999999.0 \
		-fscoef 0 "TEMP_S0" \
		-fscoef 1 "TEMP_R2" \
		-overwrite \
		-time "$echoTimes"		
	
	if [ -e "${outfile}_S0+orig.BRIK" ]
	then
		# Copy offsets and R2s into full datasets
		3dTcat -prefix ${outfile}_S0+orig -overwrite -tr ${TR} ${outfile}_S0+orig TEMP_S0+orig[0]
		3dTcat -prefix ${outfile}_R2+orig -overwrite -tr ${TR} ${outfile}_R2+orig TEMP_R2+orig[0]
	else
		3dbucket -prefix ${outfile}_S0+orig TEMP_S0+orig[0]
		3dbucket -prefix ${outfile}_R2+orig TEMP_R2+orig[0]
	fi
	
done