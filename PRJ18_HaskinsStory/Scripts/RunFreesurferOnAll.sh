#!/bin/bash

module load freesurfer/6.0.0

source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=/data/NIMH_Haskins/a182_v2/freesurfer

outTxt=/data/NIMH_Haskins/a182_v2/freesurfer_swarm.txt
rm -f $outTxt
for aSub in $@
do
	echo "source $FREESURFER_HOME/SetUpFreeSurfer.sh; export SUBJECTS_DIR=/data/NIMH_Haskins/a182_v2/freesurfer; recon-all -s $aSub -i ${aSub}/anat/Sag3DMPRAGE*.nii.gz -all -3T -openmp 4" >> $outTxt
	# echo "recon-all -s $aSub -i ${aSub}/anat/Sag3DMPRAGE*.nii.gz -all -3T -openmp 4" >> $outTxt
done

# Run swarm
swarm -f $outTxt -t 2 -g 12 --module freesurfer/6.0.0 --time 36:00:00 --logdir logs --job-name story_fs
