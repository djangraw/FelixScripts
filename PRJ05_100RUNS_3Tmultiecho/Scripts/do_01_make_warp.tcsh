#!/bin/tcsh

set here = $PWD

# -------------------  for making warp -------------------------
set dset_from = ""
set dset_to   = ""
set dset_pref = ""
# -------------------------------------------------------------- 

# -------------------  for applying warp -----------------------
set dset_parc = ""
set dset_parc_pref = ""
# -------------------------------------------------------------- 

# starts with allineate for guess, pblur for progressive blurring
# (faster/better); '-blur' to blur each input a bit *if* you want (can
# delete, or set each to '0' if you don't want this).  Should produce:
#      1) a linearly warped data set, 
#      2) a nonlinearly warped data set,
#      3) and the full warp itself (a volume data set).
# You can use '-maxlev A' to set the number A of levels to warp.
# You can apply the WARP after.
time \
3dQwarp                             \
    -allineate                      \
    -pblur                          \
    -blur 0 5                       \
    -maxlev 1                       \
    -base ${dset_to}                \
    -source ${dset_from}            \
    -prefix ${dset_pref}            \
    -overwrite

# Applying the WARP.  Should resample the input data to that of the
# 'master' set.  '-ainterp NN' is for preserving integers in
# application of the warp.
3dNwarpApply                                          \
    -source ${dset_parc}                              \
    -master ${dset_to}                                \
    -prefix ${dset_parc_pref}                         \
    -ainterp NN                                       \
    -nwarp '${dset_pref}_WARP+orig'                   \
    -overwrite
