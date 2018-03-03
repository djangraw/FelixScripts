#!/bin/bash

# RunSrtt3dDeconvolve_CensorBase-nofilt_swarm.sh
#
# Created 2/27/17 by DJ.

source /data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI/00_CommonVariables.sh

cd ${PRJDIR}/Scripts/fMRI
echo "" > TEMP_Srtt3dD_CensorBase-nofilt_swarm
for SBJ in ${okSubjects[@]}; do
    echo ${SBJ}
    AfniProc=${PRJDIR}/RawData/${SBJ}/${SBJ}.srtt${folderSuffix}
    echo "cd $AfniProc; bash /data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI/RunSrtt3dDeconvolve_CensorBase-nofilt.sh $SBJ" >> TEMP_Srtt3dD_CensorBase-nofilt_swarm
done

# Run resulting swarm command
swarm -g 4 -f TEMP_Srtt3dD_CensorBase-nofilt_swarm --partition=nimh,norm --module=afni --time=4:00:00 --job-name=3dDCen --logdir logs
