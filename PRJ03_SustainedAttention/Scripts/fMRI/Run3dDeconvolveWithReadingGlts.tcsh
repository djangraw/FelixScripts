#!/bin/tcsh -xef

# Run3dDeconvolveWithReadingGlts.tcsh
#
# Same as 05_... but with 2 GLTs added for eading and reading vs fixation.
#
# USAGE:
# tcsh Run3dDeconvolveWithReadingGlts.tcsh $subj $outFolder
#
# Created 10/16/17 by DJ.

# the user may specify a single subject to run with
if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = SBJ05
endif
if ( $#argv > 1 ) then
    set outFolder = $argv[2]
else
    set outFolder = AfniProc_MultiEcho
endif

# assign base directory
set PRJDIR = /data/jangrawdc/PRJ03_SustainedAttention

# assign output directory name
set output_dir = ${PRJDIR}/Results/${subj}/${outFolder}
# set output_dir = ${PRJDIR}/Results/GROUP_2017-10-16

# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $output_dir

# determine # of runs
set nRuns = (`ls pb06.$subj.r*.scale+tlrc.HEAD | wc -w`)

# Run 3dDeconvolve
if ( $nRuns == 3 ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.HEAD                           \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 41                                                            \
    -stim_file 1 mot_demean.r01.1D'[0]' -stim_base 1 -stim_label 1 roll_01    \
    -stim_file 2 mot_demean.r01.1D'[1]' -stim_base 2 -stim_label 2 pitch_01   \
    -stim_file 3 mot_demean.r01.1D'[2]' -stim_base 3 -stim_label 3 yaw_01     \
    -stim_file 4 mot_demean.r01.1D'[3]' -stim_base 4 -stim_label 4 dS_01      \
    -stim_file 5 mot_demean.r01.1D'[4]' -stim_base 5 -stim_label 5 dL_01      \
    -stim_file 6 mot_demean.r01.1D'[5]' -stim_base 6 -stim_label 6 dP_01      \
    -stim_file 7 mot_demean.r02.1D'[0]' -stim_base 7 -stim_label 7 roll_02    \
    -stim_file 8 mot_demean.r02.1D'[1]' -stim_base 8 -stim_label 8 pitch_02   \
    -stim_file 9 mot_demean.r02.1D'[2]' -stim_base 9 -stim_label 9 yaw_02     \
    -stim_file 10 mot_demean.r02.1D'[3]' -stim_base 10 -stim_label 10 dS_02   \
    -stim_file 11 mot_demean.r02.1D'[4]' -stim_base 11 -stim_label 11 dL_02   \
    -stim_file 12 mot_demean.r02.1D'[5]' -stim_base 12 -stim_label 12 dP_02   \
    -stim_file 13 mot_demean.r03.1D'[0]' -stim_base 13 -stim_label 13 roll_03 \
    -stim_file 14 mot_demean.r03.1D'[1]' -stim_base 14 -stim_label 14         \
    pitch_03                                                                  \
    -stim_file 15 mot_demean.r03.1D'[2]' -stim_base 15 -stim_label 15 yaw_03  \
    -stim_file 16 mot_demean.r03.1D'[3]' -stim_base 16 -stim_label 16 dS_03   \
    -stim_file 17 mot_demean.r03.1D'[4]' -stim_base 17 -stim_label 17 dL_03   \
    -stim_file 18 mot_demean.r03.1D'[5]' -stim_base 18 -stim_label 18 dP_03   \
    -stim_file 19 mot_deriv.r01.1D'[0]' -stim_base 19 -stim_label 19 roll_04  \
    -stim_file 20 mot_deriv.r01.1D'[1]' -stim_base 20 -stim_label 20 pitch_04 \
    -stim_file 21 mot_deriv.r01.1D'[2]' -stim_base 21 -stim_label 21 yaw_04   \
    -stim_file 22 mot_deriv.r01.1D'[3]' -stim_base 22 -stim_label 22 dS_04    \
    -stim_file 23 mot_deriv.r01.1D'[4]' -stim_base 23 -stim_label 23 dL_04    \
    -stim_file 24 mot_deriv.r01.1D'[5]' -stim_base 24 -stim_label 24 dP_04    \
    -stim_file 25 mot_deriv.r02.1D'[0]' -stim_base 25 -stim_label 25 roll_05  \
    -stim_file 26 mot_deriv.r02.1D'[1]' -stim_base 26 -stim_label 26 pitch_05 \
    -stim_file 27 mot_deriv.r02.1D'[2]' -stim_base 27 -stim_label 27 yaw_05   \
    -stim_file 28 mot_deriv.r02.1D'[3]' -stim_base 28 -stim_label 28 dS_05    \
    -stim_file 29 mot_deriv.r02.1D'[4]' -stim_base 29 -stim_label 29 dL_05    \
    -stim_file 30 mot_deriv.r02.1D'[5]' -stim_base 30 -stim_label 30 dP_05    \
    -stim_file 31 mot_deriv.r03.1D'[0]' -stim_base 31 -stim_label 31 roll_06  \
    -stim_file 32 mot_deriv.r03.1D'[1]' -stim_base 32 -stim_label 32 pitch_06 \
    -stim_file 33 mot_deriv.r03.1D'[2]' -stim_base 33 -stim_label 33 yaw_06   \
    -stim_file 34 mot_deriv.r03.1D'[3]' -stim_base 34 -stim_label 34 dS_06    \
    -stim_file 35 mot_deriv.r03.1D'[4]' -stim_base 35 -stim_label 35 dL_06    \
    -stim_file 36 mot_deriv.r03.1D'[5]' -stim_base 36 -stim_label 36 dP_06    \
    -stim_times_AM1 37 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 37 ignoredNoise \
    -stim_times_AM1 38 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 38 attendedNoise \
    -stim_times_AM1 39 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 39 ignoredSpeech \
    -stim_times_AM1 40 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 40 attendedSpeech \
    -stim_times_AM1 41 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 41 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -gltsym ../glt_files/glt_read.txt -glt_label 5 Reading                             \
    -gltsym ../glt_files/glt_read-fix.txt -glt_label 6 ReadingVsFixation               \
    -fout -tout -x1D X_ReadingGlt.xmat.1D -xjpeg X_ReadingGlt.jpg                                   \
    -x1D_uncensored X_ReadingGlt.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_ReadingGlt.$subj                                                        \
    -bucket stats_ReadingGlt.$subj                                                       \
    -cbucket cbucket_ReadingGlt.$subj                                                    \
    -jobs 32

# Declare number of nuisance regressors, excluding stimulus regressors
set iLastNuisanceReg = 50 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based)

else if ( $nRuns == 4 ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.HEAD                               \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 53                                                            \
    -stim_file 1 mot_demean.r01.1D'[0]' -stim_base 1 -stim_label 1 roll_01    \
    -stim_file 2 mot_demean.r01.1D'[1]' -stim_base 2 -stim_label 2 pitch_01   \
    -stim_file 3 mot_demean.r01.1D'[2]' -stim_base 3 -stim_label 3 yaw_01     \
    -stim_file 4 mot_demean.r01.1D'[3]' -stim_base 4 -stim_label 4 dS_01      \
    -stim_file 5 mot_demean.r01.1D'[4]' -stim_base 5 -stim_label 5 dL_01      \
    -stim_file 6 mot_demean.r01.1D'[5]' -stim_base 6 -stim_label 6 dP_01      \
    -stim_file 7 mot_demean.r02.1D'[0]' -stim_base 7 -stim_label 7 roll_02    \
    -stim_file 8 mot_demean.r02.1D'[1]' -stim_base 8 -stim_label 8 pitch_02   \
    -stim_file 9 mot_demean.r02.1D'[2]' -stim_base 9 -stim_label 9 yaw_02     \
    -stim_file 10 mot_demean.r02.1D'[3]' -stim_base 10 -stim_label 10 dS_02   \
    -stim_file 11 mot_demean.r02.1D'[4]' -stim_base 11 -stim_label 11 dL_02   \
    -stim_file 12 mot_demean.r02.1D'[5]' -stim_base 12 -stim_label 12 dP_02   \
    -stim_file 13 mot_demean.r03.1D'[0]' -stim_base 13 -stim_label 13 roll_03 \
    -stim_file 14 mot_demean.r03.1D'[1]' -stim_base 14 -stim_label 14         \
    pitch_03                                                                  \
    -stim_file 15 mot_demean.r03.1D'[2]' -stim_base 15 -stim_label 15 yaw_03  \
    -stim_file 16 mot_demean.r03.1D'[3]' -stim_base 16 -stim_label 16 dS_03   \
    -stim_file 17 mot_demean.r03.1D'[4]' -stim_base 17 -stim_label 17 dL_03   \
    -stim_file 18 mot_demean.r03.1D'[5]' -stim_base 18 -stim_label 18 dP_03   \
    -stim_file 19 mot_demean.r04.1D'[0]' -stim_base 19 -stim_label 19 roll_04 \
    -stim_file 20 mot_demean.r04.1D'[1]' -stim_base 20 -stim_label 20         \
    pitch_04                                                                  \
    -stim_file 21 mot_demean.r04.1D'[2]' -stim_base 21 -stim_label 21 yaw_04  \
    -stim_file 22 mot_demean.r04.1D'[3]' -stim_base 22 -stim_label 22 dS_04   \
    -stim_file 23 mot_demean.r04.1D'[4]' -stim_base 23 -stim_label 23 dL_04   \
    -stim_file 24 mot_demean.r04.1D'[5]' -stim_base 24 -stim_label 24 dP_04   \
    -stim_file 25 mot_deriv.r01.1D'[0]' -stim_base 25 -stim_label 25 roll_05  \
    -stim_file 26 mot_deriv.r01.1D'[1]' -stim_base 26 -stim_label 26 pitch_05 \
    -stim_file 27 mot_deriv.r01.1D'[2]' -stim_base 27 -stim_label 27 yaw_05   \
    -stim_file 28 mot_deriv.r01.1D'[3]' -stim_base 28 -stim_label 28 dS_05    \
    -stim_file 29 mot_deriv.r01.1D'[4]' -stim_base 29 -stim_label 29 dL_05    \
    -stim_file 30 mot_deriv.r01.1D'[5]' -stim_base 30 -stim_label 30 dP_05    \
    -stim_file 31 mot_deriv.r02.1D'[0]' -stim_base 31 -stim_label 31 roll_06  \
    -stim_file 32 mot_deriv.r02.1D'[1]' -stim_base 32 -stim_label 32 pitch_06 \
    -stim_file 33 mot_deriv.r02.1D'[2]' -stim_base 33 -stim_label 33 yaw_06   \
    -stim_file 34 mot_deriv.r02.1D'[3]' -stim_base 34 -stim_label 34 dS_06    \
    -stim_file 35 mot_deriv.r02.1D'[4]' -stim_base 35 -stim_label 35 dL_06    \
    -stim_file 36 mot_deriv.r02.1D'[5]' -stim_base 36 -stim_label 36 dP_06    \
    -stim_file 37 mot_deriv.r03.1D'[0]' -stim_base 37 -stim_label 37 roll_07  \
    -stim_file 38 mot_deriv.r03.1D'[1]' -stim_base 38 -stim_label 38 pitch_07 \
    -stim_file 39 mot_deriv.r03.1D'[2]' -stim_base 39 -stim_label 39 yaw_07   \
    -stim_file 40 mot_deriv.r03.1D'[3]' -stim_base 40 -stim_label 40 dS_07    \
    -stim_file 41 mot_deriv.r03.1D'[4]' -stim_base 41 -stim_label 41 dL_07    \
    -stim_file 42 mot_deriv.r03.1D'[5]' -stim_base 42 -stim_label 42 dP_07    \
    -stim_file 43 mot_deriv.r04.1D'[0]' -stim_base 43 -stim_label 43 roll_08  \
    -stim_file 44 mot_deriv.r04.1D'[1]' -stim_base 44 -stim_label 44 pitch_08 \
    -stim_file 45 mot_deriv.r04.1D'[2]' -stim_base 45 -stim_label 45 yaw_08   \
    -stim_file 46 mot_deriv.r04.1D'[3]' -stim_base 46 -stim_label 46 dS_08    \
    -stim_file 47 mot_deriv.r04.1D'[4]' -stim_base 47 -stim_label 47 dL_08    \
    -stim_file 48 mot_deriv.r04.1D'[5]' -stim_base 48 -stim_label 48 dP_08    \
    -stim_times_AM1 49 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 49 ignoredNoise \
    -stim_times_AM1 50 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 50 attendedNoise \
    -stim_times_AM1 51 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 51 ignoredSpeech \
    -stim_times_AM1 52 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 52 attendedSpeech \
    -stim_times_AM1 53 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 53 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -gltsym ../glt_files/glt_read.txt -glt_label 5 Reading                             \
    -gltsym ../glt_files/glt_read-fix.txt -glt_label 6 ReadingVsFixation               \
    -fout -tout -x1D X_ReadingGlt.xmat.1D -xjpeg X_ReadingGlt.jpg                                   \
    -x1D_uncensored X_ReadingGlt.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_ReadingGlt.$subj                                                        \
    -bucket stats_ReadingGlt.$subj                                                       \
    -cbucket cbucket_ReadingGlt.$subj                                                    \
    -jobs 32

# Declare number of nuisance regressors, excluding stimulus regressors
set iLastNuisanceReg = 67 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based)

else if ( $nRuns == 5 ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.BRIK                               \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 65                                                            \
    -stim_file 1 mot_demean.r01.1D'[0]' -stim_base 1 -stim_label 1 roll_01    \
    -stim_file 2 mot_demean.r01.1D'[1]' -stim_base 2 -stim_label 2 pitch_01   \
    -stim_file 3 mot_demean.r01.1D'[2]' -stim_base 3 -stim_label 3 yaw_01     \
    -stim_file 4 mot_demean.r01.1D'[3]' -stim_base 4 -stim_label 4 dS_01      \
    -stim_file 5 mot_demean.r01.1D'[4]' -stim_base 5 -stim_label 5 dL_01      \
    -stim_file 6 mot_demean.r01.1D'[5]' -stim_base 6 -stim_label 6 dP_01      \
    -stim_file 7 mot_demean.r02.1D'[0]' -stim_base 7 -stim_label 7 roll_02    \
    -stim_file 8 mot_demean.r02.1D'[1]' -stim_base 8 -stim_label 8 pitch_02   \
    -stim_file 9 mot_demean.r02.1D'[2]' -stim_base 9 -stim_label 9 yaw_02     \
    -stim_file 10 mot_demean.r02.1D'[3]' -stim_base 10 -stim_label 10 dS_02   \
    -stim_file 11 mot_demean.r02.1D'[4]' -stim_base 11 -stim_label 11 dL_02   \
    -stim_file 12 mot_demean.r02.1D'[5]' -stim_base 12 -stim_label 12 dP_02   \
    -stim_file 13 mot_demean.r03.1D'[0]' -stim_base 13 -stim_label 13 roll_03 \
    -stim_file 14 mot_demean.r03.1D'[1]' -stim_base 14 -stim_label 14         \
    pitch_03                                                                  \
    -stim_file 15 mot_demean.r03.1D'[2]' -stim_base 15 -stim_label 15 yaw_03  \
    -stim_file 16 mot_demean.r03.1D'[3]' -stim_base 16 -stim_label 16 dS_03   \
    -stim_file 17 mot_demean.r03.1D'[4]' -stim_base 17 -stim_label 17 dL_03   \
    -stim_file 18 mot_demean.r03.1D'[5]' -stim_base 18 -stim_label 18 dP_03   \
    -stim_file 19 mot_demean.r04.1D'[0]' -stim_base 19 -stim_label 19 roll_04 \
    -stim_file 20 mot_demean.r04.1D'[1]' -stim_base 20 -stim_label 20         \
    pitch_04                                                                  \
    -stim_file 21 mot_demean.r04.1D'[2]' -stim_base 21 -stim_label 21 yaw_04  \
    -stim_file 22 mot_demean.r04.1D'[3]' -stim_base 22 -stim_label 22 dS_04   \
    -stim_file 23 mot_demean.r04.1D'[4]' -stim_base 23 -stim_label 23 dL_04   \
    -stim_file 24 mot_demean.r04.1D'[5]' -stim_base 24 -stim_label 24 dP_04   \
    -stim_file 25 mot_demean.r05.1D'[0]' -stim_base 25 -stim_label 25 roll_05 \
    -stim_file 26 mot_demean.r05.1D'[1]' -stim_base 26 -stim_label 26         \
    pitch_05                                                                  \
    -stim_file 27 mot_demean.r05.1D'[2]' -stim_base 27 -stim_label 27 yaw_05  \
    -stim_file 28 mot_demean.r05.1D'[3]' -stim_base 28 -stim_label 28 dS_05   \
    -stim_file 29 mot_demean.r05.1D'[4]' -stim_base 29 -stim_label 29 dL_05   \
    -stim_file 30 mot_demean.r05.1D'[5]' -stim_base 30 -stim_label 30 dP_05   \
    -stim_file 31 mot_deriv.r01.1D'[0]' -stim_base 31 -stim_label 31 roll_06  \
    -stim_file 32 mot_deriv.r01.1D'[1]' -stim_base 32 -stim_label 32 pitch_06 \
    -stim_file 33 mot_deriv.r01.1D'[2]' -stim_base 33 -stim_label 33 yaw_06   \
    -stim_file 34 mot_deriv.r01.1D'[3]' -stim_base 34 -stim_label 34 dS_06    \
    -stim_file 35 mot_deriv.r01.1D'[4]' -stim_base 35 -stim_label 35 dL_06    \
    -stim_file 36 mot_deriv.r01.1D'[5]' -stim_base 36 -stim_label 36 dP_06    \
    -stim_file 37 mot_deriv.r02.1D'[0]' -stim_base 37 -stim_label 37 roll_07  \
    -stim_file 38 mot_deriv.r02.1D'[1]' -stim_base 38 -stim_label 38 pitch_07 \
    -stim_file 39 mot_deriv.r02.1D'[2]' -stim_base 39 -stim_label 39 yaw_07   \
    -stim_file 40 mot_deriv.r02.1D'[3]' -stim_base 40 -stim_label 40 dS_07    \
    -stim_file 41 mot_deriv.r02.1D'[4]' -stim_base 41 -stim_label 41 dL_07    \
    -stim_file 42 mot_deriv.r02.1D'[5]' -stim_base 42 -stim_label 42 dP_07    \
    -stim_file 43 mot_deriv.r03.1D'[0]' -stim_base 43 -stim_label 43 roll_08  \
    -stim_file 44 mot_deriv.r03.1D'[1]' -stim_base 44 -stim_label 44 pitch_08 \
    -stim_file 45 mot_deriv.r03.1D'[2]' -stim_base 45 -stim_label 45 yaw_08   \
    -stim_file 46 mot_deriv.r03.1D'[3]' -stim_base 46 -stim_label 46 dS_08    \
    -stim_file 47 mot_deriv.r03.1D'[4]' -stim_base 47 -stim_label 47 dL_08    \
    -stim_file 48 mot_deriv.r03.1D'[5]' -stim_base 48 -stim_label 48 dP_08    \
    -stim_file 49 mot_deriv.r04.1D'[0]' -stim_base 49 -stim_label 49 roll_09  \
    -stim_file 50 mot_deriv.r04.1D'[1]' -stim_base 50 -stim_label 50 pitch_09 \
    -stim_file 51 mot_deriv.r04.1D'[2]' -stim_base 51 -stim_label 51 yaw_09   \
    -stim_file 52 mot_deriv.r04.1D'[3]' -stim_base 52 -stim_label 52 dS_09    \
    -stim_file 53 mot_deriv.r04.1D'[4]' -stim_base 53 -stim_label 53 dL_09    \
    -stim_file 54 mot_deriv.r04.1D'[5]' -stim_base 54 -stim_label 54 dP_09    \
    -stim_file 55 mot_deriv.r05.1D'[0]' -stim_base 55 -stim_label 55 roll_10  \
    -stim_file 56 mot_deriv.r05.1D'[1]' -stim_base 56 -stim_label 56 pitch_10 \
    -stim_file 57 mot_deriv.r05.1D'[2]' -stim_base 57 -stim_label 57 yaw_10   \
    -stim_file 58 mot_deriv.r05.1D'[3]' -stim_base 58 -stim_label 58 dS_10    \
    -stim_file 59 mot_deriv.r05.1D'[4]' -stim_base 59 -stim_label 59 dL_10    \
    -stim_file 60 mot_deriv.r05.1D'[5]' -stim_base 60 -stim_label 60 dP_10    \
    -stim_times_AM1 61 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 61 ignoredNoise \
    -stim_times_AM1 62 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 62 attendedNoise \
    -stim_times_AM1 63 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 63 ignoredSpeech \
    -stim_times_AM1 64 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 64 attendedSpeech \
    -stim_times_AM1 65 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 65 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -gltsym ../glt_files/glt_read.txt -glt_label 5 Reading                             \
    -gltsym ../glt_files/glt_read-fix.txt -glt_label 6 ReadingVsFixation               \
    -fout -tout -x1D X_ReadingGlt.xmat.1D -xjpeg X_ReadingGlt.jpg                                   \
    -x1D_uncensored X_ReadingGlt.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_ReadingGlt.$subj                                                        \
    -bucket stats_ReadingGlt.$subj                                                       \
    -cbucket cbucket_ReadingGlt.$subj                                                    \
    -jobs 32

# Declare number of nuisance regressors, excluding stimulus regressors
set iLastNuisanceReg = 84 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based)

else if ( $nRuns == 6 ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.HEAD                               \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 77                                                            \
    -stim_file 1 mot_demean.r01.1D'[0]' -stim_base 1 -stim_label 1 roll_01    \
    -stim_file 2 mot_demean.r01.1D'[1]' -stim_base 2 -stim_label 2 pitch_01   \
    -stim_file 3 mot_demean.r01.1D'[2]' -stim_base 3 -stim_label 3 yaw_01     \
    -stim_file 4 mot_demean.r01.1D'[3]' -stim_base 4 -stim_label 4 dS_01      \
    -stim_file 5 mot_demean.r01.1D'[4]' -stim_base 5 -stim_label 5 dL_01      \
    -stim_file 6 mot_demean.r01.1D'[5]' -stim_base 6 -stim_label 6 dP_01      \
    -stim_file 7 mot_demean.r02.1D'[0]' -stim_base 7 -stim_label 7 roll_02    \
    -stim_file 8 mot_demean.r02.1D'[1]' -stim_base 8 -stim_label 8 pitch_02   \
    -stim_file 9 mot_demean.r02.1D'[2]' -stim_base 9 -stim_label 9 yaw_02     \
    -stim_file 10 mot_demean.r02.1D'[3]' -stim_base 10 -stim_label 10 dS_02   \
    -stim_file 11 mot_demean.r02.1D'[4]' -stim_base 11 -stim_label 11 dL_02   \
    -stim_file 12 mot_demean.r02.1D'[5]' -stim_base 12 -stim_label 12 dP_02   \
    -stim_file 13 mot_demean.r03.1D'[0]' -stim_base 13 -stim_label 13 roll_03 \
    -stim_file 14 mot_demean.r03.1D'[1]' -stim_base 14 -stim_label 14         \
    pitch_03                                                                  \
    -stim_file 15 mot_demean.r03.1D'[2]' -stim_base 15 -stim_label 15 yaw_03  \
    -stim_file 16 mot_demean.r03.1D'[3]' -stim_base 16 -stim_label 16 dS_03   \
    -stim_file 17 mot_demean.r03.1D'[4]' -stim_base 17 -stim_label 17 dL_03   \
    -stim_file 18 mot_demean.r03.1D'[5]' -stim_base 18 -stim_label 18 dP_03   \
    -stim_file 19 mot_demean.r04.1D'[0]' -stim_base 19 -stim_label 19 roll_04 \
    -stim_file 20 mot_demean.r04.1D'[1]' -stim_base 20 -stim_label 20         \
    pitch_04                                                                  \
    -stim_file 21 mot_demean.r04.1D'[2]' -stim_base 21 -stim_label 21 yaw_04  \
    -stim_file 22 mot_demean.r04.1D'[3]' -stim_base 22 -stim_label 22 dS_04   \
    -stim_file 23 mot_demean.r04.1D'[4]' -stim_base 23 -stim_label 23 dL_04   \
    -stim_file 24 mot_demean.r04.1D'[5]' -stim_base 24 -stim_label 24 dP_04   \
    -stim_file 25 mot_demean.r05.1D'[0]' -stim_base 25 -stim_label 25 roll_05 \
    -stim_file 26 mot_demean.r05.1D'[1]' -stim_base 26 -stim_label 26         \
    pitch_05                                                                  \
    -stim_file 27 mot_demean.r05.1D'[2]' -stim_base 27 -stim_label 27 yaw_05  \
    -stim_file 28 mot_demean.r05.1D'[3]' -stim_base 28 -stim_label 28 dS_05   \
    -stim_file 29 mot_demean.r05.1D'[4]' -stim_base 29 -stim_label 29 dL_05   \
    -stim_file 30 mot_demean.r05.1D'[5]' -stim_base 30 -stim_label 30 dP_05   \
    -stim_file 31 mot_demean.r06.1D'[0]' -stim_base 31 -stim_label 31 roll_06 \
    -stim_file 32 mot_demean.r06.1D'[1]' -stim_base 32 -stim_label 32         \
    pitch_06                                                                  \
    -stim_file 33 mot_demean.r06.1D'[2]' -stim_base 33 -stim_label 33 yaw_06  \
    -stim_file 34 mot_demean.r06.1D'[3]' -stim_base 34 -stim_label 34 dS_06   \
    -stim_file 35 mot_demean.r06.1D'[4]' -stim_base 35 -stim_label 35 dL_06   \
    -stim_file 36 mot_demean.r06.1D'[5]' -stim_base 36 -stim_label 36 dP_06   \
    -stim_file 37 mot_deriv.r01.1D'[0]' -stim_base 37 -stim_label 37 roll_07  \
    -stim_file 38 mot_deriv.r01.1D'[1]' -stim_base 38 -stim_label 38 pitch_07 \
    -stim_file 39 mot_deriv.r01.1D'[2]' -stim_base 39 -stim_label 39 yaw_07   \
    -stim_file 40 mot_deriv.r01.1D'[3]' -stim_base 40 -stim_label 40 dS_07    \
    -stim_file 41 mot_deriv.r01.1D'[4]' -stim_base 41 -stim_label 41 dL_07    \
    -stim_file 42 mot_deriv.r01.1D'[5]' -stim_base 42 -stim_label 42 dP_07    \
    -stim_file 43 mot_deriv.r02.1D'[0]' -stim_base 43 -stim_label 43 roll_08  \
    -stim_file 44 mot_deriv.r02.1D'[1]' -stim_base 44 -stim_label 44 pitch_08 \
    -stim_file 45 mot_deriv.r02.1D'[2]' -stim_base 45 -stim_label 45 yaw_08   \
    -stim_file 46 mot_deriv.r02.1D'[3]' -stim_base 46 -stim_label 46 dS_08    \
    -stim_file 47 mot_deriv.r02.1D'[4]' -stim_base 47 -stim_label 47 dL_08    \
    -stim_file 48 mot_deriv.r02.1D'[5]' -stim_base 48 -stim_label 48 dP_08    \
    -stim_file 49 mot_deriv.r03.1D'[0]' -stim_base 49 -stim_label 49 roll_09  \
    -stim_file 50 mot_deriv.r03.1D'[1]' -stim_base 50 -stim_label 50 pitch_09 \
    -stim_file 51 mot_deriv.r03.1D'[2]' -stim_base 51 -stim_label 51 yaw_09   \
    -stim_file 52 mot_deriv.r03.1D'[3]' -stim_base 52 -stim_label 52 dS_09    \
    -stim_file 53 mot_deriv.r03.1D'[4]' -stim_base 53 -stim_label 53 dL_09    \
    -stim_file 54 mot_deriv.r03.1D'[5]' -stim_base 54 -stim_label 54 dP_09    \
    -stim_file 55 mot_deriv.r04.1D'[0]' -stim_base 55 -stim_label 55 roll_10  \
    -stim_file 56 mot_deriv.r04.1D'[1]' -stim_base 56 -stim_label 56 pitch_10 \
    -stim_file 57 mot_deriv.r04.1D'[2]' -stim_base 57 -stim_label 57 yaw_10   \
    -stim_file 58 mot_deriv.r04.1D'[3]' -stim_base 58 -stim_label 58 dS_10    \
    -stim_file 59 mot_deriv.r04.1D'[4]' -stim_base 59 -stim_label 59 dL_10    \
    -stim_file 60 mot_deriv.r04.1D'[5]' -stim_base 60 -stim_label 60 dP_10    \
    -stim_file 61 mot_deriv.r05.1D'[0]' -stim_base 61 -stim_label 61 roll_11  \
    -stim_file 62 mot_deriv.r05.1D'[1]' -stim_base 62 -stim_label 62 pitch_11 \
    -stim_file 63 mot_deriv.r05.1D'[2]' -stim_base 63 -stim_label 63 yaw_11   \
    -stim_file 64 mot_deriv.r05.1D'[3]' -stim_base 64 -stim_label 64 dS_11    \
    -stim_file 65 mot_deriv.r05.1D'[4]' -stim_base 65 -stim_label 65 dL_11    \
    -stim_file 66 mot_deriv.r05.1D'[5]' -stim_base 66 -stim_label 66 dP_11    \
    -stim_file 67 mot_deriv.r06.1D'[0]' -stim_base 67 -stim_label 67 roll_12  \
    -stim_file 68 mot_deriv.r06.1D'[1]' -stim_base 68 -stim_label 68 pitch_12 \
    -stim_file 69 mot_deriv.r06.1D'[2]' -stim_base 69 -stim_label 69 yaw_12   \
    -stim_file 70 mot_deriv.r06.1D'[3]' -stim_base 70 -stim_label 70 dS_12    \
    -stim_file 71 mot_deriv.r06.1D'[4]' -stim_base 71 -stim_label 71 dL_12    \
    -stim_file 72 mot_deriv.r06.1D'[5]' -stim_base 72 -stim_label 72 dP_12    \
    -stim_times_AM1 73 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 73 ignoredNoise \
    -stim_times_AM1 74 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 74 attendedNoise \
    -stim_times_AM1 75 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 75 ignoredSpeech \
    -stim_times_AM1 76 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 76 attendedSpeech \
    -stim_times_AM1 77 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 77 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -gltsym ../glt_files/glt_read.txt -glt_label 5 Reading                             \
    -gltsym ../glt_files/glt_read-fix.txt -glt_label 6 ReadingVsFixation               \
    -fout -tout -x1D X_ReadingGlt.xmat.1D -xjpeg X_ReadingGlt.jpg                                   \
    -x1D_uncensored X_ReadingGlt.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_ReadingGlt.$subj                                                        \
    -bucket stats_ReadingGlt.$subj                                                       \
    -cbucket cbucket_ReadingGlt.$subj                                                    \
    -jobs 32

# Declare number of nuisance regressors, excluding stimulus regressors
set iLastNuisanceReg = 101 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based)

endif

# if 3dDeconvolve fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
endif

# display any large pariwise correlations from the X-matrix
1d_tool.py -show_cormat_warnings -infile X_ReadingGlt.xmat.1D |& tee out_ReadingGlt.cormat_warn.txt

# -- execute the 3dREMLfit script, written by 3dDeconvolve --
# Rename and Run 3dREMLfit
mv stats_ReadingGlt.REML_cmd stats_ReadingGlt.$subj.REML_cmd
tcsh -x stats_ReadingGlt.$subj.REML_cmd
