#!/bin/bash

# RunGroupTtestWithCovariates.sh
#
# SAMPLE USAGE:
# bash RunGroupTtestWithCovariates.sh $coefPrefix $covarFile $outPrefix $clustOption
#
# INPUTS:
# -coefPrefix is the start of files to be included in the ttest.
# -covarFile is the path to the covariates file (can include column selectors)
# -outPrefix is the start of the output files that will be written.
# -clustOption is an added option for 3dttest++. It can be -Clustsim or -ETAC.
#
# OUTPUTS:
# -writes one file for each brick: ${outPrefix}_brick${i}, where i is the
#  number of subbricks/contrasts.
#
# Created 1/9/18 by DJ.

# Parse inputs
coefPrefix=$1
covarFile=$2
outPrefix=$3
clustOption=$4

# Set options
# clustOption='-Clustsim'
# clustOption='-ETAC'
# clustOption=''

# Set up
files=(`ls ${coefPrefix}*.HEAD`)
nT=`3dinfo -nT ${files[0]}`
let lastBrick=$nT-1
# Run 3dttest++ for each subbrick
for i in `seq 0 $lastBrick`;
do
    echo "3dttest++ -mask MNI_mask_epiRes.nii -overwrite -prefix ${outPrefix}_brick${i} -setA ${coefPrefix}*.HEAD[$i] -covariates $covarFile $clustOption"
    3dttest++ -mask MNI_mask_epiRes.nii -overwrite -prefix ${outPrefix}_brick${i} -setA ${coefPrefix}*.HEAD[$i] -covariates $covarFile $clustOption
done
# combine the results
3dTcat -prefix ${outPrefix}_allBricks -overwrite ${outPrefix}_brick*.HEAD
