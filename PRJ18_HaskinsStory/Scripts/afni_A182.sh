#!/bin/bash


fastloc()
{
	cd $1

	afni_proc.py -subj_id $1 -script afni_fastloc_${1}.tcsh -out_dir $1.fastloc \
	-dsets func_fastloc/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3D*.nii.gz \
	-anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -volreg_warp_dxyz 3 \
	-tlrc_opts_at -init_xform AUTO_CENTER \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 -volreg_align_to first  \
	-align_opts_aea -giant_move \
	-regress_stim_times stim_times/stim_times_fastloc/times* \
	-regress_stim_labels c1 c2 c3 c4 \
	-regress_local_times \
	-regress_basis 'GAM' \
	-regress_reml_exec \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-num_glt 13 \
	-gltsym 'SYM: +c1' -glt_label 1 'print' \
	-gltsym 'SYM: +c2' -glt_label 2 'speech' \
	-gltsym 'SYM: +c3' -glt_label 3 'false font' \
	-gltsym 'SYM: +c4' -glt_label 4 'vocod speech' \
	-gltsym 'SYM: +c1 -c3' -glt_label 5 'print-falsefont' \
	-gltsym 'SYM: +c2 -c4' -glt_label 6 'speech-vocod' \
	-gltsym 'SYM: +c1 -c2' -glt_label 7 'print-speech' \
	-gltsym 'SYM: +c3 -c4' -glt_label 8 'falsefont-vocod' \
	-gltsym 'SYM: +c1 +c2 -c3 -c4' -glt_label 9 'speech+print - falsefont+vocod' \
	-gltsym 'SYM: +c1 +c3 -c2 -c4' -glt_label 10 'print+falsefont - speech+vocod' \
	-gltsym 'SYM: +c1 -c2 -c3 +c4' -glt_label 11 'interaction' \
	-gltsym 'SYM: -c1 +c2' -glt_label 12 'speech-print' \
    -gltsym 'SYM: +c1 +c2' -glt_label 13 'speech+print' \
	-jobs 12 \
	-bash -execute
	
	cd ../
}

rest()
{
	cd $1

	afni_proc.py -subj_id ${1} -script afni_rest_${1}.tcsh -out_dir ${1}.rest \
	-dsets func_rest/*ep2dbold*  			\
	-blocks despike tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3D*.nii.gz 	\
	-tshift_opts_ts -tpattern alt+z2 \
	-anat_has_skull yes						\
	-tcat_remove_first_trs 6 				\
	-volreg_align_e2a -volreg_tlrc_warp -volreg_warp_dxyz 3 \
	-tlrc_opts_at -init_xform AUTO_CENTER   \
	-blur_size 8 -volreg_align_to first  \
	-align_opts_aea -giant_move 			\
	-regress_motion_per_run                 \
	-regress_censor_motion 0.3              \
	-regress_censor_outliers 0.1            \
	-regress_anaticor \
	-regress_bandpass 0.01 0.1              \
	-regress_apply_mot_types demean deriv   \
	-regress_run_clustsim no                \
	-regress_est_blur_errts					\
	-regress_opts_3dD -jobs 8 -rout				\
	-bash -execute
	
	cd ../
}

sal()
{
	cd $1

	afni_proc.py -subj_id ${1} -script afni_sal_${1}.tcsh -out_dir ${1}.sal \
	-dsets func_sal/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3DMPRAGE*.nii.gz \
	-anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -tlrc_opts_at -init_xform AUTO_CENTER \
	-volreg_tlrc_warp \
	-align_opts_aea -giant_move \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 \
	-volreg_align_to first -volreg_warp_dxyz 3 \
	-regress_stim_times stim_times/stim_times_sal/sal*.txt  \
	-regress_stim_labels c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 \
	-regress_local_times \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_basis 'GAM' \
	-regress_reml_exec \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-num_glt 24 \
	-gltsym 'SYM: +c1' -glt_label 1    'P1_Con' \
	-gltsym 'SYM: +c2' -glt_label 2    'P1_Unc' \
	-gltsym 'SYM: +c3' -glt_label 3    'P1_Nov' \
	-gltsym 'SYM: +c4' -glt_label 4    'P1_Wrd' \
	-gltsym 'SYM: +c5' -glt_label 5    'P1_Color' \
	-gltsym 'SYM: +c6' -glt_label 6    'P2_Con' \
	-gltsym 'SYM: +c7' -glt_label 7    'P2_Unc' \
	-gltsym 'SYM: +c8' -glt_label 8    'P2_Nov' \
	-gltsym 'SYM: +c9' -glt_label 9    'P2_Wrd' \
	-gltsym 'SYM: +c10' -glt_label 10  'P2_Color' \
	-gltsym 'SYM: +c1 +c6' -glt_label 11   'Con' \
	-gltsym 'SYM: +c2 +c7' -glt_label 12   'Unc' \
	-gltsym 'SYM: +c3 +c8' -glt_label 13   'Nov' \
	-gltsym 'SYM: +c4 +c9' -glt_label 14   'Wrd' \
	-gltsym 'SYM: +c5 +c10' -glt_label 15  'Color' \
	-gltsym 'SYM: +c1 -c2 +c6 -c7' -glt_label 16             'Con-Unc' \
	-gltsym 'SYM: +c1 -c3 +c6 -c8' -glt_label 17             'Con-Nov' \
	-gltsym 'SYM: +c1 -c4 +c6 -c9' -glt_label 18             'Con-Wrd' \
	-gltsym 'SYM: +c2 -c3 +c7 -c8' -glt_label 19             'Unc-Nov' \
	-gltsym 'SYM: +c2 -c4 +c7 -c9' -glt_label 20             'Unc-Wrd' \
	-gltsym 'SYM: +c3 -c4 +c8 -c9' -glt_label 21             'Nov-Word' \
	-gltsym 'SYM: +c1 +c2 -2*c3 +c6 +c7 -2*c8' -glt_label 22 'Train-Nov' \
	-gltsym 'SYM: +c1 +c2 -2*c4 +c6 +c7 -2*c9' -glt_label 23 'Train-Wrd' \
	-jobs 8 \
	-bash -execute

	cd ../

}

old_sal()
{
	cd $1

	afni_proc.py -subj_id ${1} -script afni_sal_${1}.tcsh -out_dir ${1}.sal \
	-dsets func_sal/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3DMPRAGE*.nii.gz \
	-anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -tlrc_opts_at -init_xform AUTO_CENTER \
	-align_opts_aea -giant_move \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 \
	-volreg_align_to first -volreg_warp_dxyz 3 \
	-regress_stim_times stim_times/stim_times_sal/sal*.txt  \
	-regress_stim_labels c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 \
	-regress_local_times \
    -regress_est_blur_epits \
    -regress_est_blur_errts \
	-regress_basis 'GAM' \
	-regress_reml_exec \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-num_glt 40 \
    -gltsym 'SYM: +c1' -glt_label 1    'P1_TrainC(onsolidated)' \
	-gltsym 'SYM: +c2' -glt_label 2    'P1_TrainU(nconsolidated)' \
	-gltsym 'SYM: +c3' -glt_label 3    'P1_Untrain' \
    -gltsym 'SYM: +c4' -glt_label 4    'P1_Word' \
 	-gltsym 'SYM: +c5' -glt_label 5    'P1_ColorWord' \
    -gltsym 'SYM: +c6' -glt_label 6    'P2_TrainC' \
    -gltsym 'SYM: +c7' -glt_label 7    'P2_TrainU' \
    -gltsym 'SYM: +c8' -glt_label 8    'P2_Untrain' \
    -gltsym 'SYM: +c9' -glt_label 9    'P2_Word' \
    -gltsym 'SYM: +c10' -glt_label 10  'P2_ColorWord' \
    -gltsym 'SYM: +c1 +c6' -glt_label 11   'TrainC' \
    -gltsym 'SYM: +c2 +c7' -glt_label 12   'TrainU' \
    -gltsym 'SYM: +c3 +c8' -glt_label 13   'Untrain' \
    -gltsym 'SYM: +c4 +c9' -glt_label 14   'Word' \
    -gltsym 'SYM: +c5 +c10' -glt_label 15  'ColorWord' \
    -gltsym 'SYM: +c1 -c2' -glt_label 16       'P1_TrainC-TrainU' \
    -gltsym 'SYM: +c1 +c2 -2*c3' -glt_label 17 'P1_Train-Untrain' \
    -gltsym 'SYM: +c1 -c4' -glt_label 18       'P1_TrainC-Word' \
    -gltsym 'SYM: +c2 -c4' -glt_label 19       'P1_TrainU-Word' \
    -gltsym 'SYM: +c3 -c4' -glt_label 20       'P1_Untrain-Word' \
    -gltsym 'SYM: +c6 -c2' -glt_label 21       'P2_TrainC-TrainU' \
    -gltsym 'SYM: +c6 +c7 -2*c8' -glt_label 22 'P2_Train-Untrain' \
    -gltsym 'SYM: +c6 -c9' -glt_label 23       'P2_TrainC-Word' \
    -gltsym 'SYM: +c7 -c9' -glt_label 24       'P2_TrainU-Word' \
    -gltsym 'SYM: +c8 -c9' -glt_label 25       'P2_Untrain-Word' \
    -gltsym 'SYM: +c1 -c2 +c6 -c7' -glt_label 26             'P1P2_TrainC-TrainU' \
    -gltsym 'SYM: +c1 +c2 -2*c3 +c6 +c7 -2*c8' -glt_label 27 'P1P2_Train-Untrain' \
    -gltsym 'SYM: +c1 -c4 +c6 -c9' -glt_label 28             'P1P2_TrainC-Word' \
    -gltsym 'SYM: +c2 -c4 +c7 -c9' -glt_label 29             'P1P2_TrainU-Word' \
    -gltsym 'SYM: +c3 -c4 +c8 -c9' -glt_label 30             'P1P2_Untrain-Word' \
    -gltsym 'SYM: +c1 -c6' -glt_label 31       'P1-P2_TrainC' \
    -gltsym 'SYM: +c2 -c7' -glt_label 32       'P1-P2_TrainU' \
    -gltsym 'SYM: +c3 -c8' -glt_label 33       'P1-P2_Untrain' \
    -gltsym 'SYM: +c4 -c9' -glt_label 34       'P1-P2_Word' \
    -gltsym 'SYM: +c1 -c2 -c6 +c7' -glt_label 35             'P1xP2_TrainC-TrainU' \
    -gltsym 'SYM: +c1 +c2 -2*c3 -c6 -c7 +2*c8' -glt_label 36 'P1xP2_Train-Untrain' \
    -gltsym 'SYM: +c1 -c4 -c6 +c9' -glt_label 37             'P1xP2_TrainC-Word' \
    -gltsym 'SYM: +c2 -c4 -c7 +c9' -glt_label 38             'P1xP2_TrainU-Word' \
    -gltsym 'SYM: +c3 -c4 -c8 +c9' -glt_label 39             'P1xP2_Untrain-Word' \
	-jobs 8 \
	-bash -execute
	
	cd ../
}

srtt()
{
	cd $1

	afni_proc.py -subj_id ${1} -script afni_srtt_${1}.tcsh -out_dir ${1}.srtt \
	-dsets func_srtt/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3D*.nii.gz \
	-anat_has_skull yes \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -tlrc_opts_at -init_xform AUTO_CENTER \
	-align_opts_aea -giant_move \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 \
	-volreg_align_to first -volreg_warp_dxyz 3 \
	-regress_stim_times stim_times/stim_times_srtt/bl?_c1*.txt stim_times/stim_times_srtt/bl?_c2*.txt \
	-regress_stim_labels uns1 uns2 uns3 str1 str2 str3  \
	-regress_local_times \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_basis 'dmBLOCK(1)' \
	-regress_stim_types AM1 \
	-regress_reml_exec \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-num_glt 10 \
	-gltsym 'SYM: +uns1 +uns2 +uns3' -glt_label 1 'unstructured' \
	-gltsym 'SYM: +str1 +str2 +str3' -glt_label 2 'structured' \
	-gltsym 'SYM: +uns1 +uns2 +uns3 -str1 -str2 -str3' -glt_label 3 'unstructured-structured' \
	-gltsym 'SYM: +str1 -uns1' -glt_label 4 'structured-unstructured BL1' \
	-gltsym 'SYM: +str2 -uns2' -glt_label 5 'structured-unstructured BL2' \
	-gltsym 'SYM: +str3 -uns3' -glt_label 6 'structured-unstructured BL3' \
	-jobs 10 \
	-bash -execute
	
	cd ../
}

story()
{
	cd $1

	afni_proc.py -subj_id ${1} -script afni_story_${1}.tcsh -out_dir ${1}.story \
	-dsets func_story/*ep2dbold*  \
	-blocks tshift align tlrc volreg blur mask regress \
	-copy_anat anat/*Sag3D*.nii.gz \
	-tcat_remove_first_trs 6 \
	-volreg_align_e2a -tlrc_opts_at -init_xform AUTO_CENTER \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 -volreg_align_to first -volreg_warp_dxyz 3 \
	-align_opts_aea -giant_move \
	-regress_stim_times stim_times/stim_times_story/c1*.txt stim_times/stim_times_story/c2*.txt \
	-regress_stim_labels c1 c2 \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_reml_exec \
	-regress_local_times \
	-regress_basis 'dmBLOCK(0)' \
	-regress_stim_types AM1 \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_opts_3dD \
	-stim_times_subtract 12 \
	-num_glt 5 \
	-gltsym 'SYM: +c1' -glt_label 1 'audio' \
	-gltsym 'SYM: +c2' -glt_label 2 'visual' \
	-gltsym 'SYM: +c1 -c2' -glt_label 3 'audio-visual' \
	-gltsym 'SYM: -c1 +c2' -glt_label 4 'visual-audio' \
	-jobs 12 \
	-bash -execute
	
	cd ../
}

val()
{
	cd $1 
	
	afni_proc.py -subj_id $1 -script afni_val_${1}.tcsh -out_dir $1.val \
		-dsets func_val/*ep2dbold*  \
		-blocks tshift align tlrc volreg blur mask regress \
		-copy_anat anat/*Sag3D*.nii.gz \
		-anat_has_skull yes \
		-tcat_remove_first_trs 6 \
		-volreg_align_e2a -volreg_warp_dxyz 3 \
		-tlrc_opts_at -init_xform AUTO_CENTER \
		-tshift_opts_ts -tpattern alt+z2 \
		-blur_size 8 -volreg_align_to first  \
		-align_opts_aea -giant_move \
		-regress_stim_times stim_times/stim_times_val/val-afni_cond?.txt \
		-regress_stim_labels c1 c2 c3 c4 c5 c6 c7 \
		-regress_local_times \
		-regress_basis 'GAM' \
		-regress_reml_exec \
		-regress_est_blur_epits \
		-regress_est_blur_errts \
		-regress_censor_outliers 0.1 \
		-regress_censor_motion 0.3 \
		-regress_opts_3dD \
		-num_glt 25 \
		-gltsym 'SYM: +c1' -glt_label 1 'con_psw1' \
		-gltsym 'SYM: +c2' -glt_label 2 'exc_psw1' \
		-gltsym 'SYM: +c3' -glt_label 3 'uncon_psw2' \
		-gltsym 'SYM: +c4' -glt_label 4 'exc_psw2' \
		-gltsym 'SYM: +c5' -glt_label 5 'untr_psw' \
		-gltsym 'SYM: +c6' -glt_label 6 'real_word' \
		-gltsym 'SYM: +c7' -glt_label 7 'color_names' \
		-gltsym 'SYM: +c1 +c2' -glt_label 8 'con_psw1+exc_psw1' \
		-gltsym 'SYM: +c3 +c4' -glt_label 9 'uncon_psw2+exc_psw2' \
		-gltsym 'SYM: +c1 +c2 -2*c5' -glt_label 10 'con_psw1+exc_psw1-untr_psw' \
		-gltsym 'SYM: +c3 +c4 -2*c5' -glt_label 11 'uncon_psw2+exc_psw-untr_psw' \
		-gltsym 'SYM: +c1 +c2 -2*c6' -glt_label 12 'con_psw1+exc_psw1-real_word' \
		-gltsym 'SYM: +c3 +c4 -2*c6' -glt_label 13 'uncon_psw2+exc_psw2-real_word' \
		-gltsym 'SYM: +c1 +c2 -c3 -c4' -glt_label 14 'con_psw1+exc_psw1-uncon_psw2+exc_psw2' \
		-gltsym 'SYM: +c1 -c5' -glt_label 15 'con_psw1-untr_psw' \
		-gltsym 'SYM: +c2 -c5' -glt_label 16 'exc_psw1-untr_psw' \
		-gltsym 'SYM: +c3 -c5' -glt_label 17 'uncon_psw2-untr_psw' \
		-gltsym 'SYM: +c4 -c5' -glt_label 18 'exc_psw2-untr_psw' \
		-gltsym 'SYM: +c1 -c6' -glt_label 19 'con_psw1-real_word' \
		-gltsym 'SYM: +c2 -c6' -glt_label 20 'exc_psw1-real_word' \
		-gltsym 'SYM: +c3 -c6' -glt_label 21 'uncon_psw2-real_word' \
		-gltsym 'SYM: +c4 -c6' -glt_label 22 'exc_psw2-real_word' \
		-gltsym 'SYM: +c1 -c3' -glt_label 23 'con_psw1-uncon_psw2' \
		-gltsym 'SYM: +c2 -c4' -glt_label 24 'exc_psw1-exc_psw2' \
		-jobs 12 \
		-bash -execute
		
		cd ../
}

for aSub in $@
do
	echo "Subject $aSub: "
	if [ -e $aSub/func_fastloc ]; then
		echo "Running fastloc"
		fastloc $aSub;
	fi
	
	if [ -e $aSub/func_rest ]; then
		echo "Running Resting State"
		rest $aSub;
	fi
	
	if [ -e $aSub/func_srtt ]; then
		echo "Running SRTT"
		srtt $aSub;
	fi
	
	if [ -e $aSub/func_story ]; then
		echo "Running Story"
		story $aSub;
	fi
	
	if [ -e $aSub/func_sal ]; then
		echo "Running SAL"
		sal $aSub;
	fi
	
	if [ -e $aSub/func_val ]; then
		echo "Running VAL"
		val $aSub
	fi
	
	if [ ! -e $aSub/qc ]; then
		echo "Running QC"
		./gen_qc.sh $aSub
	fi
	
	if [ -e $aSub/dti ]; then
		echo "Running DTI"
		#./dti_process.sh $aSub
	fi	

	#sh gen_snapshots.sh $aSub

done

