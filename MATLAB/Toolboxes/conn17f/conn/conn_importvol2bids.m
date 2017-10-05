function [out,changed,V]=conn_importvol2bids(filename,nsub,nses,fmod,ftype,docopy,dodisp)
% CONN_IMPORTVOL2BIDS imports functional/anatomical file into CONN/BIDS directory
% conn_importvol2bids(filename,nsub,nses,fmod,[froot])
%   fmod   : file modality (anat, func, dwi, fmap)
%   froot  : filename root (defaults: T1w for 'anat'; task-rest_bold for 'func')

global CONN_x;
SOFTLINK=false; % change to "true" to use soft links instead of copying files (note: this feature is not fully tested)

if ~nargin
    changed=false;
    out={};
    V=[];
    for nsub=1:CONN_x.Setup.nsubjects
        nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
        if ~CONN_x.Setup.structural_sessionspecific, nsesstemp=1; else nsesstemp=nsess; end
        for nses=1:nsesstemp,
            [out{1}{nsub}{nses},tchanged]=conn_importvol2bids(CONN_x.Setup.structural{nsub}{nses}{1},nsub,nses,'anat',[],[],true);
            changed=changed|tchanged;
        end
        for nses=1:nsess,
            [out{2}{nsub}{nses},tchanged]=conn_importvol2bids(CONN_x.Setup.functional{nsub}{nses}{1},nsub,nses,'func',[],[],true);
            changed=changed|tchanged;
        end
    end
    return
end

changed=false;
V=[];
if nargin<7||isempty(dodisp), dodisp=false; end
if nargin<6||isempty(docopy), docopy=true; end
if nargin<5||isempty(ftype), 
    switch(fmod)
        case 'func', ftype='task-rest_bold.nii'; 
        case 'anat', ftype='T1w.nii'; 
        case 'dwi',  ftype='dwi.nii'; 
        case 'fmap', ftype='phasediff.nii'; 
        otherwise,   ftype='unknown';
    end
end
if ismember(fmod,{'func','anat','dwi','fmap'}), BIDSfolder=fullfile(CONN_x.folders.bids,'dataset');  % root directory
else BIDSfolder=fullfile(CONN_x.folders.bids,'derivatives'); % derivatives
end
if ~isempty(nsub), fsub=sprintf('sub-%04d',nsub(1)); else fsub=''; end
if ~isempty(nses), fses=sprintf('ses-%04d',nses(1)); else fses=''; end
newfilepath=BIDSfolder; [ok,nill]=mkdir(newfilepath);
if ~isempty(fsub),      [ok,nill]=mkdir(newfilepath,fsub); newfilepath=fullfile(newfilepath,fsub); end
if ~isempty(fses),      [ok,nill]=mkdir(newfilepath,fses); newfilepath=fullfile(newfilepath,fses);  end
if ~isempty(fmod),      [ok,nill]=mkdir(newfilepath,fmod); newfilepath=fullfile(newfilepath,fmod); end
newfilename=ftype;
if ~isempty(fses),      newfilename=sprintf('%s_%s',fses,newfilename); end
if ~isempty(fsub),      newfilename=sprintf('%s_%s',fsub,newfilename); end
out=fullfile(newfilepath,newfilename);

if iscell(filename), filename=char(filename); end
[nill,nill,fext]=fileparts(out);
[tfileroot,tfileext1,tfileext2,tfilenum]=conn_fileparts(filename);
exts={};
if strcmp(fext,'.nii')&&strcmp(tfileext1,'.img')&&isempty(tfileext2), % convert .img to .nii
    if docopy
        f=conn_dir(conn_prepend('',out,'.*'),'-R');
        if ~isempty(f)
            f=cellstr(f);
            spm_unlink(f{:});
        end
        changed=true;
        a=spm_vol(filename);
        spm_file_merge(a,out)
        filename=out;
    end
else % copy/link file
    out=conn_prepend('',fullfile(newfilepath,newfilename),[tfileext1,tfileext2,tfilenum]); % keep extension of input file
    if docopy && ~isequal(filename, out)
        f=conn_dir(conn_prepend('',out,'.*'),'-R');
        if ~isempty(f)
            f=cellstr(f);
            spm_unlink(f{:});
        end
        changed=true;
        exts={[tfileext1,tfileext2]};
        if strcmp(tfileext1,'.img'), exts=[exts, {'.hdr'}]; end
    end
end
if docopy&&changed
    switch(fmod)
        case 'dwi',  exts=[exts {'.bval','.bvec','.json'}];
        case 'rois', exts=[exts {'.txt','.csv','.xls','.info','.icon.jpg','.json'}];
        otherwise,   exts=[exts {'.json'}];
    end
    for nexts=1:numel(exts) % copy/link original and additional files if needed
        tfilename=[tfileroot,exts{nexts}];
        if conn_existfile(tfilename)
            outfile=conn_prepend('',fullfile(newfilepath,newfilename),exts{nexts});
            if ispc, [ok,nill]=mysystem(['copy "',tfilename,'" "',outfile,'"']);
            elseif SOFTLINK, [ok,nill]=system(['ln -fs ''',tfilename,''' ''',outfile,'''']);
            else, [ok,nill]=system(['cp ''',tfilename,''' ''',outfile,'''']);
            end
        end
    end
    if strcmp(fmod,'anat')
        [ok,nill,fsfiles]=conn_checkFSfiles(filename);
        if ok
            [ok,nill]=mkdir(fileparts(newfilepath),'surf');
            for nexts=1:numel(fsfiles) % copy/link original and additional files if needed
                tfilename=fsfiles{nexts};
                [nill,tfilename_name,tfilename_ext]=spm_fileparts(tfilename);
                outfile=fullfile(fileparts(newfilepath),'surf',[tfilename_name tfilename_ext]);
                if ispc, [ok,nill]=mysystem(['copy "',tfilename,'" "',outfile,'"']);
                elseif SOFTLINK, [ok,nill]=system(['ln -fs ''',tfilename,''' ''',outfile,'''']);
                else, [ok,nill]=system(['cp ''',tfilename,''' ''',outfile,'''']);
                end
            end
        end
    end
end
if docopy
    if strcmp(fmod,'func')&&~conn_existfile(conn_prepend('',outfile,'.json')),
        try % initializes .json with TR info
            spm_jsonwrite(conn_prepend('',outfile,'.json'),struct('RepetitionTime',CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub(end)))));
        end
    end
    if changed&&dodisp, fprintf('Created file %s from %s\n',out,filename(1,:)); end
    switch(fmod) % initializes CONN_x functional/structural fields
        case 'func'
            [CONN_x.Setup.functional{nsub(end)}{nses(end)},V]=conn_file(out); % note: when nsubs = [nsubs1 nsubs2] or nses = [nses1 nses2] file_bids(nsub1,nses1) is assigned to nsub2,nses2 (in order to allow subject- and session- independent data)
        case 'anat'
            [CONN_x.Setup.structural{nsub(end)}{nses(end)},V]=conn_file(out);
    end
end
end

function varargout=conn_fileparts(filename)
varargout=regexp(deblank(filename(1,:)),'^(.*?)(\.[^\.]*?)(\.gz)?(\,\d+)?$','tokens','once');
if numel(varargout)<nargout, varargout=[varargout, repmat({''},1,nargout-numel(varargout))]; end
end
