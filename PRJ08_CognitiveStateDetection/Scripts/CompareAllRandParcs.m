function dice = CompareAllRandParcs(nRand,prefix,suffix)

% Created 2/22/16 by DJ.

if ~exist('prefix','var') || isempty(prefix)
    prefix = 'SBJ06_CTask001.Craddock_RandParc_200ROIs_';
end
if ~exist('suffix','var') || isempty(suffix)
    suffix = '_10VoxelMin+orig';
end

dice = cell(nRand);
for i=1:nRand
    filename = sprintf('%s%d%s',prefix,i-1,suffix);
    fprintf('Loading %s...\n',filename);
    [err,parc1,Info] = BrikLoad(filename);    
    for j=(i+1):nRand
        filename = sprintf('%s%d%s',prefix,j-1,suffix);
        fprintf('Loading %s...\n',filename);
        [err,parc2,Info] = BrikLoad(filename);
        fprintf('===Parc%d * Parc%d===\n',i,j);
        dice{i,j} = CompareRandParcs(parc1,parc2);
    end
end