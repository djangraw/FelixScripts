#/data/SFIM/Apps/me-ica/meica.py -e 17.5,35.3,53.1 -d pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii.gz -a SBJ01_Anat_bc_ns.nii.gz --MNI --no_skullstrip --keep_int --prefix _MEICA_V001 --label _MEICA_V001 --script_only

# Multi-Echo ICA, Version v2.5 beta10
#
# Kundu, P., Brenowitz, N.D., Voon, V., Worbe, Y., Vertes, P.E., Inati, S.J., Saad, Z.S., 
# Bandettini, P.A. & Bullmore, E.T. Integrated strategy for improving functional 
# connectivity mapping using multiecho fMRI. PNAS (2013).
#
# Kundu, P., Inati, S.J., Evans, J.W., Luh, W.M. & Bandettini, P.A. Differentiating 
#   BOLD and non-BOLD signals in fMRI time series using multi-echo EPI. NeuroImage (2011).
# http://dx.doi.org/10.1016/j.neuroimage.2011.12.028
#
# meica.py version 2.5 (c) 2014 Prantik Kundu
# PROCEDURE 1 : Preprocess multi-echo datasets and apply multi-echo ICA based on spatial concatenation
# -Check arguments, input filenames, and filesystem for dependencies
# -Calculation of motion parameters based on images with highest constrast
# -Application of motion correction and coregistration parameters
# -Misc. EPI preprocessing (temporal alignment, smoothing, etc) in appropriate order
# -Compute PCA and ICA in conjuction with TE-dependence analysis

echo "
++++++++++++++++++++++++" 
echo +* "Set up script run environment" 
set -e
export OMP_NUM_THREADS=2
export MKL_NUM_THREADS=2
export DYLD_FALLBACK_LIBRARY_PATH=/home/jangrawdc/Apps/abin
export AFNI_3dDespike_NEW=YES
if [[ -e meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001 ]]; then echo ME-ICA directory exists, exiting; exit; fi
mkdir -p meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001
cp _meica_pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001.sh meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001/
cd meica.pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_MEICA_V001
echo "
++++++++++++++++++++++++" 
echo +* "Deoblique, unifize, skullstrip, and/or autobox anatomical, in starting directory (may take a little while)" 
echo "
++++++++++++++++++++++++" 
echo +* "Copy in functional datasets, reset NIFTI tags as needed" 
3dcalc -a /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii.gz -expr 'a' -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii
nifti_tool -mod_hdr -mod_field sform_code 1 -mod_field qform_code 1 -infiles ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii -overwrite
3dcalc -a /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii.gz -expr 'a' -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii
nifti_tool -mod_hdr -mod_field sform_code 1 -mod_field qform_code 1 -infiles ./pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii -overwrite
3dcalc -a /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii.gz -expr 'a' -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii
nifti_tool -mod_hdr -mod_field sform_code 1 -mod_field qform_code 1 -infiles ./pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii -overwrite
echo "
++++++++++++++++++++++++" 
echo +* "Calculate and save motion and obliquity parameters, despiking first if not disabled, and separately save and mask the base volume" 
3dDespike -overwrite -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrA.nii.gz ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii 
3daxialize -overwrite -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrA.nii.gz ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrA.nii.gz
3dcalc -a ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrA.nii.gz[0]  -expr 'a' -prefix eBbase.nii.gz 
3dvolreg -overwrite -tshift -quintic  -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrA.nii.gz -base eBbase.nii.gz -dfile ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrA.1D -1Dmatrix_save ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrmat.aff12.1D ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrA.nii.gz
1dcat './pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrA.1D[1..6]{0..$}' > motion.1D 
echo "
++++++++++++++++++++++++" 
echo +* "Preliminary preprocessing of functional datasets: despike, tshift, deoblique, and/or axialize" 
echo --------"Preliminary preprocessing dataset pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii.gz of TE=17.5ms to produce e1_ts+orig" 
3dDespike -overwrite -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_pt.nii.gz pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii
3dTshift -heptic  -prefix ./e1_ts+orig ./pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_pt.nii.gz
3daxialize  -overwrite -prefix ./e1_ts+orig ./e1_ts+orig
3drefit -TR 0.9 e1_ts+orig
echo --------"Preliminary preprocessing dataset pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii.gz of TE=35.3ms to produce e2_ts+orig" 
3dDespike -overwrite -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E02.discard_pt.nii.gz pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii
3dTshift -heptic  -prefix ./e2_ts+orig ./pb01.SBJ01_AUDIO_Gating_Run01_E02.discard_pt.nii.gz
3daxialize  -overwrite -prefix ./e2_ts+orig ./e2_ts+orig
3drefit -TR 0.9 e2_ts+orig
echo --------"Preliminary preprocessing dataset pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii.gz of TE=53.1ms to produce e3_ts+orig" 
3dDespike -overwrite -prefix ./pb01.SBJ01_AUDIO_Gating_Run01_E03.discard_pt.nii.gz pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii
3dTshift -heptic  -prefix ./e3_ts+orig ./pb01.SBJ01_AUDIO_Gating_Run01_E03.discard_pt.nii.gz
3daxialize  -overwrite -prefix ./e3_ts+orig ./e3_ts+orig
3drefit -TR 0.9 e3_ts+orig
3dBrickStat -mask eBbase.nii.gz -percentile 50 1 50 e1_ts+orig[0] > gms.1D
gms=`cat gms.1D`; gmsa=($gms); p50=${gmsa[1]}
echo "
++++++++++++++++++++++++" 
echo +* "Prepare T2* and S0 volumes for use in functional masking and (optionally) anatomical-functional coregistration (takes a little while)." 
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrmat.aff12.1D'{0..5}' -base eBbase.nii.gz -input e1_ts+orig'[0..5]' -prefix e1_vrA.nii.gz
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrmat.aff12.1D'{0..5}' -base eBbase.nii.gz -input e2_ts+orig'[0..5]' -prefix e2_vrA.nii.gz
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrmat.aff12.1D'{0..5}' -base eBbase.nii.gz -input e3_ts+orig'[0..5]' -prefix e3_vrA.nii.gz
3dZcat -prefix basestack.nii.gz  e1_vrA.nii.gz e2_vrA.nii.gz e3_vrA.nii.gz
/home/jangrawdc/envs/meica/bin/python /data/SFIM/Apps/me-ica/meica.libs/t2smap.py -d basestack.nii.gz -e 17.5,35.3,53.1
3dUnifize -prefix ./ocv_uni+orig ocv.nii
3dAutomask -prefix ./ocv_ss.nii.gz -overwrite ocv_uni+orig
3dcalc -overwrite -a t2svm.nii -b ocv_ss.nii.gz -expr 'a*ispositive(a)*step(b)' -prefix t2svm_ss.nii.gz
3dcalc -overwrite -a s0v.nii -b ocv_ss.nii.gz -expr 'a*ispositive(a)*step(b)' -prefix s0v_ss.nii.gz
3daxialize -overwrite -prefix t2svm_ss.nii.gz t2svm_ss.nii.gz
3daxialize -overwrite -prefix ocv_ss.nii.gz ocv_ss.nii.gz
3daxialize -overwrite -prefix s0v_ss.nii.gz s0v_ss.nii.gz
echo "
++++++++++++++++++++++++" 
echo +* "Copy anatomical into ME-ICA directory and process warps" 
cp /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns.nii.gz* .
afnibinloc=`which 3dAutomask`
templateloc=${afnibinloc%/*}
echo --------"If can't find affine-warped anatomical, copy native anatomical here, compute warps (takes a while) and save in start dir. ; otherwise link in existing files" 
if [ ! -e /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns_at.nii.gz ]; then \@auto_tlrc -no_ss -init_xform AUTO_CENTER -base ${templateloc}/MNI_caez_N27+tlrc -input SBJ01_Anat_bc_ns.nii.gz -suffix _at
cp SBJ01_Anat_bc_ns_at.nii /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01
gzip -f /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns_at.nii
else ln -s /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns_at.nii.gz .
fi
3dcopy /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns_at.nii.gz SBJ01_Anat_bc_ns_at
3drefit -view orig SBJ01_Anat_bc_ns_at+tlrc 
3dAutobox -prefix ./abtemplate.nii.gz ${templateloc}/MNI_caez_N27+tlrc
echo --------"Using alignp_mepi_anat.py to drive T2*-map weighted anatomical-functional coregistration" 
3daxialize -overwrite -prefix ./SBJ01_Anat_bc_ns.nii.gz /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns.nii.gz
/home/jangrawdc/envs/meica/bin/python /data/SFIM/Apps/me-ica/meica.libs/alignp_mepi_anat.py -t t2svm_ss.nii.gz -a SBJ01_Anat_bc_ns.nii.gz -p mepi 
cp alignp.mepi/mepi_al_mat.aff12.1D ./SBJ01_Anat_bc_ns_al_mat.aff12.1D
cat_matvec -ONELINE /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns_at.nii.gz::WARP_DATA -I > /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns_ns2at.aff12.1D
cat_matvec -ONELINE  /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns_at.nii.gz::WARP_DATA -I  SBJ01_Anat_bc_ns_al_mat.aff12.1D -I > pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_wmat.aff12.1D
cat_matvec -ONELINE  /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/SBJ01_Anat_bc_ns_at.nii.gz::WARP_DATA -I  SBJ01_Anat_bc_ns_al_mat.aff12.1D -I  pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrmat.aff12.1D  > pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrwmat.aff12.1D
echo "
++++++++++++++++++++++++" 
echo +* "Extended preprocessing of functional datasets" 

echo --------"Preparing functional masking for this ME-EPI run" 
3dZeropad  -I 11 -S 11 -A 11 -P 11 -L 11 -R 11  -prefix eBvrmask.nii.gz ocv_ss.nii.gz[0]
voxsize=`ccalc $(3dinfo -voxvol eBvrmask.nii.gz)**.33`
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_wmat.aff12.1D -base eBvrmask.nii.gz -input eBvrmask.nii.gz -prefix ./eBvrmask.nii.gz -master abtemplate.nii.gz -mast_dxyz ${voxsize}
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_wmat.aff12.1D -base eBvrmask.nii.gz -input t2svm_ss.nii.gz -prefix ./t2svm_ss_vr.nii.gz -master abtemplate.nii.gz -mast_dxyz ${voxsize}
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_wmat.aff12.1D -base eBvrmask.nii.gz -input ocv_uni+orig -prefix ./ocv_uni_vr.nii.gz -master abtemplate.nii.gz -mast_dxyz ${voxsize}
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_wmat.aff12.1D -base eBvrmask.nii.gz -input s0v_ss.nii.gz -prefix ./s0v_ss_vr.nii.gz -master abtemplate.nii.gz -mast_dxyz ${voxsize}
3dcalc -float -a eBvrmask.nii.gz -expr 'notzero(a)' -overwrite -prefix eBvrmask.nii.gz
echo --------"Apply combined normalization/co-registration/motion correction parameter set to e1_ts+orig" 
3dAllineate -final cubic -cubic -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrwmat.aff12.1D -base eBvrmask.nii.gz -input  e1_ts+orig -prefix ./e1_vr.nii.gz
3dTstat -min -prefix ./e1_vr_min.nii.gz ./e1_vr.nii.gz
3dcalc -a eBvrmask.nii.gz -b e1_vr_min.nii.gz -expr 'step(a)*step(b)' -overwrite -prefix eBvrmask.nii.gz 
3dcalc -float -overwrite -a eBvrmask.nii.gz -b ./e1_vr.nii.gz[0..$] -expr 'step(a)*b' -prefix ./e1_sm.nii.gz 
3dcalc -float -overwrite -a ./e1_sm.nii.gz -expr "a*10000/${p50}" -prefix ./e1_sm.nii.gz
3dTstat -prefix ./e1_mean.nii.gz ./e1_sm.nii.gz
mv e1_sm.nii.gz e1_in.nii.gz
3dcalc -float -overwrite -a ./e1_in.nii.gz -b ./e1_mean.nii.gz -expr 'a+b' -prefix ./e1_in.nii.gz
3dTstat -stdev -prefix ./e1_std.nii.gz ./e1_in.nii.gz
echo --------"Apply combined normalization/co-registration/motion correction parameter set to e2_ts+orig" 
3dAllineate -final cubic -cubic -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrwmat.aff12.1D -base eBvrmask.nii.gz -input  e2_ts+orig -prefix ./e2_vr.nii.gz
3dcalc -float -overwrite -a eBvrmask.nii.gz -b ./e2_vr.nii.gz[0..$] -expr 'step(a)*b' -prefix ./e2_sm.nii.gz 
3dcalc -float -overwrite -a ./e2_sm.nii.gz -expr "a*10000/${p50}" -prefix ./e2_sm.nii.gz
3dTstat -prefix ./e2_mean.nii.gz ./e2_sm.nii.gz
mv e2_sm.nii.gz e2_in.nii.gz
3dcalc -float -overwrite -a ./e2_in.nii.gz -b ./e2_mean.nii.gz -expr 'a+b' -prefix ./e2_in.nii.gz
3dTstat -stdev -prefix ./e2_std.nii.gz ./e2_in.nii.gz
echo --------"Apply combined normalization/co-registration/motion correction parameter set to e3_ts+orig" 
3dAllineate -final cubic -cubic -float -1Dmatrix_apply pb01.SBJ01_AUDIO_Gating_Run01_E01.discard_vrwmat.aff12.1D -base eBvrmask.nii.gz -input  e3_ts+orig -prefix ./e3_vr.nii.gz
3dcalc -float -overwrite -a eBvrmask.nii.gz -b ./e3_vr.nii.gz[0..$] -expr 'step(a)*b' -prefix ./e3_sm.nii.gz 
3dcalc -float -overwrite -a ./e3_sm.nii.gz -expr "a*10000/${p50}" -prefix ./e3_sm.nii.gz
3dTstat -prefix ./e3_mean.nii.gz ./e3_sm.nii.gz
mv e3_sm.nii.gz e3_in.nii.gz
3dcalc -float -overwrite -a ./e3_in.nii.gz -b ./e3_mean.nii.gz -expr 'a+b' -prefix ./e3_in.nii.gz
3dTstat -stdev -prefix ./e3_std.nii.gz ./e3_in.nii.gz
3dZcat -overwrite -prefix zcat_ffd.nii.gz   ./e1_in.nii.gz ./e2_in.nii.gz ./e3_in.nii.gz
3dcalc -float -overwrite -a zcat_ffd.nii.gz[0] -expr 'notzero(a)' -prefix zcat_mask.nii.gz
echo "
++++++++++++++++++++++++" 
echo +* "Perform TE-dependence analysis (takes a good while)" 
/home/jangrawdc/envs/meica/bin/python /data/SFIM/Apps/me-ica/meica.libs/tedana.py -e 17.5,35.3,53.1  -d zcat_ffd.nii.gz --sourceTEs=-1 --kdaw=10 --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 
#
echo "
++++++++++++++++++++++++" 
echo +* "Copying results to start directory" 
cp TED/ts_OC.nii TED/_MEICA_V001_tsoc.nii
cp TED/dn_ts_OC.nii TED/_MEICA_V001_medn.nii
cp TED/betas_hik_OC.nii TED/_MEICA_V001_mefc.nii
cp TED/betas_OC.nii TED/_MEICA_V001_mefl.nii
cp TED/comp_table.txt /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01/_MEICA_V001_ctab.txt
3dNotes -h '/data/SFIM/Apps/me-ica/meica.py -e 17.5,35.3,53.1 -d pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii.gz -a SBJ01_Anat_bc_ns.nii.gz --MNI --no_skullstrip --keep_int --prefix _MEICA_V001 --label _MEICA_V001 --script_only (Denoised timeseries (including thermal noise), produced by ME-ICA v2.5)' TED/_MEICA_V001_medn.nii
3dNotes -h '/data/SFIM/Apps/me-ica/meica.py -e 17.5,35.3,53.1 -d pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii.gz -a SBJ01_Anat_bc_ns.nii.gz --MNI --no_skullstrip --keep_int --prefix _MEICA_V001 --label _MEICA_V001 --script_only (Denoised ICA coeff. set for ME-ICR seed-based FC analysis, produced by ME-ICA v2.5)' TED/_MEICA_V001_mefc.nii
3dNotes -h '/data/SFIM/Apps/me-ica/meica.py -e 17.5,35.3,53.1 -d pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii.gz -a SBJ01_Anat_bc_ns.nii.gz --MNI --no_skullstrip --keep_int --prefix _MEICA_V001 --label _MEICA_V001 --script_only (Full ICA coeff. set for component assessment, produced by ME-ICA v2.5)' TED/_MEICA_V001_mefc.nii
3dNotes -h '/data/SFIM/Apps/me-ica/meica.py -e 17.5,35.3,53.1 -d pb01.SBJ01_AUDIO_Gating_Run01_E01.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E02.discard.nii.gz,pb01.SBJ01_AUDIO_Gating_Run01_E03.discard.nii.gz -a SBJ01_Anat_bc_ns.nii.gz --MNI --no_skullstrip --keep_int --prefix _MEICA_V001 --label _MEICA_V001 --script_only (T2* weighted average of ME time series, produced by ME-ICA v2.5)' TED/_MEICA_V001_tsoc.nii
nifti_tool -mod_hdr -mod_field sform_code 2 -mod_field qform_code 2 -infiles TED/_MEICA_V001_tsoc.nii -overwrite
nifti_tool -mod_hdr -mod_field sform_code 2 -mod_field qform_code 2 -infiles TED/_MEICA_V001_medn.nii -overwrite
nifti_tool -mod_hdr -mod_field sform_code 2 -mod_field qform_code 2 -infiles TED/_MEICA_V001_mefc.nii -overwrite
nifti_tool -mod_hdr -mod_field sform_code 2 -mod_field qform_code 2 -infiles TED/_MEICA_V001_mefl.nii -overwrite
gzip -f TED/_MEICA_V001_medn.nii TED/_MEICA_V001_mefc.nii TED/_MEICA_V001_tsoc.nii TED/_MEICA_V001_mefl.nii
mv TED/_MEICA_V001_medn.nii.gz TED/_MEICA_V001_mefc.nii.gz TED/_MEICA_V001_tsoc.nii.gz TED/_MEICA_V001_mefl.nii.gz /data/jangrawdc/MEData/PrcsData/SBJ01/DXX_SBJ01_AUDIO_Gating_Run01
