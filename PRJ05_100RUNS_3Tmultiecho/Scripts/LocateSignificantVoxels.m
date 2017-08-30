function [pctSigInMask,pctMaskInSig] = LocateSignificantVoxels(isSig,masks,maskNames)

% LocateSignificantVoxels(isSig,masks,maskNames)
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

% Get overlap percentages
nMasks = size(masks,4);
[pctSigInMask, pctMaskInSig, pctBrainInMask]  = deal(zeros(1,nMasks));
for i=1:nMasks
    pctMaskInSig(i) = sum(sum(sum(isSig & masks(:,:,:,i)~=0))) / sum(sum(sum(masks(:,:,:,i)~=0))) * 100;
    pctSigInMask(i) = sum(sum(sum(isSig & masks(:,:,:,i)~=0))) / sum(sum(sum(isSig & any(masks~=0,4)))) * 100;
    pctBrainInMask(i) = sum(sum(sum(masks(:,:,:,i)~=0))) / sum(sum(sum(any(masks~=0,4)))) * 100;
end

% Plot results
% figure(28); 
clf;
subplot(1,2,1);
bar([pctSigInMask; pctBrainInMask]');
set(gca,'xtick',1:nMasks,'xticklabel',maskNames);
xlabel('mask');
ylabel('% voxels in each mask');
legend('significant voxels','whole brain');
title(sprintf('Distribution of voxels\n(FDR corrected, q<0.05)'))
grid on
subplot(1,2,2);
bar(pctMaskInSig);
set(gca,'xtick',1:nMasks,'xticklabel',maskNames);
xlabel('mask');
ylabel('% voxels in mask that are significant');
title(sprintf('Significance of areas\n(FDR corrected, q<0.05)'))
grid on

