#!/bin/tcsh -e

########################################################################
#
# Movie Maker: open up AFNI, overlay a value dset, threshold by a
# stat, project into SUMA, record jpgs, and glue them together with
# ImageMagick's "convert".
#
# v1.1, PA Taylor (NIMH, NIH), Apr 25 2017.
# Modified 5/17/17 by DJ to rotate brain with constant overlay.
# v2.1, PA Taylor and DR Glen (NIMH, NIH), May 22 2017.
#    + add in cerebellum and brain stem
#    + control coloration ~decently
#
########################################################################

# ======================= main user settings =========================

# dsets
set afni_ulay = "MNI_N27_SurfVol.nii"    # can be struc or whatev
set afni_olay = "wholesong_0-360+tlrc"    # has betas and ts
# set afni_olay = "bl_edge.stats.SBJ03_task_REML+tlrc"    # has betas and ts

#set suma_spec = "~/.afni/data/suma_MNI_N27/MNI_N27_both.spec"    # created somehow !! <-unnec now
set suma_sv   = "$afni_ulay"    # created somehow

# user chooses which betas are selected for olay, and thr volumes are
# presently assumed to be at +1 relative to each of these indices
set beta_ind = "`seq 1 1 10`" #sing=13, speak=16, imagine=19  #111 2 163 # where my betas at

# image props
set image_dir = "./DRIVE_IMAGES"        # store jpgs here
set image_pre = "wholesong_rotate_images"        # ... with this prefix
# set image_pre = "temp_images"        # ... with this prefix
set movie_fin = "WHOLESONG_ROTATE.gif"             # final movie name

# size of the image window, given as:
# leftcorner_X  leftcorner_Y  windowwidth_X  windowwith_Y
setenv SUMA_Position_Original "50 50 3500 3500"
setenv SUMA_Light0Position "10 1 1"

# set values for things in driven AFNI
set func_range = 2
# set func_range = 1
# set thr_thresh = 1.876 # t corresponding to q=0.05 for sing
# set thr_thresh = 2.121 # t corresponding to q=0.05 for speak
# set thr_thresh = 2.222 # t corresponding to q=0.05 for imagine
set thr_thresh = 1 # t corresponding to q=0.05 for imagine
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
sleep 30 # 2

# just for starters
set bb = 0

# NB: Plugout drive options located at:
# http://afni.nimh.nih.gov/pub/dist/doc/program_help/README.driver.html
plugout_drive -echo_edu                                  \
    -npb $portnum                                        \
    -com "SWITCH_UNDERLAY A.${afni_ulay}"                \
    -com "SWITCH_OVERLAY  A.${afni_olay}"                \
    -com "SET_SUBBRICKS   0 $bb $bb"                     \
    -com "SEE_OVERLAY     +"                             \
    -com "SET_FUNC_RANGE  A.${func_range}"               \
    -com "SET_FUNC_VISIBLE A.+"                          \
    -com "SET_THRESHNEW A ${thr_thresh}"                 \
    -com "SET_PBAR_ALL A.+99 1.0 $my_cbar"               \
    -quit

# "SET_PBAR_ALL A.+99" = pos-only
sleep 5
#### ----> for stat thresholding, user might want to use something
#### ----> like this instead of the above one!!!
#    -com 'SET_THRESHNEW A 0.01 *p'                       \

# --------------------- SUMA setup------------------------------




#suma  \
#    -npb $portnum \
#    -niml \
#    -onestate \
#    -i  {lh,rh}.pial.gii MNI_N27_cer_brainstem_as_smooth.gii \
#    -sv $suma_sv  &

suma \
    -npb $portnum \
    -niml \
    -spec  temp_both.spec \
    -sv MNI_N27_zp1L_SurfVol.nii &

sleep 2

DriveSuma -echo_edu \
    -npb $portnum \
    -com  viewer_cont  -key ctrl+right \
    -com surf_cont -switch_cmap ngray20 \
    -com surf_cont -I_sb  0  -I_range -0.75 0.75                      \
    -T_sb -1

sleep 2

DriveSuma -echo_edu \
    -npb $portnum \
    -com  surf_cont  -switch_surf MNI_N27_cer_brainstem_as_smooth.gii \
    -com surf_cont -switch_cmap ngray20 \
    -com surf_cont -I_sb  0  -I_range -0.75 0.75                      \
    -T_sb -1

sleep 4

# start driving
DriveSuma     -echo_edu                                \
    -npb $portnum                                      \
    -com viewer_cont -key 't' -key '.'
    # connect to AFNI & switch to brain we want

echo "\n\nNAP 2/4...\n\n"
sleep 4 #3

# sagittal profile
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+left'

sleep 2

# crosshair off, node off, faceset off, label off
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'F3' -key 'F4' -key 'F5' -key 'F9'

# wait a while
sleep 4
# ------------------ now rotate suma brain
# start driving
DriveSuma     -echo_edu                                \
    -npb $portnum                                      \
    -com viewer_cont   -key '.'   -key '.'   -key '.'  \
                       -key '.'   -key '.'   -key '.'
    # connect to AFNI & switch to brain we want

foreach bbi ( `seq 1 1 360` ) # 72 is one 360deg rotation
    # wait for image capture
    sleep 2 #2

    # switch ovlerlay
    plugout_drive -echo_edu                                  \
        -npb $portnum                                        \
        -com "SET_SUBBRICKS 0 $bbi $bbi" \
        -quit

    # rotate
    DriveSuma                                              \
        -npb $portnum                                      \
        -com viewer_cont -key 'right'

    # wait for display to update
    sleep 5 #1

    # smile for the photo
    DriveSuma                                         \
        -npb $portnum                                 \
        -com viewer_cont -key 'Ctrl+r'
end

# imagemagick glueing; delay units are 'ms'
convert -delay 50 `ls $image_dir/${image_pre}*`  $movie_fin
