function seeds = MakeRandomParcellations(maskFile,nSeeds,nParc,outPrefix)

% Parcel a brain's voxels into random but contiguous ROIS.
%
% seeds = MakeRandomParcellations(maskFile,nSeeds,nParc)
%
% INPUTS:
% -maskFile is a string indicating the full-brain mask you'd like to use.
% -nSeeds is an integer indicating the number of ROIs you'd like to have in
% each parcellation.
% -nParc is the number of random parcellations you'd like to produce.
% -outPrefix is a string indicating the start of the filenames you'd like
% to save.
%
% OUTPUTS:
% -seeds is an nSeeds x 3 x nParc matrix in which seeds(i,:,j) is the seed
% for ROI #i in parcellation #j.
%
% Created 2/2/16 by DJ.
% Finished 2/3/16 by DJ.

% Declare params
if ~exist('maskFile','var') || isempty(maskFile)
    maskFile = '';%'MNI_avg152T1+tlrc';
end
if ~exist('nSeeds','var') || isempty(nSeeds)
    nSeeds = 200;
end
if ~exist('nParc','var') || isempty(nParc)
    nParc = 1;
end
if ~exist('outPrefix','var') || isempty(outPrefix)
    outPrefix = 'RandParc';
end

% load mask
if isempty(maskFile)
    mask = ones([91 109 91]);
    Info = [];
else
    [err, mask, Info, errMsg] = BrikLoad(maskFile);    
    Info.BRICK_TYPES = 1; % save values as shorts (to reduce file size)    
    Info.TypeName = 'short';
    Info.TypeBytes = 2;
    Info.BRICK_STATS = [0 nSeeds]; % min and max values in brick
end
% get (X,Y,Z) coordinates of in-brain voxels
sizeMat = size(mask);
[X,Y,Z] = ind2sub(sizeMat,find(mask>0));
% append into matrix
indices = [X(:), Y(:), Z(:)];

%% Make parcellations
seeds = nan(nSeeds,3,nParc);
nInRoi = zeros(nParc,nSeeds);
for i=1:nParc    
    fprintf('Parcellation %d/%d...\n',i,nParc);
    % randomly select seeds
    seeds(:,:,i) = indices(randsample(size(indices,1),nSeeds), :);
    % find nearest neighbors
    idx = knnsearch(seeds(:,:,i),indices);
    % project back to matrix
    iSeed = zeros(sizeMat);
    for j=1:numel(idx)
        iSeed(X(j),Y(j),Z(j)) = idx(j);
    end
    % Get # voxels in each ROI
    nInRoi(i,:) = hist(idx,1:nSeeds);
    
    % write result to file
    if ~isempty(Info)
        Opt.prefix = sprintf('%s_%dROIs_%d',outPrefix,nSeeds,i);
        WriteBrik(iSeed,Info,Opt);
    end
end


%% plot hist of number of voxels in rois
% figure;
% hist(nInRoi(:));
% xlabel('voxels in ROI')
% ylabel('# of ROIs')
% 
%% view final random parcellation in GUI_3View
% drawnow;
% GUI_3View(iSeed);
