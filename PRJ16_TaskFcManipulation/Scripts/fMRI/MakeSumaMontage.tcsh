#!/bin/tcsh -e

########################################################################
#
# MakeSumaMontage.tcsh: open up AFNI, overlay a value dset, threshold
# by a stat, project into SUMA, record jpgs, and glue them together with
# ImageMagick's "montage".
#
# Adapted from Movie Maker v1.1, PA Taylor (NIMH, NIH), Apr 25 2017.
# Updated 5/17/17 by DJ to rotate brain with constant overlay.
# Updated 2/21/18 by DJ - made into 4-view montage maker
########################################################################

# ======================= main user settings =========================

# dsets
set afni_ulay = "MNI_N27_SurfVol.nii"    # can be struc or whatev
set afni_olay = "ttest_allSubj+tlrc"    # has betas and ts
set suma_spec = "suma_MNI_N27/MNI_N27_both.spec"    # created somehow
set suma_sv   = "$afni_ulay"    # created somehow

# user chooses which betas are selected for olay, and thr volumes are
# presently assumed to be at +1 relative to each of these indices
set beta_ind = 16 # index of betas in afni_olay (assume threshold is next one up)

# image props
set image_dir = "./SUMA_IMAGES"        # store jpgs here
set image_pre = "suma_images"        # ... with this prefix
set image_fin = "${image_dir}/suma_final_new.jpg"             # final movie name (with suffix)

# size of the image window, given as:
# leftcorner_X  leftcorner_Y  windowwidth_X  windowwith_Y
setenv SUMA_Position_Original "50 50 500 425"

# set values for things in driven AFNI
set func_range = 0.5
# set thr_thresh = 2.554 # t corresponding to q=0.05
set thr_thresh = 1.962 # t value corresponding to p=0.05
# set my_cbar    = "Spectrum:red_to_blue" # "Viridis"
set my_cbar = "Reds_and_Blues_w_Green"

# ==================================================================

# --------------------- preliminary settings -----------------------

set portnum = `afni -available_npb_quiet`

setenv AFNI_ENVIRON_WARNINGS NO
setenv AFNI_PBAR_FULLRANGE NO
setenv SUMA_DriveSumaMaxCloseWait 20 #6
setenv SUMA_DriveSumaMaxWait 10 #6

setenv SUMA_AutoRecordPrefix "${image_dir}/${image_pre}"
#setenv SUMA_SnapshotOverSampling $OVERSAMP

# ------------------- Open up AFNI viewer and drive ------------------
afni -npb $portnum -niml -yesplugouts $afni_ulay $afni_olay &

# Need to slooow things down occasionally (-> sleep commands) for
# proper viewing behavior.  The number/length of naps may be
# computer/data set dependent.
echo "\n===NAP 1/8...===\n"
sleep 10 #15

# just for starters
set bb = $beta_ind
@   tt = $bb + 1

# NB: Plugout drive options located at:
# http://afni.nimh.nih.gov/pub/dist/doc/program_help/README.driver.html
plugout_drive -echo_edu                                  \
    -npb $portnum                                        \
    -com "SWITCH_UNDERLAY A.${afni_ulay}"                \
    -com "SWITCH_OVERLAY  A.${afni_olay}"                \
    -com "SET_SUBBRICKS   0 $bb $tt"                     \
    -com "SEE_OVERLAY     +"                             \
    -com "SET_FUNC_RANGE  A.${func_range}"               \
    -com "SET_FUNC_VISIBLE A.+"                          \
    -com "SET_THRESHNEW A ${thr_thresh}"                 \
    -com "SET_PBAR_ALL A.-99 1.0 $my_cbar"               \
    -quit

# "SET_PBAR_ALL A.+99" = pos-only; "-99" = bi-sided

#### ----> for stat thresholding, user might want to use something
#### ----> like this instead of the above one!!!
#    -com 'SET_THRESHNEW A 0.01 *p'                       \

# --------------------- SUMA setup------------------------------

suma                                                    \
    -dev                                                \
    -npb $portnum                                       \
    -niml                                               \
    -spec "$suma_spec"                                  \
    -sv   $suma_sv               &

echo "\n===NAP 2/8...===\n"
sleep 15 #3

# start driving
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 't' -key '.' # connect to AFNI & switch to regular brain

echo "\n===NAP 3/8...===\n"
sleep 3 #10

# crosshair off, node off, faceset off, label off, background white
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'F3' -key 'F4' -key 'F5' -key 'F9' -key 'F6'

# zoom to fill window with side view
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Z' -key 'Z' -key 'Z' -key 'Z'

# left side profile
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+left'

# wait a while
echo "\n===NAP 4/8...===\n"
sleep 3 #7

# ------------------ take 4 pictures ------------------ #
# smile for the photo
DriveSuma                                         \
    -npb $portnum                                 \
    -com viewer_cont -key 'Ctrl+r'
# wait for image capture
echo "\n===NAP 5/8...===\n"
sleep 1 #2

# right side profile
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+right'
# wait for display to update
sleep 1 #1
# smile for the photo
DriveSuma                                         \
    -npb $portnum                                 \
    -com viewer_cont -key 'Ctrl+r'
# wait for image capture
echo "\n===NAP 6/8...===\n"
sleep 1 #2

# left medial profile (hide right hemisphere)
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+]'
# wait for display to update
sleep 1 #1
# smile for the photo
DriveSuma                                         \
    -npb $portnum                                 \
    -com viewer_cont -key 'Ctrl+r'
# wait for image capture
echo "\n===NAP 7/8...===\n"
sleep 1 #2

# right medial profile (hide left hemisphere)
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+]'                     \
    -com viewer_cont -key 'Ctrl+['                     \
    -com viewer_cont -key 'Ctrl+left'
# wait for display to update
sleep 1 #1
# smile for the photo
DriveSuma                                         \
    -npb $portnum                                 \
    -com viewer_cont -key 'Ctrl+r'
# wait for image capture
echo "\n===NAP 8/8...===\n"
sleep 1 #2


# ------------------ glue pics together ------------------ #
# imagemagick gluing
echo "Saving montaged image as ${image_fin} and removing temporary files...\n"
montage -background '#000000' -geometry +0+0 `ls $image_dir/${image_pre}*`  $image_fin
# remove temporary images
rm $image_dir/${image_pre}*

echo "\n===DONE!===\n"
