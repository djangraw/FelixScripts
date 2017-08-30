#!/bin/bash
# 06_WarpCraddockAtlasToEpiSpace.sh
#
# Warp Craddock atlas into EPI space, resample it to match the EPI data, then get the timecourse in each ROI.
#  
# USAGE:
#   bash 06_WarpCraddockAtlasToEpiSpace.sh $subj $outFolder
# 
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#   - outFolder is a string indicating the name of the folder where output should be placed (and where errts.${subj}.tproject is)
#
# OUTPUTS:
#	- Writes links for CraddockAtlas_200Rois+tlrc and files for CraddockAtlas_200Rois_${subj}epires_masked and 
#     CraddockAtlas_200Rois_${subj}epires.
#
# Created 2/8/16 by DJ.
# Updated 9/7/16 by DJ - switched to scaled data file
# Updated 9/22/16 by DJ - switched back to errts.SBJ.tproject, use 3dresample instead of 3dWarp

# ======== SET UP ========
# exit if error
set -e
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj=SBJ05
fi
if [ ${#argv} > 1 ]; then
    outFolder=${argv[1]}
else
    outFolder=AfniProc_MultiEcho
fi

#echo "$subj $outFolder"

# Get project and output directory
source ./00_CommonVariables.sh # Get PRJDIR
output_dir="${PRJDIR}/Results/${subj}/${outFolder}"

cd ${output_dir}
if [ ! -f CraddockAtlas_200Rois+tlrc.HEAD ]; then
    ln -s ${PRJDIR}/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc.* .
fi
# 3dWarp -mni2tta -NN -gridset "errts.${subj}.tproject+tlrc[0]" -overwrite -prefix CraddockAtlas_200Rois_${subj}epires CraddockAtlas_200Rois+tlrc
3dresample -master "errts.${subj}.tproject+tlrc[0]" -overwrite -prefix CraddockAtlas_200Rois_${subj}epires -inset CraddockAtlas_200Rois+tlrc
3dcalc -a CraddockAtlas_200Rois_${subj}epires+tlrc. -b full_mask.${subj}+tlrc. -expr 'a*step(b)' -overwrite -prefix CraddockAtlas_200Rois_${subj}epires_masked


# Get value within each ROI using SVD
nRois=200
AtlasFile="CraddockAtlas_${nRois}Rois_${subj}epires_masked+tlrc"
DataFile="errts.${subj}.tproject+tlrc"
# DataFile="pb06.${subj}.scaled+tlrc"

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

