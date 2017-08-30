#!/bin/bash
###################################################
# RestoreSnapshots.sh
#
# Created 10/3/16 by DJ.
###################################################

# Get project directory and list of subjects
source 00_CommonVariables.sh
# SBJList=("${okSubjects[@]}")
echo ${PRJDIR}
# cd ${PRJDIR}/Results
# SBJList=( `ls -d SBJ30` )
SBJList=(SBJ09 SBJ10 SBJ11 SBJ13 SBJ14 SBJ15 SBJ16 SBJ17 SBJ18 SBJ19)
cd ${PRJDIR}/Scripts/fMRI
for SBJ in ${SBJList[@]}; do
    echo ${SBJ}
    # Get results folder
    AfniProc=( `ls -d ${PRJDIR}/Results/${SBJ}/AfniProc_MultiEcho*` )
    # Enter folder
    cd ${AfniProc}
    snapshotDir='.snapshot/weekly.2016-09-27_0753'
    pwd
    echo $snapshotDir
    # remove files first to avoid "same file" error
    rm -r Segsy
    rm WM_Timecourse.1D
    rm CSF_Timecourse.1D
    rm GS_Timecourse.1D
    rm Mask_EPIres_shen_1mm_268_parcellation+tlrc.HEAD
    rm Mask_EPIres_shen_1mm_268_parcellation+tlrc.BRI*
    rm shen268_withSegTc_${SBJ}_ROIstats.1D
    rm shen268_withSegTc_${SBJ}_ROI_TS.1D
    # Get snapshots
    # -p: copy timestamp
    cp -rfp ${snapshotDir}/Segsy .
    cp -fp ${snapshotDir}/WM_Timecourse.1D .
    cp -fp ${snapshotDir}/CSF_Timecourse.1D .
    cp -fp ${snapshotDir}/GS_Timecourse.1D .
    cp -fp ${snapshotDir}/Mask_EPIres_shen_1mm_268_parcellation+tlrc.HEAD .
    cp -fp ${snapshotDir}/Mask_EPIres_shen_1mm_268_parcellation+tlrc.BRI* .
    cp -fp ${snapshotDir}/shen268_withSegTc_${SBJ}_ROIstats.1D .
    cp -fp ${snapshotDir}/shen268_withSegTc_${SBJ}_ROI_TS.1D .
done