#!/bin/bash
# SetUpParcWarping.sh
#
# Created 8/10/17 by DJ.

scriptdir=/data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI

rm -f 02_ParcWarpCommand
for subj in $@
do

	if [ ! -f $subj/$subj.srtt/shen_1mm_268_parcellation.$subj+orig.HEAD ] && [ -f $subj/$subj.srtt/all_runs.$subj+orig.HEAD ]; then
		echo "bash $scriptdir/WarpParcToOrigBrains.sh $subj" >> 02_ParcWarpCommand
	fi

done
