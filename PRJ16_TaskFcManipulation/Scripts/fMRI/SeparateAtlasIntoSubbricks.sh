#!/bin/bash

# SeparateAtlasIntoSubbricks.sh $atlas
#
# Created 10/4/17 by DJ.

atlas=$1

# Get number of ROIs
nRois=`3dinfo -dmaxus $atlas`

# For each ROI, place it in a new sub-brick
rm TEMP_ROI*
for iRoi in `seq 1 $nRois`; do
  iRoi_3digit=$(printf "%03d" $iRoi)
  3dcalc -a $atlas"<$iRoi>" -expr 'step(a)' -prefix TEMP_ROI${iRoi_3digit}
done

# Concatenate these files as sub-bricks
outFile=${atlas%%.*}_subbricks.nii.gz
3dTcat -prefix $outFile TEMP_ROI*.HEAD
