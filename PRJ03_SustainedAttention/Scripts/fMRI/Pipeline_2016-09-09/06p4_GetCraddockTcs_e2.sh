#!/bin/bash
# 06p4_GetCraddockTcs_e2.sh
#
# Get the timecourse of activity in each ROI of the Craddock Atlas for the echo2 data.
#  
# USAGE:
#   bash 06p4_GetCraddockTcs_e2.sh $subj $outFolder
# 
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#   - outFolder is a string indicating the name of the folder where output should be placed (and where errts.${subj}.tproject is)
#
# OUTPUTS:
#	- Writes 1D file ${subj}_CraddockAtlas_${nRois}Rois_ts_e2.1D
#
# Created 6/13/16 by DJ based on 06_WarpCraddockAtlasToEpiSpace.sh.

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

# Get value within each ROI using SVD
nRois=200
AtlasFile="CraddockAtlas_${nRois}Rois_${subj}epires_masked+tlrc"
DataFile="errts_e2.${subj}.tproject+tlrc"

# Perform SVD in masks
for roi in $(seq 1 $nRois)
do
  roiID=`printf %03d ${roi}`
  echo "## INFO: ROI[${roiID}]"
  3dmaskSVD -vnorm -mask ${AtlasFile}"<${roi}..${roi}>" ${DataFile} > rm_SVD_roi${roiID}.1D      
done
# glue together into one big file, then delete the individual files
echo "## INFO: Assembling results..."
1dcat rm_SVD_roi*.1D > ${subj}_CraddockAtlas_${nRois}Rois_ts_e2.1D
rm -f rm_SVD_roi*.1D
echo "## DONE!"

