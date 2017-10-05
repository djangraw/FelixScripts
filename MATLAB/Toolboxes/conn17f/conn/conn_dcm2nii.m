function [filenameout,filetypeout,fileRTout]=conn_dcm2nii(filename,varargin)
% CONN_DCM2NII converts DICOM to NIFTI format
%
% CONN_DCM2NII [rootfilename]-1.dcm
% converts DICOM [rootfilename]-*.dcm files into [rootfilename].nii NIFTI format
%
% CONN_DCM2NII(...,optionname,optionvalue,...) sets CONN_DCM2NII options
%   valid optionname strings are:
%   'folderout' : output folder options
%                   './' to write nii files in same folder as DICOM files
%                   './nii' to write nii files in [DICOMFOLDER]/nii folder
%                   '../nii' to write nii files in [DICOMFOLDER]/../nii folder [default]
%                   use any other string to explicitly define the output folder
%   'overwrite' : 1/0 overwrites target nifti files if they already exist (default 0)
%   'opts'        see spm_dicom_convert help
%   'root_dir'    see spm_dicom_convert help
%   'format'      see spm_dicom_convert help
%   note: options defined using CONN_DCM2NII([],optionname,optionvalue,...) are PERSISTENT for the length of the current Matlab sessions (or until a "clear conn_dcm2nii;" command is issued)
%   note: options defined using CONN_DCM2NII(filename,optionname,optionvalue,...) only appy to the convertion of the file "filename" 
%

persistent saved;

if isempty(saved), 
    saved.folderout='../nii';
    saved.overwrite=false;
    saved.spm_dicom_convert_opts='all';
    saved.spm_dicom_convert_root_dir='flat';
    saved.spm_dicom_convert_format=spm_get_defaults('images.format');
end
this=saved;

logfile=[];
if nargin>1,
    for n=1:2:numel(varargin)-1
        switch(varargin{n})
            case 'folderout', this.folderout=varargin{n+1};
            case 'overwrite', this.overwrite=varargin{n+1};
            case 'opts', this.spm_dicom_convert_opts=varargin{n+1};
            case 'root_dir', this.spm_dicom_convert_root_dir=varargin{n+1};
            case 'format', this.spm_dicom_convert_format=varargin{n+1};
            case 'logfile', logfile=varargin{n+1};
            otherwise, error('unrecognized option ',varargin{n});
        end
    end
end
if isempty(filename), saved=this; return; end
ischarfilename=ischar(filename);
filename=cellfun(@strtrim,cellstr(filename),'uni',0);

if all(cellfun('length',regexp(filename,'-1\.dcm$'))>0)
    for n0=1:numel(filename)
        allfilename=conn_dir(regexprep(filename{n0},'-1\.dcm$','-*.dcm'),'-R'); % find all -\d.dcm and sort by numbers
        if ~isempty(allfilename), filename{n0}=conn_sortfilenames(allfilename); end
    end
end

filenameout={};
filetypeout=[];
fileRTout=[];
fprintf('converting dcm files to nifti format...\n');
bak_filesout_path=0;
fhlog=[];
for n0=1:numel(filename)
    tfilename=char(filename{n0});
    [filesout_path,filesout_name,filesout_ext]=fileparts(deblank(tfilename(1,:)));
    filesout_name=[filesout_name,filesout_ext];
    switch(lower(this.folderout))
        case './',
        case './nii',  filesout_path=fullfile(filesout_path,'nii');
            [ok,nill]=mkdir(filesout_path);
        case '../nii', filesout_path=fullfile(fileparts(filesout_path),'nii');
            [ok,nill]=mkdir(filesout_path);
        otherwise,
            if ~isempty(this.folderout)&&this.folderout(1)=='.', filesout_path=fullfile(filesout_path,this.folderout);
            else filesout_path=this.folderout;
            end
    end
    if ~isempty(logfile)&&isequal(bak_filesout_path,0)
        bak_filesout_path=filesout_path;
        fhlog=fopen(logfile,'wt');
    end
    if isempty(logfile)&&~isequal(bak_filesout_path, filesout_path),
        bak_filesout_path=filesout_path;
        try, if ~isempty(fhlog), fclose(fhlog); end; end
        try, fhlog=fopen(fullfile(filesout_path,sprintf('conn_dcm2nii_%s.log',datestr(now,'yyyy_mm_dd_HHMMSSFFF'))),'wt'); end
    end
    filesout_name=regexprep(filesout_name,'-1\.dcm$','.nii');
    filesout_name=regexprep(filesout_name,'\.dcm$','.nii');
    filesout_new=fullfile(filesout_path,filesout_name);
    
    if this.overwrite || ~conn_existfile(filesout_new)
        hdrs=spm_dicom_headers(tfilename,true);
        if nargin(@spm_dicom_convert)<5, % fix for spm8 and early spm12
            filesout=spm_dicom_convert(hdrs,this.spm_dicom_convert_opts,this.spm_dicom_convert_root_dir,this.spm_dicom_convert_format);
            movefiles=true;
            if isempty(filesout)||isempty(filesout.files), error('Unable to convert DICOM file. Please try installing a more recent SPM version'); end
        else % late spm12 and beyond
            filesout=spm_dicom_convert(hdrs,this.spm_dicom_convert_opts,this.spm_dicom_convert_root_dir,this.spm_dicom_convert_format,filesout_path);
            movefiles=false;
        end
        if isstruct(filesout)&&isfield(filesout,'files')&&~isempty(filesout.files)
            if movefiles
                for n=1:numel(filesout.files),
                    tfilename=filesout.files{n};
                    [nill,tfilename_name,tfilename_ext]=fileparts(filesout.files{n});
                    newtfilename=fullfile(filesout_path,[tfilename_name,tfilename_ext]);
                    if ~strcmp(newtfilename,tfilename)
                        for ext={'.nii','.mat'}
                            if ispc, [ok,nill]=system(['move "',conn_prepend('',tfilename,ext{1}),'" "',conn_prepend('',newtfilename,ext{1}),'"']);
                            else, [ok,nill]=system(['mv ''',conn_prepend('',tfilename,ext{1}),''' ''',conn_prepend('',newtfilename,ext{1}),'''']);
                            end
                        end
                        filesout.files{n}=newtfilename;
                    end
                end
            end
            if numel(filesout.files)==1 % one 3d output file
                if ispc, [ok,nill]=system(['move "',char(filesout.files),'" "',filesout_new,'"']);
                else, [ok,nill]=system(['mv ''',char(filesout.files),''' ''',filesout_new,'''']);
                end
                if ispc, [ok,nill]=system(['move "',regexprep(char(filesout.files),'\.nii$','.mat'),'" "',regexprep(filesout_new,'\.nii$','.mat'),'"']);
                else, [ok,nill]=system(['mv ''',regexprep(char(filesout.files),'\.nii$','.mat'),''' ''',regexprep(filesout_new,'\.nii$','.mat'),'''']);
                end
                filenameout{n0}=filesout_new;
                filetypeout(n0)=1;
                fileRTout(n0)=nan;
                try,
                    a=spm_vol(filesout_new);
                    str=evalc('disp(hdrs{1})');
                    rt='unknown'; if isfield(hdrs{1},'RepetitionTime'), rt=mat2str(hdrs{1}.RepetitionTime); end
                    fprintf(fhlog,'created 3d nifti file %s\n  Description: %s\n  RT: %s\n  Dimensions: %s\n  Mapping: %s\n%s\n',filesout_new,a.descrip,rt,mat2str(a.dim),mat2str(a.mat),str);
                          fprintf('created 3d nifti file %s\n  Description: %s\n  RT: %s\n  Dimensions: %s\n  Mapping: %s\n%s\n',filesout_new,a.descrip,rt,mat2str(a.dim),mat2str(a.mat),str);
                end
            else
                a=spm_vol(char(filesout.files));
                ok=false;
                try,
                    tdim=cat(1,a.dim);
                    ok=~any(any(diff(tdim,1,1),1),2);
                end
                if ok, %spm_check_orientations(a,false) % one 4d output file
                    spm_file_merge(a,filesout_new);
                    spm_unlink(filesout.files{:});
                    filenameout{n0}=filesout_new;
                    filetypeout(n0)=numel(a);
                    str=evalc('disp(hdrs{1})');
                    rt='unknown'; if isfield(hdrs{1},'RepetitionTime'), rt=mat2str(hdrs{1}.RepetitionTime/1e3); end
                    fileRTout(n0)=str2double(rt);
                    try, fprintf(fhlog,'created 4d nifti file %s (%d volumes)\n  Description: %s\n  RT: %s\n  Dimensions: %s\n  Mapping_first: %s\n  Mapping_last: %s\n%s\n',filesout_new,numel(a),a(1).descrip,rt,mat2str(a(1).dim),mat2str(a(1).mat),mat2str(a(end).mat),str); end
                               fprintf('created 4d nifti file %s (%d volumes)\n  Description: %s\n  RT: %s\n  Dimensions: %s\n  Mapping_first: %s\n  Mapping_last: %s\n%s\n',filesout_new,numel(a),a(1).descrip,rt,mat2str(a(1).dim),mat2str(a(1).mat),mat2str(a(end).mat),str);
                else
                    filenameout{n0}={};
                    for n1=1:numel(filesout.files) % multiple 3d output files
                        tfilesout_new=conn_prepend('',filesout_new,['-',num2str(n1,'%04d'),'.nii']);
                        if ispc, [ok,nill]=system(['move "',char(filesout.files{n1}),'" "',tfilesout_new,'"']);
                        else, [ok,nill]=system(['mv ''',char(filesout.files{n1}),''' ''',tfilesout_new,'''']);
                        end
                        if ispc, [ok,nill]=system(['move "',regexprep(char(filesout.files{n1}),'\.nii$','.mat'),'" "',regexprep(tfilesout_new,'\.nii$','.mat'),'"']);
                        else, [ok,nill]=system(['mv ''',regexprep(char(filesout.files{n1}),'\.nii$','.mat'),''' ''',regexprep(tfilesout_new,'\.nii$','.mat'),'''']);
                        end
                        filenameout{n0}{n1}=tfilesout_new;
                    end
                    str=evalc('disp(hdrs{1})');
                    rt='unknown'; if isfield(hdrs{1},'RepetitionTime'), rt=mat2str(hdrs{1}.RepetitionTime/1e3); end
                    try, fprintf(fhlog,'created multiple 3d nifti files %s-#### (%d volumes)\n  Description: %s\n  RT: %s\n  Dimensions_first: %s\n  Mapping_first: %s\n  Dimensions_last: %s\n  Mapping_last: %s\n%s\n',filesout_new,numel(a),a(1).descrip,rt,mat2str(a(1).dim),mat2str(a(1).mat),mat2str(a(end).dim),mat2str(a(end).mat),str); end
                               fprintf('created multiple 3d nifti files %s-#### (%d volumes)\n  Description: %s\n  RT: %s\n  Dimensions_first: %s\n  Mapping_first: %s\n  Dimensions_last: %s\n  Mapping_last: %s\n%s\n',filesout_new,numel(a),a(1).descrip,rt,mat2str(a(1).dim),mat2str(a(1).mat),mat2str(a(end).dim),mat2str(a(end).mat),str);
                    filenameout{n0}=char(filenameout{n0});
                    filetypeout(n0)=numel(a);
                    fileRTout(n0)=str2double(rt);
                end
            end
        else
            filenameout{n0}=[];
            filetypeout(n0)=0;
            fileRTout(n0)=nan;
        end
    else
        a=spm_vol(filesout_new);
        filenameout{n0}=filesout_new;
        filetypeout(n0)=numel(a);
        fileRTout(n0)=nan;
    end
end
try, fclose(fhlog); end
if ischarfilename,
    while iscell(filenameout)&&numel(filenameout)==1, filenameout=filenameout{1}; end
    try, filenameout=char(filenameout); end;
end
fprintf('done\n');
    

