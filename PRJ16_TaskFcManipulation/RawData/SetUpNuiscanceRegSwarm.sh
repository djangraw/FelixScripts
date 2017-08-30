#!/bin/bash

# SetUpNuisanceRegSwarm.sh
#
# Created 8/16/17 by DJ.

scriptdir=/data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI

rm -f 03_3dDeconCommand
for subj in $@
do
	dataDir=/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/$subj/$subj.srtt
	epiFile=$dataDir/all_runs.$subj+orig.HEAD
	outFile=$dataDir/all_runs_nonuisance.$subj+orig.HEAD
	if [ -f $epiFile ] && [ ! -f ${outFile} ]; then
		echo "bash $scriptdir/RemoveSrttNuisanceRegressors.sh $subj" >> 03_3dDeconCommand
	fi

done
