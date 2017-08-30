#!/bin/tcsh -xef
# 02p5_ExtraMeicaPrep.tcsh
#
# Created 4/18/17 by DJ.

# the user may specify a single subject to run with
if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = SBJ03
endif
if ( $#argv > 1 ) then
    set run = $argv[2]
else
    set run = 004
endif
if ( $#argv > 2 ) then
    set outFolder = $argv[3]
else
    set outFolder = run${run}
endif
if ( $#argv > 3 ) then
    set echoTimes = $argv[4]
else
    set echoTimes = "11.0,23.96,36.92"
endif

set PRJDIR = /data/jangrawdc/PRJ11_Music

# Move to data directory
cd ${PRJDIR}/PrcsData/${subj}/D00_OriginalData

# assign output directory name
set output_dir = ${PRJDIR}/Results/${subj}/${outFolder}
set script_dir = ${PRJDIR}/Scripts/
set inputFiles = `ls ${subj}_scan${run}_*.HEAD`
set nEchoes = $#inputFiles
set echoes = (`count -digits 1 1 $nEchoes`)

# move to output directory
cd ${output_dir}

# Calculate mask from anatomy
3dfractionize -input ${subj}_Anat_bc_ns_al_keep+tlrc -template pb03.$subj.r${runs[1]}_e${iRegEcho}.volreg+tlrc -clip 0.5 -overwrite -prefix rm.anatmask # resample skull-stripped, epi-aligned anat file to match epi resolution
3dcalc -a "rm.anatmask+tlrc" -expr 'notzero(a)' -overwrite -prefix rm.anatmask.bin # binarize
3dmask_tool -fill_holes -input rm.anatmask.bin+tlrc -overwrite -prefix rm.meicamask.bin+tlrc


# Calculate mask from EPI (usually from anatomy)
# 3dmask_tool -inputs rm.mask_r*+orig.HEAD -union -prefix full_mask.${subj}
# 3dmask_tool -inputs rm.mask_r${run}_e3+orig.HEAD -union -prefix full_mask.${subj}
# 3dcalc -a full_mask.${subj}+orig -expr 'notzero(a)' -prefix rm.meicamask.bin+orig

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
      -b rm.meicamask.bin+tlrc -expr "a*b*10000/${p50}" -overwrite -prefix rm.$subj.r${run}_e${iEcho}.in.nii.gz
end

# concatenate across echoes in the z direction
3dZcat -overwrite -prefix rm.zcat_ffd_$subj.r${run}.nii.gz  \
   rm.$subj.r${run}_e1.in.nii.gz \
   rm.$subj.r${run}_e2.in.nii.gz \
   rm.$subj.r${run}_e3.in.nii.gz

  # make sure slices are axial
  3daxialize -overwrite -prefix rm.zcat_ffd_$subj.r${run}.nii.gz rm.zcat_ffd_$subj.r${run}.nii.gz
