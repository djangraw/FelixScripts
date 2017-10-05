function filename=conn_surf_smooth(filename,nsmooth,ref)
% SURF_SMOOTH smoothes fsaverage data
%
% SURF_SMOOTH(FILENAME,N)
% applies spatial smoothing (N diffusion steps) to fsaverage vertex-level data in FILENAME
% note: output smoothed filename prepended with 's'
%

if nargin<2||isempty(nsmooth), nsmooth=10; end
if nargin<3||isempty(ref), ref=fullfile(fileparts(which('conn')),'utils','surf','lh.pial.surf'); end

[xyz,faces]=conn_freesurfer_read_surf(ref);
faces=faces+1;
if ~ischar(filename), 
    a=[];
    b=filename;
    filename='manual data'; 
else 
    a=spm_vol(filename);
    b=spm_read_vols(a);
end
if rem(numel(b),163842), error('Incorrect dimensions in file %s (%d voxels)',filename); end
sB=size(b);
b=reshape(b,163842,[]);
b(isnan(b))=0;
A=double(sparse(repmat(faces,3,1),repmat(faces,1,3), 1)>0);
A=double(A|speye(size(A,1)));
A=A*sparse(1:size(A,1),1:size(A,1),1./sum(A,2));
for n=1:nsmooth,
    b=A*b;
end
b=reshape(b,sB);
if isempty(a)
    filename=b;
else
    V=a(1);
    V.fname=conn_prepend('s',filename);
    V.dt(1)=spm_type('float32');
    V.pinfo=[1;0;0];
    filename=V.fname;
    if size(b,4)>1
        V=repmat(V,[size(b,4),1]);for nh=1:size(b,4),V(nh).n=[nh,1];end
        V=spm_create_vol(V);
        for nh=1:size(b,4), V(nh)=spm_write_vol(V(nh),b(:,:,:,nh)); end
    else
        spm_write_vol(V,b);
    end
    fprintf('Saved output to %s\n',filename);
end

