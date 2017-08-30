function fileout = TimeShiftAllFiles(filenames,nPerms)

% TimeShiftAllFiles(filenames,nPerms)
%
% INPUTS:
% -filenames is an n-element cell array of strings indicating the files
% you'd like to shift randomly (i.e., permute) in time.
% -nPerms is an integer indicating the number of random permutations you'd
% like to perform.
%
% OUTPUTS:
% -fileout is an n x nPerms cell array of strings indicating the name of
% the permutation for each input file (row) and permutation (column)
% written to output. 
% -saves n*nPerms files in the ICAtest/Perms/ directory.
%
% Created 10/6/15 by DJ.

% filenames = strsplit(ls('*_MeicaDenoised.nii'),{' ','\n'});
% filenames = strsplit(ls('*_Echo2+orig.BRIK'),{' ','\n'});
% filenames(cellfun(@isempty,filenames))=[];

fileout = cell(numel(filenames),nPerms);
for j=1:nPerms
    for i=1:numel(filenames)
        filestart = filenames{i}(1:find(ismember(filenames{i},'.+'),1)-1);
        fileout{i,j} = sprintf('ICAtest/Perms/%s_perm%03d+orig',filestart,j);
        TimeShiftData(filenames{i},fileout{i,j});
    end
end