function out=conn_importspm(spmfiles,varargin)
% Imports experiment info from SPM.mat files
%
% CONN_IMPORTSPM(spmfiles);
%
% CONN_IMPORTSPM(spmfiles,parameter1_name,parameter1_value,...);
%  Valid parameter names are:
%    'addrestcondition'          : 1/0 add default 'rest' condition (entire functional data) to Setup.Conditions [true]
%    'addconditions'             : 1/0 add condition information (from SPM.Sess(nses).U) to Setup.Conditions [true]
%    'breakconditionsbysession'  : 1/0 creates session-specific conditions [false] 
%    'addcovariates'             : 1/0 add additional covariates (from SPM.Sess(nses).C) to Setup.CovariatesFirstLevel [true]
%    'addrealignment'            : 1/0 add realignment covariates (from rp_<functional_filename>.txt) to Setup.CovariatesFirstLevel [false]
%    'addartfiles'               : 1/0 add ART covariates (from art_regresion_outliers_<functional_filename>.mat) to Setup.CovariatesFirstLevel [true]
%    

global CONN_x;
options=struct('addrestcondition',true,...
               'addconditions',true,...
               'addcovariates',true,...
               'addrealignment',false,...
               'addartfiles',true,...
               'breakconditionsbysession',false,...
               'subjects',[]);
for n1=1:2:nargin-1, if ~isfield(options,lower(varargin{n1})), error('unknown option %s',lower(varargin{n1})); else options.(lower(varargin{n1}))=varargin{n1+1}; end; end
if ~isempty(options.subjects), SUBJECTS=options.subjects; else SUBJECTS=1:CONN_x.Setup.nsubjects; end
if nargin>0&&~isempty(spmfiles),
    if ~iscell(spmfiles),spmfiles=cellstr(spmfiles);end
    nsubjects=length(spmfiles);
    for nsub=1:nsubjects,
        CONN_x.Setup.spm{SUBJECTS(nsub)}=conn_file(char(spmfiles{nsub}));
    end
end

%CONN_x.Setup.nsessions=zeros(1,CONN_x.Setup.nsubjects);
changed=0;err=0;
importfunctional=true;
for nsub=SUBJECTS,
    if ~isempty(CONN_x.Setup.spm{nsub}{1}),
        session_count=0;
        files=cellstr(CONN_x.Setup.spm{nsub}{1});
        for ifile=1:numel(files)
            %try,
            spmfile=load(files{ifile});
            if isfield(spmfile.SPM,'xBF')&&isfield(spmfile.SPM.xBF,'UNITS'),
                units=spmfile.SPM.xBF.UNITS;
                if strcmp(units,'scans'), units=1;
                elseif strcmp(units,'secs'), units=2;
                else, disp(['warning: importing from ',files{ifile},': invalid SPM.xBF.UNITS value (assuming scans)']); err=err+1; end
            else, disp(['warning: importing from ',files{ifile},': SPM.xBF.UNITS not found (assuming scans)']); units=1; err=err+1; end
            if isfield(spmfile.SPM,'xY')&&isfield(spmfile.SPM.xY,'RT'),
                if session_count>0&&CONN_x.Setup.RT(nsub)~=spmfile.SPM.xY.RT, 
                    disp(['ERROR: importing from ',files{ifile},': SPM.xY.RT different from previous session(s) (leaving unchanged)']); err=err+1;
                else
                    CONN_x.Setup.RT(nsub)=spmfile.SPM.xY.RT;
                end
            else,
                if isempty(CONN_x.Setup.RT), CONN_x.Setup.RT=2; end
                CONN_x.Setup.RT(nsub)=CONN_x.Setup.RT(end);
                disp(['warning: importing from ',files{ifile},': SPM.xY.RT not found (leaving unchanged)']); err=err+1;
            end
            if ~isfield(spmfile.SPM,'nscan'), disp(['ERROR: importing from ',files{ifile},': SPM.nscan not found (stopped importing for this subject)']); err=err+1;
            else,
                nsess=length(spmfile.SPM.nscan);
                for nses=1:nsess,
                    session_count=session_count+1;
                    idx=spmfile.SPM.Sess(nses).row;
                    filename=fliplr(deblank(fliplr(deblank(spmfile.SPM.xY.P(idx,:)))));
                    switch(filesep),case '\',idx=find(filename=='/');case '/',idx=find(filename=='\');end; filename(idx)=filesep;
                    if importfunctional
                        n=0; while n<size(filename,1),
                            ok=conn_existfile(filename(n+1,:));
                            if ok, n=n+1;
                            else
                                if changed,
                                    fullnamematch=strvcat(fliplr(fullname1),fliplr(fullname2));
                                    m=sum(cumsum(fullnamematch(1,:)~=fullnamematch(2,:))==0);
                                    m1=max(0,length(fullname1)-m); m2=max(0,length(fullname2)-m);
                                    %filename=strvcat(filename(1:n,:),[repmat(fullname2(1:m2),[size(filename,1)-n,1]),filename(n+1:end,m1+1:end)]);
                                    filenamet=strvcat(filename(1:n,:),[fullname2(1:m2),filename(n+1,m1+1:end)],filename(n+2:end,:));
                                    if ~conn_existfile(filenamet(n+1,:)), askthis=1;
                                    else
                                        try
                                            disp(['conn_importspm: updating reference from ',deblank(filename(n+1,:)),' to ',deblank(filenamet(n+1,:))]);
                                            [V,str,icon]=conn_getinfo(deblank(filenamet(n+1,:)));
                                            askthis=0;filename=filenamet;
                                        catch
                                            askthis=1;
                                        end
                                    end
                                else askthis=1;
                                end
                                if askthis,
                                    disp(['conn_importspm: file ',deblank(filename(n+1,:)),' not found']);
                                    fullname1=deblank(filename(n+1,:));
                                    [pathname1,name1,ext1,num1]=spm_fileparts(fullname1);
                                    name2='';
                                    while ~strcmp(name2,[name1,ext1])&&~isequal(name2,0)
                                        disp(['File not found: ',name1,ext1]);
                                        [name2,pathname2]=uigetfile(['*',ext1],['File not found: ',name1,ext1],['*',name1,ext1]);
                                    end
                                    if isequal(name2,0), importfunctional=false; break; end
                                    fullname2=fullfile(pathname2,[name2,num1]);
                                    changed=1;
                                    fullnamematch=strvcat(fliplr(fullname1),fliplr(fullname2));
                                    m=sum(cumsum(fullnamematch(1,:)~=fullnamematch(2,:))==0);
                                    m1=max(0,length(fullname1)-m); m2=max(0,length(fullname2)-m);
                                    filename=strvcat(filename(1:n,:),[fullname2(1:m2),filename(n+1,m1+1:end)],filename(n+2:end,:));
                                end
                            end
                        end
                    end
                    [filename1_path,filename1_name,filename1_ext,filename1_num]=spm_fileparts(filename(1,:));
                    filename1=fullfile(filename1_path,[filename1_name,filename1_ext]);
                    if importfunctional
                        [V,str,icon]=conn_getinfo(filename);
                        CONN_x.Setup.functional{nsub}{session_count}={filename,str,icon};
                        CONN_x.Setup.nscans{nsub}{session_count}=numel(V);
                    else
                        disp('warning: no functional data imported'); %err=err+1;
                        CONN_x.Setup.nscans{nsub}{session_count}=size(filename,1);
                    end
                    % adds rest condition
                    if options.addrestcondition
                        name='rest';
                        idx=strmatch(name,CONN_x.Setup.conditions.names,'exact');
                        if isempty(idx), idx=length(CONN_x.Setup.conditions.names); CONN_x.Setup.conditions.names{end+1}=' '; end
                        CONN_x.Setup.conditions.param(idx)=0;
                        CONN_x.Setup.conditions.filter{idx}=[];
                        CONN_x.Setup.conditions.names{idx}=name;
                        CONN_x.Setup.conditions.values{nsub}{idx}{session_count}{1}=0;
                        CONN_x.Setup.conditions.values{nsub}{idx}{session_count}{2}=inf;
                    end
                    % adds other conditions/covariates
                    if 0, % this option is no longer supported   isfield(CONN_x.Setup,'spmascovariate')&&CONN_x.Setup.spmascovariate
                        if isfield(spmfile.SPM.Sess(nses),'col')&&~isempty(spmfile.SPM.Sess(nses).col)
                            name='SPM effects';
                            idx=strmatch(name,CONN_x.Setup.l1covariates.names,'exact');
                            if isempty(idx), idx=length(CONN_x.Setup.l1covariates.names); CONN_x.Setup.l1covariates.names{end+1}=' '; end
                            CONN_x.Setup.l1covariates.names{idx}=name;
                            CONN_x.Setup.l1covariates.files{nsub}{idx}{session_count}={'[raw values]',[],spmfile.SPM.xX.X(spmfile.SPM.Sess(nses).row,spmfile.SPM.Sess(nses).col)};
                        end
                        if isfield(spmfile.SPM.Sess(nses),'C')&&~isempty(spmfile.SPM.Sess(nses).C.C)
                            name='SPM covariates';
                            idx=strmatch(name,CONN_x.Setup.l1covariates.names,'exact');
                            if isempty(idx), idx=length(CONN_x.Setup.l1covariates.names); CONN_x.Setup.l1covariates.names{end+1}=' '; end
                            CONN_x.Setup.l1covariates.names{idx}=name;
                            CONN_x.Setup.l1covariates.files{nsub}{idx}{session_count}={'[raw values]',[],spmfile.SPM.Sess(nses).C.C};
                        elseif ~isempty(dir(conn_prepend('rp_',filename1,'.txt'))),
                            name='realignment';
                            idx=strmatch(name,CONN_x.Setup.l1covariates.names,'exact');
                            if isempty(idx), idx=length(CONN_x.Setup.l1covariates.names); CONN_x.Setup.l1covariates.names{end+1}=' '; end
                            CONN_x.Setup.l1covariates.names{idx}=name;
                            CONN_x.Setup.l1covariates.files{nsub}{idx}{session_count}=conn_file(conn_prepend('rp_',filename1,'.txt'));
                        end
                    else
                        nconditions=length(spmfile.SPM.Sess(nses).U);
                        if options.addconditions,
                            for ncondition=1:nconditions,
                                name=spmfile.SPM.Sess(nses).U(ncondition).name{1};
                                if isempty(name)||~ischar(name), name=sprintf('SPMcondition%d',ncondition); end
                                if options.breakconditionsbysession, name=sprintf('%s_Session%d',name,session_count); end
                                idx=strmatch(name,CONN_x.Setup.conditions.names,'exact');
                                if isempty(idx),
                                    idx=length(CONN_x.Setup.conditions.names);
                                    CONN_x.Setup.conditions.names{end+1}=' ';
                                end
                                CONN_x.Setup.conditions.param(idx)=0;
                                CONN_x.Setup.conditions.filter{idx}=[];
                                CONN_x.Setup.conditions.names{idx}=name;
                                if units==2,
                                    CONN_x.Setup.conditions.values{nsub}{idx}{session_count}{1}=spmfile.SPM.Sess(nses).U(ncondition).ons;
                                    CONN_x.Setup.conditions.values{nsub}{idx}{session_count}{2}=spmfile.SPM.Sess(nses).U(ncondition).dur;
                                else,
                                    CONN_x.Setup.conditions.values{nsub}{idx}{session_count}{1}=(spmfile.SPM.Sess(nses).U(ncondition).ons-0)*CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub));
                                    CONN_x.Setup.conditions.values{nsub}{idx}{session_count}{2}=spmfile.SPM.Sess(nses).U(ncondition).dur*CONN_x.Setup.RT(min(numel(CONN_x.Setup.RT),nsub));
                                end
                            end
                        end
                        
                        if options.addcovariates && isfield(spmfile.SPM.Sess(nses),'C')&&~isempty(spmfile.SPM.Sess(nses).C.C)
                            name='SPM covariates';
                            idx=strmatch(name,CONN_x.Setup.l1covariates.names,'exact');
                            if isempty(idx), idx=length(CONN_x.Setup.l1covariates.names); CONN_x.Setup.l1covariates.names{end+1}=' '; end
                            CONN_x.Setup.l1covariates.names{idx}=name;
                            CONN_x.Setup.l1covariates.files{nsub}{idx}{session_count}={'[raw values]',[],spmfile.SPM.Sess(nses).C.C};
                        end
                        if options.addrealignment && ~isempty(dir(conn_prepend('rp_',filename1,'.txt'))),
                            name='realignment';
                            idx=strmatch(name,CONN_x.Setup.l1covariates.names,'exact');
                            if isempty(idx), idx=length(CONN_x.Setup.l1covariates.names); CONN_x.Setup.l1covariates.names{end+1}=' '; end
                            CONN_x.Setup.l1covariates.names{idx}=name;
                            CONN_x.Setup.l1covariates.files{nsub}{idx}{session_count}=conn_file(conn_prepend('rp_',filename1,'.txt'));
                        end
                        if options.addartfiles && ~isempty(dir(conn_prepend('art_regresion_outliers_',filename1,'.mat'))),
                            name='ART covariates';
                            idx=strmatch(name,CONN_x.Setup.l1covariates.names,'exact');
                            if isempty(idx), idx=length(CONN_x.Setup.l1covariates.names); CONN_x.Setup.l1covariates.names{end+1}=' '; end
                            CONN_x.Setup.l1covariates.names{idx}=name;
                            CONN_x.Setup.l1covariates.files{nsub}{idx}{session_count}=conn_file(conn_prepend('art_regresion_outliers_',filename1,'.mat'));
                        end
                    end
                end
            end
        end
        if ~err, CONN_x.Setup.nsessions(nsub)=session_count; end
    end
end
if ~err, % fills possible empty conditions for each subject/session
    nconditions=length(CONN_x.Setup.conditions.names)-1;
    for nsub2=1:nsub,
        nsess=CONN_x.Setup.nsessions(nsub2);
        for ncondition=1:nconditions
            for nses=1:nsess
                if numel(CONN_x.Setup.conditions.values{nsub2})<ncondition||numel(CONN_x.Setup.conditions.values{nsub2}{ncondition})<nses||numel(CONN_x.Setup.conditions.values{nsub2}{ncondition}{nses})<1,
                    CONN_x.Setup.conditions.values{nsub2}{ncondition}{nses}{1}=[];
                end
                if numel(CONN_x.Setup.conditions.values{nsub2})<ncondition||numel(CONN_x.Setup.conditions.values{nsub2}{ncondition})<nses||numel(CONN_x.Setup.conditions.values{nsub2}{ncondition}{nses})<2,
                    CONN_x.Setup.conditions.values{nsub2}{ncondition}{nses}{2}=[];
                end
            end
        end
    end
end
	%catch,
	%	disp(['warning: importing from ',CONN_x.Setup.spm{nsub}{1},': unexpected error (stopped importing for this subject)']); 
	%	err=err+1;
	%	disp(lasterr);
	%end
if isfield(CONN_x,'gui')&&isnumeric(CONN_x.gui)&&CONN_x.gui, 
    if ~err, conn_msgbox([num2str(CONN_x.Setup.nsubjects),' subjects imported with no errors'],'Done',true);
    else conn_msgbox(['Import finished with ',num2str(err),' errors'],'WARNING!',true); 
    end
end
if nargout,out=CONN_x;end
end

