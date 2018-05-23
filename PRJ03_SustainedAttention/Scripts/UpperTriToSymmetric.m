function FC_sym = UpperTriToSymmetric(FC,diagValue)

% FC_sym = UpperTriToSymmetric(FC,diagValue)
%
% Reflect upper triangular half of matrix to fill the bottom part, making a
% symmetric matrix. The diagonal will be filled with input diagValue
% (default = 0).
%
% Created 3/9/17 by DJ.
% Updated 5/22/18 by DJ - added diagValue input, comments.

if ~exist('diagValue','var') || isempty(diagValue)
    diagValue = 0;
end
FC_sym = UnvectorizeFc(VectorizeFc(FC),diagValue,true);