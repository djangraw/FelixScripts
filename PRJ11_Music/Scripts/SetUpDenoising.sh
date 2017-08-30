#!/bin/bash
#
# USAGE:
# bash SetUpDenoising.sh
#
# Created 5/18/17 by DJ.

subj=SBJ03_wholesong
scriptPath=/data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI
atlasFile=Segsy/Classes+tlrc.HEAD
epiFile=bl.all_runs.$subj
prefix=./

3dTcat -overwrite -prefix $epiFile bl07.${subj}.r*.scale+tlrc.HEAD
python $scriptPath/TsExtractGmWmCsfGs.py -Atlas $atlasFile -EPI $epiFile+tlrc.HEAD -prefix $prefix


# superior parietal: (xyz (RAI) = 1.5 62.5 74.5)
3dmaskave -q -dbox 1.5 62.5 74.5 $epiFile+tlrc > bl.MaskData_1_62_74.1D
# inferior occipital: (xyz (RAI) = -1.5 104.5 8.5)
3dmaskave -q -dbox -1.5 104.5 8.5 $epiFile+tlrc > bl.MaskData_-1_104_8.1D
# superior occipital: (xyz (RAI) = -2 92 40)
3dmaskave -q -dbox -2.5 92.5 40.5 $epiFile+tlrc > bl.MaskData_-2_92_40.1D
# frontal pole: (xyz (RAI) = -1 -67 -20)
3dmaskave -q -dbox -1 67 -20 $epiFile+tlrc > bl.MaskData_-1_-67_-20.1D


# left inferior occipital: (xyz (RAI) = 20 77 -20)
# 3dmaskave -q -dbox 20 77 -20 $epiFile+tlrc > bl.MaskData_20_77_-20.1D
