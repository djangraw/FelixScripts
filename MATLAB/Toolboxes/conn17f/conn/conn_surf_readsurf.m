function surf=conn_surf_readsurf(filename,singlefile)
if nargin<1||isempty(filename), filename=fullfile(fileparts(which(mfilename)),'utils','surf','pial.smoothed.surf'); end
[file_path,file_name,file_ext]=fileparts(filename);

if nargin<2||isempty(singlefile), 
    singlefile=isequal(file_name,'lh')|isequal(file_name,'rh')|strncmp(file_name,'lh.',3)|strncmp(file_name,'rh.',3); 
end
if singlefile
    [vertices,faces]=conn_freesurfer_read_surf(filename);
    surf=struct('vertices',vertices,'faces',faces+1);
else
    [vertices,faces]=conn_freesurfer_read_surf(fullfile(file_path,['lh.',file_name,file_ext]));
    surf=struct('vertices',vertices,'faces',faces+1);
    [vertices,faces]=conn_freesurfer_read_surf(fullfile(file_path,['rh.',file_name,file_ext]));
    surf(2)=struct('vertices',vertices,'faces',faces+1);
end


