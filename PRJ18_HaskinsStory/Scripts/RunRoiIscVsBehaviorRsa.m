% RunRoiIscVsBehaviorRsa.m
%
% Run a representational similarity analysis (RSA) comparing the behavioral
% similarity of each subject pair with the ISC of each subject pair (in
% various ROIs).
%
% For details, see comment from Emily Finn in draft of Haskins Story paper,
% which cites her 2020 NeuroImage paper explaining details:
% https://www.sciencedirect.com/science/article/pii/S1053811920303153
%
% Created 5/18/22 by DJ.

%% Get behavior scores (from PlotReadingSubscoreHistos.m)

info = GetStoryConstants();
subjects = info.okReadSubj;
% get standard reading scores
[readScores, weights,weightNames,IQs,ages] = GetStoryReadingScores(subjects);
% sort subjects by their reading score
[readScore_sorted,order] = sort(readScores,'ascend');
subj_sorted = constants.okReadSubj(order);

% Read behavior file
behTable = readtable(info.behFile);
% TODO: SORT behTable




% Append all reading scores
allReadScores = [behTable.TOWREVerified__SWE_SS,behTable.TOWREVerified__PDE_SS,behTable.TOWREVerified__TWRE_SS,...
    behTable.WoodcockJohnsonVerified__BscR_SS, behTable.WoodcockJohnsonVerified__LW_SS, behTable.WoodcockJohnsonVerified__WA_SS,...
    behTable.WASIVerified__Perf_IQ,behTable.EdinburghHandedness__LiQ,behTable.MRIScans__ProfileAge];
% weightNames = {'TOWRE_SWE_SS','TOWRE_PDE_SS','TOWRE_TWRE_SS','WJ3_BscR_SS','WJ3_LW_SS','WJ3_WA_SS'};
weightNames = {'TOWRE Sight-Word','TOWRE Phoenetic Decoding','TOWRE Total Word Reading','WJ3 Basic Reading','WJ3 Letter-Word ID','WJ3 Word Attack','WASI Performance IQ','Edinburgh Handedness LiQ','Age (years)'};

% TODO: Try other collections of scores that we might hypothesize match the
% function of a certain ROI

%% TODO: Get & Plot "ISC" matrices from behavioral scores 
% (i.e., how much does each pair's behavioral profile match?)


%% TODO: Calculate statistics
% Shuffle brain-behavior mappings many times to get a null distribution
% Compare actual values to this null distribution


%% Get ISC matrices (from PlotPairwiseIscInRois.m)

% Collect atlas ROI filenames and label names
% roiTerms = {'anteriorcingulate','dlpfc','inferiorfrontal','inferiortemporal','supramarginalgyrus','primaryauditory','primaryvisual','frontaleye'};
% roiNames = {'ACC','DLPFC','IFG','ITG','SMG','A1','V1','FEF'};
roiTerms = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG','CG'}; % filenames
roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'}; % label names
% sides={'r','l',''}; % unilateral
sides = {''}; % bilateral

nRoi = numel(roiNames);

mapName = cell(1,nRoi);
for j=1:length(roiTerms)
    fprintf('===ROI %d/%d...\n',j,length(roiTerms));
    for k=1:numel(sides)
        % load mask for this ROI
%             neuroSynthMask = sprintf('%s/NeuroSynthTerms/%s_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir,roiTerms{j});
        neuroSynthMask = sprintf('%s/atlasRois/atlas_%s+tlrc',constants.dataDir,roiTerms{j});
        roiName = sprintf('%s%s',sides{k},roiNames{j});

        % load volume
        [V,Info] = BrikLoad(neuroSynthMask);

        % handle hemisphere splits
        if roiName(1)=='r'
            midline = size(V,1)/2;
            V(1:midline,:,:) = false;
        elseif roiName(1)=='l'
            midline = size(V,1)/2;
            V(midline:end,:,:) = false;
        end % if not r or l, do nothing
        
        % get number of voxels in mask
        nVoxels = sum(V(:));
        fprintf('%d voxels in mask %s.\n',nVoxels,roiName);
        mapName{j} = sprintf('%s (%d voxels)',roiName,nVoxels);
        
        % add to volume roiBrik
        if j==1
            roiBrik = V;
        else
            roiBrik = roiBrik + j*V;
        end  
    end
end

%% Get pairwise ISC in ROI
% tcInRoi = GetTcInRoi(subj_sorted,roiBrik,1:nRoi);
iscInRoi = GetIscInRoi(subj_sorted,roiBrik,1:nRoi);


%% Plot ISC matrices next to each other
% get number of readers in the bottom half of the reading scores
nBot = sum(readScore_sorted>median(readScore_sorted));

% set up plot
figure(246);
set(246,'Position',[10,10,600,1000]);
for iRoi = 1:nRoi
    
    % plot
    subplot(ceil(nRoi/2),2,iRoi); cla; hold on;
    imagesc(iscInRoi(:,:,iRoi));
    % denote good-good and poor-poor reader areas of plot
%     plot([nBot,nBot,nSubj,nSubj,nBot]+1.5,[0,nBot,nBot,0,0]-0.5,'g-','LineWidth',2);
    plot([0,nBot,nBot,0]+0.5,[0,nBot,0,0]+0.5,'-','color',[112 48 160]/255,'LineWidth',2);
    plot([nBot,nSubj,nSubj,nBot]+0.5,[nBot,nSubj,nBot,nBot]+0.5,'r-','LineWidth',2);

    % annotate plot
    axis square
    xlabel(sprintf('better reader-->'))
    ylabel(sprintf('participant\nbetter reader-->'))
    set(gca,'ydir','normal');
    set(gca,'xtick',[],'ytick',[]);
    title(roiNames{iRoi})
    if strcmp(roiNames{iRoi},'STG (Aud)')
        set(gca,'clim',[-.3 .3]);
    elseif strcmp(roiNames{iRoi},'CalcGyr (Vis)')
        set(gca,'clim',[-.15 .15]);
    else
        set(gca,'clim',[-.075 .075]);
    end
    ylim([1 nSubj]-0.5)
%     colormap jet
    colorbar
    
end

% save figure
% saveas(246,sprintf('%s/IscResults/Group/SUMA_IMAGES/top-bot_atlasRois_isccol.png',constants.dataDir));

%% TODO: Match upper triangle of behavioral ISC with upper triangle of each ROI ISC
% This is the "RSA": the similarity between brain and behavior across ppl
