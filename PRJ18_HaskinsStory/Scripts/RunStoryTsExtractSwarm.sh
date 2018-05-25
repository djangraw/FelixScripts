#!/bin/bash
# RunStoryTsExtractSwarm.sh
#
# Created 5/24/18 by DJ based on SetUpTsExtractSwarm.sh.

source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
tsExtDir=/data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI
atlasFile=/data/jangrawdc/PRJ03_SustainedAttention/Results/shen_1mm_268_parcellation+tlrc.HEAD
swarmFile=TsExtractSwarmCommand
rm -f $swarmFile

for subj in ${okReadSubj[@]}
do
  subjDir=$dataDir/$subj/${subj}.storyISC_d2
	epiFile=$subjDir/errts.$subj.fanaticor+tlrc.HEAD
	maskFile=$subjDir/mask_anat.$subj+tlrc.HEAD
	prefix=$subjDir/shents.$subj.roi_
	if [ -f $epiFile ] && [ ! -f ${prefix}ROI_TS.1D ]; then
		echo "python $tsExtDir/TsExtractByROIs.py -Atlas $atlasFile -EPI $epiFile -Mask $maskFile -prefix $prefix" >> $swarmFile
	fi

done

# run swarm command
# jobid=`swarm -g 2 -t 1 -f $swarmFile --partition=nimh,norm --module=afni --time=0:20:00 --job-name=TsExt --logdir=logsDJ`
# echo jobid=$jobid
