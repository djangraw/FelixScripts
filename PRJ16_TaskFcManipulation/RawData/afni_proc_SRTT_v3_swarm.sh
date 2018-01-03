#!/bin/bash

# afni_proc_SRTT_v3_swarm.sh
#
# Run afni_proc.py on SRTT data from the given subj's
#
# Usage: bash afni_proc_SRTT_v3_swarm.sh $subj1 $subj2... $subjN
#
# Created 10/11/17 by DJ based on afni_A182_swarm.sh
# Updated 12/11/17 by DJ - comments
# Updated 1/2/18 by DJ - switch to v3

rm -f 01_AfniProcSwarmCommand
for aSub in $@
do
	if [ ! -f $aSub/$aSub.srtt_v3/all_runs.$aSub+orig.HEAD ]; then
		echo $aSub...
		rm -rf $aSub/afni_srtt_v3_$aSub.tcsh $aSub/output.afni_srtt_v3_$aSub.tcsh $aSub/$aSub.srtt_v3
		echo "bash afni_proc_SRTT_v3.sh $aSub" >> 01_AfniProcSwarmCommand
	fi
done
