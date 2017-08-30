function NeurosynthNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold)

% NeurosynthNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold)
% 
% INPUTS:
% -pos/neg/atlasFilename are the AFNI bricks of the positive mask, the
% negative mask, and the atlas with p ROIs defined.
% -pos/negMaskThreshold are each a scalar value indicating the lowest value
% that should be considered part of the mask. [default = 0]
% -pos/negMatchThreshold is the amount of overlap an ROI needs to have with
% a mask to be considered part of the mask. [default = 0.15]
%
% OUTPUTS:
% -NeurosynthNetwork is a pxp matrix where value (i,j) is +1 if the FC
% between ROIs i and j is in the positive network, -1 if it's in the
% negative network, and 0 if it's in neither.
%
% Created 1/3/16 by DJ.
% Updated 2/17/17 by DJ - empty inputs mean all zeros

% Declare defaults: AFNI bricks
if ~exist('posFilename','var')% || isempty(posFilename)
    posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_dorsalattention_pAgF_z_FDR_0.01_EpiRes_MNI+tlrc';
end
if ~exist('negFilename','var')% || isempty(negFilename)
    negFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_defaultmode_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
end
if ~exist('atlasFilename','var') || isempty(atlasFilename)
    atlasFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc';
end

% Declare defaults: thresholds
if ~exist('posMaskThreshold','var') || isempty(posMaskThreshold)
    posMaskThreshold = 0;
end
if ~exist('negMaskThreshold','var') || isempty(negMaskThreshold)
    negMaskThreshold = 0; %5;
end
if ~exist('posMatchThreshold','var') || isempty(posMatchThreshold)
    posMatchThreshold = 0.15;
end
if ~exist('negMatchThreshold','var') || isempty(negMatchThreshold)
    negMatchThreshold = 0.15;
end

doPlot = false; % plot FC matrix

% [MaskPos,maskPosInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_reading_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc');
[shenAtlas,shenAtlasInfo] = BrikLoad(atlasFilename);
if isempty(posFilename)
    MaskPos = zeros(size(shenAtlas));
    maskPosInfo = shenAtlasInfo;
else
    [MaskPos,maskPosInfo] = BrikLoad(posFilename);
end
if isempty(negFilename)
    MaskNeg = zeros(size(shenAtlas));
    maskNegInfo = shenAtlasInfo;
else
    [MaskNeg,maskNegInfo] = BrikLoad(negFilename);
end
if ~isequal(maskPosInfo.Orientation,shenAtlasInfo.Orientation) || ~isequal(maskNegInfo.Orientation,shenAtlasInfo.Orientation)
    error('brick orientations don''t match!');
end

% Apply mask thresholds
MaskPos(MaskPos<posMaskThreshold) = 0;
MaskNeg(MaskNeg<negMaskThreshold) = 0;

% Apply match thresholds
[isPosPosEdge, ~, ~] = GetFcNetworksFromMasks(MaskPos,MaskNeg,shenAtlas,posMatchThreshold);
[~, isNegNegEdge, ~] = GetFcNetworksFromMasks(MaskPos,MaskNeg,shenAtlas,negMatchThreshold);

% Combine into network for visualization
NeurosynthNetwork = isPosPosEdge-isNegNegEdge;
fprintf('%d in pos, %d in neg\n', sum(VectorizeFc(isPosPosEdge)), sum(VectorizeFc(isNegNegEdge)));

% Plot results
if doPlot
    PlotFcMatrix(NeurosynthNetwork,[],shenAtlas,attnNetLabels,true,colors,'sum');
end