#!/bin/bash
#
# Created 2/4/19 by DJ
# Run with modules afni, freesurfer/6.0.0

# Parse inputs
asub=$1;

# Set up
source $FREESURFER_HOME/SetUpFreeSurfer.sh;
export SUBJECTS_DIR=/data/NIMH_Haskins/a182_v2/freesurfer;

# Use SUMA to convert the FS output to NIFTI for AFNI to use.
@SUMA_Make_Spec_FS -NIFTI -fspath ${SUBJECTS_DIR}/${asub} -sid $asub;

# Enter new directory
cd ${SUBJECTS_DIR}/${asub}/SUMA;

# Select the ventricle maps from the FS output.
3dcalc -a aparc+aseg.nii -datum byte -prefix FSmask_vent.nii \
     -expr 'amongst(a,4,43)'

# Select the WM maps from the FS output.
3dcalc -a aparc+aseg.nii -datum byte -prefix FSmask_WM.nii \
     -expr 'amongst(a,2,7,41,46,251,252,253,254,255)'
