function FC = UnvectorizeFc(FCvec,diagValue,fillLowerTri)

% FC = UnvectorizeFc(FCvec,diagValue,fillLowerTri)
%
% INPUTS:
% -FCvec is a matrix of size N*(N-1)/2 x T. Each row is a unique ROI pair.
% -diagValue is a scalar that will be placed on the diagonal of every
% output page [default = 1].
% -fillLowerTri is a binary value indicating whether you'd like the lower
% triangular part of the matrix to be filled with FC values (true) or zeros 
% (false). [default: true]
% 
% OUTPUTS:
% -FC is an NxNxT matrix, where N is the # ROIs and T is the # time points.
%
% Created 6/1/16 by DJ.
% Updated 6/19/16 by DJ - added diagValue input.
% Updated 12/19/16 by DJ - added fillLowerTri input.

if ~exist('diagValue','var') || isempty(diagValue)
    diagValue = 1;
end
if ~exist('fillLowerTri','var') || isempty(fillLowerTri)
    fillLowerTri = true;
end

fprintf('Assembling FC matrix...\n')
nFC = size(FCvec,1);
nT = size(FCvec,2);
nROIs = (1+sqrt(1+8*nFC)) / 2;

% get upper triangular matrix to convert mat <-> vec
uppertri = triu(ones(nROIs),1); % above the diagonal
% Get matrix with desired value on diagonal.
diagMat = ones(nROIs);
diagMat(eye(nROIs)==1) = diagValue;
diagMat = repmat(diagMat,1,1,nT);

% Turn each time point's matrix into a vector of the unique indices.
% (assume the elements above the diagonal contain all the information)
FC = nan(nROIs,nROIs,nT);
for i=1:nT
    if fillLowerTri
        thisFC = ones(nROIs,nROIs);
        thisFC(uppertri==1) = FCvec(:,i); % save out for easy indexing
        thisFC = thisFC.*thisFC'; % assume a symmetric matrix
    else
        thisFC = zeros(nROIs,nROIs);
        thisFC(uppertri==1) = FCvec(:,i); % save out for easy indexing
    end
    FC(:,:,i) = thisFC; 
end

% apply diagonal values
FC = FC.*diagMat; 