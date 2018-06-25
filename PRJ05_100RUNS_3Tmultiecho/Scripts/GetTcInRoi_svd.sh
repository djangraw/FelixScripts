#!/bin/bash
# GetTcInRoi_svd.sh
# Created 4/24/15 by DJ.

set -e

cd /data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ01/
mask=TestSphere_olap
files=($(ls -d *MeicaDenoised+orig.nii))

for file in ${files[@]}
do
	namestart=`echo $file | cut -c1-14`
	3dBlurInMask -overwrite -FWHM 6 -mask SBJ01_FullBrain_EPIRes+orig. -prefix ${namestart}_blur6+orig.nii $file 
	
	# 3dmaskSVD -vnorm -sval 1 -mask ${mask}+orig -polort 0 $file > ${namestart}${mask}_top2svd_TC.1D
done
	