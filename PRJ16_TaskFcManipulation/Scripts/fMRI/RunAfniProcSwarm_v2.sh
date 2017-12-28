#!/bin/bash

# RunAfniProcSwarm_v2.sh
#
# Created 12/27/17 by DJ.

# Set up
source 00_CommonVariables.sh
cd ${PRJDIR}/RawData

# Create swarm command
bash afni_proc_SRTT_v2_swarm.sh ${iOkSubjects[@]}

# Run the swarm script
swarm -g 8 -t 4 -f 01_AfniProcSwarmCommand --partition=nimh,norm --module=afni --time=4:00:00 --job-name=AfnPrc
