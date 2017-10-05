function [ok,FS_folder,files]=conn_checkFSfiles(filename,verbose)
% conn_checkFSfiles checks existence of FreeSurfer result files
% 

if isstruct(filename), filename=filename(1).fname; end
FS_folder=spm_fileparts(filename);
if isempty(FS_folder), FS_folder=pwd; end
[temp1,temp2]=spm_fileparts(FS_folder);
if strcmp(temp2,'mri')||strcmp(temp2,'anat'), FS_folder=temp1; end
files=cellfun(@(x)fullfile(FS_folder,'surf',x),{'lh.white','lh.pial','lh.sphere.reg','rh.white','rh.pial','rh.sphere.reg'},'uni',0); 
existfiles=conn_existfile([{filename},files]);
ok=all(existfiles);
if nargin>1
    tfiles=[{filename},files];
    str={'not ',''};
    for n=1:numel(tfiles)
        fprintf('File %s %sfound\n',tfiles{n},str{existfiles(n)+1});
    end
    end
end
