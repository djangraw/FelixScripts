#!/bin/bash
set -e

# RunStory3dDeconvolve_block_tlrc.sh
#
# Created 5/22/18 by DJ.
# Updated 3/4/19 by DJ - a182_v2 version of filenames, use pb05, no stim_times_subtract 12

# set up
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
subj=$1
cd $dataDir/$subj/${subj}.story

# move old REML_cmd if it exists
if [ -f stats.REML_cmd ]; then
  mv stats.REML_cmd stats.${subj}_REML_cmd
fi

# ------------------------------
# run the regression analysis
mkdir -p stimuli
cp $dataDir/$subj/stim_times/stim_times_story/*.txt stimuli/
3dDeconvolve -input pb05.$subj.r*.scale+tlrc.HEAD                           \
    -censor censor_${subj}_combined_2.1D                                   \
    -ortvec ROIPC.FSvent.1D ROIPC.FSvent                                   \
    -polort 3                                                              \
    -local_times                                                         \
    -num_stimts 14                                                         \
    -stim_file 1 motion_demean.1D'[0]' -stim_base 1 -stim_label 1 roll_01  \
    -stim_file 2 motion_demean.1D'[1]' -stim_base 2 -stim_label 2 pitch_01 \
    -stim_file 3 motion_demean.1D'[2]' -stim_base 3 -stim_label 3 yaw_01   \
    -stim_file 4 motion_demean.1D'[3]' -stim_base 4 -stim_label 4 dS_01    \
    -stim_file 5 motion_demean.1D'[4]' -stim_base 5 -stim_label 5 dL_01    \
    -stim_file 6 motion_demean.1D'[5]' -stim_base 6 -stim_label 6 dP_01    \
    -stim_file 7 motion_deriv.1D'[0]' -stim_base 7 -stim_label 7 roll_02   \
    -stim_file 8 motion_deriv.1D'[1]' -stim_base 8 -stim_label 8 pitch_02  \
    -stim_file 9 motion_deriv.1D'[2]' -stim_base 9 -stim_label 9 yaw_02    \
    -stim_file 10 motion_deriv.1D'[3]' -stim_base 10 -stim_label 10 dS_02  \
    -stim_file 11 motion_deriv.1D'[4]' -stim_base 11 -stim_label 11 dL_02  \
    -stim_file 12 motion_deriv.1D'[5]' -stim_base 12 -stim_label 12 dP_02  \
    -stim_times_AM1 13 stimuli/c1_auditory.txt 'dmBLOCK(0)'              \
    -stim_label 13 aud                                                   \
    -stim_times_AM1 14 stimuli/c2_visual.txt 'dmBLOCK(0)'                \
    -stim_label 14 vis                                                   \
    -num_glt 3                                                           \
    -gltsym 'SYM: +0.5*aud +0.5*vis'                                     \
    -glt_label 1 audio+visual                                            \
    -gltsym 'SYM: +aud -vis'                                             \
    -glt_label 2 audio-visual                                            \
    -gltsym 'SYM: -aud +vis'                                             \
    -glt_label 3 visual-audio                                            \
    -jobs 12                                                             \
    -fout -tout -x1D X.block.xmat.1D -xjpeg X.block.jpg                  \
    -x1D_uncensored X.block.nocensor.xmat.1D -x1D_stop                   \
    -fitts fitts.block.$subj                                             \
    -errts errts.block.${subj}                                           \
    -bucket stats.block.$subj

# if 3dDeconvolve fails, terminate the script
if [ $status != 0 ]; then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
fi

# display any large pairwise correlations from the X-matrix
1d_tool.py -show_cormat_warnings -infile X.block.xmat.1D |& tee out.block.cormat_warn.txt

# -- execute the 3dREMLfit script, written by 3dDeconvolve --
mv stats.REML_cmd stats.block.REML_cmd
tcsh -x stats.block.REML_cmd

# # if 3dREMLfit fails, terminate the script
# if [ $status != 0 ]; then
#     echo '---------------------------------------'
#     echo '** 3dREMLfit error, failing...'
#     exit
# fi
