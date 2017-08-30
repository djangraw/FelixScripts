function FCvec = VectorizeFc(FC)

% Turn a 3d FC matrix into a 2d matrix of just the unique elements.
%
% FCvec = VectorizeFc(FC)
%
% INPUTS:
% -FC is an NxNxT matrix, where N is the # ROIs and T is the # time points.
%  This function assumes FC is a symmetric matrix.
%
% OUTPUTS:
% -FCvec is a matrix of size N*(N-1)/2 x T. Each row is a unique ROI pair.
%
% Created 6/1/16 by DJ.

fprintf('Assembling FC vector...\n')
% get upper triangular matrix to convert mat <-> vec
uppertri = triu(ones(size(FC,1)),1); % above the diagonal

% Turn each time point's matrix into a vector of the unique indices.
% (assume the elements above the diagonal contain all the information)
nT = size(FC,3);
nFC = sum(uppertri(:)); % number of unique elements 
FCvec = nan(nFC,nT);
for i=1:nT
    thisFC = FC(:,:,i); % save out for easy indexing
    FCvec(:,i) = thisFC(uppertri==1); % assume a symmetric matrix
end