% PlotWindowedIscAndTc.m
% 
% Created 4/11/19 by DJ.
% Updated 4/17/19 by DJ - added loop
% Updated 5/22/19 by DJ - switched from NeuroSynth to atlas

constants = GetStoryConstants();

figure(523); clf;
set(523,'Position',[4 200 1914 862])
figure(525); clf;
set(525,'Position',[671   726   484   338])

groupDiffMaps = {sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n69_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz',constants.dataDir), ''};
% roiTerms = {'anteriorcingulate','dlpfc','inferiorfrontal','inferiortemporal','supramarginalgyrus','primaryauditory','primaryvisual','frontaleye'};
% roiNames = {'ACC','DLPFC','IFG','ITG','SMG','A1','V1','FEF'};
roiTerms = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG','CG'};
roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'};
% sides={'r','l',''};
sides={'r','l',''};

[iAud,iVis,iBase] = GetStoryBlockTiming();

for i=1:length(groupDiffMaps)
    fprintf('====Map %d/%d...\n',i,length(groupDiffMaps));
    for j=1:length(roiTerms)
        fprintf('===ROI %d/%d...\n',j,length(roiTerms));
        for k=1:length(sides)
            fprintf('==Hemisphere %d/%d...\n',k,length(sides));
            
            groupDiffMap = groupDiffMaps{i};
%             neuroSynthMask = sprintf('%s/NeuroSynthTerms/%s_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir,roiTerms{j});
            neuroSynthMask = sprintf('%s/atlasRois/atlas_%s+tlrc',constants.dataDir,roiTerms{j});
            roiName = sprintf('%s%s',sides{k},roiNames{j});
            
%             groupDiffMap = sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n69_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz',constants.dataDir);
%             groupDiffMap = '';
% 
%             neuroSynthMask = sprintf('%s/NeuroSynthTerms/thalamus_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
%             roiName = 'thalamus';

            % neuroSynthMask = sprintf('%s/NeuroSynthTerms/anteriorcingulate_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
            % roiName = 'ACC';

            % neuroSynthMask = sprintf('%s/NeuroSynthTerms/dlpfc_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
            % roiName = 'rDLPFC';

            % neuroSynthMask = sprintf('%s/NeuroSynthTerms/inferiorfrontal_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
            % roiName = 'rIFG';

            % neuroSynthMask = sprintf('%s/NeuroSynthTerms/inferiortemporal_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
            % roiName = 'lITG';

            % neuroSynthMask = sprintf('%s/NeuroSynthTerms/supramarginalgyrus_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
            % roiName = 'rSMG';

            % neuroSynthMask = sprintf('%s/NeuroSynthTerms/primaryauditory_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
            % roiName = 'rAud';

            % neuroSynthMask = sprintf('%s/NeuroSynthTerms/primaryvisual_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
            % roiName = 'lVis';

%             groupDiffMap='';
%             neuroSynthMask=sprintf('%s/IscResults/Group/MNI_mask_epiRes.nii',constants.dataDir);
%             roiName='wholeBrain';

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
            clear iscInRoi
            topResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_toptop+tlrc',constants.dataDir);
            iscInRoi(:,1) = GetTimecourseInRoi(topResult,olap);
            botResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_botbot+tlrc',constants.dataDir);
            iscInRoi(:,2) = GetTimecourseInRoi(botResult,olap);

            tIsc = ((1:length(iscInRoi)) + winLength/2)*TR;

%             % Get timecourse in ROI
%             clear tcInRoi
%             topResult = sprintf('%s/MeanErrtsFanaticor_top+tlrc',constants.dataDir);
%             tcInRoi(:,1) = GetTimecourseInRoi(topResult,olap);
%             botResult = sprintf('%s/MeanErrtsFanaticor_bot+tlrc',constants.dataDir);
%             tcInRoi(:,2) = GetTimecourseInRoi(botResult,olap);
% 
%             t = (1:length(tcInRoi))*TR;
% 
%             % Plot ISC
%             figure(523); clf;
%             subplot(2,1,1);
%             PlotTimecoursesWithConditions(tIsc,iscInRoi)
%             ylabel('mean ISC')
%             xlabel('time of window center (sec)')
%             title(mapName);
%             MakeLegend({'r','g'},{'Top Readers','Bottom Readers'},[2,2],[0.17,0.9]);
%             xlim([0,t(end)])
% 
%             % Plot timecourse
%             % figure(524); clf;
%             subplot(2,1,2);
%             PlotTimecoursesWithConditions(t,tcInRoi)
%             ylabel('Mean BOLD signal change (%)')
%             title(mapName);
%             % MakeLegend({'r','g'},{'Top Readers','Bottom Readers'},[2,2],[0.17,0.9]);
%             xlim([0,t(end)])
%             
%             % Save figure
%             if isempty(groupDiffMap)
% %                 print(sprintf('%s/NeuroSynthTerms/SUMA_IMAGES/%s_%ds-win-isc+tc.png',constants.dataDir,roiName,winLength*TR),'-dpng')
%                 print(sprintf('%s/atlasRois/SUMA_IMAGES/%s_%ds-win-isc+tc.png',constants.dataDir,roiName,winLength*TR),'-dpng')
%             else
% %                 print(sprintf('%s/NeuroSynthTerms/SUMA_IMAGES/%s_top-bot_%ds-win-isc+tc.png',constants.dataDir,roiName,winLength*TR),'-dpng')
%                 print(sprintf('%s/atlasRois/SUMA_IMAGES/%s_top-bot_%ds-win-isc+tc.png',constants.dataDir,roiName,winLength*TR),'-dpng')
%             end
%             
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