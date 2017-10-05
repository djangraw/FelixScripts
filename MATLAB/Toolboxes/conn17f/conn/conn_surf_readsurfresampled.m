function surf=conn_surf_readsurfresampled(filename,fcn)
if nargin<2, fcn=@conn_freesurfer_read_surf; end
[file_path,file_name,file_ext]=fileparts(filename);
file_name=[file_name,file_ext];
if strncmp(file_name,'lh.',3), hem='lh'; 
elseif strncmp(file_name,'rh.',3), hem='rh';
else error(['unable to determine hemisphere of file ',filename]);
end
fileref=fullfile(file_path,[hem,'.sphere.reg']);
if ~conn_existfile(fileref), error(['unable to find file ',fileref]); end

% resample at sphere reference grid
data_ref=feval(fcn,filename);
resolution=8;
xyz_ref=conn_freesurfer_read_surf(fileref);
[xyz_sphere,sphere2ref,ref2sphere]=conn_surf_sphere(resolution,xyz_ref);
xyz=data_ref(ref2sphere,:);
faces=xyz_sphere.faces;
surf=struct('vertices',xyz,'faces',faces);

