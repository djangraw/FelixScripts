function [out,iFail] = areConnected(comps,match_cell,threshold)

% out = areConnected(comps,match_cell,threshold)
%
% INPUTS:
% -comps is an n-element vector of the components, one from each run
% -match_cell is an nxn cell array in which each upper triangular cell
% (i,j) contain an mxp array of correlation coefficients to be thresholded
% at threshold.
% -threshold is a scalar indicating the maximum value of match_cell
% considered disconnected.
%
% OUTPUTS:
% -out is a boolean value that is true if all the nodes are connected to
% all the other nodes.
% -iFail is a 2-element vector containing the pair of nodes that didn't 
%
% Created 4/1/15 by DJ.

if nargin<3 || isempty(threshold)
    threshold=0.15;
end

nComps = length(comps);
for i=1:nComps
    for j=(i+1):nComps
        if abs(match_cell{i,j}(comps(i),comps(j))) <= threshold
            % failed! return false
%             fprintf('run(comp) %d(%d) and %d(%d) are not connected.\n',i,comps(i),j,comps(j));
            out = false;
            iFail = [i j];
            return
        end
    end
end
% passed! Return true
out = true;
iFail = [NaN NaN];
