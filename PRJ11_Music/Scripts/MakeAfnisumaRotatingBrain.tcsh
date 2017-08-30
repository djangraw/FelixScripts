#!/bin/tcsh -e

########################################################################
#
# Movie Maker: open up AFNI, overlay a value dset, threshold by a
# stat, project into SUMA, record jpgs, and glue them together with
# ImageMagick's "convert".
#
# v1.1, PA Taylor (NIMH, NIH), Apr 25 2017.
# Modified 5/17/17 by DJ to rotate brain with constant overlay.
#
########################################################################

# ======================= main user settings =========================

# dsets
set afni_ulay = "MNI_N27_SurfVol.nii"    # can be struc or whatev
set afni_olay = "bl.stats.SBJ03_task_REML+tlrc"    # has betas and ts
set suma_spec = "suma_MNI_N27/MNI_N27_both.spec"    # created somehow
set suma_sv   = "$afni_ulay"    # created somehow

# user chooses which betas are selected for olay, and thr volumes are
# presently assumed to be at +1 relative to each of these indices
set beta_ind = 19 #sing=13, speak=16, imagine=19  #111 2 163 # where my betas at

# image props
set image_dir = "./DRIVE_IMAGES"        # store jpgs here
set image_pre = "imagine_rotate_images"        # ... with this prefix
set movie_fin = "IMAGINE_ROTATE.gif"             # final movie name

# size of the image window, given as:
# leftcorner_X  leftcorner_Y  windowwidth_X  windowwith_Y
setenv SUMA_Position_Original "50 50 3500 3500"

# set values for things in driven AFNI
set func_range = 1
# set thr_thresh = 1.876 # t corresponding to q=0.05 for sing
# set thr_thresh = 2.121 # t corresponding to q=0.05 for speak
set thr_thresh = 2.391 # t corresponding to q=0.05 for imagine
# 1.962 # t value corresponding to p=0.05
set my_cbar    = "Spectrum:red_to_blue" # "Viridis"

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
echo "\n\nNAP 0/4...\n\n"
sleep 15 # 2

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
    -com "SET_PBAR_ALL A.+99 1.0 $my_cbar"               \
    -quit

# "SET_PBAR_ALL A.+99" = pos-only

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

echo "\n\nNAP 1/4...\n\n"
sleep 30 #3

# start driving
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 't' -key '.' # connect to AFNI & switch to regular brain

echo "\n\nNAP 2/4...\n\n"
sleep 10 #3

# sagittal profile
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+left'
# crosshair off, node off, faceset off, label off
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'F3' -key 'F4' -key 'F5' -key 'F9'

# wait a while
sleep 7
# ------------------ now rotate suma brain

foreach bb ( `seq 1 1 360` ) # 72 is one 360deg rotation
    # wait for image capture
    sleep 3 #2

    # rotate
    DriveSuma                                              \
        -npb $portnum                                      \
        -com viewer_cont -key 'right'

    # wait for display to update
    sleep 3 #1

    # smile for the photo
    DriveSuma                                         \
        -npb $portnum                                 \
        -com viewer_cont -key 'Ctrl+r'
end

# imagemagick glueing; delay units are 'ms'
convert -delay 50 `ls $image_dir/${image_pre}*`  $movie_fin
