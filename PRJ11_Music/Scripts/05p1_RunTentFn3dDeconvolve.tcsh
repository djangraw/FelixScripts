
#!/bin/tcsh -xef

# TENT(b,c,n)' = n parameter tent function expansion from times b..c after stimulus time [piecewise linear] [n must be at least 2; time step is (c-b)/(n-1)]
set subj = SBJ03_task

cd /data/jangrawdc/PRJ11_Music/Results/${subj}/AfniProc_MultiEcho

if ( $subj == SBJ03_task ) then
3dDeconvolve -input pb06.${subj}.r*.scale+tlrc.HEAD                               \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -global_times                                                             \
    -num_stimts 99                                                            \
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
    -stim_file 37 mot_demean.r07.1D'[0]' -stim_base 37 -stim_label 37 roll_07 \
    -stim_file 38 mot_demean.r07.1D'[1]' -stim_base 38 -stim_label 38 pitch_07 \
    -stim_file 39 mot_demean.r07.1D'[2]' -stim_base 39 -stim_label 39 yaw_07  \
    -stim_file 40 mot_demean.r07.1D'[3]' -stim_base 40 -stim_label 40 dS_07   \
    -stim_file 41 mot_demean.r07.1D'[4]' -stim_base 41 -stim_label 41 dL_07   \
    -stim_file 42 mot_demean.r07.1D'[5]' -stim_base 42 -stim_label 42 dP_07   \
    -stim_file 43 mot_demean.r08.1D'[0]' -stim_base 43 -stim_label 43 roll_08 \
    -stim_file 44 mot_demean.r08.1D'[1]' -stim_base 44 -stim_label 44 pitch_08 \
    -stim_file 45 mot_demean.r08.1D'[2]' -stim_base 45 -stim_label 45 yaw_08  \
    -stim_file 46 mot_demean.r08.1D'[3]' -stim_base 46 -stim_label 46 dS_08   \
    -stim_file 47 mot_demean.r08.1D'[4]' -stim_base 47 -stim_label 47 dL_08   \
    -stim_file 48 mot_demean.r08.1D'[5]' -stim_base 48 -stim_label 48 dP_08   \
    -stim_file 49 mot_deriv.r01.1D'[0]' -stim_base 49 -stim_label 49 roll_09  \
    -stim_file 50 mot_deriv.r01.1D'[1]' -stim_base 50 -stim_label 50 pitch_09 \
    -stim_file 51 mot_deriv.r01.1D'[2]' -stim_base 51 -stim_label 51 yaw_09   \
    -stim_file 52 mot_deriv.r01.1D'[3]' -stim_base 52 -stim_label 52 dS_09    \
    -stim_file 53 mot_deriv.r01.1D'[4]' -stim_base 53 -stim_label 53 dL_09    \
    -stim_file 54 mot_deriv.r01.1D'[5]' -stim_base 54 -stim_label 54 dP_09    \
    -stim_file 55 mot_deriv.r02.1D'[0]' -stim_base 55 -stim_label 55 roll_10  \
    -stim_file 56 mot_deriv.r02.1D'[1]' -stim_base 56 -stim_label 56 pitch_10 \
    -stim_file 57 mot_deriv.r02.1D'[2]' -stim_base 57 -stim_label 57 yaw_10   \
    -stim_file 58 mot_deriv.r02.1D'[3]' -stim_base 58 -stim_label 58 dS_10    \
    -stim_file 59 mot_deriv.r02.1D'[4]' -stim_base 59 -stim_label 59 dL_10    \
    -stim_file 60 mot_deriv.r02.1D'[5]' -stim_base 60 -stim_label 60 dP_10    \
    -stim_file 61 mot_deriv.r03.1D'[0]' -stim_base 61 -stim_label 61 roll_11  \
    -stim_file 62 mot_deriv.r03.1D'[1]' -stim_base 62 -stim_label 62 pitch_11 \
    -stim_file 63 mot_deriv.r03.1D'[2]' -stim_base 63 -stim_label 63 yaw_11   \
    -stim_file 64 mot_deriv.r03.1D'[3]' -stim_base 64 -stim_label 64 dS_11    \
    -stim_file 65 mot_deriv.r03.1D'[4]' -stim_base 65 -stim_label 65 dL_11    \
    -stim_file 66 mot_deriv.r03.1D'[5]' -stim_base 66 -stim_label 66 dP_11    \
    -stim_file 67 mot_deriv.r04.1D'[0]' -stim_base 67 -stim_label 67 roll_12  \
    -stim_file 68 mot_deriv.r04.1D'[1]' -stim_base 68 -stim_label 68 pitch_12 \
    -stim_file 69 mot_deriv.r04.1D'[2]' -stim_base 69 -stim_label 69 yaw_12   \
    -stim_file 70 mot_deriv.r04.1D'[3]' -stim_base 70 -stim_label 70 dS_12    \
    -stim_file 71 mot_deriv.r04.1D'[4]' -stim_base 71 -stim_label 71 dL_12    \
    -stim_file 72 mot_deriv.r04.1D'[5]' -stim_base 72 -stim_label 72 dP_12    \
    -stim_file 73 mot_deriv.r05.1D'[0]' -stim_base 73 -stim_label 73 roll_13  \
    -stim_file 74 mot_deriv.r05.1D'[1]' -stim_base 74 -stim_label 74 pitch_13 \
    -stim_file 75 mot_deriv.r05.1D'[2]' -stim_base 75 -stim_label 75 yaw_13   \
    -stim_file 76 mot_deriv.r05.1D'[3]' -stim_base 76 -stim_label 76 dS_13    \
    -stim_file 77 mot_deriv.r05.1D'[4]' -stim_base 77 -stim_label 77 dL_13    \
    -stim_file 78 mot_deriv.r05.1D'[5]' -stim_base 78 -stim_label 78 dP_13    \
    -stim_file 79 mot_deriv.r06.1D'[0]' -stim_base 79 -stim_label 79 roll_14  \
    -stim_file 80 mot_deriv.r06.1D'[1]' -stim_base 80 -stim_label 80 pitch_14 \
    -stim_file 81 mot_deriv.r06.1D'[2]' -stim_base 81 -stim_label 81 yaw_14   \
    -stim_file 82 mot_deriv.r06.1D'[3]' -stim_base 82 -stim_label 82 dS_14    \
    -stim_file 83 mot_deriv.r06.1D'[4]' -stim_base 83 -stim_label 83 dL_14    \
    -stim_file 84 mot_deriv.r06.1D'[5]' -stim_base 84 -stim_label 84 dP_14    \
    -stim_file 85 mot_deriv.r07.1D'[0]' -stim_base 85 -stim_label 85 roll_15  \
    -stim_file 86 mot_deriv.r07.1D'[1]' -stim_base 86 -stim_label 86 pitch_15 \
    -stim_file 87 mot_deriv.r07.1D'[2]' -stim_base 87 -stim_label 87 yaw_15   \
    -stim_file 88 mot_deriv.r07.1D'[3]' -stim_base 88 -stim_label 88 dS_15    \
    -stim_file 89 mot_deriv.r07.1D'[4]' -stim_base 89 -stim_label 89 dL_15    \
    -stim_file 90 mot_deriv.r07.1D'[5]' -stim_base 90 -stim_label 90 dP_15    \
    -stim_file 91 mot_deriv.r08.1D'[0]' -stim_base 91 -stim_label 91 roll_16  \
    -stim_file 92 mot_deriv.r08.1D'[1]' -stim_base 92 -stim_label 92 pitch_16 \
    -stim_file 93 mot_deriv.r08.1D'[2]' -stim_base 93 -stim_label 93 yaw_16   \
    -stim_file 94 mot_deriv.r08.1D'[3]' -stim_base 94 -stim_label 94 dS_16    \
    -stim_file 95 mot_deriv.r08.1D'[4]' -stim_base 95 -stim_label 95 dL_16    \
    -stim_file 96 mot_deriv.r08.1D'[5]' -stim_base 96 -stim_label 96 dP_16    \
    -stim_times 97 ../stimuli/${subj}_Sing_start.1D 'TENT(0,52,27)' -stim_label 97 sing \
    -stim_times 98 ../stimuli/${subj}_Speak_start.1D 'TENT(0,52,27)' -stim_label 98 speak \
    -stim_times 99 ../stimuli/${subj}_Imagine_start.1D 'TENT(0,52,27)' -stim_label 99 imagine \
    -fout -tout -x1D X_tent.xmat.1D -xjpeg X_tent.jpg                                   \
    -x1D_uncensored X_tent.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts_tent.$subj                                                        \
    -bucket stats_tent.$subj                                                       \
    -cbucket cbucket_tent.$subj                                                    \
    -jobs 32 \
    -overwrite

endif

# display any large pariwise correlations from the X-matrix
1d_tool.py -show_cormat_warnings -infile X_tent.xmat.1D |& tee out.cormat_warn_tent.txt

# -- execute the 3dREMLfit script, written by 3dDeconvolve --
# Rename and Run 3dREMLfit
mv stats_tent.REML_cmd stats_tent.$subj.REML_cmd
tcsh -x stats_tent.$subj.REML_cmd

# if 3dREMLfit fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dREMLfit error, failing...'
    exit
endif
