#!/bin/bash

source 00_CommonVariables.sh
cd $dataDir/atlasRois

ln -s /usr/local/apps/afni/current/linux_centos_7_64/MNI152_T1_2009c+tlrc.* .
ln -s /usr/local/apps/afni/current/linux_centos_7_64/MNI_caez_ml_18+tlrc.* .

# resample to EPI resolution
3dresample -inset MNI_caez_ml_18_MNI09.nii.gz -master /data/NIMH_Haskins/a182_v2/IscResults/Group/3dLME_1grp_n69_Automask+tlrc -prefix MNI_caez_ml_18_MNI09_epiRes

# Get masks
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,90)' -overwrite -prefix atlas_rITG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,89)' -overwrite -prefix atlas_lITG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,63)' -overwrite -prefix atlas_lSMG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,64)' -overwrite -prefix atlas_rSMG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,11)' -overwrite -prefix atlas_lIFG-pOp
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,12)' -overwrite -prefix atlas_rIFG-pOp
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,13)' -overwrite -prefix atlas_lIFG-pTri
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,14)' -overwrite -prefix atlas_rIFG-pTri
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,15)' -overwrite -prefix atlas_lIFG-pOrb
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,16)' -overwrite -prefix atlas_rIFG-pOrb
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,31)' -overwrite -prefix atlas_lACC
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,32)' -overwrite -prefix atlas_rACC
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,7)'  -overwrite -prefix atlas_lMFG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,8)'  -overwrite -prefix atlas_rMFG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,81)' -overwrite -prefix atlas_lSTG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,82)' -overwrite -prefix atlas_rSTG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,43)' -overwrite -prefix atlas_rCG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,43)' -overwrite -prefix atlas_lCG
3dcalc -a MNI_caez_ml_18_MNI09_epiRes+tlrc. -expr 'equals(a,44)' -overwrite -prefix atlas_rCG

# Get bi-sided masks
3dcalc -a atlas_rITG+tlrc -b atlas_lITG+tlrc -expr 'a+b' -overwrite -prefix atlas_ITG
3dcalc -a atlas_rSMG+tlrc -b atlas_lSMG+tlrc -expr 'a+b' -overwrite -prefix atlas_SMG
3dcalc -a atlas_rIFG-pOp+tlrc -b atlas_lIFG-pOp+tlrc -expr 'a+b' -overwrite -prefix atlas_IFG-pOp
3dcalc -a atlas_rIFG-pTri+tlrc -b atlas_lIFG-pTri+tlrc -expr 'a+b' -overwrite -prefix atlas_IFG-pTri
3dcalc -a atlas_rIFG-pOrb+tlrc -b atlas_lIFG-pOrb+tlrc -expr 'a+b' -overwrite -prefix atlas_IFG-pOrb
3dcalc -a atlas_rACC+tlrc -b atlas_lACC+tlrc -expr 'a+b' -overwrite -prefix atlas_ACC
3dcalc -a atlas_rMFG+tlrc -b atlas_lMFG+tlrc -expr 'a+b' -overwrite -prefix atlas_MFG
3dcalc -a atlas_rSTG+tlrc -b atlas_lSTG+tlrc -expr 'a+b' -overwrite -prefix atlas_STG
3dcalc -a atlas_rCG+tlrc -b atlas_lCG+tlrc -expr 'a+b' -overwrite -prefix atlas_CG
