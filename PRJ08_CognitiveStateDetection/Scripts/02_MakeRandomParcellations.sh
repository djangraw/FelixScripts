#!/bin/bash
# 02_MakeRandomParcellations.sh
#
# Created 2/3/16 by DJ.

# COMMON STUFF
source ./00_CommonVariables.sh
scriptDir=${PRJDIR}Scripts/cluster_roi-master/
atlasDir=${PRJDIR}Atlases/

nRois=200
nParc=10

# make parcellations from atlas
cd $atlasDir
# make Craddock atlas into NIFTI file
3dAFNItoNIFTI Craddock_T2Level_0200.MNI+tlrc
# get filenames
maskname="Craddock_T2Level_0200.MNI.nii"
outPrefix="Craddock.MNI.RandParc"
python ${scriptDir}pyClusterROI_randomOnly.py $maskname $outPrefix $nRois $nParc
# clean up by removing NIFTI version of mask
rm ${maskname}


subjNums=(`count -digits 2 6 27`)

# transform into individual space and remove any ROIs with <10 voxels
for subjNum in ${subjNums[@]}
do
    # set up
    subject=SBJ$subjNum
    echo "Making parcellations for $subject..."    
    dataDir=${PRJDIR}PrcsData/${subject}/D02_CTask001/
    cd $dataDir
    # transform random parcellations into orig space and mask to 'low-sigma' voxels
    subjMask=pb06.${subject}_CTask001.bpf.WL045.mask.lowSigma+orig
    for iRand in $(seq 0 $((nParc - 1)) )
    do
        3dAllineate -overwrite \
                  -input ${atlasDir}${outPrefix}_200ROIs_${iRand}.nii.gz \
                  -1Dmatrix_apply ${subject}_CTask001.MNI2REF.Xaff12.1D \
                  -master $subjMask \
                  -emask $subjMask \
                  -final NN \
                  -prefix ${subject}_CTask001.Craddock_RandParc_200ROIs_${iRand}
    done
    
    # remove ROIS with <10 voxels    
    for iRand in $(seq 0 $((nParc - 1)) )
    do
        roiFile=${subject}_CTask001.Craddock_RandParc_200ROIs_${iRand}+orig
        3dROIstats -quiet -nzvoxels -mask $roiFile $roiFile > rm_nVoxInRoi        
        1d_tool.py -infile 'rm_nVoxInRoi[0..$(2)]' -overwrite -write rm_roiNums
        1d_tool.py -infile 'rm_nVoxInRoi[1..$(2)]' -moderate_mask 0 9 -overwrite -write rm_isBelow10
        1deval -a rm_roiNums\' -b rm_isBelow10\' -expr 'a*b' > rm_tinyRoisCol
        1d_tool.py -infile rm_tinyRoisCol -transpose -overwrite -write rm_tinyRois
        # convert to comma-separated list
        str_tinyRois="`cat rm_tinyRois`" # dump into variable
        str_tinyRois=${str_tinyRois//"0 "/} # remove zeros and the spaces after them
        str_tinyRois=${str_tinyRois// /,} # replace spaces with commas
        # use 3dCalc to remove the selected ROIs
        3dcalc -a ${roiFile} -expr "a*not(amongst(a,${str_tinyRois}))" -overwrite -prefix ${subject}_CTask001.Craddock_RandParc_200ROIs_${iRand}_10VoxelMin
    done
    rm rm_*
done