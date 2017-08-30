function WriteFcNetworkToAfniBrik(FcNet,atlasFilename,outFilename)

% WriteFcNetworkToAfniBrik(FcNet,atlasFilename,outFilename)
%
% Created 6/21/17 by DJ.

if ~exist('atlasFilename','var') || isempty(atlasFilename)
    vars = GetDistractionVariables;
    homedir = vars.homedir;
    atlasFilename = [homedir '/Results/Shen_2013_atlas/EPIres_shen_1mm_268_parcellation+tlrc.BRIK'];
end
if ~exist('outFilename','var') || isempty(outFilename)
    outFilename = 'FcNetwork+tlrc';
end
[atlas,atlasInfo] = BrikLoad(atlasFilename);

% Make FC Net symmetric
FcNet = UnvectorizeFc(VectorizeFc(FcNet),0,true);

% ID each ROI as either pos, neg, or both
isNeg = any(FcNet<0,1) & ~any(FcNet>0,1);
isBoth = any(FcNet>0,1) & any(FcNet<0,1);
isPos = any(FcNet>0,1) & ~any(FcNet<0,1);

% Save output as AFNI Brik
BrickToWrite = MapValuesOntoAtlas(atlas, 3*isPos + 2*isBoth + isNeg);
Opt = struct('Prefix',outFilename);
fprintf('Writing result as %s...\n',outFilename)
WriteBrik(BrickToWrite,atlasInfo,Opt);
fprintf('Done!\n');