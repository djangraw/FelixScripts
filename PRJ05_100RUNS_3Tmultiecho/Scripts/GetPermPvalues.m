function GetPermPvalues(subject,fileType)

% GetPermPvalues(subject,fileType)
%
% INPUTS:
% -subject is a string indicating the subject's name.
% -fileType is a string indicating the type of data used as input:
% 'MEICA','Echo2', etc.
% 
% OUTPUTS:
% -an AFNI brick called <subject>_<fileType>_ISC_16files_PermAdj+orig will
% be written to the current directory.
%
% Created 10/8/15 by DJ.

% subject = 'SBJ01';
% fileType = 'MEICA';
filenames = strsplit(ls(sprintf('Perms%s/%s_%s_ISC_perm*+orig.BRIK',fileType,subject,fileType)),{' ','\n'});
filenames(cellfun(@isempty,filenames))=[];

switch subject
    case 'SBJ01'
        nFiles = 16;
    case 'SBJ02'
        nFiles = 17;
end

compFilename = sprintf('%s_%s_ISC_%dfiles+orig.BRIK',subject,fileType,nFiles);
[err,V,Info,errMsg] = BrikLoad(compFilename);

V_newp = V(:,:,:,2)*0;
fprintf('Comparing with %d permutation files...\n',numel(filenames))
for i=1:numel(filenames)    
    fprintf('%d/%d...\n',i,numel(filenames));
    [err,Vperm,Info,errMsg] = BrikLoad(filenames{i});
    V_newp = V_newp + (V(:,:,:,2) < Vperm(:,:,:,2));
end
V_newp = V_newp/numel(filenames);
V_newz = icdf('normal',1-V_newp,0,1);

% write new file
V_new = cat(4,V(:,:,:,1), V_newz);
outFile = sprintf('%s_%s_ISC_%dfiles_PermAdj+orig.BRIK',subject,fileType,nFiles);
Opt = struct('prefix',outFile,'OverWrite','y');
WriteBrik(V_new,Info,Opt);