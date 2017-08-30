rm -rf alignp.mepi 
mkdir alignp.mepi 
cd alignp.mepi 
3dcopy -overwrite /spin1/users/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001/t2svm_ss.nii.gz /spin1/users/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001/alignp.mepi/t2svm_ss
3drefit -view orig `ls /spin1/users/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001/alignp.mepi/t2svm_ss+*.HEAD`
3dcopy -overwrite /spin1/users/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001/SBJ01_Anat_bc_ns.nii.gz /spin1/users/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001/alignp.mepi/SBJ01_Anat_bc_ns
3drefit -view orig `ls /spin1/users/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001/alignp.mepi/SBJ01_Anat_bc_ns+*.HEAD`
3dBrickStat -mask t2svm_ss+orig -percentile 50 1 50 t2svm_ss+orig > graywt_thr.1D
maxthr=`cat graywt_thr.1D`; maxthra=($maxthr); vmax=${maxthra[1]}
3dcalc -overwrite -a t2svm_ss+orig -expr "a*isnegative(a-2*${vmax})" -prefix t2svm_thr.nii.gz
3dUnifize -overwrite -prefix align_base.nii.gz t2svm_thr.nii.gz
3dSeg -prefix Segsy.t2svm -anat align_base.nii.gz -mask align_base.nii.gz
3dcalc -overwrite -a 'Segsy.t2svm/Posterior+orig[2]' -prefix align_weight.nii.gz -expr 'a' 
3dAllineate -overwrite -weight_frac 1.0 -VERB -warp aff -source_automask+2 -master SOURCE -source SBJ01_Anat_bc_ns+orig -base align_base.nii.gz -prefix ./mepi_al -1Dmatrix_save ./mepi_al_mat -lpc -weight align_weight.nii.gz -maxshf 30 -maxrot 30 -maxscl 1.2  