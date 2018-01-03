#!/bin/bash

# RunAfniProcSwarm_v3.sh
#
# Created 12/27/17 by DJ.
# Updated 1/2/18 by DJ - made _v3.

# Set up
source 00_CommonVariables.sh
cd ${PRJDIR}/RawData

# Create swarm command
bash afni_proc_SRTT_v3_swarm.sh ${okSubjects[@]}

# Run the swarm script
swarm -g 8 -t 4 -f 01_AfniProcSwarmCommand --partition=nimh,norm --module=afni --time=4:00:00 --job-name=AfnPrc
