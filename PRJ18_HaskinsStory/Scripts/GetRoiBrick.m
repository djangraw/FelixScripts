function roiBrick = GetRoiBrick(roiTerms,roiNames,roiTypes,groupDiffMaps,sides)
% roiBrick = GetRoiBrick(roiTerms,roiNames,roiTypes,groupDiffMaps,sides)
% Get a brick with a different constant for each ROI.
% Created 8/16/19 by DJ.

% Load constants & directories
constants = GetStoryConstants();

% Parse inputs & defaults
if ~exist('roiTerms','var') || isempty(roiTerms)
    roiTerms = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG','CG'};
    % roiTerms = {'anteriorcingulate','dlpfc','inferiorfrontal','inferiortemporal','supramarginalgyrus','primaryauditory','primaryvisual','frontaleye'};
end
if ~exist('roiNames','var') || isempty(roiNames)
    roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'};
    % roiNames = {'ACC','DLPFC','IFG','ITG','SMG','A1','V1','FEF'};
end
if ~exist('roiTypes','var') || isempty(roiTypes)
    roiTypes = 'atlas';
end
if ~exist('groupDiffMaps','var') || isempty(groupDiffMaps)
    groupDiffMaps = {''};
    % groupDiffMaps = {sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n69_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz',constants.dataDir), ''};
end
if ~exist('sides','var') || isempty(sides)
    % sides={'r','l',''};
    sides = {''};
end

% convert string to cell
if ischar(roiTypes)
    roiTypes = repmat({roiTypes},size(roiTerms));
end

% initialize variables
nRoi = numel(roiTypes);
mapName = cell(1,nRoi*numel(groupDiffMaps)*numel(sides));
iRoi = 0;

% Main loop
for i=1:length(groupDiffMaps)
    groupDiffMap = groupDiffMaps{i};
    for j=1:length(roiTerms)
        fprintf('===ROI %d/%d...\n',j,length(roiTerms));
        for k=1:numel(sides)
            % increment ROI number
            iRoi = iRoi+1;
            
            % determine mask to use
            if strcmp(roiTypes{j},'neurosynth')
                % for neurosynth-derived masks
                % neuroSynthMask = sprintf('%s/NeuroSynthTerms/%s_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir,roiTerms{j});
            else
                % for atlas-derived masks
                neuroSynthMask = sprintf('%s/atlasRois/atlas_%s+tlrc',constants.dataDir,roiTerms{j});
            end
            
            % get map and its name
            olap = GetMaskOverlap(neuroSynthMask);
            roiName = sprintf('%s%s',sides{k},roiNames{j});

            % handle hemisphere splits
            if roiName(1)=='r'
                midline = size(olap,1)/2;
                olap(1:midline,:,:) = false;
            elseif roiName(1)=='l'
                midline = size(olap,1);
                olap(midline:end,:,:) = false;
            end
            % get # voxels in mask
            nVoxels = sum(olap(:));
            fprintf('%d voxels in mask %s.\n',nVoxels,roiName);
            % Get full map name
            if isempty(groupDiffMap)
                mapName{iRoi} = sprintf('%s (%d voxels)',roiName,nVoxels);
            else
                mapName{iRoi} = sprintf('%s * top-bot p<0.01, a<0.05 (%d voxels)',roiName,nVoxels);
            end

            if iRoi==1
                roiBrick = olap;
            else
                if any(roiBrick(:)>0 & olap(:)>0)
                    error('ROI %s overlaps with prevoius ROI!',mapName{iRoi});
                end
                roiBrick = roiBrick + j*olap;
            end  
        end
    end
end