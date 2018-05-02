#!/bin/bash

# RunSrttPpiSwarm.sh
#
# Created 5/1/18 by DJ.

# Set up
source 00_CommonVariables.sh
cd ${PRJDIR}/RawData
iRoi="167 261 124 258 121"

# Create swarm command
rm -f 04_PpiSwarmCommand
for aSub in ${okSubjects[@]}
do
	if [ -f $aSub/$aSub.srtt_v3/all_runs.$aSub+tlrc.HEAD ]; then
		echo $aSub...
		echo "bash ${scriptDir}/RunPpiOnSrttSubject_v3.sh $aSub $iROI" >> 04_PpiSwarmCommand
	fi
done
# Run the swarm script
swarm -g 8 -t 4 -f 04_PpiSwarmCommand --partition=nimh,norm --module=afni --time=1:00:00 --job-name=AfnPpi --logdir=logs
