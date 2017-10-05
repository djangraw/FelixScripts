function conn_matc2nii(filename,dowaitbar)
% CONN_MATC2NII
% converts .mat/.matc volumes to .nii format

global CONN_x;
if nargin<2, dowaitbar=1;end

if nargin<1,
    filename={};
	filepathresults=CONN_x.folders.preprocessing;
	nconditions=length(CONN_x.Setup.conditions.names)-1;
    for nsub=1:CONN_x.Setup.nsubjects,
        for ncondition=1:nconditions,
            [icondition,isnew]=conn_conditionnames(CONN_x.Setup.conditions.names{ncondition});
            if isnew, error(['Mismatched condition ',CONN_x.Setup.conditions.names{ncondition}]); end
            filename{end+1}=fullfile(filepathresults,['DATA_Subject',num2str(nsub,'%03d'),'_Condition',num2str(icondition,'%03d'),'.mat']);
        end
    end
end
if ~iscell(filename), filename={filename};end
filename=regexprep(filename,'\.matc$','.mat');

outfiles={};
if dowaitbar, warning off; h=conn_waitbar(0,['Converting to nifti. Please wait...']); warning on; end
for nfile=1:length(filename),
    Y=conn_vol(filename{nfile});
    if isfield(Y,'softlink')&&~isempty(Y.softlink),
        str1=regexp(Y.fname,'Subject\d+','match'); if ~isempty(str1), Y.softlink=regexprep(Y.softlink,'Subject\d+',str1{end}); end
        [file_path,file_name,file_ext]=fileparts(Y.fname);
        filename{nfile}=fullfile(file_path,Y.softlink);
    end
    if ~ismember(filename{nfile},outfiles)
        [filenamepath,filenamename,filenameext]=fileparts(filename{nfile});
        V=struct('fname',conn_prepend('nifti',fullfile(filenamepath,[filenamename,'.nii'])),...
            'mat',Y.matdim.mat,...
            'dim',[Y.matdim.dim],...
            'n',[1,1],...
            'pinfo',[1;0;0],...
            'dt',[spm_type('float32'),spm_platform('bigend')],...
            'descrip',mfilename);
        V=repmat(V,[Y.size.Nt,1]);for nt=1:Y.size.Nt,V(nt).n=[nt,1];end
        V=spm_create_vol(V);
        for nt=1:Y.size.Nt
            Z=conn_get_time(Y,nt);
            V(nt)=spm_write_vol(V(nt),Z);
        end
        outfiles{end+1}=filename{nfile};
    end
    if dowaitbar, conn_waitbar(nfile/length(filename),h); end
end
if dowaitbar, close(h); end

