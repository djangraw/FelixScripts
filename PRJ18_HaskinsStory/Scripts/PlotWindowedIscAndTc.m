% PlotWindowedIscAndTc.m
% 
% Created 4/11/19 by DJ.
% Updated 4/17/19 by DJ - added loop
% Updated 5/22/19 by DJ - switched from NeuroSynth to atlas
% Updated 8/23/19 by DJ - added ste back in



constants = GetStoryConstants();

figure(523); clf;
set(523,'Position',[4 200 1914 862])

figure(525); clf;
set(525,'Position',[671   726   484   338])

% groupDiffMaps = {sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n69_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz',constants.dataDir), ''};
groupDiffMaps = {''};
% sides={'r','l',''};
sides={''};


% roiTerms = {'anteriorcingulate','dlpfc','inferiorfrontal','inferiortemporal','supramarginalgyrus','primaryauditory','primaryvisual','frontaleye'};
% roiNames = {'ACC','DLPFC','IFG','ITG','SMG','A1','V1','FEF'};

roiTerms = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG','CG'};
roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'};



[iAud,iVis,iBase] = GetStoryBlockTiming();

for i=1:length(groupDiffMaps)
    fprintf('====Map %d/%d...\n',i,length(groupDiffMaps));
    for j=1:length(roiTerms)
        fprintf('===ROI %d/%d...\n',j,length(roiTerms));
        for k=1:length(sides)
            fprintf('==Hemisphere %d/%d...\n',k,length(sides));
            
            % extract names
            groupDiffMap = groupDiffMaps{i};
%             neuroSynthMask = sprintf('%s/NeuroSynthTerms/%s_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir,roiTerms{j});
            neuroSynthMask = sprintf('%s/atlasRois/atlas_%s+tlrc',constants.dataDir,roiTerms{j});
            roiName = sprintf('%s%s',sides{k},roiNames{j});
            
            % Get brick
            if isempty(groupDiffMap)
                olap = GetMaskOverlap(neuroSynthMask);
            else
                olap = GetMaskOverlap(groupDiffMap,neuroSynthMask);
            end
            % handle hemisphere splits
            if roiName(1)=='r'
                midline = size(olap,1)/2;
                olap(1:midline,:,:) = false;
            elseif roiName(1)=='l'
                midline = size(olap,1)/2;
                olap(midline:end,:,:) = false;
            end
            nVoxels = sum(olap(:));
            fprintf('%d voxels in mask %s.\n',nVoxels,roiName);
            if isempty(groupDiffMap)
                mapName = sprintf('%s (%d voxels)',roiName,nVoxels);
            else
                mapName = sprintf('%s * top-bot p<0.01, a<0.05 (%d voxels)',roiName,nVoxels);
            end

            % Get ISC in ROI
            winLength = 15;
            TR = 2;
            clear iscInRoi iscInRoi_ste
            topResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_toptop+tlrc',constants.dataDir);
            iscInRoi(:,1) = GetTimecourseInRoi(topResult,olap);
            botResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_botbot+tlrc',constants.dataDir);
            iscInRoi(:,2) = GetTimecourseInRoi(botResult,olap);
            % add STERR
            topResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_toptop_ste+tlrc',constants.dataDir);
            iscInRoi_ste(:,1) = GetTimecourseInRoi(topResult,olap);
            botResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_botbot_ste+tlrc',constants.dataDir);
            iscInRoi_ste(:,2) = GetTimecourseInRoi(botResult,olap);
            
            tIsc = ((1:length(iscInRoi)) + winLength/2)*TR;

%             % Get timecourse in ROI
%             clear tcInRoi
%             topResult = sprintf('%s/MeanErrtsFanaticor_top+tlrc',constants.dataDir);
%             tcInRoi(:,1) = GetTimecourseInRoi(topResult,olap);
%             botResult = sprintf('%s/MeanErrtsFanaticor_bot+tlrc',constants.dataDir);
%             tcInRoi(:,2) = GetTimecourseInRoi(botResult,olap);
%             % Add STDERR
%             clear tcInRoi_ste
%             topResult = sprintf('%s/SteErrtsFanaticor_top+tlrc',constants.dataDir);
%             tcInRoi_ste(:,1) = GetTimecourseInRoi(topResult,olap);            
%             botResult = sprintf('%s/SteErrtsFanaticor_bot+tlrc',constants.dataDir);
%             tcInRoi_ste(:,2) = GetTimecourseInRoi(botResult,olap);
% 
%             t = (1:length(tcInRoi))*TR;
% 
%             % Set up figure
%             figure(523); clf;
%             colors = {[1 0 0],[112 48 160]/255};
%             
%             % Plot timecourse
%             subplot(2,1,1);
%             PlotTimecoursesWithConditions(t,tcInRoi,tcInRoi_ste,colors)
%             ylabel('Mean BOLD signal change (%)')
%             xlabel('time (sec)')
%             title(mapName);
%             xlim([0,t(end)])
% 
%             % Plot ISC
%             subplot(2,1,2);
%             PlotTimecoursesWithConditions(tIsc,iscInRoi,iscInRoi_ste,colors)
%             ylabel('mean ISC')
%             xlabel('time of window center (sec)')
%             title(mapName);
%             xlim([0,t(end)])
% 
% 
% %             subplot(2,1,2);
% %             PlotTimecoursesWithConditions(t,tcInRoi_ste,[],colors)
% %             ylabel('StdErr of BOLD signal change (%)')
% %             title(mapName);
% %             xlim([0,t(end)])
%             
%             % Add legend
%             MakeLegend(colors,{'Top Readers','Bottom Readers'},[2,2],[0.17,0.9]);
%             
%             
%             % Save figure
%             if isempty(groupDiffMap)
% %                 print(sprintf('%s/NeuroSynthTerms/SUMA_IMAGES/%s_%ds-win-isc+tc.png',constants.dataDir,roiName,winLength*TR),'-dpng')
%                 print(sprintf('%s/atlasRois/SUMA_IMAGES/%s_%ds-win-isc+tc.png',constants.dataDir,roiName,winLength*TR),'-dpng')
% %                 print(sprintf('%s/atlasRois/SUMA_IMAGES/%s_tc+ste.png',constants.dataDir,roiName),'-dpng')
%             else
% %                 print(sprintf('%s/NeuroSynthTerms/SUMA_IMAGES/%s_top-bot_%ds-win-isc+tc.png',constants.dataDir,roiName,winLength*TR),'-dpng')
%                 print(sprintf('%s/atlasRois/SUMA_IMAGES/%s_top-bot_%ds-win-isc+tc.png',constants.dataDir,roiName,winLength*TR),'-dpng')
% %                 print(sprintf('%s/atlasRois/SUMA_IMAGES/%s_top-bot_tc+ste.png',constants.dataDir,roiName),'-dpng')
%             end
            
            % Make summary barplot (median per block type)
            figure(525); clf;
            iscInRoi_padded = zeros(length(tcInRoi),2);
            iscInRoi_padded((1:length(iscInRoi)) + ceil(winLength/2),:) = iscInRoi;
            medAud = median(iscInRoi_padded(iAud,:));
            medVis = median(iscInRoi_padded(iVis,:));
            medBase = median(iscInRoi_padded(iBase,:));
            bar([medAud',medVis',medBase']);
            set(gca,'xtick',1:2,'xticklabels',{'Top 1/2','Bottom 1/2'});
            xlabel('Reading Score')
            ylabel(sprintf('Median %ds Sliding-Window ISC',winLength*TR))
            legend({'Aud','Vis','Base'})
            grid on;
            title(mapName);
            
            % Save figure
            if isempty(groupDiffMap)
%                 print(sprintf('%s/NeuroSynthTerms/SUMA_IMAGES/%s_%ds-win-isc_block-bar.png',constants.dataDir,roiName,winLength*TR),'-dpng')
                print(sprintf('%s/atlasRois/SUMA_IMAGES/%s_%ds-win-isc_block-bar.png',constants.dataDir,roiName,winLength*TR),'-dpng')
            else
%                 print(sprintf('%s/NeuroSynthTerms/SUMA_IMAGES/%s_top-bot_%ds-win-isc_block-bar.png',constants.dataDir,roiName,winLength*TR),'-dpng')
                print(sprintf('%s/atlasRois/SUMA_IMAGES/%s_top-bot_%ds-win-isc_block-bar.png',constants.dataDir,roiName,winLength*TR),'-dpng')
            end
            
        end
    end
end