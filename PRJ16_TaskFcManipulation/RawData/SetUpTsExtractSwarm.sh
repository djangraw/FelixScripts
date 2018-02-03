#!/bin/bash
# SetUpTsExtractSwarm.sh
#
# Created 8/11/17 by DJ.
# Updated 2/2/18 by DJ - switched to _v3 analysis folders.

scriptdir=/data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI
atlasFile=/data/jangrawdc/PRJ03_SustainedAttention/Results/shen_1mm_268_parcellation+tlrc.HEAD
rm -f 04_TsExtractCommand
for subj in $@
do
	dataDir=/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/$subj/$subj.srtt_v3
	# atlasFile=$dataDir/shen_1mm_268_parcellation.$subj+orig.HEAD
	# epiFile=$dataDir/all_runs_nonuisance.$subj+orig.HEAD
	epiFile=$dataDir/all_runs_nonuisance_nowmcsf.$subj+tlrc.HEAD
	maskFile=$dataDir/mask_anat.$subj+tlrc.HEAD
	prefix=$dataDir/all_runs_nonuisance_nowmcsf.$subj.shen_
	if [ -f $epiFile ] && [ ! -f ${prefix}ROI_TS.1D ]; then
		echo "python $scriptdir/TsExtractByROIs.py -Atlas $atlasFile -EPI $epiFile -Mask $maskFile -prefix $prefix" >> 04_TsExtractCommand
	fi

done
