#!/bin/bash
# 01_AnatPrep.sh
# ===============================================================
# Usage:
#	01_AnatPrep SubjectID AnatFile PdFile
#
# Inputs:
#   * SubjectID is the name of the subject (e.g., SBJ01)
#   * AnatFile is the name of the MP-RAGE file (.BRIK or .nii)
#   * PdFile is the name of the proton density file (.BRIK or .nii)
#
# Outputs:
#   * Skull-strip PD
#   * Intracranial mask based on PD
#   * Create Skull Stripped and Bias Corrected MP-RAGE
#   * Perform trasformation to MNI space
#
# Created 07/15/2014 by Javier Gonzalez-Castillo, Colin W. Hoy
# Updated 10/29/15 by DJ - send anat files as input
# Updated 2/6/16 by DJ - use PD image for skull stripping instead of Anat
# Updated 7/8/16 by DJ - added special skull strip case for SBJ36
# ===============================================================

# COMMON STUFF
# ============
set -e
source ./00_CommonVariables.sh

# READ INPUT PARAMETERS
# =====================
if [ $# -ne 3 ]; then
 echo "Usage: $basename $0 SBJID AnatFile PdFile"
 exit
fi
SBJ=$1
AnatFile=${2%.*} # strip off extension
PdFile=${3%.*} # strip off extension

# CREATE DIRECTORIES AND COPY FILES
# =================================
if [ ! -d ${PRJDIR}/PrcsData/${SBJ} ]; then mkdir -p ${PRJDIR}/PrcsData/${SBJ}; fi
cd ${PRJDIR}/PrcsData/${SBJ}

if [ ! -d D01_Anatomical ]; then mkdir D01_Anatomical; fi
cd D01_Anatomical

ln -s ../D00_OriginalData/${AnatFile}.* .
ln -s ../D00_OriginalData/${PdFile}.* .

# CREATE INTRACRANIAL MASK
# ========================
# If the Anat-derived mask looks bad, try starting over and using the PD file (or vice versa).
if [ "$SBJ" == "SBJ36" ]; then
    3dSkullStrip -prefix ${SBJ}_Anat_mask -input ${PdFile} -push_to_edge -no_avoid_eyes
else
    3dSkullStrip -prefix ${SBJ}_Anat_mask -input ${PdFile}
fi
3dcalc -a ${SBJ}_Anat_mask+orig. -expr 'step(a)' -overwrite -prefix ${SBJ}_Anat_mask

# CREATE SKULL STRIPPED + DIVIDED BY PD DATASET
# ============================================
AnatMean=`3dROIstats -quiet -mask ${SBJ}_Anat_mask+orig. ${AnatFile} | awk '{ print $1}'`
3dcalc -a ${PdFile} -b ${AnatFile} -m ${SBJ}_Anat_mask+orig. \
       -expr "m*(${AnatMean}*b/a)*isnegative((${AnatMean}*b/a)-1500)" \
       -overwrite -float -prefix ${SBJ}_Anat_dbPD

# BIAS CORRECTION WITH 3DSEG
# ==========================
3dSeg -anat ${SBJ}_Anat_dbPD+orig. -mask ${SBJ}_Anat_mask+orig
3dcopy -overwrite Segsy/AnatUB+orig. ${SBJ}_Anat_bc_ns+orig
3dcalc -overwrite -a ${AnatFile} -b ${SBJ}_Anat_bc_ns+orig. -expr '(b*step(b))+(0.4*a*not(step(b)))' -prefix ${SBJ}_Anat_bc

# CONVERT ANATOMICAL TO MNI SPACE
# ===============================
@auto_tlrc -base MNI_caez_N27+tlrc -input ${SBJ}_Anat_bc_ns+orig. -no_ss -twopass
cat_matvec -ONELINE ${SBJ}_Anat_bc_ns+tlrc::WARP_DATA > ${SBJ}_MNI2Anat.Xaff12.1D
cat_matvec -ONELINE ${SBJ}_MNI2Anat.Xaff12.1D -I      > ${SBJ}_Anat2MNI.Xaff12.1D
rm ${SBJ}_Anat_bc_ns_WarpDrive.log
rm ${SBJ}_Anat_bc_ns.Xaff12.1D
rm ${SBJ}_Anat_bc_ns.Xat.1D

# CONVERT BIAS CORRECTED AND SKULL STRIPPED ANATOMICAL TO NIFTI
# =============================================================
3dcopy ${SBJ}_Anat_bc_ns+orig. ${SBJ}_Anat_bc_ns.nii.gz
