#!/bin/bash
# SetUpTsExtractSwarm.sh
#
# Created 8/11/17 by DJ.

scriptdir=/data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI

rm -f 04_TsExtractCommand
for subj in $@
do
	dataDir=/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/$subj/$subj.srtt
	atlasFile=$dataDir/shen_1mm_268_parcellation.$subj+orig.HEAD
	epiFile=$dataDir/all_runs_nonuisance.$subj+orig.HEAD
	maskFile=$dataDir/mask_anat.$subj+orig.HEAD
	prefix=$dataDir/all_runs_nonuisance.$subj.shen_
	if [ -f $epiFile ] && [ ! -f ${prefix}ROI_TS.1D ]; then
		echo "python $scriptdir/TsExtractByROIs.py -Atlas $atlasFile -EPI $epiFile -Mask $maskFile -prefix $prefix" >> 04_TsExtractCommand
	fi

done
