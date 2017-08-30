# ===============================================================   
# Date: 07/15/2014
# Authors: Javier Gonzalez-Castillo, Colin W. Hoy
#
# Inputs:
#   * SubjectID is the only input parameter
#
# Outputs:
#   * Skull-strip PD
#   * Intracranial mask based on PD
#   * Create Skull Stripped and Bias Corrected MP-RAGE
#   * Perform trasformation to MNI space
#
# ===============================================================   

# COMMON STUFF
# ============
source ./00_CommonVariables.sh

# READ INPUT PARAMETERS
# =====================
if [ $# -ne 1 ]; then
 echo "Usage: $basename $0 SBJID"
 exit
fi
SBJ=$1

# CREATE DIRECTORIES AND COPY FILES
# =================================
cd ${PRJDIR}/PrcsData/${SBJ}

if [ ! -d D01_Anatomical ]; then mkdir D01_Anatomical; fi
cd D01_Anatomical

ln -s ../D00_OriginalData/${SBJ}_Anat+orig.* .
ln -s ../D00_OriginalData/${SBJ}_Anat_PD+orig.* .

# CREATE INTRACRANIAL MASK
# ========================
3dSkullStrip -prefix ${SBJ}_Anat_mask -input ${SBJ}_Anat_PD+orig
3dcalc -a ${SBJ}_Anat_mask+orig. -expr 'step(a)' -overwrite -prefix ${SBJ}_Anat_mask

# CREATE SKULL STRIPED + DIVIDED BY PD DATASET
# ============================================
AnatMean=`3dROIstats -quiet -mask ${SBJ}_Anat_mask+orig. ${SBJ}_Anat+orig. | awk '{ print $1}'`
3dcalc -a ${SBJ}_Anat_PD+orig. -b ${SBJ}_Anat+orig. -m ${SBJ}_Anat_mask+orig. \
       -expr "m*(${AnatMean}*b/a)*isnegative((${AnatMean}*b/a)-1500)" \
       -overwrite -float -prefix ${SBJ}_Anat_dbPD

# BIAS CORRECTION WITH 3DSEG
# ==========================
3dSeg -anat ${SBJ}_Anat_dbPD+orig. -mask ${SBJ}_Anat_mask+orig
3dcopy -overwrite Segsy/AnatUB+orig. ${SBJ}_Anat_bc_ns+orig
3dcalc -overwrite -a ${SBJ}_Anat+orig. -b ${SBJ}_Anat_bc_ns+orig. -expr '(b*step(b))+(0.4*a*not(step(b)))' -prefix ${SBJ}_Anat_bc

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
