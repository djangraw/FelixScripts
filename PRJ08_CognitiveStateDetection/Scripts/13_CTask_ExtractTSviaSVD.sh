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
###########################################################################

#!/bin/bash

# COMMON STUFF
source /data/SFIMJGC/PRJ_CognitiveStateDetection01/Scripts/00_CommonVariables.sh
## Read Input Parameters
#if [ $# -ne 1 ]; then
# echo "Usage: $basename $0 SBJID"
# exit
#fi
#SBJ=$1

cd ${PRJDIR}/PrcsData/${SBJ}
cd ${DPREFIX}_${RUN}



#SBJ=$1
OMP_NUM_THREADS=24
NumROIsID=`printf %04d ${NROIS}`
AtlasID=`echo Craddock_T2Level_${NumROIsID}`
winLen_inSec=(180 090 060 045 030 015)

if [ ! -d DXX_NROIS${NumROIsID} ]; then mkdir DXX_NROIS${NumROIsID}; fi
#wl=$2
#for wl in {0..5}
#do
#   WL=${winLen_inSec[${wl}]}
   AtlasFile=`echo ${SBJ}_${RUN}.${AtlasID}.lowSigma+orig`
   DataFile=`echo pb08.${SBJ}_${RUN}.blur.WL${WL}+orig`
   numROIs=`3dinfo -nt ${AtlasFile}`
   max_roi=`echo "${numROIs} -1 " | bc`
   echo "** Atlas File = ${AtlasFile}"
   echo "** Data  File = ${DataFile}" 
   echo "** max_roi    = ${max_roi}"
   echo "** numROIs    = ${numROIs}"  
   # Perform SVD in masks
   # ========================== 
   for roi in  $(seq 0 1 ${max_roi})
   do
      roiID=`printf %03d ${roi}`
      echo "## INFO: ROI[${roiID}]"
      3dmaskSVD -vnorm -mask ${AtlasFile}"[${roi}]" ${DataFile} > ${SBJ}_${RUN}.${AtlasID}.lowSigma.${roiID}.WL${WL}.1D
      mv ${SBJ}_${RUN}.${AtlasID}.lowSigma.${roiID}.WL${WL}.1D DXX_NROIS${NumROIsID}
   done

#done
