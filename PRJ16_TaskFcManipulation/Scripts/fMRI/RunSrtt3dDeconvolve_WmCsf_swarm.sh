#!/bin/bash

# RunSrtt3dDeconvolve_WmCsf_swarm.sh
#
# Created 2/26/17 by DJ.

source /data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI/00_CommonVariables.sh

cd ${PRJDIR}/Scripts/fMRI
echo "" > TEMP_Srtt3dD_WmCsf_swarm
for SBJ in ${okSubjects[@]}; do
    echo ${SBJ}
    AfniProc=${PRJDIR}/RawData/${SBJ}/${SBJ}.srtt${folderSuffix}
    echo "cd $AfniProc; bash /data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI/RunSrtt3dDeconvolve_WmCsf.sh $SBJ" >> TEMP_Srtt3dD_WmCsf_swarm
done

# Run resulting swarm command
swarm -g 3 -f TEMP_Srtt3dD_WmCsf_swarm --partition=nimh,norm --module=afni --time=0:30:00 --job-name=3dDWm --logdir logs
