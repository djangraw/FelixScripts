function niifilename = conn_annot2nii(varargin)
% CONN_ANNOT2NII lh.filename.annot rh.filename.annot
% converts freesurfer .annot file into .nii/.txt surface nifti ROI file

FORCEREDO=false; % forces creation of target file even if it already exists

if nargin==1&&ischar(varargin{1}), roifiles=varargin;
elseif nargin==1&&iscell(varargin{1}), roifiles=varargin{1};
else roifiles=varargin;
end

if numel(roifiles)==1
    [file_path,file_name,file_ext]=fileparts(roifiles{1});
    if strncmp(file_name,'lh.',3), roifiles=[roifiles, {fullfile(file_path,[regexprep(file_name,'^lh\.','rh.') file_ext])}]; 
    elseif strncmp(file_name,'rh.',3), roifiles=[roifiles, {fullfile(file_path,[regexprep(file_name,'^rh\.','lh.') file_ext])}]; 
    end
end

log=struct('name',{{}},'hem',[],'data',{{}},'labels',{{}});
for nfile=1:numel(roifiles)
    % gets info from .annot file
    roifile=deblank(roifiles{nfile});
    [temp_vert,temp_label,temp_table]=conn_freesurfer_read_annotation(roifile,0);
    [nill,temp_rois]=ismember(temp_label,temp_table.table(:,5));
    temp_colors=temp_table.table(:,1:3)/255;
    names_rois=temp_table.struct_names;
    
    [file_path,file_name,file_ext]=fileparts(roifile);
    if strcmp(file_name(1:2),'lh'), lhrh=1; 
    elseif strcmp(file_name(1:2),'rh'), lhrh=2; 
    else error('unrecognized file naming convention (lh.* rh.* filenames expected)');
    end
    
    log.name{end+1}=file_name(4:end);
    log.hem(end+1)=lhrh;
    log.data{end+1}=temp_rois;
    log.labels{end+1}=names_rois;
end

% creates associated .nii / .txt files
niifilename={};
for nfile1=1:numel(log.name)
    for nfile2=nfile1+1:numel(log.name)
        if strcmp(log.name{nfile1},log.name{nfile2})&&isequal(sort(log.hem([nfile1 nfile2])),[1 2])
            ifile=[nfile1,nfile2];
            fname=fullfile(file_path,[log.name{ifile(1)},'.surf.img']);
            [nill,idx]=sort(log.hem(ifile));
            ifile=ifile(idx);
            dim=conn_surf_dims(8).*[1 1 2];
            data=[log.data{ifile(1)}(:) log.data{ifile(2)}(:)];
            if numel(data)==prod(dim)
                niifilename{end+1}=fname;
                if FORCEREDO||~conn_existfile(fname),
                    names_rois=log.labels{ifile(1)};
                    none=find(strncmp('None',names_rois,4));
                    data(ismember(data,none))=0;
                    data(data(:,2)>0,2)=numel(names_rois)+data(data(:,2)>0,2);
                    names_rois=[cellfun(@(x)[x ' (L)'],names_rois,'uni',0); cellfun(@(x)[x ' (R)'],names_rois,'uni',0)];
                    V=struct('mat',eye(4),'dim',dim,'pinfo',[1;0;0],'fname',fname,'dt',[spm_type('uint16') spm_platform('bigend')]);
                    spm_write_vol(V,reshape(data,dim));
                    fprintf('Created file %s\n',fname);
                    fname=fullfile(file_path,[log.name{ifile(1)},'.surf.txt']);
                    fh=fopen(fname,'wt');
                    for n=1:max(data(:))
                        fprintf(fh,'%s\n',names_rois{n});
                    end
                    fclose(fh);
                end
                %fprintf('Created file %s\n',fname);
            end
        end
    end
end
if isempty(niifilename), error('nii file not created'); end
niifilename=char(niifilename);
