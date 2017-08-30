#!/bin/bash
#
# CopyData.sh
#
# Created 2/2/16 by DJ.
# Updated 11/9/16 by DJ - added pb03 mask

subjNums=(`count -digits 2 6 27`)

for subjNum in ${subjNums[@]}
do
    # set up
    subject=SBJ$subjNum
    echo "Copying files for $subject..."    
    outdir=/data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/${subject}/D02_CTask001/
    mkdir -p $outdir # make the directory if it doesn't exist yet
    # move into Javier's data directory
    cd /data/SFIMJGC/PRJ_CognitiveStateDetection01/PrcsData/${subject}/D02_CTask001/
    # COPY!
    3dcopy -overwrite pb03.SBJ06_CTask001.volreg.REF.mask.FBrain+orig. $outdir # mask of ALL in-brain voxels
    3dcopy -overwrite pb08.${subject}_CTask001.blur.WL045+orig. $outdir # volumetric (45s window)
    3dcopy -overwrite pb06.${subject}_CTask001.bpf.WL045.mask.lowSigma+orig. $outdir # volumetric (45s window)
    3dcopy -overwrite ${subject}_Anat_bc_ns_al+orig $outdir # anatomical
    3dcopy -overwrite ${subject}_CTask001.Craddock_T2Level_0200.lowSigma+orig $outdir # Craddock atlas (200ROI)
    cp *.Xaff12.1D $outdir # transform between MNI, this subj's anatomical, and its EPI ref space
done

echo "Copying other files..."
3dcopy -overwrite /data/SFIMJGC/PRJ_CognitiveStateDetection01/Atlases/Craddock_T2Level_0200/Craddock_T2Level_0200.MNI+tlrc /data/jangrawdc/PRJ08_CognitiveStateDetection/Atlases/
cp /data/SFIMJGC/PRJ_CognitiveStateDetection01/SharingJoaquin/NOTES.txt /data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData # notes on ROIs, paradigm, and file notation

echo "Done!"