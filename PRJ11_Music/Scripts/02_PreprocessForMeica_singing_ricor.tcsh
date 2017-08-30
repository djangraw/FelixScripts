#!/bin/tcsh -xef
# 02_PreprocessForMeica_singing
#
# USAGE:
#   tcsh -xef 02_PreprocessForMeica_singing $subj $nRuns $echoTimes $outFolder 2>&1 | tee output.02_PreprocessForMeica.$subj.$outFolder
#
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#	  - nRuns is a scalar indicating how many runs are included (e.g., 4)
#   - echoTimes is a string with 3 comma-separated values for the echo times in ms
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
# Updated 4/20/17 by DJ - adapted for singing study, renamed _singing
# Updated 4/27/17 by DJ - added retroicor block, renamed _ricor
# Updated 4/30/17 by DJ - fixed tlrc bug

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
    set subj = SBJ03_task
endif
if ( $#argv > 1 ) then
    set nRuns = $argv[2]
else
    set nRuns = 0
endif
if ( $#argv > 2 ) then
    set echoTimes = $argv[3]
else
    set echoTimes = "11.0,23.96,36.92"
endif
if ( $#argv > 3 ) then
    set outFolder = $argv[4]
else
    set outFolder = AfniProc_MultiEcho
endif


# assign base directory
set PRJDIR = /data/jangrawdc/PRJ11_Music

# assign output directory name
set output_dir = ${PRJDIR}/Results/${subj}/${outFolder}

# Move to data directory
cd ${PRJDIR}/PrcsData/${subj}/D00_OriginalData

# find nRuns automatically if it was not given as input
if ( $nRuns == 0 ) then
    set nRuns = (`ls ${subj}_Run*_e2+orig.HEAD | wc -w`)
endif

# set list of runs
set runs = (`count -digits 2 1 ${nRuns}`)
set echoes = (`count -digits 1 1 3`) # MULTIECHO
set iRegEcho = 2 # MULTIECHO

set outCountLimit = 0.15 #0.1 # fraction of voxels that can be outliers before censoring a TR (default 0.1)

# verify that the results directory does not yet exist
if ( -d $output_dir ) then
    echo output dir "$subj.results" already exists
    # rm -rf $output_dir
    # exit
endif


# create results and stimuli directories
mkdir -p $output_dir
mkdir -p $output_dir/stimuli

# === NEW 4/27/17 by DJ === #
# copy slice-based regressors for RETROICOR (rm first 3 TRs)
foreach run ( $runs )
  1dcat                                                                                                             \
      /data/jangrawdc/PRJ11_Music/PrcsData/${subj}/D02_Behavior/physio.${subj}.r${run}_retrots.slibase.1D'{3..$}' \
      > $output_dir/stimuli/ricor_orig_r${run}.1D
end
# copy Anat2MNI transform
# cp ${PRJDIR}/PrcsData/${subj}/D01_Anatomical/${subj}_Anat2MNI.Xaff12.1D ${output_dir}/${subj}_Anat2MNI.Xaff12.1D

# === END 4/27/17 by DJ === #

# copy anatomy to results dir
3dcopy                                                                                             \
    ${PRJDIR}/PrcsData/${subj}/D01_Anatomical/${subj}_Anat_bc_ns \
    $output_dir/${subj}_Anat_bc_ns

# copy over the external volreg base
3dbucket -prefix $output_dir/external_volreg_base \
	"${subj}_Run01_e${iRegEcho}+orig[0]+orig[0]" # DJ switched to double-quotes to make $subj work

# ============================ auto block: tcat ============================
# apply 3dTcat to copy input dsets to results dir, while
# removing the first 3 TRs
foreach run ( $runs )
	foreach iEcho ( $echoes )
    if ( ($subj == "SBJ03_task") && ($run == "01") ) then
      3dTcat -prefix $output_dir/pb00.$subj.r${run}_e${iEcho}.tcat ${subj}_Run${run}_e${iEcho}+orig'[3..156]'
    else
      3dTcat -prefix $output_dir/pb00.$subj.r${run}_e${iEcho}.tcat ${subj}_Run${run}_e${iEcho}+orig'[3..$]'
    endif
  end
end

# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $output_dir
# make note of repetitions (TRs) per run
# set tr_counts = ( 237 237 237 237 )
set nTRs = `3dinfo -nv pb00.$subj.r${runs[1]}_e${echoes[1]}.tcat`
set tr_counts = (`yes $nTRs | head -n $nRuns`)

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
	    1deval -a outcount.r${run}_e${iEcho}.1D -expr "1-step(a-$outCountLimit)" > rm.out.cen.r${run}_e${iEcho}.1D

	    # outliers at TR 0 might suggest pre-steady state TRs
	    if ( `1deval -a outcount.r${run}_e${iEcho}.1D"{0}" -expr "step(a-0.4)"` ) then
	        echo "** TR #0 outliers: possible pre-steady state TRs in run $run" \
	            >> out.pre_ss_warn.txt
	    endif
	end

	# MULTIECHO: Combine across echoes outlier count (max) censor file (if any echo is censored, censor them all)
	1deval -a rm.out.cen.r${run}_e1.1D -b rm.out.cen.r${run}_e2.1D -c rm.out.cen.r${run}_e3.1D -expr "step( a*b*c )" > rm.out.cen.r${run}.max.1D
	1dcat outcount.r${run}_e1.1D outcount.r${run}_e2.1D outcount.r${run}_e3.1D > rm.outcount.r${run}.allechoes.1D
	3dTstat -prefix stdout: -max rm.outcount.r${run}.allechoes.1D > outcount.r${run}.max.1D
	# MULTIECHO: check if censoring disagrees across echoes, then alert the user.
	echo "Checking if the 3 echoes' censoring files disagree..."
	1deval -a rm.out.cen.r${run}_e1.1D -b rm.out.cen.r${run}_e2.1D -c rm.out.cen.r${run}_e3.1D -expr "step( (a-b)*(a-b) + (a-c)*(a-c) )" > rm.out.cen.r${run}.diff.1D
	set nDiff = `3dTstat -sum -prefix stdout: rm.out.cen.r${run}.diff.1D\' `
	if ( $nDiff == 0 ) then
		echo "They agree."
	else
		echo "WARNING: $nDiff censoring points disagree across the 3 echoes... If any echo is censored, they will all be censored."
	endif
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

# === NEW 4/27/17 by DJ === #
# ================================= ricor ==================================
# RETROICOR - remove cardiac and respiratory signals
#           - across runs: catenate regressors across runs
if ($subj == "SBJ03_task") then
  set nBetas = 47
  set ricor_polort = 5
elseif ($subj == "SBJ03_wholesong") then
  set nBetas = 5
  set ricor_polort = 4
else
  set nBetas = 5
  set ricor_polort = 2
endif

foreach run ( $runs )
    # detrend regressors (make orthogonal to poly baseline)
    3dDetrend -polort $ricor_polort -prefix rm.ricor.$run.1D              \
              stimuli/ricor_orig_r$run.1D\'

    1dtranspose rm.ricor.$run.1D rm.ricor_det_r$run.1D
end

# put ricor regressors into a single file for each regression

# ... catenate all runs for current 'ricor' block
cat rm.ricor_det_r[0-9]*.1D > stimuli/ricor_det_rall.1D

# ... extract slice 0, for future 'regress' block
1dcat stimuli/ricor_det_rall.1D'[0..12]' > stimuli/ricor_s0_rall.1D

foreach iEcho ( $echoes )
  # create (polort) X-matrix to apply in 3dREMLfit
  3dDeconvolve -polort $ricor_polort -input pb01.$subj.r*_e${iEcho}.despike+orig.HEAD \
      -x1D_stop -x1D pb02.ricor_e${iEcho}.xmat.1D


  # 3dREMLfit does not currently catenate a dataset list
  set dsets = ( pb01.$subj.r*_e${iEcho}.despike+orig.HEAD )

  # regress out the detrended RETROICOR regressors
  # (matrix from 3dD does not have slibase regressors)
  3dREMLfit -input "$dsets"                                     \
      -matrix pb02.ricor_e${iEcho}.xmat.1D                                \
      -Obeta pb02.ricor_e${iEcho}.betas                                   \
      -Oerrts pb02.ricor_e${iEcho}.errts                                  \
      -slibase_sm stimuli/ricor_det_rall.1D

  # re-create polynomial baseline
  3dSynthesize -matrix pb02.ricor_e${iEcho}.xmat.1D                       \
      -cbucket pb02.ricor_e${iEcho}.betas+orig"[0..$nBetas]"                   \
      -select polort -prefix pb02.ricor_e${iEcho}.polort

  # final result: add REML errts to polynomial baseline
  # (and separate back into individual runs)
  set startind = 0
  foreach rind ( `count -digits 1 1 $#runs` )
      set run = $runs[$rind]
      set runlen = $tr_counts[$rind]
      @ endind = $startind + $runlen - 1

      3dcalc -a pb02.ricor_e${iEcho}.errts+orig"[$startind..$endind]"     \
             -b pb02.ricor_e${iEcho}.polort+orig"[$startind..$endind]"    \
             -datum short -nscale                               \
             -expr a+b -prefix pb02.$subj.r${run}_e${iEcho}.ricor
      @ startind = $endind + 1
  end

end
# === END 4/27/17 by DJ === #

# ================================= tshift =================================
# time shift data so all slice timing is the same
foreach run ( $runs )
	foreach iEcho ( $echoes )
	    3dTshift -tzero 0 -quintic -prefix pb02p1.$subj.r${run}_e${iEcho}.tshift \
	             pb02.$subj.r${run}_e${iEcho}.ricor+orig
	end
end

# ================================= align ==================================
# a2e: align anatomy to EPI registration base
# (new anat will be aligned and stripped, ${subj}_Anat_bc_ns_al_keep+orig)
align_epi_anat.py -anat2epi -anat ${subj}_Anat_bc_ns+orig \
       -suffix _al_keep                                 \
       -epi external_volreg_base+orig -epi_base 0       \
       -epi_strip 3dAutomask                            \
       -anat_has_skull no                               \
       -giant_move                                      \
       -volreg off -tshift off

# ================================== tlrc ==================================
# warp anatomy to standard space

# zero-pad EPI dataset
3dZeropad -S 10 -I 50 -prefix rm.${subj}_Anat_bc_ns_al_keep_padded -overwrite ${subj}_Anat_bc_ns_al_keep+orig
# convert matrix
cat_matvec ${subj}_Anat_bc_ns_al_keep_mat.aff12.1D > rm.${subj}_Anat_bc_ns_al_keep_mat_3x4.aff12.1D
# warp anatomy to epi with no clipping
3dWarp -matvec_out2in rm.${subj}_Anat_bc_ns_al_keep_mat_3x4.aff12.1D -gridset rm.${subj}_Anat_bc_ns_al_keep_padded+orig -prefix ${subj}_Anat_bc_ns_al_full -overwrite ${subj}_Anat_bc_ns+orig

#     echo "Using option -pad_base 60 for @auto_tlrc ($subj requires large rotation)."
# @auto_tlrc -base MNI_caez_N27+tlrc -input ${subj}_Anat_bc_ns_al_keep+orig -no_ss -pad_base 60
@auto_tlrc -base MNI_caez_N27+tlrc -input ${subj}_Anat_bc_ns_al_full+orig -no_ss -pad_base 60
@auto_tlrc -apar ${subj}_Anat_bc_ns_al_full+tlrc -input ${subj}_Anat_bc_ns_al_keep+orig

# ================================= volreg =================================
# align each dset to base volume, warp to tlrc space

# verify that we have a +tlrc warp dataset
if ( ! -f ${subj}_Anat_bc_ns_al_keep+tlrc.HEAD ) then
    echo "** missing +tlrc warp dataset: ${subj}_Anat_bc_ns_al_keep+tlrc.HEAD"
    exit
endif

# register and warp
foreach run ( $runs )
    # register each volume to the base
    3dvolreg -verbose -zpad 1 -base external_volreg_base+orig   \
             -1Dfile dfile.r$run.1D -prefix rm.epi.volreg.r$run \
             -cubic                                             \
             -1Dmatrix_save mat.r$run.vr.aff12.1D               \
             pb02p1.$subj.r${run}_e${iRegEcho}.tshift+orig

    # create an all-1 dataset to mask the extents of the warp
    3dcalc -overwrite -a pb02p1.$subj.r${run}_e${iRegEcho}.tshift+orig -expr 1   \
           -prefix rm.epi.all1

    # catenate volreg and tlrc transformations
    cat_matvec -ONELINE                                         \
               ${subj}_Anat_bc_ns_al_full+tlrc::WARP_DATA -I      \
               mat.r$run.vr.aff12.1D > mat.r$run.warp.aff12.1D
    # cat_matvec -ONELINE                                         \
    #             ${subj}_Anat2MNI.Xaff12.1D ${subj}_Anat_bc_ns_al_keep_e2a_only_mat.aff12.1D \
    #             mat.r$run.vr.aff12.1D > mat.r$run.warp.aff12.1D

	# MULTIECHO: MOVED THESE UP
    # warp the all-1 dataset for extents masking
    3dAllineate -base ${subj}_Anat_bc_ns_al_keep+tlrc             \
                -input rm.epi.all1+orig                         \
                -1Dmatrix_apply mat.r$run.warp.aff12.1D         \
                -mast_dxyz 3 -final NN -quiet                   \
                -prefix rm.epi.1.r$run

    # make an extents intersection mask of this run
    3dTstat -min -prefix rm.epi.min.r$run rm.epi.1.r$run+tlrc

	# MULTIECHO: APPLY MATRIX FROM REGECHO TO EACH ECHO
	foreach iEcho ( $echoes )
	    # apply catenated xform : volreg and tlrc
	    3dAllineate -base ${subj}_Anat_bc_ns_al_keep+tlrc             \
	                -input pb02p1.$subj.r${run}_e${iEcho}.tshift+orig             \
	                -1Dmatrix_apply mat.r$run.warp.aff12.1D         \
	                -mast_dxyz 3                                    \
	                -prefix rm.epi.nomask.r${run}_e${iEcho}
	end

    # if there was an error, exit so user can see
    if ( $status ) exit
end

# make a single file of registration params
cat dfile.r*.1D > dfile_rall.1D

# ----------------------------------------
# create the extents mask: mask_epi_extents+tlrc
# (this is a mask of voxels that have valid data at every TR)
3dMean -datum short -prefix rm.epi.mean rm.epi.min.r*.HEAD
3dcalc -a rm.epi.mean+tlrc -expr 'step(a-0.999)' -prefix mask_epi_extents

# and apply the extents mask to the EPI data
# (delete any time series with missing data)
foreach run ( $runs )
	foreach iEcho ( $echoes )
	    3dcalc -a rm.epi.nomask.r${run}_e${iEcho}+tlrc -b mask_epi_extents+tlrc \
	           -expr 'a*b' -prefix pb03.$subj.r${run}_e${iEcho}.volreg
	end
end

# create an anat_final dataset, aligned with stats
3dcopy ${subj}_Anat_bc_ns_al_keep+tlrc anat_final.$subj

# # ================================== mask ==================================
# # create 'full_mask' dataset (union mask)
# foreach run ( $runs )
#     foreach iEcho ( $echoes )
#         3dAutomask -dilate 1 -prefix rm.mask_r${run}_e${iEcho} pb03.$subj.r${run}_e${iEcho}.volreg+tlrc
#     end
# end
#
# # create union of inputs, output type is byte
# 3dmask_tool -inputs rm.mask_r*+tlrc.HEAD -union -prefix full_mask_allechoes.$subj # union across all echoes
# 3dmask_tool -inputs rm.mask_r*_e${iRegEcho}+tlrc.HEAD -union -prefix full_mask.$subj # version for just echo2
#
# # ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
# #      (resampled from tlrc anat)
# 3dresample -master full_mask.$subj+tlrc -input ${subj}_Anat_bc_ns_al_keep+tlrc \
#            -prefix rm.resam.anat
#
# # convert to binary anat mask; fill gaps and holes
# 3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc         \
#             -prefix mask_anat.$subj
#
# # compute overlaps between anat and EPI masks
# 3dABoverlap -no_automask full_mask.$subj+tlrc mask_anat.$subj+tlrc           \
#             |& tee out.mask_ae_overlap.txt
#
# # note correlation as well
# 3ddot full_mask.$subj+tlrc mask_anat.$subj+tlrc |& tee out.mask_ae_corr.txt
#
# # ---- create group anatomy mask, mask_group+tlrc ----
# #      (resampled from tlrc base anat, MNI_caez_N27+tlrc)
# 3dresample -master full_mask.$subj+tlrc -prefix ./rm.resam.group             \
#            -input /data/jangrawdc/abin/MNI_caez_N27+tlrc
#
# # convert to binary group mask; fill gaps and holes
# 3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.group+tlrc        \
#             -prefix mask_group
#
# # ---- segment anatomy into classes CSF/GM/WM ----
# 3dSeg -anat anat_final.$subj+tlrc -mask AUTO -classes 'CSF ; GM ; WM'
#
# # copy resulting Classes dataset to current directory
# 3dcopy Segsy/Classes+tlrc .


# ================================ meica =================================

# make brain mask for input to MEICA
3dfractionize -input ${subj}_Anat_bc_ns_al_keep+tlrc -template pb03.$subj.r${runs[1]}_e${iRegEcho}.volreg+tlrc -clip 0.5 -overwrite -prefix rm.anatmask # resample skull-stripped, epi-aligned anat file to match epi resolution
3dcalc -a "rm.anatmask+tlrc" -expr 'notzero(a)' -overwrite -prefix rm.anatmask.bin # binarize
3dmask_tool -fill_holes -input rm.anatmask.bin+tlrc -overwrite -prefix rm.meicamask.bin+tlrc

foreach run ( $runs )

	# calculate the median value for the 5th value in the first echo
    # 3dBrickStat -mask full_mask.$subj+tlrc -percentile 50 1 50 pb03.$subj.r${run}_e1.volreg+tlrc'[4]' > gms.1D
	3dBrickStat -mask rm.meicamask.bin+tlrc -percentile 50 1 50 pb03.$subj.r${run}_e1.volreg+tlrc'[4]' > gms.1D
	set gms = `cat gms.1D`
	set gmsa = ($gms)
	set p50 = ${gmsa[2]} # tcsh is 1-based... this index would be [1] in bash.

	# Rescale to the large values that ICA prefers
 	foreach iEcho ( $echoes )
		# mask and scale all values by 10000/"the median value of volume 5 for the first echo"
		3dcalc -float -overwrite -a pb03.$subj.r${run}_e${iEcho}.volreg+tlrc \
		    -b rm.meicamask.bin+tlrc -expr "a*b*10000/${p50}" -overwrite -prefix pb04.$subj.r${run}_e${iEcho}.in.nii.gz
	end

	# concatenate across echoes in the z direction
	3dZcat -overwrite -prefix zcat_ffd_$subj.r${run}.nii.gz  \
	   pb04.$subj.r${run}_e1.in.nii.gz \
	   pb04.$subj.r${run}_e2.in.nii.gz \
	   pb04.$subj.r${run}_e3.in.nii.gz

    # make sure slices are axial
    3daxialize -overwrite -prefix zcat_ffd_$subj.r${run}.nii.gz zcat_ffd_$subj.r${run}.nii.gz

end


# SET UP TEDANA.PY TO DENOISE RUNS AND CALCULATE OPTIMALLY COMBINED TIME SERIES
# ===========================
# CREATES A SWARM CALL THAT RUNS TEDANA.PY FOLLOWED BY Ben Gutierrez' MEICA_REPORT.PY FOR EACH RUN

# Before running this, I made an environment called python27 that uses Anaconda, Python 2.7, and libraries bokeh, matplotlib,numpy,and sphinx

# initialize tedana_swarm.txt
# if ( -f 03_TedanaSwarmCommand.txt ) rm 03_TedanaSwarmCommand.txt # remove it if it exists
# touch 03_TedanaSwarmCommand.txt
# # Write tedana swarm text file
# foreach run ( $runs )
# 	cd ${output_dir}
# 	# bash syntax
# 	echo "module load Anaconda; source activate python27; OMP_NUM_THREADS=4; cd ${output_dir}; python ${PRJDIR}/Scripts/me-ica/meica.libs/tedana.py -e ${echoTimes}  -d zcat_ffd_$subj.r${run}.nii.gz --sourceTEs=-1 --kdaw=10 --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 --label=$subj.r${run}; 3dcalc -a  anat_final.$subj+tlrc -prefix anat_final.$subj.nii.gz -expr 'a' -overwrite; python ${PRJDIR}/Scripts/Meica_Report/meica_report.py -o ./meica.Report.$subj.r${run} -t TED.$subj.r${run} --overwrite  --motion mat.r$run.warp.aff12.1D" >> 03_TedanaSwarmCommand.txt # use motion in tlrc space
#
# end

# TO RUN SWARM JOB:
# swarm -g 8 -t 4 -f 03_TedanaSwarmCommand.txt # Must be run on Biowulf2, not Helix/Felix.


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
