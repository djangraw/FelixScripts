function match = GetSpatialTemplateMatch(data,template,mask,doRand)

% Created 7/6/17 by DJ.

% Declare defaults
if ~exist('template','var') || isempty(template)
    template = '/gpfs/gsfs5/users/jangrawdc/PRJ14_ArousalIsc/smpT_0001.nii'; % Arousal template from Catie Chang
end
if ~exist('mask','var')
    mask = [];
end
if ~exist('doRand','var') || isempty(doRand)
    doRand = false;
end

% Load afni bricks
if ischar(data)
    data = BrikLoad(data);
end
if ischar(template)
    template = BrikLoad(template);
end
if ischar(mask)
    mask = BrikLoad(mask);
end
if isempty(mask)
    fprintf('No mask provided. Using all values in data brick.')
    mask = ones(size(data));
end

% Set up and check sizes
[nX,nY,nZ,nT] = size(data);
if ~isequal(size(template),[nX,nY,nZ])
    error('size of template ([%s]), mask ([%s]), and data([%d %d %d]) do not match!', ...
        num2str(size(template)),num2str(size(mask)),nX,nY,nZ');
end
% Mask and turn into 2d matrices
maskVec = mask(:);
templateVec = template(mask>0);
dataVec = reshape(data,[nX*nY*nZ , nT]);
dataVec = dataVec(maskVec>0,:);
nV = size(dataVec,1); % # of voxels

% Do randomization if requested
if doRand
    iRand = randperm(nV);
    dataVec = dataVec(iRand,:);
end

% Normalize data vec
% From Catie: To obtain the fMRI arousal index, we (1) temporally z-score
% the fMRI data, i.e. normalize each voxel’s time series to mean=0 and
% variance=1, and (2) spatially correlate each fMRI time frame from this
% z-scored data against the template. Let me know if you’d like to discuss
% further or if I can send anything else that would be helpful.
dataVecNorm = (dataVec - repmat(mean(dataVec,1),[nV,1])) ./ ...
    repmat(var(dataVec,[],1),[nV,1]);

% Get template match
match = corr(dataVecNorm,templateVec);