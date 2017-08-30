#/data/steelad/Baker/BIOWULF/me-ica//meica.py -d echo_001_dataset+orig,echo_002_dataset+orig,echo_003_dataset+orig -e 14.9,28.4,41.9 -a HV_023.anat.ss+orig --no_skullstrip -b 60s --fres=3 --prefix rest_1 --cpus=8 --OVERWRITE

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

echo Oblique data detected.
echo "
++++++++++++++++++++++++" 
echo +* "Set up script run environment" 
set -e
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
export AFNI_3dDespike_NEW=YES
rm -rf meica.echo_001_dataset
mkdir -p meica.echo_001_dataset
cp _meica_echo_001_dataset.sh meica.echo_001_dataset/
cd meica.echo_001_dataset
echo "
++++++++++++++++++++++++" 
echo +* "Deoblique, unifize, skullstrip, and/or autobox anatomical, in starting directory (may take a little while)" 
if [ ! -e /data/steelad/Baker/SubjectData/HV_023/rest_1/HV_023.anat.ss_do.nii.gz ]; then 3dWarp -overwrite -prefix /data/steelad/Baker/SubjectData/HV_023/rest_1/HV_023.anat.ss_do.nii.gz -deoblique /data/steelad/Baker/SubjectData/HV_023/rest_1/HV_023.anat.ss+orig; fi
echo "
++++++++++++++++++++++++" 
echo +* "Copy in functional datasets, reset NIFTI tags as needed" 
3dcalc -a /data/steelad/Baker/SubjectData/HV_023/rest_1/echo_001_dataset+orig -expr 'a' -prefix ./echo_001_dataset.nii
3dcalc -a /data/steelad/Baker/SubjectData/HV_023/rest_1/echo_002_dataset+orig -expr 'a' -prefix ./echo_002_dataset.nii
3dcalc -a /data/steelad/Baker/SubjectData/HV_023/rest_1/echo_003_dataset+orig -expr 'a' -prefix ./echo_003_dataset.nii
echo "
++++++++++++++++++++++++" 
echo +* "Calculate and save motion and obliquity parameters, despiking first if not disabled, and separately save and mask the base volume" 
3dWarp -verb -card2oblique ./echo_001_dataset.nii[0] -overwrite  -newgrid 1.000000 -prefix ./HV_023.anat.ss_ob.nii.gz /data/steelad/Baker/SubjectData/HV_023/rest_1/HV_023.anat.ss_do.nii.gz | \grep  -A 4 '# mat44 Obliquity Transformation ::'  > echo_001_dataset_obla2e_mat.1D
3dDespike -overwrite -prefix ./echo_001_dataset_vrA.nii.gz ./echo_001_dataset.nii 
3daxialize -overwrite -prefix ./echo_001_dataset_vrA.nii.gz ./echo_001_dataset_vrA.nii.gz
3dcalc -a ./echo_001_dataset_vrA.nii.gz[30]  -expr 'a' -prefix eBbase.nii.gz 
3dvolreg -overwrite -tshift -quintic  -prefix ./echo_001_dataset_vrA.nii.gz -base eBbase.nii.gz -dfile ./echo_001_dataset_vrA.1D -1Dmatrix_save ./echo_001_dataset_vrmat.aff12.1D ./echo_001_dataset_vrA.nii.gz
1dcat './echo_001_dataset_vrA.1D[1..6]{30..$}' > motion.1D 
echo "
++++++++++++++++++++++++" 
echo +* "Preliminary preprocessing of functional datasets: despike, tshift, deoblique, and/or axialize" 
echo --------"Preliminary preprocessing dataset echo_001_dataset+orig of TE=14.9ms to produce e1_ts+orig" 
3dDespike -overwrite -prefix ./echo_001_dataset_pt.nii.gz echo_001_dataset.nii
3dTshift -heptic  -prefix ./e1_ts+orig ./echo_001_dataset_pt.nii.gz
3daxialize  -overwrite -prefix ./e1_ts+orig ./e1_ts+orig
3drefit -deoblique -TR 2.0 e1_ts+orig
echo --------"Preliminary preprocessing dataset echo_002_dataset+orig of TE=28.4ms to produce e2_ts+orig" 
3dDespike -overwrite -prefix ./echo_002_dataset_pt.nii.gz echo_002_dataset.nii
3dTshift -heptic  -prefix ./e2_ts+orig ./echo_002_dataset_pt.nii.gz
3daxialize  -overwrite -prefix ./e2_ts+orig ./e2_ts+orig
3drefit -deoblique -TR 2.0 e2_ts+orig
echo --------"Preliminary preprocessing dataset echo_003_dataset+orig of TE=41.9ms to produce e3_ts+orig" 
3dDespike -overwrite -prefix ./echo_003_dataset_pt.nii.gz echo_003_dataset.nii
3dTshift -heptic  -prefix ./e3_ts+orig ./echo_003_dataset_pt.nii.gz
3daxialize  -overwrite -prefix ./e3_ts+orig ./e3_ts+orig
3drefit -deoblique -TR 2.0 e3_ts+orig
3dBrickStat -mask eBbase.nii.gz -percentile 50 1 50 e1_ts+orig[30] > gms.1D
gms=`cat gms.1D`; gmsa=($gms); p50=${gmsa[1]}
echo "
++++++++++++++++++++++++" 
echo +* "Prepare T2* and S0 volumes for use in functional masking and (optionally) anatomical-functional coregistration (takes a little while)." 
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply echo_001_dataset_vrmat.aff12.1D'{30..35}' -base eBbase.nii.gz -input e1_ts+orig'[30..35]' -prefix e1_vrA.nii.gz
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply echo_001_dataset_vrmat.aff12.1D'{30..35}' -base eBbase.nii.gz -input e2_ts+orig'[30..35]' -prefix e2_vrA.nii.gz
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply echo_001_dataset_vrmat.aff12.1D'{30..35}' -base eBbase.nii.gz -input e3_ts+orig'[30..35]' -prefix e3_vrA.nii.gz
3dZcat -prefix basestack.nii.gz  e1_vrA.nii.gz e2_vrA.nii.gz e3_vrA.nii.gz
/usr/local/Python/2.7.7/bin/python /data/steelad/Baker/BIOWULF/me-ica/meica.libs/t2smap.py -d basestack.nii.gz -e 14.9,28.4,41.9
3dUnifize -prefix ./ocv_uni+orig ocv.nii
3dSkullStrip -prefix ./ocv_ss.nii.gz -overwrite -input ocv_uni+orig
3dcalc -overwrite -a t2svm.nii -b ocv_ss.nii.gz -expr 'a*ispositive(a)*step(b)' -prefix t2svm_ss.nii.gz
3dcalc -overwrite -a s0v.nii -b ocv_ss.nii.gz -expr 'a*ispositive(a)*step(b)' -prefix s0v_ss.nii.gz
3daxialize -overwrite -prefix t2svm_ss.nii.gz t2svm_ss.nii.gz
3daxialize -overwrite -prefix ocv_ss.nii.gz ocv_ss.nii.gz
3daxialize -overwrite -prefix s0v_ss.nii.gz s0v_ss.nii.gz
echo "
++++++++++++++++++++++++" 
echo +* "Copy anatomical into ME-ICA directory and process warps" 
cp /data/steelad/Baker/SubjectData/HV_023/rest_1/HV_023.anat.ss_do.nii.gz* .
echo --------"Using alignp_mepi_anat.py to drive T2*-map weighted anatomical-functional coregistration" 
3daxialize -overwrite -prefix ./HV_023.anat.ss_ob.nii.gz ./HV_023.anat.ss_ob.nii.gz
/usr/local/Python/2.7.7/bin/python /data/steelad/Baker/BIOWULF/me-ica/meica.libs/alignp_mepi_anat.py -t t2svm_ss.nii.gz -a HV_023.anat.ss_ob.nii.gz -p mepi 
cp alignp.mepi/mepi_al_mat.aff12.1D ./HV_023.anat.ss_al_mat.aff12.1D
cat_matvec -ONELINE   echo_001_dataset_obla2e_mat.1D HV_023.anat.ss_al_mat.aff12.1D -I > echo_001_dataset_wmat.aff12.1D
cat_matvec -ONELINE   echo_001_dataset_obla2e_mat.1D HV_023.anat.ss_al_mat.aff12.1D -I  echo_001_dataset_vrmat.aff12.1D  > echo_001_dataset_vrwmat.aff12.1D
echo "
++++++++++++++++++++++++" 
echo +* "Extended preprocessing of functional datasets" 

echo --------"Preparing functional masking for this ME-EPI run" 
3dZeropad  -I 18 -S 18 -A 18 -P 18 -L 18 -R 18  -prefix eBvrmask.nii.gz ocv_ss.nii.gz[0]
voxsize=`ccalc $(3dinfo -voxvol eBvrmask.nii.gz)**.33`
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply echo_001_dataset_wmat.aff12.1D -base eBvrmask.nii.gz -input eBvrmask.nii.gz -prefix ./eBvrmask.nii.gz -master HV_023.anat.ss_do.nii.gz -mast_dxyz 3
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply echo_001_dataset_wmat.aff12.1D -base eBvrmask.nii.gz -input t2svm_ss.nii.gz -prefix ./t2svm_ss_vr.nii.gz -master HV_023.anat.ss_do.nii.gz -mast_dxyz 3
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply echo_001_dataset_wmat.aff12.1D -base eBvrmask.nii.gz -input ocv_uni+orig -prefix ./ocv_uni_vr.nii.gz -master HV_023.anat.ss_do.nii.gz -mast_dxyz 3
3dAllineate -overwrite -final NN -NN -float -1Dmatrix_apply echo_001_dataset_wmat.aff12.1D -base eBvrmask.nii.gz -input s0v_ss.nii.gz -prefix ./s0v_ss_vr.nii.gz -master HV_023.anat.ss_do.nii.gz -mast_dxyz 3
3dcalc -float -a eBvrmask.nii.gz -expr 'notzero(a)' -overwrite -prefix eBvrmask.nii.gz
echo --------"Apply combined normalization/co-registration/motion correction parameter set to e1_ts+orig" 
3dAllineate -final cubic -cubic -float -1Dmatrix_apply echo_001_dataset_vrwmat.aff12.1D -base eBvrmask.nii.gz -input  e1_ts+orig -prefix ./e1_vr.nii.gz
3dTstat -min -prefix ./e1_vr_min.nii.gz ./e1_vr.nii.gz
3dcalc -a eBvrmask.nii.gz -b e1_vr_min.nii.gz -expr 'step(a)*step(b)' -overwrite -prefix eBvrmask.nii.gz 
3dcalc -float -overwrite -a eBvrmask.nii.gz -b ./e1_vr.nii.gz[30..$] -expr 'step(a)*b' -prefix ./e1_sm.nii.gz 
3dcalc -float -overwrite -a ./e1_sm.nii.gz -expr "a*10000/${p50}" -prefix ./e1_sm.nii.gz
3dTstat -prefix ./e1_mean.nii.gz ./e1_sm.nii.gz
mv e1_sm.nii.gz e1_in.nii.gz
3dcalc -float -overwrite -a ./e1_in.nii.gz -b ./e1_mean.nii.gz -expr 'a+b' -prefix ./e1_in.nii.gz
3dTstat -stdev -prefix ./e1_std.nii.gz ./e1_in.nii.gz
rm -f e1_ts+orig* e1_vr.nii.gz e1_sm.nii.gz
echo --------"Apply combined normalization/co-registration/motion correction parameter set to e2_ts+orig" 
3dAllineate -final cubic -cubic -float -1Dmatrix_apply echo_001_dataset_vrwmat.aff12.1D -base eBvrmask.nii.gz -input  e2_ts+orig -prefix ./e2_vr.nii.gz
3dcalc -float -overwrite -a eBvrmask.nii.gz -b ./e2_vr.nii.gz[30..$] -expr 'step(a)*b' -prefix ./e2_sm.nii.gz 
3dcalc -float -overwrite -a ./e2_sm.nii.gz -expr "a*10000/${p50}" -prefix ./e2_sm.nii.gz
3dTstat -prefix ./e2_mean.nii.gz ./e2_sm.nii.gz
mv e2_sm.nii.gz e2_in.nii.gz
3dcalc -float -overwrite -a ./e2_in.nii.gz -b ./e2_mean.nii.gz -expr 'a+b' -prefix ./e2_in.nii.gz
3dTstat -stdev -prefix ./e2_std.nii.gz ./e2_in.nii.gz
rm -f e2_ts+orig* e2_vr.nii.gz e2_sm.nii.gz
echo --------"Apply combined normalization/co-registration/motion correction parameter set to e3_ts+orig" 
3dAllineate -final cubic -cubic -float -1Dmatrix_apply echo_001_dataset_vrwmat.aff12.1D -base eBvrmask.nii.gz -input  e3_ts+orig -prefix ./e3_vr.nii.gz
3dcalc -float -overwrite -a eBvrmask.nii.gz -b ./e3_vr.nii.gz[30..$] -expr 'step(a)*b' -prefix ./e3_sm.nii.gz 
3dcalc -float -overwrite -a ./e3_sm.nii.gz -expr "a*10000/${p50}" -prefix ./e3_sm.nii.gz
3dTstat -prefix ./e3_mean.nii.gz ./e3_sm.nii.gz
mv e3_sm.nii.gz e3_in.nii.gz
3dcalc -float -overwrite -a ./e3_in.nii.gz -b ./e3_mean.nii.gz -expr 'a+b' -prefix ./e3_in.nii.gz
3dTstat -stdev -prefix ./e3_std.nii.gz ./e3_in.nii.gz
rm -f e3_ts+orig* e3_vr.nii.gz e3_sm.nii.gz
3dZcat -overwrite -prefix zcat_ffd.nii.gz   ./e1_in.nii.gz ./e2_in.nii.gz ./e3_in.nii.gz
3dcalc -float -overwrite -a zcat_ffd.nii.gz[0] -expr 'notzero(a)' -prefix zcat_mask.nii.gz
echo "
++++++++++++++++++++++++" 
echo +* "Perform TE-dependence analysis (takes a good while)" 
/usr/local/Python/2.7.7/bin/python /data/steelad/Baker/BIOWULF/me-ica/meica.libs/tedana.py -e 14.9,28.4,41.9  -d zcat_ffd.nii.gz --sourceTEs=-1 --kdaw=10 --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 
#
echo "
++++++++++++++++++++++++" 
echo +* "Copying results to start directory" 
cp TED/ts_OC.nii TED/rest_1_tsoc.nii
cp TED/dn_ts_OC.nii TED/rest_1_medn.nii
cp TED/betas_hik_OC.nii TED/rest_1_mefc.nii
cp TED/betas_OC.nii TED/rest_1_mefl.nii
cp TED/comp_table.txt /data/steelad/Baker/SubjectData/HV_023/rest_1/rest_1_ctab.txt
3dNotes -h '/data/steelad/Baker/BIOWULF/me-ica//meica.py -d echo_001_dataset+orig,echo_002_dataset+orig,echo_003_dataset+orig -e 14.9,28.4,41.9 -a HV_023.anat.ss+orig --no_skullstrip -b 60s --fres=3 --prefix rest_1 --cpus=8 --OVERWRITE (Denoised timeseries (including thermal noise), produced by ME-ICA v2.5)' TED/rest_1_medn.nii
3dNotes -h '/data/steelad/Baker/BIOWULF/me-ica//meica.py -d echo_001_dataset+orig,echo_002_dataset+orig,echo_003_dataset+orig -e 14.9,28.4,41.9 -a HV_023.anat.ss+orig --no_skullstrip -b 60s --fres=3 --prefix rest_1 --cpus=8 --OVERWRITE (Denoised ICA coeff. set for ME-ICR seed-based FC analysis, produced by ME-ICA v2.5)' TED/rest_1_mefc.nii
3dNotes -h '/data/steelad/Baker/BIOWULF/me-ica//meica.py -d echo_001_dataset+orig,echo_002_dataset+orig,echo_003_dataset+orig -e 14.9,28.4,41.9 -a HV_023.anat.ss+orig --no_skullstrip -b 60s --fres=3 --prefix rest_1 --cpus=8 --OVERWRITE (Full ICA coeff. set for component assessment, produced by ME-ICA v2.5)' TED/rest_1_mefc.nii
3dNotes -h '/data/steelad/Baker/BIOWULF/me-ica//meica.py -d echo_001_dataset+orig,echo_002_dataset+orig,echo_003_dataset+orig -e 14.9,28.4,41.9 -a HV_023.anat.ss+orig --no_skullstrip -b 60s --fres=3 --prefix rest_1 --cpus=8 --OVERWRITE (T2* weighted average of ME time series, produced by ME-ICA v2.5)' TED/rest_1_tsoc.nii
gzip -f TED/rest_1_medn.nii TED/rest_1_mefc.nii TED/rest_1_tsoc.nii TED/rest_1_mefl.nii
mv TED/rest_1_medn.nii.gz TED/rest_1_mefc.nii.gz TED/rest_1_tsoc.nii.gz TED/rest_1_mefl.nii.gz /data/steelad/Baker/SubjectData/HV_023/rest_1
