function [pctRoiInMask,pctMaskInRoi] = LocateSignificantVoxels_multi(roiMasks,tissueMasks,roiMaskNames,tissueMaskNames)

% LocateSignificantVoxels_multi(roiMasks,tissueMasks,roiMaskNames,tissueMaskNames)
%
% INPUTS:
% -isSig is an nxmxp matrix of binary values indicating which values should
% be included in the localization.
% -masks is an nxmxpxq matrix of binary (zero vs non-zero) values for q
% different masks.
% -maskNames is a q-element cell array of strings indicating the name of
% each mask.
%
% OUTPUTS:
% -pctSigInMask is a q-element vector of values indicating what percentage 
% of significant voxels were in each mask. 
% -pctMaskInSig is a q-element vector of values indicating what percentage
% of voxels in each mask were significant.
%
% Created 4/2/15 by DJ.
% Updated 5/4/15 by DJ - switched input to isSig (use
% isSignificant_voxelwise to get to this from z scores)
% Updated 10/13/15 by DJ - switched to _multi version

% Get overlap percentages
nRMasks = size(roiMasks,4);
nTMasks = size(tissueMasks,4);
[pctRoiInMask, pctMaskInRoi, pctBrainInMask]  = deal(zeros(nRMasks,nTMasks));
for i=1:nRMasks
    for j=1:nTMasks
        pctMaskInRoi(i,j) = sum(sum(sum(roiMasks(:,:,:,i) & tissueMasks(:,:,:,j)~=0))) / sum(sum(sum(tissueMasks(:,:,:,j)~=0))) * 100;
        pctRoiInMask(i,j) = sum(sum(sum(roiMasks(:,:,:,i) & tissueMasks(:,:,:,j)~=0))) / sum(sum(sum(roiMasks(:,:,:,i) & any(tissueMasks~=0,4)))) * 100;
%         pctBrainInMask(i,j) = sum(sum(sum(tissueMasks(:,:,:,j)~=0))) / sum(sum(sum(any(tissueMasks~=0,4)))) * 100;
    end
end

% Plot results
% figure; 
clf;
subplot(1,2,1);
bar(pctRoiInMask');
set(gca,'xtick',1:nTMasks,'xticklabel',tissueMaskNames);
xlabel('tissue type');
ylabel('% voxels in tissue type');
legend(roiMaskNames);
title(sprintf('Distribution of voxels\n(FDR corrected, q<0.05)'))
grid on
subplot(1,2,2);
% figure;
bar(pctMaskInRoi');
set(gca,'xtick',1:nTMasks,'xticklabel',tissueMaskNames);
xlabel('tissue type');
ylabel('% voxels significant');
title(sprintf('Significance of areas\n(FDR corrected, q<0.05)'))
legend(roiMaskNames);
grid on

