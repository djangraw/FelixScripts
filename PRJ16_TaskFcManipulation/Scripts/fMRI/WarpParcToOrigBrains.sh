#!/bin/bash

# WarpParcToOrigBrains.sh
# Convert an MNI parcellation to an individual brain space, where each
# individual has a nonlinear warp to a TLRC brain.


# Set up
# source /data/jangrawdc/PRJ16_TaskFcManipulation/Scripts/fMRI/00_CommonVariables.sh
PRJDIR=/data/jangrawdc/PRJ16_TaskFcManipulation
subjects=$@
echo ${subjects[@]}

# Declare tlrc parcellation
parcfile=/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc.HEAD
parcfile_tlrc=/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation_tlrc+tlrc.HEAD

# Try to get mni-to-tta transformation so we can include it in the 3dnwarpapply call
# tta2mniFile=/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/tta2mni.1D
# cat_matvec -I TEMP+tlrc::WARP_DATA > ${tta2mniFile}
# rm -f TEMP+tlrc.*

# make tta2mni warp 1D file
if [ ! -f ${parcfile_tlrc} ]; then
  3dWarp -overwrite -mni2tta -NN -prefix ${parcfile_tlrc} ${parcfile}
fi

#${subjects[@]}
for subj in ${subjects[@]}
do
  echo "subject ${subj}..."
  # move to proper directory
  cd $PRJDIR/RawData/$subj/$subj.srtt
  # apply non-linear warp to parcellation to make it match all_runs dataset
  3dNwarpApply -nwarp "./anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D" -iwarp -interp NN -master ./all_runs.$subj+orig -source $parcfile_tlrc -prefix ./shen_1mm_268_parcellation.$subj+orig
  # 3dNwarpApply -nwarp "./anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D ${tta2mniFile}" -iwarp -interp NN -master ./all_runs.$subj+orig -source $parcfile -prefix ./shen_1mm_268_parcellation.$subj+orig
done
