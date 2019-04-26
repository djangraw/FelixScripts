#!/bin/bash

source 00_CommonVariables.sh
cd $dataDir/atlasRois

ln -s /usr/local/apps/afni/current/linux_centos_7_64/MNI152_T1_2009c+tlrc.* .
ln -s /usr/local/apps/afni/current/linux_centos_7_64/MNI_caez_ml_18+tlrc.* .

3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,89)' -prefix atlas_lITG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,90)' -prefix atlas_rITG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,63)' -prefix atlas_lSMG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,64)' -prefix atlas_rSMG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,11)' -prefix atlas_lIFG-pOp
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,12)' -prefix atlas_rIFG-pOp
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,13)' -prefix atlas_lIFG-pTri
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,14)' -prefix atlas_rIFG-pTri
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,15)' -prefix atlas_lIFG-pOrb
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,16)' -prefix atlas_rIFG-pOrb
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,31)' -prefix atlas_lACC
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,32)' -prefix atlas_rACC
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,7)' -prefix atlas_lMFG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,8)' -prefix atlas_rMFG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,81)' -prefix atlas_lSTG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,82)' -prefix atlas_rSTG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,43)' -prefix atlas_rCG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,43)' -prefix atlas_lCG
3dcalc -a MNI_caez_ml_18+tlrc. -expr 'equals(a,44)' -prefix atlas_rCG
