#!/bin/tcsh

set here = $PWD

# -------------------  for making warp -------------------------
set dset_from = "/home/jangrawdc/Apps/abin/MNI_avg152T1+tlrc.BRIK.gz"
set dset_to   = "SBJ01_Anatomy+orig"
set dset_pref = "MNI_to_SBJ01Anat_qw"
# -------------------------------------------------------------- 

# -------------------  for applying warp -----------------------
set dset_parc = "CraddockAtlas_200Rois+tlrc.BRIK"
set dset_parc_pref = "CraddockAtlas_200Rois_SBJ01_EPI_qw"
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
#  Blur the anat a little but not the atlas, which is already blurry.
#  maxlev 5 is recommended, but 1-3 is a bit faster.
time \
3dQwarp                             \
    -allineate                      \
    -pblur                          \
    -blur 2 0                       \
    -maxlev 5                       \
    -base ${dset_to}                \
    -source ${dset_from}            \
    -prefix ${dset_pref}            \
    -overwrite

# Applying the WARP.  Should resample the input data to that of the
# 'master' set.  '-ainterp NN' is for preserving integers in
# application of the warp.
3dNwarpApply                                          \
    -source ${dset_parc}                              \
    -master ${dset_parc_grid}                                \
    -prefix ${dset_parc_pref}                         \
    -ainterp NN                                       \
    -nwarp "${dset_pref}_WARP+orig"                   \
    -overwrite

3dcalc                                    \
       -a "${dset_parc_grid}"             \
       -b "${dset_parc_pref}+orig"        \
       -expr "step(a)*b"                  \
       -prefix "${dset_parc_pref}_masked" \
       -overwrite