#!/bin/tcsh -xef
# 02_PreprocessForMeica
#
# USAGE:
#   tcsh -xef 02_PreprocessForMeica_phantom.tcsh $subj $run $outFolder 2>&1 | tee output.02_PreprocessForMeica
#
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#	  - run is a 3-digit string indicating the scan's scan number.
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- Many, many files.
#
# Created 11/16/15 by afni_proc.py
# Updated 11/17/15 by DJ - adapted to Multi-echo data.
# Updated 11/18/15 by DJ - debugged, switched meica_report's motion input to tlrc space
# Updated 11/20/15 by DJ - separated afni_proc output into 3 scripts: pre-meica, MEICA swarm, and post-meica. That way all 3 can be submitted to Biowulf with the proper dependencies.
# Updated 12/7/15 by DJ - make anat-derived masks for meica input instead of using automasks
# Updated 12/8/15 by DJ - mask data before input to MEICA
# Updated 12/9/15 by DJ - fixed ${runs[0]} bug
# Updated 9/15/16 by DJ - switched to MNI_caez_27 atlas, used real 5th volume in meica scaling step, added 3dAxialize
# Updated 9/22/16 by DJ - added -pad_base option to auto_tlrc command for all subjects (MNI atlas is closer to volume edges than TT was), moved mask section to after MEICA (to take advantage of optimal combination across echoes).

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
    set run = $argv[2]
else
    set run = 2
endif
if ( $#argv > 2 ) then
    set outFolder = $argv[3]
else
    set outFolder = AfniProc_MultiEcho
endif
if ( $#argv > 3 ) then
    set echoTimes = $argv[4]
else
    set echoTimes = "1,2,3,4"
endif

# assign base directory
set PRJDIR = /data/jangrawdc/PRJ11_Music

# assign output directory name
set output_dir = ${PRJDIR}/Results/${subj}/${outFolder}
set script_dir = ${PRJDIR}/Scripts/
# Move to data directory
cd ${PRJDIR}/PrcsData/${subj}/D00_OriginalData

# # find nRuns automatically if it was not given as input
# if ( $nRuns == 0 ) then
#     set nRuns = (`ls ${subj}_Run*_e2+orig.HEAD | wc -w`)
# endif

# set list of runs and echoes
# set runs = (`count -digits 2 1 ${nRuns}`)
set runs = ($run)
set inputFiles = `ls ${subj}_scan${run}_*.HEAD`
set nEchoes = $#inputFiles
set echoes = (`count -digits 1 1 $nEchoes`) # MULTIECHO
# set iRegEcho = 2 # MULTIECHO


# verify that the results directory does not yet exist
if ( -d $output_dir ) then
    echo "=== output dir $subj.results already exists. Continue?"
    echo -n "(Y/N)-->"
    # rm -rf $output_dir
    set answer = $<
    if ( $answer != 'Y') then
      exit
    endif
endif


# create results and stimuli directories
mkdir -p $output_dir

# # copy anatomy to results dir
# 3dcopy                                                                                             \
#     ${PRJDIR}/PrcsData/${subj}/D01_Anatomical/${subj}_Anat_bc_ns \
#     $output_dir/${subj}_Anat_bc_ns

# # copy over the external volreg base
# 3dbucket -prefix $output_dir/external_volreg_base \
# 	"${subj}_Run01_e2+orig[0]+orig[0]" # DJ switched to double-quotes to make $subj work

# ============================ auto block: tcat ============================
# apply 3dTcat to copy input dsets to results dir, while
# removing the first 3 TRs
foreach run ( $runs )
  foreach iEcho ( $echoes )
    echo ${inputFiles[$iEcho]:r}
  	3dTcat -prefix $output_dir/pb00.$subj.r${run}_e${iEcho}.tcat ${inputFiles[$iEcho]:r}'[3..$]'
  end
end

# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $output_dir


# ========================== auto block: outcount ==========================
# data check: compute outlier fraction for each volume
touch out.pre_ss_warn.txt
foreach run ( $runs )
	foreach iEcho ( $echoes ) # MULTIECHO
	    3dToutcount -automask -fraction -polort 4 -legendre                     \
	                pb00.$subj.r${run}_e${iEcho}.tcat+orig > outcount.r${run}_e${iEcho}.1D # MULTIECHO

	    # censor outlier TRs per run, ignoring the first 0 TRs
	    # - censor when more than 0.1 of automask voxels are outliers
	    # - step() defines which TRs to remove via censoring
	    1deval -a outcount.r${run}_e${iEcho}.1D -expr "1-step(a-0.1)" > rm.out.cen.r${run}_e${iEcho}.1D

	    # outliers at TR 0 might suggest pre-steady state TRs
	    if ( `1deval -a outcount.r${run}_e${iEcho}.1D"{0}" -expr "step(a-0.4)"` ) then
	        echo "** TR #0 outliers: possible pre-steady state TRs in run $run" \
	            >> out.pre_ss_warn.txt
	    endif
	end

	# MULTIECHO: Combine across echoes outlier count (max) censor file (if any echo is censored, censor them all)
  if ( $nEchoes == 1 ) then
    1deval -a rm.out.cen.r${run}_e1.1D -expr "step( a )" > rm.out.cen.r${run}.max.1D
    1deval -a outcount.r${run}_e1.1D -expr "a" > rm.outcount.r${run}.allechoes.1D
  else if ( $nEchoes == 2 ) then
  	1deval -a rm.out.cen.r${run}_e1.1D -b rm.out.cen.r${run}_e2.1D -expr "step( a*b )" > rm.out.cen.r${run}.max.1D
  	1dcat outcount.r${run}_e1.1D outcount.r${run}_e2.1D > rm.outcount.r${run}.allechoes.1D
  else if ( $nEchoes == 3 ) then
  	1deval -a rm.out.cen.r${run}_e1.1D -b rm.out.cen.r${run}_e2.1D -c rm.out.cen.r${run}_e3.1D -expr "step( a*b*c )" > rm.out.cen.r${run}.max.1D
  	1dcat outcount.r${run}_e1.1D outcount.r${run}_e2.1D outcount.r${run}_e3.1D > rm.outcount.r${run}.allechoes.1D
  else if ( $nEchoes == 4 ) then
    	1deval -a rm.out.cen.r${run}_e1.1D -b rm.out.cen.r${run}_e2.1D -c rm.out.cen.r${run}_e3.1D -d rm.out.cen.r${run}_e4.1D -expr "step( a*b*c*d )" > rm.out.cen.r${run}.max.1D
    	1dcat outcount.r${run}_e1.1D outcount.r${run}_e2.1D outcount.r${run}_e3.1D outcount.r${run}_e4.1D > rm.outcount.r${run}.allechoes.1D
  endif
	3dTstat -prefix stdout: -max rm.outcount.r${run}.allechoes.1D > outcount.r${run}.max.1D
	# # MULTIECHO: check if censoring disagrees across echoes, then alert the user.
	# echo "Checking if the 3 echoes' censoring files disagree..."
	# 1deval -a rm.out.cen.r${run}_e1.1D -b rm.out.cen.r${run}_e2.1D -c rm.out.cen.r${run}_e3.1D -expr "step( (a-b)*(a-b) + (a-c)*(a-c) )" > rm.out.cen.r${run}.diff.1D
	# set nDiff = `3dTstat -sum -prefix stdout: rm.out.cen.r${run}.diff.1D\' `
	# if ( $nDiff == 0 ) then
	# 	echo "They agree."
	# else
	# 	echo "WARNING: $nDiff censoring points disagree across the 3 echoes... If any echo is censored, they will all be censored."
	# endif
end

# catenate outlier counts into a single time series
cat outcount.r*.max.1D > outcount_rall.1D # use the max across echoes

# catenate outlier censor files into a single time series
cat rm.out.cen.r*.max.1D > outcount_${subj}_censor.1D # use the one combined across echoes

# ================================ despike =================================
# apply 3dDespike to each run
foreach run ( $runs )
	foreach iEcho ( $echoes )
	    3dDespike -NEW -nomask -prefix pb01.$subj.r${run}_e${iEcho}.despike \
	        pb00.$subj.r${run}_e${iEcho}.tcat+orig
	end
end

# ================================= tshift =================================
# time shift data so all slice timing is the same
foreach run ( $runs )
	foreach iEcho ( $echoes )
	    3dTshift -tzero 0 -quintic -prefix pb02.$subj.r${run}_e${iEcho}.tshift \
	             pb01.$subj.r${run}_e${iEcho}.despike+orig
	end
end

# ================================= align ==================================
# SKIP
# ================================== tlrc ==================================
# SKIP
# ================================= volreg =================================
# SKIP
# # ================================== mask ==================================
# create 'full_mask' dataset (union mask)
foreach run ( $runs )
  set iEcho = 1
    3dAutomask -dilate 1 -prefix rm.mask_r${run}_e${iEcho} pb02.${subj}.r${run}_e${iEcho}.tshift+orig
end

# create union of inputs, output type is byte
3dmask_tool -inputs rm.mask_r*+orig.HEAD -union -prefix full_mask.${subj}

# ================================ optcom =================================
# concatenate echoes in z direction

if ( $nEchoes == 1 ) then
  3dZcat -prefix rm.${subj}.r${run}.zcat.nii pb02.${subj}.r${run}_e1.tshift+orig
else if ( $nEchoes == 2 ) then
  3dZcat -prefix rm.${subj}.r${run}.zcat.nii pb02.${subj}.r${run}_e1.tshift+orig pb02.${subj}.r${run}_e2.tshift+orig
else if ( $nEchoes == 3 ) then
  3dZcat -prefix rm.${subj}.r${run}.zcat.nii pb02.${subj}.r${run}_e1.tshift+orig pb02.${subj}.r${run}_e2.tshift+orig pb02.${subj}.r${run}_e3.tshift+orig
else if ( $nEchoes == 4 ) then
    3dZcat -prefix rm.${subj}.r${run}.zcat.nii pb02.${subj}.r${run}_e1.tshift+orig pb02.${subj}.r${run}_e2.tshift+orig pb02.${subj}.r${run}_e3.tshift+orig  pb02.${subj}.r${run}_e4.tshift+orig
endif

echo $echoTimes > EchoTimes.1D
3dAFNItoNIFTI -prefix full_mask.${subj} full_mask.${subj}+orig

# get T2* estimate
python $script_dir/me_get_staticT2star.py --tes_file EchoTimes.1D -d rm.${subj}.r${run}.zcat.nii --prefix rm.${subj}.r${run}.t2s --mask full_mask.${subj}.nii

# optimally combine
python $script_dir/me_get_OCtimeseries.py --tes_file EchoTimes.1D -d rm.${subj}.r${run}.zcat.nii --prefix pb03.${subj}.r${run}.optcom --mask full_mask.${subj}.nii --t2s rm.${subj}.r${run}.t2s.sTE.t2s.nii

# ================================ meica =================================
# SKIP
# ================================ scale =================================
# scale each voxel time series to have a mean of 100
# (be sure no negatives creep in)
# (subject to a range of [0,200])

foreach run ( $runs )
    # Extract mean brick for this run
    3dTstat -overwrite -prefix rm.mean.r${run} pb03.${subj}.r${run}.optcom.OCTS.nii
    # Scale
    3dcalc -a pb03.${subj}.r${run}.optcom.OCTS.nii -b rm.mean.r${run}+orig \
        -expr 'min(200, a/b*100) *step(a)*step(b)' \
            -overwrite -prefix pb04.${subj}.r${run}.scale
end


# ================================ regress =================================
# combine multiple censor files
# 1deval -a motion_${subj}_censor.1D -b outcount_${subj}_censor.1D              \
#        -expr "a*b" > censor_${subj}_combined_2.1D
1deval -a outcount_${subj}_censor.1D              \
       -expr "a" > censor_${subj}_combined_2.1D

# note TRs that were not censored
set ktrs = `1d_tool.py -infile censor_${subj}_combined_2.1D                   \
                       -show_trs_uncensored encoded`

3dDeconvolve -input pb04.${subj}.r*.scale+orig.HEAD                 \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 4                                                                 \
    -num_stimts 0                                                             \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                                   \
    -x1D_uncensored X.nocensor.xmat.1D                                        \
    -x1D_stop                                                                 \
    -errts errts.$subj                                                        \
    -bucket stats.$subj                                                       \
    -cbucket cbucket.$subj                                                    \
    -overwrite

# -- use 3dTproject to project out regression matrix WITHOUT STIM REGRESSORS --
3dTproject -polort 0 -input pb04.${subj}.r*.scale+orig.HEAD          \
           -censor censor_${subj}_combined_2.1D -cenmode ZERO                 \
           -ort X.nocensor.xmat.1D -overwrite -prefix errts.${subj}.tproject

# create an all_runs dataset to match the fitts, errts, etc.
# 3dTcat -overwrite -prefix all_runs.$subj pb03.$subj.r*.scale+tlrc.HEAD
3dTcat -overwrite -prefix all_runs.${subj} pb04.$subj.r*.scale+orig.HEAD


# ================================ cleanup =================================

# --------------------------------------------------
# create a temporal signal to noise ratio dataset
#    signal: if 'scale' block, mean should be 100
#    noise : compute standard deviation of errts
3dTstat -mean -prefix rm.signal all_runs.${subj}+orig"[$ktrs]"
3dTstat -stdev -prefix rm.noise errts.${subj}.tproject+orig"[$ktrs]"
3dcalc -a rm.signal+orig                                           \
       -b rm.noise+orig                                            \
       -c full_mask.$subj+orig                                               \
       -expr 'c*a/b' -overwrite -prefix TSNR.$subj

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
