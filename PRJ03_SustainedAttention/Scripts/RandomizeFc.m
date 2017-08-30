function FCrand = RandomizeFc(FC)

% FCrand = RandomizeFc(FC)
%
% INPUTS:
% -FC is an nxn FC matrix, an nxnxm matrix, or an m-element cell array of
% nxn FC matrices. 
% 
% OUTPUTS:
% -FCrand is the same size as FC, but the upper triangular elements have 
% been randomized and reconstituted into a symmetric matrix.
%
% Created 10/11/16 by DJ.
% Updated 11/21/16 by DJ - allow 3D inputs and randomize each separately

if iscell(FC)
    FCrand = cell(size(FC));
    for i=1:numel(FC)
        FCrand{i} = RandomizeFc(FC{i});
    end
elseif ndims(FC)==3
    FCrand = nan(size(FC));
    for i=1:size(FC,3)
        FCrand(:,:,i) = RandomizeFc(FC(:,:,i));
    end
else
    FCvec = VectorizeFc(FC);
    FCrand = UnvectorizeFc(FCvec(randperm(numel(FCvec))),1);
end