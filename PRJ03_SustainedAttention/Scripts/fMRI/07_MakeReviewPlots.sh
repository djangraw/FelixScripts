#!/bin/bash
# 07_MakeReviewPlots.sh
#
# Use AFNI's -com inputs to produce plots that can be used to check the outcome of processing steps.
#  
# USAGE:
#   bash 07_MakeReviewPlots.sh $subj $resultsFolder
# 
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#   - resultsFolder is a string indicating the name of the folder where errts.${subj}.tproject is
#
# OUTPUTS:
#	- Writes images to ${PRJDIR}/Results/Figures
#
# Created 2/11-12/16 by DJ.
# Updated 5/19/16 by DJ - save to Results/Figures instead of individual subject directory

# ======== SET UP ========
# exit if error
set -e
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj=SBJ05
fi
if [ ${#argv} > 1 ]; then
    resultsFolder=${argv[1]}
else
    resultsFolder=AfniProc_MultiEcho
fi

# Get directories
source ./00_CommonVariables.sh # Get PRJDIR
anatDir="${PRJDIR}/PrcsData/${subj}/D01_Anatomical"
resultsDir="${PRJDIR}/Results/${subj}/${resultsFolder}"
outDir="${PRJDIR}/Results/Figures"

# Center positions
centerC_anat="128 128 110"
centerC_epi="35 35 23"
centerC_ttn27="60 99 93"

# Make review folder
# echo "Making folder ${outDir}/Review"
# mkdir -p ${outDir}/Review

# Add TT_N27 atlas to results directory
if [ ! -f ${resultsDir}/TT_N27+tlrc.HEAD ]; then
    ln -s ${AFNI_HOME}TT_N27+tlrc.* ${resultsDir}/
fi

# Skull stripping
cd $anatDir
afni -com "OPEN_WINDOW A.sagittalimage mont=4x4:8 geom=1000x1000+0+0 opacity=4 ifrac=1" \
-com "CLOSE_WINDOW A.axialimage" \
-com "SWITCH_UNDERLAY ${subj}_Anat01+orig" \
-com "SWITCH_OVERLAY ${subj}_Anat_mask+orig" \
-com "SET_VIEW A.orig" \
-com "SET_IJK A ${centerC_anat}" \
-com "SET_XHAIRS A.OFF" \
-com "SAVE_JPEG A.sagittalimage ${outDir}/${subj}_AnatMask.jpg" \
-com "QUIT"

# Alignment with anatomy (orig)
cd $resultsDir
afni -com "OPEN_WINDOW A.axialimage mont=4x4:2 geom=1000x1000+0+0 opacity=4 ifrac=1" \
-com "CLOSE_WINDOW A.sagittalimage" \
-com "SWITCH_UNDERLAY external_volreg_base+orig" \
-com "SWITCH_OVERLAY ${subj}_Anat_bc_ns_al_keep+orig" \
-com "SET_VIEW A.orig" \
-com "SET_FUNC_AUTORANGE A.-" \
-com "SET_FUNC_RANGE A.450" \
-com "SET_PBAR_SIGN A.+" \
-com "SET_IJK A ${centerC_epi}" \
-com "SET_XHAIRS A.OFF" \
-com "SAVE_JPEG A.axialimage ${outDir}/${subj}_AnatToEpiAlign.jpg" \
-com "QUIT"

# Alignment with tlrc
afni -com "OPEN_WINDOW A.axialimage mont=4x4:8 geom=1000x1000+0+0 opacity=4 ifrac=1" \
-com "CLOSE_WINDOW A.sagittalimage" \
-com "SWITCH_UNDERLAY TT_N27+tlrc" \
-com "SWITCH_OVERLAY ${subj}_Anat_bc_ns_al_keep+tlrc" \
-com "SET_VIEW A.tlrc" \
-com "SET_FUNC_AUTORANGE A.-" \
-com "SET_FUNC_RANGE A.450" \
-com "SET_PBAR_SIGN A.+" \
-com "SET_IJK A ${centerC_ttn27}" \
-com "SET_XHAIRS A.OFF" \
-com "SAVE_JPEG A.axialimage ${outDir}/${subj}_AnatToTlrcAlign.jpg" \
-com "QUIT"

# Plot Movement
# 1dplot -volreg -censor motion_${subj}_censor.1D \
# -jpgs 1000 ${outDir}/${subj}_Motion.jpg \
# -xlabel "time (samples)" -plabel "${subj} Motion" \
# motion_demean.1D
#
# 1dplot -volreg -censor motion_${subj}_censor.1D \
# -jpgs 1000 ${outDir}/${subj}_MotionDeriv.jpg \
# -xlabel "time (samples)" -plabel "${subj} Motion Derivative" \
# motion_deriv.1D
