#!/bin/tcsh -xef
# 05p3_RunRegressionWithSegTimecourses.tcsh
#
# Run 3dDeconvolve with segmentation timecourses (WM, CSF, and global signal) included as nuisance regressors.
#
# USAGE:
#   tcsh -xef 05p3_RunRegressionWithSegTimecourses.tcsh $subj $outFolder 2>&1 | tee output.05p3_RunRegressionWithSegTimecourses.$subj.$outFolder
# 
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- 3dDeconvolve output files with suffix _withSegTc.
#
# Created 5/19/16 by DJ based on 05_RunRegressionOnMeicaResults.tcsh.

# ============================== DISPLAY INFO ==============================

echo "auto-generated by afni_proc.py, Mon Nov 16 16:01:44 2015"
echo "(version 4.21, September 8, 2014)"
echo "modified manually for multi-echo data" # MULTIECHO notice
echo "execution started: `date`"


# =========================== auto block: setup ============================
# script setup

# take note of the AFNI version
afni -ver

# check that the current AFNI version is recent enough
afni_history -check_date 13 May 2014
if ( $status ) then
    echo "** this script requires newer AFNI binaries (than 13 May 2014)"
    echo "   (consider: @update.afni.binaries -defaults)"
    exit
endif

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

# enter the results directory (can begin processing data)
cd $output_dir

# detect number of runs by counting pb05 datasets
set nRuns = `ls pb05.$subj.r*.meica.nii | wc -l`
echo "Found ${nRuns} runs for subject ${subj}."
		
# ================================ regress =================================
# assume 05_ has already been run, so the setup files have already been written.


# ------------------------------
# run the regression analysis
# MULTIECHO: use output from MEICA as input
if ( $nRuns == 3 ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.HEAD                           \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 44                                                            \
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
    -stim_file 37 WM_Timecourse.1D -stim_base 37 -stim_label 37 WM_tc    \
    -stim_file 38 CSF_Timecourse.1D -stim_base 38 -stim_label 38 CSF_tc    \
    -stim_file 39 GS_Timecourse.1D -stim_base 39 -stim_label 39 GS_tc    \
    -stim_times_AM1 40 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 40 ignoredNoise \
    -stim_times_AM1 41 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 41 attendedNoise \
    -stim_times_AM1 42 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 42 ignoredSpeech \
    -stim_times_AM1 43 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 43 attendedSpeech \
    -stim_times_AM1 44 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 44 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -fout -tout -x1D X_withSegTc.xmat.1D -xjpeg X_withSegTc.jpg                                   \
    -x1D_uncensored X_withSegTc.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_withSegTc.$subj                                                        \
    -bucket stats_withSegTc.$subj                                                       \
    -cbucket cbucket_withSegTc.$subj                                                    \
    -jobs 32 \
    -overwrite

# Declare number of nuisance regressors, excluding stimulus regressors
set iLastNuisanceReg = 53 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based) 

else if ( $nRuns == 4 ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.HEAD                               \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 56                                                            \
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
    -stim_file 49 WM_Timecourse.1D -stim_base 49 -stim_label 49 WM_tc    \
    -stim_file 50 CSF_Timecourse.1D -stim_base 50 -stim_label 50 CSF_tc    \
    -stim_file 51 GS_Timecourse.1D -stim_base 51 -stim_label 51 GS_tc    \
    -stim_times_AM1 52 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 52 ignoredNoise \
    -stim_times_AM1 53 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 53 attendedNoise \
    -stim_times_AM1 54 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 54 ignoredSpeech \
    -stim_times_AM1 55 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 55 attendedSpeech \
    -stim_times_AM1 56 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 56 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -fout -tout -x1D X_withSegTc.xmat.1D -xjpeg X_withSegTc.jpg                                   \
    -x1D_uncensored X_withSegTc.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_withSegTc.$subj                                                        \
    -bucket stats_withSegTc.$subj                                                       \
    -cbucket cbucket_withSegTc.$subj                                                    \
    -jobs 32 \
    -overwrite

# Declare number of nuisance regressors, excluding stimulus regressors
set iLastNuisanceReg = 70 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based) 

else if ( $nRuns == 5 ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.BRIK                               \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 68                                                            \
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
    -stim_file 61 WM_Timecourse.1D -stim_base 61 -stim_label 61 WM_tc    \
    -stim_file 62 CSF_Timecourse.1D -stim_base 62 -stim_label 62 CSF_tc    \
    -stim_file 63 GS_Timecourse.1D -stim_base 63 -stim_label 63 GS_tc    \
    -stim_times_AM1 64 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 64 ignoredNoise \
    -stim_times_AM1 65 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 65 attendedNoise \
    -stim_times_AM1 66 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 66 ignoredSpeech \
    -stim_times_AM1 67 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 67 attendedSpeech \
    -stim_times_AM1 68 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 68 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -fout -tout -x1D X_withSegTc.xmat.1D -xjpeg X_withSegTc.jpg                                   \
    -x1D_uncensored X_withSegTc.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_withSegTc.$subj                                                        \
    -bucket stats_withSegTc.$subj                                                       \
    -cbucket cbucket_withSegTc.$subj                                                    \
    -jobs 32 \
    -overwrite
    
# Declare number of nuisance regressors, excluding stimulus regressors
set iLastNuisanceReg = 87 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based) 
    
else if ( $nRuns == 6 ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.HEAD                               \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 80                                                            \
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
    -stim_file 73 WM_Timecourse.1D -stim_base 73 -stim_label 73 WM_tc         \
    -stim_file 74 CSF_Timecourse.1D -stim_base 74 -stim_label 74 CSF_tc       \
    -stim_file 75 GS_Timecourse.1D -stim_base 75 -stim_label 75 GS_tc         \
    -stim_times_AM1 76 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 76 ignoredNoise \
    -stim_times_AM1 77 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 77 attendedNoise \
    -stim_times_AM1 78 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 78 ignoredSpeech \
    -stim_times_AM1 79 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 79 attendedSpeech \
    -stim_times_AM1 80 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 80 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech    \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                      \
    -fout -tout -x1D X_withSegTc.xmat.1D -xjpeg X_withSegTc.jpg                                   \
    -x1D_uncensored X_withSegTc.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_withSegTc.$subj                                                        \
    -bucket stats_withSegTc.$subj                                                       \
    -cbucket cbucket_withSegTc.$subj                                                    \
    -jobs 32 \
    -overwrite

# Declare number of nuisance regressors, excluding stimulus regressors
set iLastNuisanceReg = 104 # total regressors + 5*nRuns (polorts) - 5 (stim regressors) - 1 (zero-based) 
    
endif

# -- use 3dTproject to project out regression matrix WITHOUT STIM REGRESSORS --
3dTproject -polort 0 -input pb06.$subj.r*.scale+tlrc.HEAD                    \
           -censor censor_${subj}_combined_2.1D -cenmode ZERO                 \
           -ort X_withSegTc.nocensor.xmat.1D[0..${iLastNuisanceReg}] \
           -overwrite -prefix errts_withSegTc.${subj}.tproject


# if 3dDeconvolve fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
endif

# display any large pariwise correlations from the X-matrix
1d_tool.py -show_cormat_warnings -infile X_withSegTc.xmat.1D |& tee out.cormat_warn_withSegTc.txt

# return to parent directory
cd ..

echo "execution finished: `date`"




# ==========================================================================
# script generated by the command:
#
# afni_proc.py -subj_id SBJ05 -dsets SBJ05_Run01_e2+orig.HEAD                 \
#     SBJ05_Run02_e2+orig.HEAD SBJ05_Run03_e2+orig.HEAD                       \
#     SBJ05_Run04_e2+orig.HEAD -out_dir                                       \
#     /data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ05/AfniProc -blocks \
#     despike tshift align tlrc volreg mask regress -copy_anat                \
#     ../D01_Anatomical/SBJ05_Anat_bc_ns -anat_has_skull no                   \
#     -tcat_remove_first_trs 3 -align_opts_aea -giant_move -volreg_base_dset  \
#     'SBJ05_Run01_e2+orig[0]+orig[0]' -volreg_tlrc_warp -mask_segment_anat   \
#     yes -regress_motion_per_run -regress_censor_motion 0.2                  \
#     -regress_censor_outliers 0.1 -regress_bandpass 0.01 0.1                 \
#     -regress_apply_mot_types demean deriv -regress_est_blur_errts -script   \
#     proc_SBJ05_1116_1601 -bash
