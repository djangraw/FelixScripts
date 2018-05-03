#!/bin/bash

3dDeconvolve -input pb05.tb9614.r*.scale+tlrc.HEAD                        \
    -censor censor_tb9614_combined_2.1D                                 \
    -polort 3                                                 \
    -local_times                                                         \
    -num_stimts 58                                                    \
    -stim_times_AM1 1 stimuli/bl1_c1_unstr.txt 'dmBLOCK(1)'              \
    -stim_label 1 uns1                                                   \
    -stim_times_AM1 2 stimuli/bl2_c1_unstr.txt 'dmBLOCK(1)'              \
    -stim_label 2 uns2                                                   \
    -stim_times_AM1 3 stimuli/bl3_c1_unstr.txt 'dmBLOCK(1)'              \
    -stim_label 3 uns3                                                   \
    -stim_times_AM1 4 stimuli/bl1_c2_str.txt 'dmBLOCK(1)'                \
    -stim_label 4 str1                                                   \
    -stim_times_AM1 5 stimuli/bl2_c2_str.txt 'dmBLOCK(1)'                \
    -stim_label 5 str2                                                   \
    -stim_times_AM1 6 stimuli/bl3_c2_str.txt 'dmBLOCK(1)'                \
    -stim_label 6 str3                                                   \
    -stim_file 7 motion_demean.1D'[0]' -stim_base 7 -stim_label 7 roll_01    \
    -stim_file 8 motion_demean.1D'[1]' -stim_base 8 -stim_label 8 pitch_01   \
    -stim_file 9 motion_demean.1D'[2]' -stim_base 9 -stim_label 9 yaw_01     \
    -stim_file 10 motion_demean.1D'[3]' -stim_base 10 -stim_label 10 dS_01   \
    -stim_file 11 motion_demean.1D'[4]' -stim_base 11 -stim_label 11 dL_01   \
    -stim_file 12 motion_demean.1D'[5]' -stim_base 12 -stim_label 12 dP_01   \
    -stim_file 13 motion_deriv.1D'[0]' -stim_base 13 -stim_label 13 roll_02  \
    -stim_file 14 motion_deriv.1D'[1]' -stim_base 14 -stim_label 14 pitch_02 \
    -stim_file 15 motion_deriv.1D'[2]' -stim_base 15 -stim_label 15 yaw_02   \
    -stim_file 16 motion_deriv.1D'[3]' -stim_base 16 -stim_label 16 dS_02    \
    -stim_file 17 motion_deriv.1D'[4]' -stim_base 17 -stim_label 17 dL_02    \
    -stim_file 18 motion_deriv.1D'[5]' -stim_base 18 -stim_label 18 dP_02    \
    -stim_file 19 Seed_tsROI167.1D -stim_label 19 Seed_ROI167 \
    -stim_file 20 Inter_tsc0_baselineROI167.1D -stim_label 20 PPI_ROI167_rest \
    -stim_file 21 Inter_tsc1_unstrROI167.1D -stim_label 21 PPI_ROI167_uns  \
    -stim_file 22 Inter_tsc2_strROI167.1D -stim_label 22 PPI_ROI167_str  \
    -stim_file 23 Seed_tsROI33.1D -stim_label 23 Seed_ROI33 \
    -stim_file 24 Inter_tsc0_baselineROI33.1D -stim_label 24 PPI_ROI33_rest \
    -stim_file 25 Inter_tsc1_unstrROI33.1D -stim_label 25 PPI_ROI33_uns  \
    -stim_file 26 Inter_tsc2_strROI33.1D -stim_label 26 PPI_ROI33_str  \
    -stim_file 27 Seed_tsROI151.1D -stim_label 27 Seed_ROI151 \
    -stim_file 28 Inter_tsc0_baselineROI151.1D -stim_label 28 PPI_ROI151_rest \
    -stim_file 29 Inter_tsc1_unstrROI151.1D -stim_label 29 PPI_ROI151_uns  \
    -stim_file 30 Inter_tsc2_strROI151.1D -stim_label 30 PPI_ROI151_str  \
    -stim_file 31 Seed_tsROI16.1D -stim_label 31 Seed_ROI16 \
    -stim_file 32 Inter_tsc0_baselineROI16.1D -stim_label 32 PPI_ROI16_rest \
    -stim_file 33 Inter_tsc1_unstrROI16.1D -stim_label 33 PPI_ROI16_uns  \
    -stim_file 34 Inter_tsc2_strROI16.1D -stim_label 34 PPI_ROI16_str  \
    -stim_file 35 Seed_tsROI197.1D -stim_label 35 Seed_ROI197 \
    -stim_file 36 Inter_tsc0_baselineROI197.1D -stim_label 36 PPI_ROI197_rest \
    -stim_file 37 Inter_tsc1_unstrROI197.1D -stim_label 37 PPI_ROI197_uns  \
    -stim_file 38 Inter_tsc2_strROI197.1D -stim_label 38 PPI_ROI197_str  \
    -stim_file 39 Seed_tsROI64.1D -stim_label 39 Seed_ROI64 \
    -stim_file 40 Inter_tsc0_baselineROI64.1D -stim_label 40 PPI_ROI64_rest \
    -stim_file 41 Inter_tsc1_unstrROI64.1D -stim_label 41 PPI_ROI64_uns  \
    -stim_file 42 Inter_tsc2_strROI64.1D -stim_label 42 PPI_ROI64_str  \
    -stim_file 43 Seed_tsROI200.1D -stim_label 43 Seed_ROI200 \
    -stim_file 44 Inter_tsc0_baselineROI200.1D -stim_label 44 PPI_ROI200_rest \
    -stim_file 45 Inter_tsc1_unstrROI200.1D -stim_label 45 PPI_ROI200_uns  \
    -stim_file 46 Inter_tsc2_strROI200.1D -stim_label 46 PPI_ROI200_str  \
    -stim_file 47 Seed_tsROI71.1D -stim_label 47 Seed_ROI71 \
    -stim_file 48 Inter_tsc0_baselineROI71.1D -stim_label 48 PPI_ROI71_rest \
    -stim_file 49 Inter_tsc1_unstrROI71.1D -stim_label 49 PPI_ROI71_uns  \
    -stim_file 50 Inter_tsc2_strROI71.1D -stim_label 50 PPI_ROI71_str  \
    -stim_file 51 Seed_tsROI261.1D -stim_label 51 Seed_ROI261 \
    -stim_file 52 Inter_tsc0_baselineROI261.1D -stim_label 52 PPI_ROI261_rest \
    -stim_file 53 Inter_tsc1_unstrROI261.1D -stim_label 53 PPI_ROI261_uns  \
    -stim_file 54 Inter_tsc2_strROI261.1D -stim_label 54 PPI_ROI261_str  \
    -stim_file 55 Seed_tsROI124.1D -stim_label 55 Seed_ROI124 \
    -stim_file 56 Inter_tsc0_baselineROI124.1D -stim_label 56 PPI_ROI124_rest \
    -stim_file 57 Inter_tsc1_unstrROI124.1D -stim_label 57 PPI_ROI124_uns  \
    -stim_file 58 Inter_tsc2_strROI124.1D -stim_label 58 PPI_ROI124_str  \
    -num_glt 30                                                           \
    -gltsym 'SYM: +0.33*uns1 +0.33*uns2 +0.33*uns3'                          \
    -glt_label 1 unstructured                                                \
    -gltsym 'SYM: +0.33*str1 +0.33*str2 +0.33*str3'                          \
    -glt_label 2 structured                                                  \
    -gltsym 'SYM: +str1 +str2 +str3 -uns1 -uns2 -uns3'                       \
    -glt_label 3 structured-unstructured                                     \
    -gltsym 'SYM: +str1 -uns1'                                               \
    -glt_label 4 'structured-unsructured BL1'                                \
    -gltsym 'SYM: +str2 -uns2'                                               \
    -glt_label 5 'structured-unstructured BL2'                               \
    -gltsym 'SYM: +str3 -uns3'                                               \
    -glt_label 6 'structured-unstructured BL3'                               \
    -gltsym 'SYM: +0.167*uns1 +0.167*uns2 +0.167*uns3 +0.167*str1 +0.167*str2 +0.167*str3'  \
    -glt_label 7 task                                                        \
    -gltsym 'SYM: +0.5*uns1 +0.5*str1'                                       \
    -glt_label 8 'task BL1'                                                  \
    -gltsym 'SYM: +0.5*uns2 +0.5*str2'                                       \
    -glt_label 9 'task BL2'                                                  \
    -gltsym 'SYM: +0.5*uns3 +0.5*str3'                                       \
    -glt_label 10 'task BL3'                                                 \
    -gltsym 'SYM: +0.5*PPI_ROI167_uns +0.5*PPI_ROI167_str -PPI_ROI167_rest'           \
    -glt_label 11 PPI_ROI167_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI167_str -PPI_ROI167_uns'                                   \
    -glt_label 12 PPI_ROI167_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI33_uns +0.5*PPI_ROI33_str -PPI_ROI33_rest'           \
    -glt_label 13 PPI_ROI33_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI33_str -PPI_ROI33_uns'                                   \
    -glt_label 14 PPI_ROI33_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI151_uns +0.5*PPI_ROI151_str -PPI_ROI151_rest'           \
    -glt_label 15 PPI_ROI151_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI151_str -PPI_ROI151_uns'                                   \
    -glt_label 16 PPI_ROI151_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI16_uns +0.5*PPI_ROI16_str -PPI_ROI16_rest'           \
    -glt_label 17 PPI_ROI16_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI16_str -PPI_ROI16_uns'                                   \
    -glt_label 18 PPI_ROI16_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI197_uns +0.5*PPI_ROI197_str -PPI_ROI197_rest'           \
    -glt_label 19 PPI_ROI197_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI197_str -PPI_ROI197_uns'                                   \
    -glt_label 20 PPI_ROI197_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI64_uns +0.5*PPI_ROI64_str -PPI_ROI64_rest'           \
    -glt_label 21 PPI_ROI64_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI64_str -PPI_ROI64_uns'                                   \
    -glt_label 22 PPI_ROI64_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI200_uns +0.5*PPI_ROI200_str -PPI_ROI200_rest'           \
    -glt_label 23 PPI_ROI200_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI200_str -PPI_ROI200_uns'                                   \
    -glt_label 24 PPI_ROI200_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI71_uns +0.5*PPI_ROI71_str -PPI_ROI71_rest'           \
    -glt_label 25 PPI_ROI71_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI71_str -PPI_ROI71_uns'                                   \
    -glt_label 26 PPI_ROI71_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI261_uns +0.5*PPI_ROI261_str -PPI_ROI261_rest'           \
    -glt_label 27 PPI_ROI261_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI261_str -PPI_ROI261_uns'                                   \
    -glt_label 28 PPI_ROI261_str-uns                                               \
    -gltsym 'SYM: +0.5*PPI_ROI124_uns +0.5*PPI_ROI124_str -PPI_ROI124_rest'           \
    -glt_label 29 PPI_ROI124_task-rest                                             \
    -gltsym 'SYM: +PPI_ROI124_str -PPI_ROI124_uns'                                   \
    -glt_label 30 PPI_ROI124_str-uns                                               \
    -rout -tout -overwrite -x1D_stop\
    -errts errts.PPI.tb9614              \
    -bucket stats.PPI.tb9614
