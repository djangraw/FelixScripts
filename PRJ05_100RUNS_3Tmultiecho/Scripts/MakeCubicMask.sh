#!/bin/bash
######
# MakeCubicMask.sh
#
# Make cubic mask of a certain radius (half the edge length) around a certain point.
#
# USAGE:
# >> MakeCubicMask x_ctr y_ctr z_ctr radius resfile outfile [coordsys]
#
# INPUTS:
# -(x_ctr, y_ctr, z_ctr) is the position of the center of the cube (in mm: AFNI coordinates)
# -radius is the radius (half the edge length) of the cube (in mm)
# -resfile is the filename whose size/resolution you want to use in the mask (an AFNI file)
# -outfile is the filename where you'd like to save the mask (.BRIK/.HEAD)
# -coordsys is the flag (e.g., -RAI or -LPI) to pass to 3dcalc to define the coordinate system order. 
#   If none is specified, AFNI defaults to RAI.
#
# Created 4/21/15 by DJ.
# Updated 12/3/15 by DJ - added optional coordsys input.
######

# stop if error 
set -e

# check nInputs
if [[ $# -lt 6 ]]; then
	echo "USAGE: MakeSphericalMask x_ctr y_ctr z_ctr radius resfile outfile [coordsys]"
fi

# parse inputs
x_ctr=$1
y_ctr=$2
z_ctr=$3
radius=$4
resfile=$5
outfile=$6
coordsys=$7

echo $1 $2 $3 $4 $5 $6 $7

# use 3dcalc to create mask
3dcalc $coordsys -a $resfile -expr "within(x,${x_ctr}-${radius},${x_ctr}+${radius}-.001) * within(y,${y_ctr}-${radius},${y_ctr}+${radius}-.001) * within(z,${z_ctr}-${radius},${z_ctr}+${radius}-.001)" -prefix $outfile -overwrite # add .001s to make it exclusive on one side
