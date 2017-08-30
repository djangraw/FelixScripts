function tc = GetAtlasTimecourses(datafile, atlasfile, subbrick)

% tc = GetAtlasTimecourses(datafile, atlasfile, subbrick)
% 
% Created 11/6/15 by DJ.
% Updated 12/3/15 by DJ - atlas size must match data size.
% Updated 12/15/15 by DJ - allow numeric data/atlas inputs
% declare defaults
if ~exist('subbrick','var') || isempty(subbrick)
    subbrick = 1;
end
% load atlas
if isnumeric(atlasfile)
    atlas = atlasfile;
else
    fprintf('Loading atlas...\n');
    Opt = struct('Frames',subbrick);
    [err,atlas,atlasInfo,ErrMsg] = BrikLoad(atlasfile,Opt);
end
% load data
if isnumeric(datafile)
    data = datafile;
else
    fprintf('Loading data...\n');
    [err,data,dataInfo,ErrMsg] = BrikLoad(datafile);
end

% reshape data
fprintf('Reshaping data...\n');
sizeData = size(data);
nVoxels = prod(sizeData(1:3));
nT = sizeData(4);
data2d = reshape(data,nVoxels,nT);
atlasvec = atlas(:);
% check that mask matches data
if numel(atlas) ~= nVoxels
    error('atlas size does not match data size!');
end

% get tc in each atlas parcellation
fprintf('Extracting timecourses...\n');
nParc = max(atlas(:));
tc = nan(nParc,nT);
for i=1:nParc
    tc(i,:) = mean(data2d(atlasvec==i,:),1);
end

fprintf('Done!\n')
