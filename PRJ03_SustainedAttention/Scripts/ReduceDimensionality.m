function [dataMatOut, V_reduced] = ReduceDimensionality(dataMat,fracVarToKeep,isCensoredSample)

% [dataMatOut,V_reduced] = ReduceDimensionality(dataMat,fracVarToKeep,isCensoredSample)
%
% INPUTS:
% - dataMat is an NxT matrix with N features and T samples.
% - fracVarToKeep is a scalar indicating what fraction of the variance
% you'd like to keep in the dimensionality-reduced data.
% - isCensoredSample is a T-element vector of booleans indicating whether
% each sample of dataMat should be included in the SVD calculation.
% 
% OUTPUTS:
% - dataMatOut is an MxT matrix, where M<=N, with M components and T time
% points. dataMatOut is a dimensionality-reduced version of M.
% - V_reduced is an NxM matrix that can be used to transform the data back
% to the original feature space. (dataMatOut = V_reduced' * dataMat;
% dataMatOut_origSpace = V_reduced * dataMatOut;)
%
% Created 8/10/16 by DJ.

% Declare defaults
if ~exist('isCensoredSample','var') || isempty(isCensoredSample)
    isCensoredSample = false(1,size(dataMat,2));
end

% Run SVD
[~,S,V] = svd(dataMat(:,~isCensoredSample)',0);
fracVar = cumsum(diag(S).^2)/sum(diag(S).^2);
% Determine how many components to keep
lastToKeep = find(fracVar<=fracVarToKeep,1,'last');
if isempty(lastToKeep)
    lastToKeep = 1;
end
fprintf('Keeping %d/%d PCs (%.1f%% variance)\n',lastToKeep,size(dataMat,1),fracVarToKeep*100)
% Perform dimensionality reduction on mag features
V_reduced = V(:,1:lastToKeep);
dataMatOut = V_reduced'*dataMat; % rotate using SVD matrix
