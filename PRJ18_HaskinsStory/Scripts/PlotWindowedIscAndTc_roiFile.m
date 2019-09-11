% PlotWindowedIscAndTc_roiFile.m
% 
% Created 4/11/19 by DJ.
% Updated 4/17/19 by DJ - added loop
% Updated 5/22/19 by DJ - switched from NeuroSynth to atlas
% Updated 8/23/19 by DJ - added ste back in, switched to ROI input file.



constants = GetStoryConstants();

figure(523); clf;
set(523,'Position',[4 200 1914 862])

figure(525); clf;
set(525,'Position',[671   726   484   338])

groupDiffMaps = {''};

% roiMask = BrikLoad(sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n68_Automask_top-bot_clust_p0.002_a0.05_bisided_map.nii.gz',constants.dataDir));
% roiIndices = 1:8;
% roiNames = {'lITC+lHC+thalamus','lMidTG+AngGyr','ACC','rCer','lIns+lTempPole','mPFC','lMidFG','lIFG'};
roiMask = BrikLoad(sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n40-iqMatched_Automask_top-bot_clust_p0.002_a0.05_bisided_map.nii.gz',constants.dataDir));
roiIndices = 1:14;
roiNames = {'IFG-pTri/MidFG','lITG/lMidTG','lSPL/Precun','rSPL/rPostCG','rCer(V1/Crus1)','lIns','lSMedG/lSFG','rMidTG','lPrec/lCalcG','midbrain/VTA','lMidTG/lSTG','laSTG','lMidFG/lSFG','rIOG/rITG'};



[iAud,iVis,iBase] = GetStoryBlockTiming();

for iRoi=1:length(roiIndices)
    fprintf('===ROI %d/%d...\n',iRoi,length(roiIndices));

    % extract ROI info
    roiName = roiNames{iRoi};
    isInRoi = (roiMask==roiIndices(iRoi));
    nVoxels = sum(isInRoi(:));
    
    fprintf('%d voxels in mask %s.\n',nVoxels,roiName);
    mapName = sprintf('ROI%02d: %s (%d voxels)',iRoi,roiName,nVoxels);


    % Get ISC in ROI
    winLength = 15;
    TR = 2;
    clear iscInRoi 
    topResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_toptop+tlrc',constants.dataDir);
    iscInRoi(:,1) = GetTimecourseInRoi(topResult,isInRoi);
    botResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_botbot+tlrc',constants.dataDir);
    iscInRoi(:,2) = GetTimecourseInRoi(botResult,isInRoi);
    % add STERR
    clear iscInRoi_ste
    topResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_toptop_ste+tlrc',constants.dataDir);
    iscInRoi_ste(:,1) = GetTimecourseInRoi(topResult,isInRoi);
    botResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_botbot_ste+tlrc',constants.dataDir);
    iscInRoi_ste(:,2) = GetTimecourseInRoi(botResult,isInRoi);

    tIsc = ((1:length(iscInRoi)) + winLength/2)*TR;

    % Get timecourse in ROI
    clear tcInRoi
    topResult = sprintf('%s/MeanErrtsFanaticor_top+tlrc',constants.dataDir);
    tcInRoi(:,1) = GetTimecourseInRoi(topResult,isInRoi);
    botResult = sprintf('%s/MeanErrtsFanaticor_bot+tlrc',constants.dataDir);
    tcInRoi(:,2) = GetTimecourseInRoi(botResult,isInRoi);
    % Add STDERR
    clear tcInRoi_ste
    topResult = sprintf('%s/SteErrtsFanaticor_top+tlrc',constants.dataDir);
    tcInRoi_ste(:,1) = GetTimecourseInRoi(topResult,isInRoi);            
    botResult = sprintf('%s/SteErrtsFanaticor_bot+tlrc',constants.dataDir);
    tcInRoi_ste(:,2) = GetTimecourseInRoi(botResult,isInRoi);

    t = (1:length(tcInRoi))*TR;
    figure(523); clf;
    % Plot timecourse
    subplot(2,1,1);
    PlotTimecoursesWithConditions(t,tcInRoi,tcInRoi_ste,colors)
    ylabel('Mean BOLD signal change (%)')
    xlabel('time (sec)')
    title(mapName);
    xlim([0,t(end)])
    
    % Plot ISC
    subplot(2,1,2);
    colors = {[1 0 0],[112 48 160]/255};
    PlotTimecoursesWithConditions(tIsc,iscInRoi,iscInRoi_ste,colors)
    ylabel('mean ISC')
    xlabel('time of window center (sec)')
    title(mapName);
    xlim([0,t(end)])

    % Add legend
    MakeLegend(colors,{'Good Readers','Poor Readers'},[2,2],[0.17,0.9]);


    % Save figure
    if isempty(groupDiffMap)
        print(sprintf('%s/atlasRois/SUMA_IMAGES/ROI%02d_%s_%ds-win-isc+tc.png',constants.dataDir,iRoi,strrep(roiName,'/','-'),winLength*TR),'-dpng')
    else
        print(sprintf('%s/atlasRois/SUMA_IMAGES/ROI%02d_%s_top-bot_%ds-win-isc+tc.png',constants.dataDir,iRoi,strrep(roiName,'/','-'),winLength*TR),'-dpng')
    end

end
