#!/bin/bash
###################################################
# TEMP_Remove_2016-09-15.sh
#
# Created 9/22/16 by DJ.
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
    AfniProc=${PRJDIR}/Results/${SBJ}/AfniProc_MultiEcho_2016-09-15
    if [ -d $AfniProc ]; then
        echo "Removing folder $AfniProc."
        rm -rf $AfniProc
    fi
done

