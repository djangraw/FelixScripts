#!/bin/bash

rm -f 01_AfniProcSwarmCommand
for aSub in $@
do
	if [ ! -f $aSub/$aSub.srtt/all_runs.$aSub+orig.HEAD ]; then
		echo $aSub...
		rm -rf $aSub/afni_srtt_$aSub.tcsh $aSub/output.afni_srtt_$aSub.tcsh $aSub/$aSub.srtt
		echo "bash afni_A182.sh $aSub" >> 01_AfniProcSwarmCommand
	fi
done
