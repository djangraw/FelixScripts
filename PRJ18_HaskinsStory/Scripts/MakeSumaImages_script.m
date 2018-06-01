% MakeSumaImages_script.m
%
% Created 5/29/18 by DJ.

%% 1-grp Aud-Vis, q<0.01
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD-VIS.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_1grp+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    20,21,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_1grp_aud-vis_lim3_q01.jpg',[],3,'0.01 *q','');

%% 1-grp Aud+Vis, q<0.01
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD+VIS.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_1grp+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    14,15,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_1grp_aud+vis_lim1p5_q01.jpg',[],1.5,'0.01 *q','');

%% 1-grp Aud, q<0.01
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_1grp+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    2,3,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_1grp_aud_lim1p5_q01.jpg',[],1.5,'0.01 *q','');

%% 1-grp Vis, q<0.01
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_VIS.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_1grp+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    8,9,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_1grp_vis_lim1p5_q01.jpg',[],1.5,'0.01 *q','');





%% 1-grp Aud-Vis, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_1grp_aud-vis_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_1grp_aud-vis_lim3_p01_a05.jpg',[],3,'0','');

%% 1-grp Aud+Vis, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD+VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_1grp_aud+vis_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_1grp_aud+vis_lim1p5_p01_a05.jpg',[],1.5,'0','');

%% 1-grp Aud, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_1grp_aud_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_1grp_aud_lim1p5_p01_a05.jpg',[],1.5,'0','');

%% 1-grp Vis, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_1grp_vis_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_1grp_vis_lim1p5_p01_a05.jpg',[],1.5,'0','');





%% 2-grp Aud-Vis, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_2grp_aud-vis_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_2grp_aud-vis_lim0p3_p01_a05.jpg',[],0.3,'0','');

%% 2-grp Aud+Vis, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD+VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_2grp_aud+vis_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_2grp_aud+vis_lim0p3_p01_a05.jpg',[],0.3,'0','');

%% 2-grp Aud, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_AUD_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_2grp_aud_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_2grp_aud_lim0p3_p01_a05.jpg',[],0.3,'0','');

%% 2-grp Vis, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2','TEMP_VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    'ttest_allSubj_2grp_vis_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_2grp_vis_lim0p3_p01_a05.jpg',[],0.3,'0','');





%% 1-grp ISC, q<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/IscResults_d2/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    '3dLME_OneGroup_n42_Automask+tlrc.HEAD','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,1,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_ISC_1grp_lim0p4_q01.jpg',[],0.4,'0.01 *q','');

%% 2-grp ISC top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/IscResults_d2/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_ISC_top-bot_lim0p1_p01_a05.jpg',[],0.1,'0','');

%% 2-grp ISC top-topbot, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/IscResults_d2/Group','TEMP_AUD+VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-topbot_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_ISC_top-topbot_lim0p1_p01_a05.jpg',[],0.1,'0','');

%% 2-grp ISC bot-topbot, p<0.01 alpha<0.05
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/IscResults_d2/Group','TEMP_AUD_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    '3dLME_2Grps_readScoreMedSplit_n42_Automask_bot-topbot_clust_p0.01_a0.05_bisided_EE.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_ISC_bot-topbot_lim0p1_p01_a05.jpg',[],0.1,'0','');

%% 2-grp ISC top-bot,q<0.05, 20vox clusters
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/IscResults_d2/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    '3dLME_2Grps_readScoreMedSplit_n42_Automask_G2-G1_q01_20vox-clustermask+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_ISC_top-bot_lim0p1_q05_20vox.jpg',[],0.1,'0','');



%% 2-grp ISC top-bot, p<0.01 alpha<0.05: CLUSTER MASK
SetUpSumaMontage_4view('/data/NIMH_Haskins/a182/IscResults_d2/Group','TEMP_AUD-VIS_CLUSTMAP.tcsh','MNI152_2009_SurfVol.nii',...
    '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','','SUMA_IMAGES/suma_4view_ISC_top-bot_clustmap_p01_a05.jpg',[],32,'0','roi_i32');
