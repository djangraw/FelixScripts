#!/bin/bash
set -e

# Resample Shen atlas to match EPI scans in the Haskins Story data.
# ResampleShenAtlasToEpiRes.sh
#
# Created 5/25/22 by DJ based on 06_WarpCraddockAtlasToEpiSpace.sh.

# set up
dataDir='/Volumes/DJ_Transfer/a182_v2'
atlasFile=${dataDir}/shen_1mm_268_parcellation.nii.gz
maskFile=${dataDir}/IscResults/Pairwise/MNI_mask_epiRes.nii
outFile=${dataDir}/IscResults/Pairwise/shen_268_epiRes

# resample mask
3dresample -master ${maskFile} -overwrite -prefix $outFile -inset ${atlasFile}
3dcalc -a ${outFile}+tlrc. -b ${maskFile} -expr 'a*step(b)' -overwrite -prefix ${outFile}_masked
