#!/bin/tcsh
# script to transform MNI N27 dataset to MNI_2009c template space

set afniDir = /usr/local/apps/afni/current/linux_centos_7_64/ # for Helix/Felix/Biowulf
set base = ${afniDir}/MNI152_T1_2009c+tlrc.
set MNI_OTHER = ${afniDir}/MNI_caez_N27+tlrc.
set MNI_OTHER_ATLAS =  ${afniDir}/MNI_caez_ml_18+tlrc
set MNI_OTHER_ATLAS_PREFIX =  MNI_caez_ml_18_MNI09.nii.gz
set MNI_OTHER_BASE = `@GetAfniPrefix MNI_caez_N27+tlrc.`

# align the N27 to the MNI_2009c template
auto_warp.py -base $base -input $MNI_OTHER

# apply the transformation to the ML atlas
3dNwarpApply -nwarp awpy/anat.un.aff.qw_WARP.nii -master $base -dxyz 1 \
   -source $MNI_OTHER_ATLAS -prefix $MNI_OTHER_ATLAS_PREFIX -interp NN \
   -overwrite

# copy the transformed N27 template over
cp awpy/${MNI_OTHER_BASE}.aw.nii .

# make the transformed atlas in MNI space in the header
3drefit -space MNI -cmap INT_CMAP -copytables $MNI_OTHER_ATLAS  \
   $MNI_OTHER_ATLAS_PREFIX
