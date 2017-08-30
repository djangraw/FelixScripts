#!/bin/bash
# GetTimeCoursesInAtlas.sh
#
# Warp a given atlas to the EPI space, resample it to match the EPI data, then get the time series within each ROI of the atlas.
#  
# USAGE:
#   bash GetTimeCoursesInAtlas.sh $epiFile $atlasFile $outFile
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
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    epiFile=${argv[0]}
else
    epiFile="errts.SBJ05.tproject+tlrc"
fi
if [ ${#argv} > 1 ]; then
    atlasFile=${argv[1]}
else
    atlasFile=CraddockAtlas_200Rois+tlrc.
fi
if [ ${#argv} > 2 ]; then
    outFile=${argv[2]}
else
    outFile=TEST
fi

#echo "$subj $outFolder"

# Get project and output directory
source ./00_CommonVariables.sh # Get PRJDIR
output_dir="${PRJDIR}/Results/${subj}/${outFolder}"

# Make shortcut to atlas in directory
cd ${output_dir}
if [ ! -f CraddockAtlas_200Rois+tlrc.HEAD ]; then
    ln -s ${PRJDIR}/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc.* .
fi
# warp into TLRC space of EPI dataset
3dWarp -mni2tta -NN -gridset "errts.${subj}.tproject+tlrc[0]" -overwrite -prefix CraddockAtlas_200Rois_${subj}epires CraddockAtlas_200Rois+tlrc
3dcalc -a CraddockAtlas_200Rois_${subj}epires+tlrc. -b full_mask.${subj}+tlrc. -expr 'a*step(b)' -overwrite -prefix CraddockAtlas_200Rois_${subj}epires_masked

# Get value within each ROI using SVD
nRois=`3dBrickStat -max ${atlasFile}`

# Perform SVD in masks
for roi in $(seq 1 $nRois)
do
  roiID=`printf %03d ${roi}`
  echo "## INFO: ROI[${roiID}]"
  3dmaskSVD -vnorm -mask ${AtlasFile}"<${roi}..${roi}>" ${DataFile} > rm_SVD_roi${roiID}.1D      
done
# glue together into one big file, then delete the individual files
echo "## INFO: Assembling results..."
1dcat rm_SVD_roi*.1D > ${subj}_CraddockAtlas_${nRois}Rois_ts.1D
rm -f rm_SVD_roi*.1D
echo "## DONE!"

