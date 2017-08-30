#!/bin/tcsh
# do_01_make_allin.tcsh
#
# Created 12/11/15 by Paul Taylor.
# Updated 12/11/15 by DJ - comments.

set here = $PWD

# -------------------  for making warp -------------------------
set dset_from = "/home/jangrawdc/Apps/abin/MNI_avg152T1+tlrc.BRIK.gz"
set dset_to   = "SBJ01_Anatomy+orig"
set dset_pref = "MNI_to_SBJ01Anat"
# -------------------------------------------------------------- 

# -------------------  for applying warp -----------------------
set dset_parc = "CraddockAtlas_200Rois+tlrc.BRIK"
set dset_parc_pref = "CraddockAtlas_200Rois_SBJ01_EPI"
set dset_parc_grid = "SBJ01_FullBrain_EPIRes+orig"
# -------------------------------------------------------------- 

# starts with allineate for guess, pblur for progressive blurring
# (faster/better); '-blur' to blur each input a bit *if* you want (can
# delete, or set each to '0' if you don't want this).  Should produce:
#      1) a linearly warped data set, 
#      2) a nonlinearly warped data set,
#      3) and the full warp itself (a volume data set).
# You can use '-maxlev A' to set the number A of levels to warp.
# You can apply the WARP after.
echo "Getting matrix..."
time \
3dAllineate                         \
    -1Dmatrix_save ${dset_pref}.aff12.1D \
    -base ${dset_to}                \
    -source ${dset_from}            \
    -prefix ${dset_pref}            \
    -overwrite

# Applying the affine matrix.  Should resample the input data to that
# of the 'master' set.  '-final NN' is for preserving integers in
# application of the warp.
echo "Applying matrix..."
3dAllineate                                           \
    -source ${dset_parc}                              \
    -master ${dset_parc_grid}                         \
    -prefix ${dset_parc_pref}                         \
    -final NN                                         \
    -1Dmatrix_apply ${dset_pref}.aff12.1D             \
    -overwrite

# Mask with final grid volume
echo Masking...
3dcalc                                    \
       -a "${dset_parc_grid}"             \
       -b "${dset_parc_pref}+orig"        \
       -expr "step(a)*b"                  \
       -prefix "${dset_parc_pref}_masked" \
       -overwrite

echo Done!