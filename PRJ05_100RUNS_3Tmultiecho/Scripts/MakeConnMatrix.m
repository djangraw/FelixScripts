function connMat = MakeConnMatrix(runs,comps,match_cell,threshold)

% out = areConnected(runs,comps,match_cell)
%
% INPUTS:
% -iMatches is an nx2 matrix where each row is a (run,component) pair.
% -match_cell is an nxn cell array in which each upper triangular cell
% (i,j) contain an mxp array of correlation coefficients to be thresholded
% at threshold.
% -threshold is a scalar.
%
% OUTPUTS:
% -connMat is an nxn matrix of booleans. connMat(i,j) is true if
% run runs(i) component components(i) and run run(j) component
% components(j) are connected.
%
% Created 4/1/15 by DJ.

if nargin<4 || isempty(threshold)
    threshold=0.15;
end

nComps = length(comps);
connMat = false(nComps,nComps);
for i=1:nComps
    for j=(i+1):nComps
        if runs(i)>=runs(j) continue; end
        if abs(match_cell{runs(i),runs(j)}(comps(i),comps(j))) > threshold
            connMat(i,j) = true;
            connMat(j,i) = true;
        end
    end
end