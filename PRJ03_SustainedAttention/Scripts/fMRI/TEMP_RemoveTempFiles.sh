#!/bin/bash
###################################################
# TEMP_RemoveTempFiles.sh
#
# Created 9/6/16 by DJ.
###################################################

# Get project directory and list of subjects
source 00_CommonVariables.sh
SBJList=("${okSubjects[@]}") # (SBJ09 SBJ12) #
echo ${PRJDIR}
# cd ${PRJDIR}/Results
# SBJList=( `ls -d SBJ*` )

cd ${PRJDIR}/Scripts/fMRI

for SBJ in ${SBJList[@]}; do
    echo "=== ${SBJ} ==="
    # Get results folder
    AfniProc=( `ls -d ${PRJDIR}/Results/${SBJ}/AfniProc_MultiEcho*` )
    cd $AfniProc
    nFiles=`ls rm_* tmp.* | wc -w`
    echo "Removing $nFiles files."
    rm -rf rm_* tmp.*
done

