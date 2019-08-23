% MakeSumaImages_script.m
%
% Created 5/29/18 by DJ.
% Updated 5/1/19 by DJ - added trans, made 8-view
% Updated 8/22/19 by DJ - switched to n68, added csim_pthr param

doPause = false;
% csim_pthr = 0.01;
csim_pthr = 0.002;

% %% 1-grp Aud-Vis, q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD-VIS.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('ttest_allSubj_1grp_minus12+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     20,21,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_1grp_aud-vis_lim0.3_q0.01.jpg',csim_pthr),[],0.3,'0.01 *q','');
% 
% %% 1-grp Aud+Vis, q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD+VIS.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('ttest_allSubj_1grp_minus12+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     14,15,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_1grp_aud+vis_lim0.3_q0.01.jpg',csim_pthr),[],0.3,'0.01 *q','');
% 
% %% 1-grp Aud, q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('ttest_allSubj_1grp_minus12+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     2,3,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_1grp_aud_lim0.3_q0.01.jpg',csim_pthr),[],0.3,'0.01 *q','');
% 
% %% 1-grp Vis, q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_VIS.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('ttest_allSubj_1grp_minus12+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     8,9,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_1grp_vis_lim0.3_q0.01.jpg',csim_pthr),[],0.3,'0.01 *q','');
% 
% 
% 
% 
% 
%% 1-grp Aud-Vis, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('ttest_allSubj_1grp_minus12_aud-vis_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_1grp_aud-vis_lim0.3_p%g_a0.05.jpg',csim_pthr),[],0.3,'0','');
if doPause, pause(60); end
%% 1-grp Aud+Vis, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD+VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('ttest_allSubj_1grp_minus12_aud+vis_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_1grp_aud+vis_lim0.3_p%g_a0.05.jpg',csim_pthr),[],0.3,'0','');
if doPause, pause(60); end
%% 1-grp Aud, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('ttest_allSubj_1grp_minus12_aud_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_1grp_aud_lim0.3_p%g_a0.05.jpg',csim_pthr),[],0.3,'0','');
if doPause, pause(60); end
%% 1-grp Vis, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('ttest_allSubj_1grp_minus12_vis_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_1grp_vis_lim0.3_p%g_a0.05.jpg',csim_pthr),[],0.3,'0','');
if doPause, pause(60); end



%% 2-grp Aud-Vis, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('ttest_allSubj_2grp_minus12_aud-vis_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_2grp_aud-vis_lim0.3_p%g_a0.05.jpg',csim_pthr),[],0.3,'0','');
if doPause, pause(60); end
%% 2-grp Aud+Vis, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD+VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('ttest_allSubj_2grp_minus12_aud+vis_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_2grp_aud+vis_lim0.3_p%g_a0.05.jpg',csim_pthr),[],0.3,'0','');
if doPause, pause(60); end
%% 2-grp Aud, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_AUD_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('ttest_allSubj_2grp_minus12_aud_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_2grp_aud_lim0.3_p%g_a0.05.jpg',csim_pthr),[],0.3,'0','');
if doPause, pause(60); end
%% 2-grp Vis, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/GROUP_block_tlrc','TEMP_VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('ttest_allSubj_2grp_minus12_vis_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_2grp_vis_lim0.3_p%g_a0.05.jpg',csim_pthr),[],0.3,'0','');
if doPause, pause(60); end



% %% 1-grp ISC, q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_1Grp_n68_Automask+tlrc.HEAD','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     0,1,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_1grp_lim0.4_q0.01.jpg',csim_pthr),[],0.4,'0.01 *q','');
% 
% if doPause, pause(60); end
%% 1-grp ISC, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_1Grp_n68_Automask_all_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_1grp_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end
% %% 2-grp ISC top-bot,q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     6,7,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_top-bot_lim0.1_q0.01.jpg',csim_pthr),[],0.1,'0.01 *q','');
% 
% if doPause, pause(60); end
%% 2-grp ISC top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end
%% 2-grp ISC top-topbot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD+VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_top-topbot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_top-topbot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end
%% 2-grp ISC bot-topbot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_bot-topbot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_bot-topbot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end
% %% 2-grp ISC top-bot,q<0.05, 20vox clusters
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_G2-G1_q01_20vox-clustermask+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_top-bot_lim0.1_q05_20vox.jpg',csim_pthr),[],0.1,'0','');
% 
% if doPause, pause(60); end
% %% 2-grp ISC top-bot, p<0.01 alpha<0.05: CLUSTER MASK
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUSTMAP.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_top-bot_clust_p%g_a0.05_bisided_map.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_top-bot_clustmap_p%g_a0.05.jpg',csim_pthr),[],32,'0','roi_i32');



% ====== AUD/VIS/TRANS ISC ======== %

%% 1-grp AUD ISC, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_1GRP_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_1Grp_n68_Automask_aud_all_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_aud_all_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end
%% 1-grp VIS ISC, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_1GRP_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_1Grp_n68_Automask_vis_all_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_vis_all_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end
%% 1-grp TRANS ISC, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_1GRP_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_1Grp_n68_Automask_trans_all_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_trans_all_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end

% ====== AUD/VIS/TRANS 1-GROUP ISC DIFFS ======== %

%% 1-grp AUD-VIS ISC, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_1GRP_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_1Grp_n68_Automask_aud-vis_all_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_aud-vis_all_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end
%% 1-grp TRANS-AUD ISC, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_1GRP_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_1Grp_n68_Automask_trans-aud_all_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_trans-aud_all_lim0.5_p%g_a0.05.jpg',csim_pthr),[],0.5,'0','');

if doPause, pause(60); end
%% 1-grp TRANS-VIS ISC, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_1GRP_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_1Grp_n68_Automask_trans-vis_all_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_trans-vis_all_lim0.5_p%g_a0.05.jpg',csim_pthr),[],0.5,'0','');

if doPause, pause(60); end


% ====== AUD/VIS/TRANS 2-GROUP ISC ======== %


% %% 2-grp AUD ISC top-bot,q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_aud+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     6,7,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_aud_top-bot_lim0.1_q0.01.jpg',csim_pthr),[],0.1,'0.01 *q','');
% 
% if doPause, pause(60); end
%% 2-grp AUD ISC top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_aud_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_aud_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end

% %% 2-grp VIS ISC top-bot,q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_vis+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     6,7,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_vis_top-bot_lim0.1_q0.01.jpg',csim_pthr),[],0.1,'0.01 *q','');
% 
% if doPause, pause(60); end
%% 2-grp VIS ISC top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_vis_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_vis_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end

% %% 2-grp TRANS ISC top-bot,q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_trans+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     6,7,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_trans_top-bot_lim0.1_q0.01.jpg',csim_pthr),[],0.1,'0.01 *q','');
% 
% if doPause, pause(60); end
%% 2-grp TRANS ISC top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_trans_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_trans_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end


% ====== AUD/VIS/TRANS 2-GROUP ISC DIFFS ======== %

% %% 2-grp AUD-VIS ISC top-bot,q<0.01
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_aud-vis+tlrc','suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     6,7,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_aud-vis_top-bot_lim0.6_q0.01.jpg',csim_pthr),[],0.6,'0.01 *q','');
% 
% if doPause, pause(60); end
%% 2-grp AUD-VIS ISC top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_aud-vis_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_aud-vis_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end
% %% 2-grp AUD-VIS ISC top-bot, p<0.01 alpha<0.05 CLUSTER MAP
% SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
%     sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_aud-vis_top-bot_clust_p%g_a0.05_bisided_map.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
%     0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_aud-vis_top-bot_clustmap_p%g_a0.05.jpg',csim_pthr),[],32,'0','roi_i32');
% 
% if doPause, pause(60); end

%% 2-grp TRANS-AUD ISC top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_trans-aud_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_trans-aud_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end

%% 2-grp TRANS-VIS ISC top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_TOP-BOT_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n68_Automask_trans-vis_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_trans-vis_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end



% ============= AGE & IQ ================= %

%% 2-grp ISC AGE top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_ageMedSplit_n68_Automask_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_age-top-bot_lim0.03_p%g_a0.05.jpg',csim_pthr),[],0.03,'0','');

if doPause, pause(60); end

%% 2-grp ISC IQ top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_iqMedSplit_n68_Automask_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_iq-top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end

%% 2-grp ISC IQ and ReadScore conjunction (top-bot, p<0.01 alpha<0.05)
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('Conjunction_readScore-plus-2IQ_p%g_a0.05+tlrc.BRIK.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_Conj_readScorePlus2Iq-top-bot_p%g_a0.05.jpg',csim_pthr),[],32,'0','ROI_i32');

if doPause, pause(60); end

%% 2-grp VIS ISC IQ and ReadScore conjunction (top-bot, p<0.01 alpha<0.05)
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('Conjunction_readScore-plus-2IQ_vis_p%g_a0.05+tlrc.BRIK.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_Conj_readScorePlus2Iq_vis-top-bot_p%g_a0.05.jpg',csim_pthr),[],32,'0','ROI_i32');

if doPause, pause(60); end

%% 2-grp AUD ISC IQ and ReadScore conjunction (top-bot, p<0.01 alpha<0.05)
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('Conjunction_readScore-plus-2IQ_aud_p%g_a0.05+tlrc.BRIK.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_Conj_readScorePlus2Iq_aud-top-bot_p%g_a0.05.jpg',csim_pthr),[],32,'0','ROI_i32');

if doPause, pause(60); end

%% 2-grp AUD and VIS ISC conjunction, ReadScore groups (top-bot, p<0.01 alpha<0.05)
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('Conjunction_readScoreGrps_aud-plus-2vis_p%g_a0.05+tlrc.BRIK.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_Conj_readScoreGrps_audPlus2Vis_top-bot_p%g_a0.05.jpg',csim_pthr),[],32,'0','ROI_i32');

if doPause, pause(60); end

%% 2-grp AUD and VIS ISC conjunction, IQ groups (top-bot, p<0.01 alpha<0.05)
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('Conjunction_iqGrps_aud-plus-2vis_p%g_a0.05+tlrc.BRIK.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_Conj_iqGrps_audPlus2Vis_top-bot_p%g_a0.05.jpg',csim_pthr),[],32,'0','ROI_i32');

if doPause, pause(60); end


% ========== READSCORE & IQ MATCHED, N=40 ========== %
%% 2-grp ISC Readscore grps, IQ matched, top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_readScoreMedSplit_n40-iqMatched_Automask_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_readScoreGrps_n40-iqMatched_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end

%% 2-grp ISC IQ grps, readScore matched, top-bot, p<0.01 alpha<0.05
SetUpSumaMontage_8view('/data/NIMH_Haskins/a182_v2/IscResults/Group','TEMP_AUD-VIS_CLUST.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('3dLME_2Grps_iqMedSplit_n40-readMatched_Automask_top-bot_clust_p%g_a0.05_bisided_EE.nii.gz',csim_pthr),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/suma_8view_ISC_iqGrps_n40-readScoreMatched_top-bot_lim0.1_p%g_a0.05.jpg',csim_pthr),[],0.1,'0','');

if doPause, pause(60); end