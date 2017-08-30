#!/bin/bash
# Date: 07/15/2014
# Authors: Javier Gonzalez-Castillo, Colin W. Hoy
###########################################################################
#### Date: June 23, 2014
####
#### DESCRIPTION:
#### ============
####   Colin took this program from PRJ04_MostLeastStable to extract an SVD
####       timeseries for each ROI in the Craddock atlas. (Replaces the 
####       intra-ROI correlation approach.
####
####   6/27/14: updated this to work on ts that are bandpassed differently
####			for each window length
####   8/17/14: updated to work with atlas with different number of ROIs
####            INPUTS:
####              SBJ=SBJ06
####              NROIS=150
####              WL=180
####   2/3/16: updated by DJ to work for random parcellations. 
###########################################################################

# COMMON STUFF
source ./00_CommonVariables.sh
# ## Read Input Parameters
# if [ $# -ne 2 ]; then
#     echo "Usage: $basename $0 SBJID AtlasID"
#     exit
# fi

OMP_NUM_THREADS=24

subjNums=(`count -digits 2 6 27`)
WL=045
nRois=200 # number of ROIs (originally) in each parcellation
nParc=10 # number of random parcellations
AtlasID=Craddock_RandParc_${nRois}ROIs

# transform into individual space and remove any ROIs with <10 voxels
for subjNum in ${subjNums[@]}
do
    # set up
    SBJ=SBJ$subjNum

    # Get into data directory for this subject
    cd ${PRJDIR}/PrcsData/${SBJ}/${DPREFIX}_${RUN}
        
    DataFile="pb08.${SBJ}_${RUN}.blur.WL${WL}+orig"
    
    for iRand in $(seq 0 $((nParc - 1)) )
    do
        AtlasFile="${SBJ}_${RUN}.${AtlasID}_${iRand}_10VoxelMin+orig"
        echo "** Atlas File = ${AtlasFile}"
        # Perform SVD in masks
        for roi in $(seq 1 $nRois)
        do
          roiID=`printf %03d ${roi}`
          echo "## INFO: ROI[${roiID}]"
          3dmaskSVD -vnorm -mask ${AtlasFile}"<${roi}..${roi}>" ${DataFile} > rm_SVD_roi${roiID}.1D || rm rm_SVD_roi${roiID}.1D  # if it doesn't finish (bc there are no voxels in mask), remove the file   
        done
        # glue together into one big file, then delete the individual files
        1dcat rm_SVD_roi*.1D > ${SBJ}_${RUN}.${AtlasID}_${iRand}_10VoxelMin.lowSigma.WL${WL}.1D
        rm -f rm_SVD_roi*.1D
    done
done