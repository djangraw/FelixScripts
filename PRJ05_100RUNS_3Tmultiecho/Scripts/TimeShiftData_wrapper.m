function outFiles = TimeShiftData_wrapper(inFiles,nPerms)

% outFiles = TimeShiftData_wrapper(inFiles,nPerms)
%
% INPUTS:
% -inFiles is an n-element cell array of strings containing filenames.
% -nPerms is a scalar indicating the number of permutations you'd like to
% run.
%
% OUTPUTS:
% -outFiles is an n x nPerms matrix of strings indicating the filename that
% was saved to current directory for each file (row) and permutation
% (column). 
%
% Created 10/7/15 by DJ.

outFiles = cell(numel(inFiles),nPerms);
for i=1:numel(inFiles)
    for j=1:nPerms    
        inFile = inFiles{i};
        inFileStart = inFile(1:find(inFile=='+',1)-1);
        outFile = sprintf('%s_perm%03d',inFileStart,j);
        iShift = []; % random
        TimeShiftData(inFile,outFile,iShift);
        outFiles{i,j} = outFile;
    end
end