#!/bin/bash

# afni_proc_SRTT_v2_swarm.sh
#
# Run afni_proc.py on SRTT data from the given subj's
#
# Usage: bash afni_proc_SRTT_v2_swarm.sh $subj1 $subj2... $subjN
#
# Created 10/11/17 by DJ based on afni_A182_swarm.sh
# Updated 12/11/17 by DJ - comments

rm -f 01_AfniProcSwarmCommand
for aSub in $@
do
	if [ ! -f $aSub/$aSub.srtt_v2/all_runs.$aSub+orig.HEAD ]; then
		echo $aSub...
		rm -rf $aSub/afni_srtt_v2_$aSub.tcsh $aSub/output.afni_srtt_v2_$aSub.tcsh $aSub/$aSub.srtt_v2
		echo "bash afni_proc_SRTT_v2.sh $aSub" >> 01_AfniProcSwarmCommand
	fi
done
