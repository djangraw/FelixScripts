#!/bin/bash

# RunSrtt3dDeconvolve_noNuisanceRegs.sh
#
# Regress out task without nuisance regressors like motion, polynomials, and WM/CSF timecourses.
#
# USAGE:
#   RunSrtt3dDeconvolve_noNuisanceRegs.sh $subj
# INPUTS:
# -subj is a string indicating the subject name, e.g., tb0065.
#
# Created 2/26/18 by DJ based on RunSrtt3dDeconvolve_WmCsf

# parse inputs
subj=$1

# move into directory
cd /data/jangrawdc/PRJ16_TaskFcManipulation/RawData/$subj/$subj.srtt_v3

# avoid overwriting old REML script and output
# mv stats.REML_cmd stats.afni_srtt_v3.REML_cmd
# mv 3dREMLfit.err 3dREMLfit.afni_srtt_v3.err

# run 3dDeconvolve with WM/CSF regressors to get stats
3dDeconvolve -input pb05.$subj.r*.scale+tlrc.HEAD                            \
    -censor censor_${subj}_combined_2.1D                                     \
    -polort 3                                                                \
    -local_times                                                             \
    -num_stimts 6                                                           \
    -stim_times_AM1 1 stimuli/bl1_c1_unstr.txt 'dmBLOCK(1)'                  \
    -stim_label 1 uns1                                                       \
    -stim_times_AM1 2 stimuli/bl2_c1_unstr.txt 'dmBLOCK(1)'                  \
    -stim_label 2 uns2                                                       \
    -stim_times_AM1 3 stimuli/bl3_c1_unstr.txt 'dmBLOCK(1)'                  \
    -stim_label 3 uns3                                                       \
    -stim_times_AM1 4 stimuli/bl1_c2_str.txt 'dmBLOCK(1)'                    \
    -stim_label 4 str1                                                       \
    -stim_times_AM1 5 stimuli/bl2_c2_str.txt 'dmBLOCK(1)'                    \
    -stim_label 5 str2                                                       \
    -stim_times_AM1 6 stimuli/bl3_c2_str.txt 'dmBLOCK(1)'                    \
    -stim_label 6 str3                                                       \
    -num_glt 10                                                              \
    -gltsym 'SYM: +uns1 +uns2 +uns3'                                         \
    -glt_label 1 unstructured                                                \
    -gltsym 'SYM: +str1 +str2 +str3'                                         \
    -glt_label 2 structured                                                  \
    -gltsym 'SYM: +str1 +str2 +str3 -uns1 -uns2 -uns3'                       \
    -glt_label 3 structured-unstructured                                     \
    -gltsym 'SYM: +str1 -uns1'                                               \
    -glt_label 4 'structured-unstructured BL1'                               \
    -gltsym 'SYM: +str2 -uns2'                                               \
    -glt_label 5 'structured-unstructured BL2'                               \
    -gltsym 'SYM: +str3 -uns3'                                               \
    -glt_label 6 'structured-unstructured BL3'                               \
    -gltsym 'SYM: +str1 +str2 +str3 +uns1 +uns2 +uns3'                       \
    -glt_label 7 task                                                        \
    -gltsym 'SYM: +uns1 +str1'                                               \
    -glt_label 8 'task BL1'                                                  \
    -gltsym 'SYM: +uns2 +str2'                                               \
    -glt_label 9 'task BL2'                                                  \
    -gltsym 'SYM: +uns3 +str3'                                               \
    -glt_label 10 'task BL3'                                                 \
    -jobs 10                                                                 \
    -fout -tout                                                              \
    -fitts fitts.noNuisanceRegs.${subj}                                             \
    -errts errts.noNuisanceRegs.${subj}                                             \
    -bucket stats.noNuisanceRegs.${subj}


# if 3dDeconvolve fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
fi


# -- execute the 3dREMLfit script, written by 3dDeconvolve --
mv stats.REML_cmd stats.noNuisanceRegs.REML_cmd
tcsh -x stats.noNuisanceRegs.REML_cmd
mv 3dREMLfit.err 3dREMLfit.noNuisanceRegs.err # to avoid confusing with old version
