function roiSizes = GetAllRandParcSizes(nRand,prefix,suffix)

% Created 2/22/16 by DJ.

if ~exist('prefix','var') || isempty(prefix)
    prefix = 'SBJ06_CTask001.Craddock_RandParc_200ROIs_';
end
if ~exist('suffix','var') || isempty(suffix)
    suffix = '_10VoxelMin+orig';
end

roiSizes = cell(1,nRand);
for i=1:nRand
    filename = sprintf('%s%d%s',prefix,i-1,suffix);
%     fprintf('Loading %s...\n',filename);
%     [err,parc,Info] = BrikLoad(filename);
    roiSizes{i} = GetRandParcRoiSizes(filename);
end