#!/bin/tcsh -xef
#
# USAGE:
#   tcsh -xef 05p2_RunStimRegression.tcsh $subj $outFolder 2>&1 | tee output.05p2_RunStimRegression.$subj
#
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- some files for 3dDeconvolve output
#
# Created 5/19/16 by DJ based on 05p1_RunRegressionWithStim.tcsh.
# Created 1/13/17 by DJ - added reading GLTs (5 & 6)

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

# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $output_dir

# Make sure stim text files exist
if ( ! (-f ../stimuli/${subj}_fixation.1D && -f ../stimuli/${subj}_ignoredNoise.1D && -f ../stimuli/${subj}_attendedNoise.1D && -f ../stimuli/${subj}_ignoredSpeech.1D && -f ../stimuli/${subj}_attendedSpeech.1D) ) then
    echo "ERROR: stimulus files not found!" 
    exit 1
endif

# Make sure glt text files exist
if ( ! (-f ../glt_files/glt_noise-speech.txt && -f ../glt_files/glt_noise_ign-att.txt && -f ../glt_files/glt_speech_ign-att.txt && -f ../glt_files/glt_speech.txt && -f ../glt_files/glt_read.txt && -f ../glt_files/glt_read-fix.txt) ) then
    echo "ERROR: GLT files not found!" 
    exit 1
endif

echo 'Starting 3dDeconvolve...'
# Run 3dDeconvolve
3dDeconvolve -input errts.$subj.tproject+tlrc.                            \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort -1                                                                 \
    -num_stimts 5                                                            \
    -global_times                                                             \
    -stim_times_AM1 1 ../stimuli/${subj}_ignoredNoise.1D 'dmBLOCK4(1)' -stim_label 1 ignoredNoise \
    -stim_times_AM1 2 ../stimuli/${subj}_attendedNoise.1D 'dmBLOCK4(1)' -stim_label 2 attendedNoise \
    -stim_times_AM1 3 ../stimuli/${subj}_ignoredSpeech.1D 'dmBLOCK4(1)' -stim_label 3 ignoredSpeech \
    -stim_times_AM1 4 ../stimuli/${subj}_attendedSpeech.1D 'dmBLOCK4(1)' -stim_label 4 attendedSpeech \
    -stim_times_AM1 5 ../stimuli/${subj}_fixation.1D 'dmBLOCK4(1)' -stim_label 5 fixation \
    -gltsym ../glt_files/glt_noise-speech.txt -glt_label 1 WhiteNoiseVsSpeech          \
    -gltsym ../glt_files/glt_noise_ign-att.txt -glt_label 2 IgnoredVsAttendedNoise     \
    -gltsym ../glt_files/glt_speech_ign-att.txt -glt_label 3 IgnoredVsAttendedSpeech   \
    -gltsym ../glt_files/glt_speech.txt -glt_label 4 Speech                            \
    -gltsym ../glt_files/glt_read.txt -glt_label 5 Reading                             \
    -gltsym ../glt_files/glt_read-fix.txt -glt_label 6 ReadingVsFixation               \
    -fout -tout -x1D X_stimOnly.xmat.1D -xjpeg X_stim.jpg                              \
    -x1D_uncensored X_stimOnly.nocensor.xmat.1D                                        \
    -fitts fitts_stimOnly.$subj+tlrc                                                   \
    -errts errts_stimOnly.${subj}+tlrc                                                 \
    -bucket stats_stimOnly.$subj                                                       \
    -jobs 32 \
    -overwrite

echo 'Done!'