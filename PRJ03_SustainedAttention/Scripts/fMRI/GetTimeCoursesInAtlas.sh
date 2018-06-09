#!/bin/bash
# GetTimeCoursesInAtlas.sh
#
# Warp a given atlas to the EPI space, resample it to match the EPI data, then get the time series within each ROI of the atlas.
#
# USAGE:
#   bash GetTimeCoursesInAtlas.sh $subj $epiFile $atlasFile $outFile
#
# INPUTS:
# 	- epiFile is a string indicating the 4D AFNI file whose timecourses you want to extract
#       -
#
# OUTPUTS:
#	- Writes links for CraddockAtlas_200Rois+tlrc and files for CraddockAtlas_200Rois_${subj}epires_masked and
#     CraddockAtlas_200Rois_${subj}epires.
#
# Created 5/2/16 by DJ based on 06_WarpCraddockAtlasToEpiSpace.sh.

# ======== SET UP ========
# exit if error
set -e
source ./00_CommonVariables.sh # Get PRJDIR
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj="errts.SBJ05.tproject+tlrc"
fi
if [ ${#argv} > 1 ]; then
    epiFile=${argv[1]}
else
    epiFile="errts.SBJ05.tproject+tlrc"
fi
if [ ${#argv} > 2 ]; then
    atlasFile=${argv[2]}
else
    atlasFile=${PRJDIR}/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc
fi
if [ ${#argv} > 3 ]; then
    outFile=${argv[3]}
else
    outFile=${subj}_CraddockAtlas_200Rois_ts.1D
fi

# Get project and output directory
output_dir=${epiFile%/*}
atlasFile_short=${atlasFile##*/}
atlasFile_prefix=${atlasFile_short%%+*}
echo "output_dir = $output_dir"
echo "outFile = $outFile"

# get output directory
if [ -z ${output_dir} ]; then
  output_dir=`pwd`
fi
cd ${output_dir}

# Make shortcut to atlas in current directory
if [ ! -f ${atlasFile_short}.HEAD ]; then
    ln -s ${atlasFile}* .
fi

# warp into space of EPI dataset
3dresample -rmode NN -master "${epiFile}[0]" -overwrite -prefix ${atlasFile_prefix}_${subj}epires -input ${atlasFile_short}
3dcalc -a ${atlasFile_prefix}_${subj}epires+tlrc. -b full_mask.${subj}+tlrc. -expr 'a*step(b)' -overwrite -prefix ${atlasFile_prefix}_${subj}epires_masked

# Get value within each ROI using SVD
nRois=`3dBrickStat -max ${atlasFile}`

# Perform SVD in masks
for roi in $(seq 1 $nRois)
do
  roiID=`printf %03d ${roi}`
  echo "## INFO: ROI[${roiID}]"
  3dmaskSVD -vnorm -mask ${atlasFile_prefix}_${subj}epires_masked+tlrc"<${roi}..${roi}>" ${epiFile} > rm_SVD_roi${roiID}.1D
done
# glue together into one big file, then delete the individual files
echo "## INFO: Assembling results..."
1dcat rm_SVD_roi*.1D > ${outFile}
rm -f rm_SVD_roi*.1D
echo "## DONE!"
