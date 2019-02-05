#!/bin/bash
#
# Created 2/4/19 by DJ

module load freesurfer/6.0.0

source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=/data/NIMH_Haskins/a182_v2/freesurfer

outTxt=/data/NIMH_Haskins/a182_v2/freesurfer_swarm.txt
outTxt2=/data/NIMH_Haskins/a182_v2/freesurfer_SUMA_swarm.txt
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh

# rm -f $outTxt
rm -f $outTxt2
for aSub in ${subjects[@]}
do
	echo "source $FREESURFER_HOME/SetUpFreeSurfer.sh; export SUBJECTS_DIR=/data/NIMH_Haskins/a182_v2/freesurfer; recon-all -s $aSub -i ${aSub}/anat/Sag3DMPRAGE*.nii.gz -all -3T -openmp 4" >> $outTxt
	echo "${scriptDir}/RunPostFreesurferSuma.sh $aSub" >> $outTxt2
done

# Run swarm
jobid1=`swarm -f $outTxt -t 2 -g 12 --module freesurfer/6.0.0 --time 36:00:00 --logdir logs --job-name story_fs`
jobid2=`swarm -f $outTxt2 -t 2 -g 12 --module freesurfer/6.0.0 --time 1:00:00 --logdir logs --dependency afterok:$jobid1 --job-name story_suma`

# Print job names
echo jobid1:$jobid1
echo jobid2:$jobid2
