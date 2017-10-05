function varargout = conn_jobmanager(option,varargin)
% CONN_JOBMANAGER 
%
% GUI calls:
%   conn_jobmanager;  
%     launches GUI displaying pending jobs (in currently open project, or alternatively in current directory)
%
%   conn_jobmanager all;
%     launches GUI displaying finished or pending jobs
%
%   conn_jobmanager settings;
%     launches GUI display configuration settings
%
% JOB MANAGEMENT
%   conn_jobmanager report;
%     if there is a pending job, displays status of individual nodes
%
%   conn_jobmanager restartstopped;
%     if there is a pending job, resubmits any stopped nodes
%
%   conn_jobmanager delete;
%     if there is a pending job, stop all nodes and cancel job
%
% CONFIGURATION OPTIONS
%   conn_jobmanager profiles
%     lists available configuration profile names (by default: Grid Engine, PBS, LSF, Slurm, Background process)
%
%   conn_jobmanager save all|current
%     saves current profile settings for all users or for current user only
%
%   conn_jobmanager test
%     tests configuration profile
%
%   conn_jobmanager setdefault PROFILENAME [save all|current]
%     sets default configuration profile to PROFILENAME
%
%   conn_jobmanager options FIELDNAME FIELDVALUE [save all|current];
%     modifies individual settings in current profile
%     e.g. conn_jobmanager options cmd_submitoptions -l h_rt=48:00:00;
%     valid FIELDNAMES are: name, comments, cmd_submit, cmd_submitoptions, cmd_submitoptions_infile
%       cmd_rundeployed, cmd_deletejob, cmd_checkstatus, cmd_checkstatus_automatic, cmd_submitoptions_example
%

% note: several options require a conn project currently loaded (e.g. use "conn load conn_myproject.mat")
% others work with project in current directory
%
% internal function: manages job submission for parallel/background processes
%

persistent CFG PROFILES DEFAULT;
global CONN_x;
LOADTESTPROFILES=false; % set to "true" for additional test profiles (additional profiles still in development) 
if isempty(CFG)
    filename=conn_fullfile('~/conn_jobmanager.mat');
    if conn_existfile(filename), 
    elseif isdeployed, 
        [nill,tfolder]=conn_jobmanager_checkdeployedname;
        filename=fullfile(tfolder,'conn_jobmanager.mat');
    else filename=fullfile(fileparts(which(mfilename)),'conn_jobmanager.mat');
    end
    if conn_existfile(filename), 
        data=load(filename,'profiles','default'); 
        PROFILES=data.profiles; 
        for n=1:numel(PROFILES), 
            if ~isfield(PROFILES{n},'cmd_checkstatus_automatic'), PROFILES{n}.cmd_checkstatus_automatic=false; end
            if ~isfield(PROFILES{n},'cmd_rundeployed'), PROFILES{n}.cmd_rundeployed=0; end
            if ~isfield(PROFILES{n},'cmd_submitoptions_infile'), PROFILES{n}.cmd_submitoptions_infile={}; end
            if ~isfield(PROFILES{n},'comments'), PROFILES{n}.comments=''; end
        end
        DEFAULT=data.default; fprintf('parallelization settings loaded from %s\n',filename);
    else
        PROFILES={...
            struct('name','Grid Engine computer cluster',... % tested on BU SCC
                   'comments','This profile may be used in cluster environments that implement a standard Open Grid Scheduler / Grid Engine / SGE scheduler',...
                   'cmd_submit','qsub -N JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','qdel JOBLABEL',...
                   'cmd_checkstatus','qstat -j JOBLABEL',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','-l h_rt=[hh:mm:ss] -q [queue] -A [account]'),...
            struct('name','PBS/Torque computer cluster',...  % tested on MIT mindhive
                   'comments','This profile may be used in cluster environments that implement a standard Portable Batch System / Torque scheduler',...
                   'cmd_submit','qsub -N JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','qdel JOBID',...
                   'cmd_checkstatus','qstat JOBID',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','-l walltime=[hh:mm:ss] -q [queue] -W [account]'),...
            struct('name','LSF computer cluster',...         % untested yet
                   'comments','This profile may be used in cluster environments that implement a standard Platform Load Sharing Facility scheduler',...
                   'cmd_submit','bsub -J JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','bkill -J JOBLABEL',...
                   'cmd_checkstatus','bjobs -J JOBLABEL',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','-W [hh:mm:ss] -q [queue] -P [account]'),...
            struct('name','Slurm computer cluster',...  % tested on MIT openmind
                   'comments','This profile may be used in cluster environments that implement a standard Slurm Workload Manager scheduler',...
                   'cmd_submit','sbatch --job-name=JOBLABEL --error=STDERR --output=STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','scancel JOBID',...
                   'cmd_checkstatus','squeue --jobs=JOBID',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','-t [hh:mm:ss] -p [queue] --acount=[account]'), ...
            struct('name','Background process (Unix,Mac)',...
                   'comments','This profile may be used in Mac/Unix systems with multiple processors that do not have access to a Cluster/HPC environment',...
                   'cmd_submit','/bin/bash SCRIPT 2> STDERR 1> STDOUT &',...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','pkill -f SCRIPT',...
                   'cmd_checkstatus','pgrep -f SCRIPT',...
                   'cmd_checkstatus_automatic',true,...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_submitoptions_example',''),...
            struct('name','Null profile',...
                   'comments','',...
                   'cmd_submit','',...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','',...
                   'cmd_checkstatus','',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_submitoptions_example','') ...
                   };
        DEFAULT=1;
    end
    if LOADTESTPROFILES
       TESTPROFILES={...
            struct('name','Background process (Windows)',...
                   'comments','<HTML>This profile may be used in Windows/PC systems with multiple processors that do not have access to a Cluster/HPC environment<br/>This profile is under development and it may require extensive changes to work in your system</HTML>',...
                   'cmd_submit','start "JOBLABEL" /min SCRIPT 2> STDERR 1> STDOUT',...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','taskkill /FI "WINDOWTITLE eq JOBLABEL"',...
                   'cmd_checkstatus','tasklist /FI "WINDOWTITLE eq JOBLABEL"',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_submitoptions_example',''),...
            struct('name','SITE: Boston University "SCC"',...
                   'comments','<HTML>notes: SCC uses a standard Grid Engine scheduler, with Matlab installed on all nodes (TAH license)<br/>Default hard-time limit is set to 24h ("additional submit options" are set to easily allow users to specify longer limits if needed)</HTML>',...
                   'cmd_submit','qsub -N JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','-l h_rt=24:00:00?',...
                   'cmd_submitoptions_infile',{{'# e.g. non-default Matlab','# module load matlab/2016b','# e.g. non-default standalone MCR','# module load conn_standalone/R2017a'}},...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','qdel JOBLABEL',...
                   'cmd_checkstatus','qstat -j JOBLABEL',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','-l h_rt=24:00:00? # gives user chance to change job''s hard-time limit'),...
            struct('name','SITE: Martinos Center MGH/HST "Launchpad"',...
                   'comments','<HTML>notes: Launchpad uses a standard PBS scheduler<br/>Use of standalone-CONN is encouraged due to limited Matlab licenses available<br/>Use alternative queues depending on whether using Matlab-based CONN (e.g. -q matlab), high I/O (e.g. -q highio), extended time (e.g. -q extended), etc.',...
                   'cmd_submit','qsub -N JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','-q highio?',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_rundeployed',1,...
                   'cmd_deletejob','qdel JOBID',...
                   'cmd_checkstatus','qstat JOBID',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','<HTML>-q highio # for high input/output file operations<br/>-q matlab # for matlab-based CONN</HTML>'),...
            struct('name','SITE: McGovern / MIT "Mindhive"',... 
                   'comments','',...
                   'cmd_submit','qsub -N JOBLABEL -e STDERR -o STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','qdel JOBID',...
                   'cmd_checkstatus','qstat JOBID',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','-l walltime=[hh:mm:ss] -q [queue] -W [account]'),...
            struct('name','SITE: McGovern / MIT "OpenMind"',...
                   'comments','',...
                   'cmd_submit','sbatch --job-name=JOBLABEL --error=STDERR --output=STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_rundeployed',0,...
                   'cmd_deletejob','scancel JOBID',...
                   'cmd_checkstatus','squeue --jobs=JOBID',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','-t [hh:mm:ss] -p [queue] --acount=[account]'),...
            struct('name','SITE: NIH HPC "Biowulf"',...
                   'comments','',...
                   'cmd_submit','sbatch --job-name=JOBLABEL --error=STDERR --output=STDOUT OPTS SCRIPT',...
                   'cmd_submitoptions','--partition=norm?',...
                   'cmd_submitoptions_infile',{{}},...
                   'cmd_rundeployed',1,...
                   'cmd_deletejob','scancel JOBID',...
                   'cmd_checkstatus','squeue --jobs=JOBID',...
                   'cmd_checkstatus_automatic',false,...
                   'cmd_submitoptions_example','-t [hh:mm:ss] -p [queue] --acount=[account]')};
       for n=1:numel(TESTPROFILES)
           names=cellfun(@(x)x.name,PROFILES,'uni',0);
           if ~any(strcmp(TESTPROFILES{n}.name,names))
               PROFILES{end+1}=TESTPROFILES{n};
           end
       end
    end
    CFG=struct(...
        'profile',DEFAULT,... 
        'matlabpath',fullfile(matlabroot,'bin'),...
        'osquotes',char('"'*ispc+''''*~ispc));
    for n=reshape(fieldnames(PROFILES{CFG.profile}),1,[])
        CFG.(n{1})=PROFILES{CFG.profile}.(n{1});
    end
end
            
varargout={};
qoptions={'all','report','restartstopped','finish','delete','ispending'};
if ~nargin||(nargin==1&&ischar(option)&&any(strcmp(option,qoptions)))||isstruct(option), % GUI
    if nargin==1&&ischar(option)&&any(strcmp(option,qoptions)), whichoption=find(strcmp(option,qoptions),1);
    else whichoption=[];
    end
    if ~nargin||~isempty(whichoption), 
        if isempty(CONN_x), 
            ftemp=dir('*.qlog'); 
            if numel(ftemp)==1, CONN_x_filename=conn_fullfile(ftemp.name); 
            else error('Unknown project. Load a conn project first (or cd to the folder containing your conn*.mat project file)'); 
            end
        else CONN_x_filename=CONN_x.filename;
        end
        if whichoption==1 %all
            files=conn_dir(conn_prepend('',conn_fullfile(CONN_x_filename),'.qlog/info.mat'));
            if ~isempty(files), files=cellstr(files); end
        else
            localfilename=conn_projectmanager('projectfile',CONN_x_filename,struct('id','*','isextended',true));
            allfiles=conn_dir(localfilename,'-R'); % check .dmat
            files={};
            if isempty(allfiles),
                if isempty(whichoption)||isequal(whichoption,6)
                    tfiles=conn_dir(conn_prepend('',conn_fullfile(CONN_x_filename),'.qlog/*.status.submitted'));
                    if ~isempty(tfiles),
                        files=cellstr(tfiles);
                        files={fullfile(fileparts(files{1}),'info.mat')};
                        if ~conn_existfile(files{1}), files={}; end
                    end
                end
            else
                tag=regexp(cellstr(allfiles),'\d{4}(\d+)\.dmat$','tokens','once');
                tag=unique([tag{:}]);
                for n=1:numel(tag)
                    pathname=fullfile(conn_prepend('',CONN_x_filename,'.qlog'),tag{n});
                    if exist(pathname,'dir')&&conn_existfile(fullfile(pathname,'info.mat'))
                        files{end+1}=fullfile(pathname,'info.mat');
                    end
                end
            end
        end
        if isequal(whichoption,6),
            varargout={~isempty(files)};
            return;
        end
        if isempty(files), 
            varargout={[]};
            if ~nargout,
                if whichoption==1, conn_msgbox({'There are no finished or pending jobs associated with this project',' ','To submit new jobs simply switch the option that reads','''local processing (run on this computer)'' to ''distributed processing''','when running Preprocessing/Setup/Denoising/Analyses steps'},'',true);
                elseif ~isempty(whichoption), disp('There are no pending jobs associated with this project');
                else conn_msgbox('There are no pending jobs associated with this project','',true);
                end
            end
            return;
        end
        [nill,filedates]=cellfun(@(x)fileparts(fileparts(x)),files,'uni',0);
        %filedates=cellfun(@(x)sprintf('%s-%s-%s %s:%s:%s',x(1:2),x(3:4),x(5:6),x(7:8),x(9:10),x(11:12)),filedates,'uni',0);
        filedates=cellfun(@(x)sprintf('%s-%s-%s',x(1:2),x(3:4),x(5:6)),filedates,'uni',0);
        for nfile=1:numel(files),
            try
                load(files{nfile},'info');
                [itag,nill,jtag]=unique(info.tagmsg);
                [nill,temp]=fileparts(info.pathname); 
                temp=sprintf('%s    (%s)',temp,filedates{nfile});
                for n=1:numel(itag), temp=[temp sprintf(' %d job(s) %s ',sum(jtag==n),itag{n})]; end
                filedates{nfile}=temp;
            end
        end
        load(files{end},'info');
        if isempty(whichoption) % pending / check if just finished
            info=conn_jobmanager('statusjob',info,[],true); 
            if numel(files)==1, files={}; end
            validlabels={'finished'}; %{'finished','stopped'};
            if all(ismember(info.tagmsg,validlabels)),
                answ=conn_questdlg({'Your pending job has finished','Finished jobs need to be merged with your current CONN project','Would you like to do this now?'},'Finished job','Now','Later','Now');
                if isequal(answ,'Now'), 
                    filename=regexprep(info.private{1}(1).project,'\?.*$','');
                    conn('load',filename);
                    conn save;
                    varargout={info};
                    return;
                end
            end
            validlabels={'queued'}; 
            if all(ismember(info.tagmsg,validlabels)),
                answ=conn_questdlg({sprintf('Your queued job %s is ready to start',info.pathname),'Would you like to do this now?'},'Queued job','Now','Later','Now');
                if isequal(answ,'Now'), 
                    info=conn_jobmanager('submitjob',info);
                end
            end
            %th=timerfindall('name','jobmanager'); if ~isempty(th), stop(th); delete(th); end
        elseif whichoption==2 %report
            info=conn_jobmanager('statusjob',info,[],true,true);
            varargout={info};
            return;
        elseif whichoption==3 %restartstopped
            info=conn_jobmanager('statusjob',info,[],true,true);
            info=conn_jobmanager('submitjob',info,'stopped');
            varargout={info};
            return;
        elseif whichoption==4, %finish
            %info=conn_jobmanager('deletejob',info);
            %info=conn_jobmanager('clearqlog',info);
            filename=regexprep(info.private{1}(1).project,'\?.*$','');
            conn('load',filename);
            conn save;
            varargout={info};
            return;
        elseif whichoption==5, %delete
            info=conn_jobmanager('deletejob',info);
            info=conn_jobmanager('clearqlog',info);
            filename=regexprep(info.private{1}(1).project,'\?.*$','');
            conn('load',filename);
            conn save;
            varargout={info};
            return;
        end
    else
        info=option;
        files={};
        filedates={};
    end
    info=conn_jobmanager_gui(info,files,filedates,varargin{:});
    if nargout, varargout={info}; end
else
    switch(lower(option))
        case 'settings'
            [PROFILES,DEFAULT]=conn_jobmanager_settings(PROFILES,DEFAULT);
            CFG.profile=DEFAULT;
            for n=reshape(fieldnames(PROFILES{CFG.profile}),1,[])
                CFG.(n{1})=PROFILES{CFG.profile}.(n{1});
            end
            
        case 'profiles',
            names=cellfun(@(x)x.name,PROFILES,'uni',0);
            if nargin>1, idx=varargin{1};
            else idx=1:numel(names);
            end
            if ~nargout, disp(char(names(idx)));
            else varargout={names(idx),DEFAULT};
            end
            
        case 'setprofile'
            name=varargin{1};
            if iscell(name), name=[name{:}]; end
            if ischar(name)
                names=cellfun(@(x)lower(x.name),PROFILES,'uni',0);
                idx=strmatch(lower(name),names);
                if numel(idx)~=1, idx=strmatch(lower(name),names,'exact'); end
                if isempty(idx), error('unknown profile name %s',name);
                elseif numel(idx)>1, error('multiple potential matches for profile name %s',name);
                end
            else idx=name;
            end
            if ~isempty(idx)&&~isnan(idx), conn_jobmanager('options','profile',idx); end
            if nargout, varargout={idx}; end
            if numel(varargin)>1, conn_jobmanager(varargin{2:end}); end
            
        case 'setdefault'
            name=varargin{1};
            conn_jobmanager('options','default',name);
            if numel(varargin)>1, [varargout{1:nargout}]=conn_jobmanager(varargin{2:end}); end
            
        case 'getdefault',
            name=PROFILES{DEFAULT}.name;
            varargout={name};
            
        case 'getprofile',
            varargout={CFG.name};
            
        case {'test','testprofile'}
            conn_jobmanager_settings(PROFILES,DEFAULT,'test',true,varargin{:});
        case {'save','saveprofile'}
            conn_jobmanager_settings(PROFILES,DEFAULT,'save',varargin{:});
            
        case 'options',
            if numel(varargin)>1
                for n=1:2:numel(varargin)
                    if strcmp(varargin{n},'save')||strcmp(varargin{n},'saveprofile'), conn_jobmanager(varargin{n:min(numel(varargin),n+1)}); 
                    elseif strcmp(varargin{n},'default'),
                        DEFAULT=conn_jobmanager('setprofile',varargin{n+1});
                    elseif strcmp(varargin{n},'profile'), 
                        CFG.(varargin{n})=varargin{n+1}; 
                        for n=reshape(fieldnames(PROFILES{min(numel(PROFILES),CFG.profile)}),1,[])
                            CFG.(n{1})=PROFILES{min(numel(PROFILES),CFG.profile)}.(n{1});
                        end
                    elseif isfield(CFG,varargin{n}), 
                        CFG.(varargin{n})=varargin{n+1}; 
                        PROFILES{CFG.profile}.(varargin{n})=CFG.(varargin{n});
                    else error('unknown parallelization profile option %s',varargin{n})
                    end
                end
                if nargout, varargout={CFG}; end
            else
                varargout={CFG.(varargin{1})};
            end
            
        case 'submit' %('submit',strprocess,subjects,N,options)     ('submit',batch,[],N,options) 
            strcom=varargin{1};
            if nargin>2&&~isempty(varargin{2}), subjects=varargin{2};
            else subjects=1:CONN_x.Setup.nsubjects;
            end
            if iscell(subjects), N=numel(subjects);
            elseif nargin>3&&~isempty(varargin{3}), N=varargin{3};
            else
                answer=inputdlg('Number of parallel jobs?','',1,{num2str(numel(subjects))});
                if isempty(answer), return; end
                N=str2num(answer{1});
            end
            if iscell(subjects), Isubjects=subjects;
            else
                Ns=numel(subjects);
                N=min(Ns,N);
                ns=Ns/N;
                Isubjects=arrayfun(@(n)subjects(floor(ns*(n-1))+1:min(Ns,floor(ns*n))),1:N,'uni',0);
            end
            options=varargin(4:end);
            if isempty(strcom), job=conn_jobmanager('job','test',[]);
            elseif ischar(strcom), job=conn_jobmanager('job','process',strcom,options{:}); 
            elseif iscell(strcom), 
                for n=1:numel(strcom), 
                    job(n)=conn_jobmanager('job','process',strcom{n},options{1}{n}{:}); 
                end
            else error('unknown-process option'); %job=conn_jobmanager('job','batch',strcom,options{:}); 
            end
            info=conn_jobmanager('createjob',job,Isubjects);
            info=conn_jobmanager('submitjob',info);
            if isempty(info), return; end
            save(fullfile(info.pathname,'info.mat'),'info');
            if nargout, varargout={info}; 
            elseif ~isempty(CFG.cmd_submit), conn_jobmanager(info);
            else
                fprintf('Job %s scripted & queued \n  To submit from CONN gui visit Tools.Cluster/HPC.PendingJobs menu\n  To run from Matlab use run_all.m or node_*.m files\n  To run from OS command-line use node.*.sh|.bat files\n',info.pathname);
                try, conn_msgbox({sprintf('Job %s scripted & queued',info.pathname),'To submit from CONN gui use Tools.Cluster/HPC.PendingJobs menu',' ','To run from Matlab use run_all.m or node_*.m files','To run from OS command-line use node.*.sh|.bat files'},'',1);
                end
            end
            
        case 'killjob' %('deletejob',info,inodes)
            info=varargin{1};
            if nargin>2&&~isempty(varargin{2}), ijobs=varargin{2}; else ijobs=1:numel(info.scripts); end
            for i=ijobs(:)',
                str=regexprep(CFG.cmd_deletejob,{'JOBLABEL','JOBID','OPTS','SCRIPT','STDOUT','STDERR','STDLOG'},[{info.joblabel{i} info.jobid{i} CFG.cmd_submitoptions} cellfun(@(x)[CFG.osquotes x CFG.osquotes],{info.scripts{i},info.stdout{i},info.stderr{i},info.stdlog{i}},'uni',0)]);
                [ok,msg]=system(str);
                msg(msg<32|msg>=127)=' ';
                info.deletemsg{i}=msg;
            end
            varargout={info};
            
        case 'deletejob' %('deletejob',info,inodes)
            info=varargin{1};
            if nargin>2&&~isempty(varargin{2}), ijobs=varargin{2}; else ijobs=1:numel(info.scripts); end
            for i=ijobs(:)',
                conn_jobmanager('tag',info.scripts{i},'stopped');
                str=regexprep(CFG.cmd_deletejob,{'JOBLABEL','JOBID','OPTS','SCRIPT','STDOUT','STDERR','STDLOG'},[{info.joblabel{i} info.jobid{i} CFG.cmd_submitoptions} cellfun(@(x)[CFG.osquotes x CFG.osquotes],{info.scripts{i},info.stdout{i},info.stderr{i},info.stdlog{i}},'uni',0)]);
                [ok,msg]=system(str);
                %if ok~=0, fprintf(2,'%s\n',msg); end
                msg(msg<32|msg>=127)=' ';
                info.deletemsg{i}=msg;
            end
            varargout={info};
            
        case 'statusjob' %('statusjob',info,inodes)
            MAXFINISHINGCOUNTER=5;
            info=varargin{1};
            if nargin>2&&~isempty(varargin{2}), ijobs=varargin{2}; else ijobs=1:numel(info.scripts); end
            if nargin>3&&~isempty(varargin{3}), force=varargin{3}; else force=false; end
            if nargin>4&&~isempty(varargin{4}), dodisp=varargin{4}; else dodisp=false; end
            changed=false(1,numel(info.scripts));
            for i=ijobs(:)',
                newtag=conn_jobmanager('tag',info.scripts{i});
                if isempty(newtag), newtag=''; end
                if force||~isfield(info,'tagmsg')||numel(info.tagmsg)<i||~isequal(newtag,info.tagmsg{i}), changed(i)=true; end
                info.tagmsg{i}=newtag; 
            end
            for i=find(changed),
                %disp(['check ',info.joblabel{i}]);
                str=regexprep(CFG.cmd_checkstatus,{'JOBLABEL','JOBID','OPTS','SCRIPT','STDOUT','STDERR','STDLOG'},[{info.joblabel{i} info.jobid{i} CFG.cmd_submitoptions} cellfun(@(x)[CFG.osquotes x CFG.osquotes],{info.scripts{i},info.stdout{i},info.stderr{i},info.stdlog{i}},'uni',0)]);
                if CFG.cmd_checkstatus_automatic||force, [ok,msg]=system(str);
                else ok=0; msg='';
                end
                info.statemsg{i}=msg;
                if strcmp(info.jobid{i},'?')&&~isempty(msg), 
                    ID=regexp(msg,'\d+','match');
                    [nill,idx]=max(cellfun('length',ID));
                    if ~isempty(idx), info.jobid{i}=ID{idx}; else info.jobid{i}='?'; end
                end
                if ~ok, msg=info.jobid{i}; else msg=''; end
                %if ok~=0&&~isempty(msg), fprintf(2,'%s\n',msg); end
                msg(msg<32|msg>=127|msg=='?')='';
                info.statusmsg{i}=msg;
                if strcmp(info.tagmsg{i},'finished')&&~isempty(info.statusmsg{i}), 
                    if ~isfield(info,'finishingcounter')||numel(info.finishingcounter)<i, info.finishingcounter(i)=0; end; 
                    info.finishingcounter(i)=info.finishingcounter(i)+1; 
                    if info.finishingcounter(i)>MAXFINISHINGCOUNTER, % note: how long to wait for queue manager to automatically delete job from queue
                        info=conn_jobmanager('killjob',info,i);
                    else info.tagmsg{i}='finishing'; 
                    end
                end
                if strcmp(info.tagmsg{i},'stopped')&&~isempty(info.statusmsg{i}), info.tagmsg{i}='stopping'; end
                if strcmp(info.tagmsg{i},'running')&&isempty(info.statusmsg{i}), info.tagmsg{i}='stopped'; end
                if strcmp(info.tagmsg{i},'submitted')&&isempty(info.statusmsg{i}), info.tagmsg{i}='queued'; end
                if numel(ijobs)==1, fprintf('%s %s\n',info.joblabel{i},info.tagmsg{i}); end
            end
            try, if any(changed), save(fullfile(info.pathname,'info.mat'),'info'); end; end
            varargout={info};
            if dodisp||(any(changed)&&numel(ijobs)>1), 
                [itag,nill,jtag]=unique(info.tagmsg);
                for n=1:numel(itag), fprintf('%d job(s) %s  ',sum(jtag==n),itag{n}); end
                fprintf('\n');
            end
            
        case 'submitjob', %('submitjob',info,inodes)
            info=varargin{1};
            if nargin>2&&~isempty(varargin{2}), ijobs=varargin{2}; else ijobs=1:numel(info.scripts); end
            if ischar(ijobs), ijobs=find(strcmp(info.tagmsg,ijobs)); end
            cmd_submitoptions=CFG.cmd_submitoptions;
            if ~isempty(regexp(cmd_submitoptions,'\?$'))&&~isempty(regexp(CFG.cmd_submit,'OPTS'))
                cmd_submitoptions=regexprep(cmd_submitoptions,'\?$','');
                try
                    disp('Enter user-defined additional submit options');
                    [opt_str,opt_i,opt_j]=regexp(cmd_submitoptions,'\[.*?\]','match','start','end');
                    checkdesktop=true;
                    try, checkdesktop=checkdesktop&usejava('awt'); end
                    if isempty(opt_str)
                        if ~checkdesktop,
                        else answer=inputdlg('Additional submit options:','',1,{cmd_submitoptions}); end
                        if isempty(answer), cmd_submitoptions='';
                        else cmd_submitoptions=answer{1}; 
                        end
                    else
                        opt_str=regexprep(opt_str,'[\[\]]','');
                        opt_str1=regexprep(opt_str,':.*','');
                        opt_str2=regexprep(opt_str,'.*:','');
                        answer=inputdlg(opt_str1,'Options',1,opt_str2);
                        if isempty(answer),cmd_submitoptions='';
                        else for opt_n=numel(answer):-1:1, cmd_submitoptions=[cmd_submitoptions(1:opt_i(opt_n)-1),strtrim(answer{opt_n}),cmd_submitoptions(opt_j(opt_n)+1:end)]; end; 
                        end
                    end
                end
            end
            for i=ijobs(:)',
                conn_jobmanager('tag',info.scripts{i},'submitted');
                str=regexprep(CFG.cmd_submit,{'JOBLABEL','JOBID','OPTS','SCRIPT','STDOUT','STDERR','STDLOG'},[{info.joblabel{i} info.jobid{i} cmd_submitoptions} cellfun(@(x)[CFG.osquotes x CFG.osquotes],{info.scripts{i},info.stdout{i},info.stderr{i},info.stdlog{i}},'uni',0)]);
                [ok,msg]=system(str);
                if ok~=0, 
                    %fprintf(2,'%s\n',msg); 
                    conn_jobmanager('tag',info.scripts{i},'failed');
                end
                %msg(msg<32|msg>=127)=' ';
                info.submitcmd{i}=str;
                info.submitmsg{i}=msg;
                ID=regexp(msg,'\d+','match'); 
                [nill,idx]=max(cellfun('length',ID)); 
                if ~isempty(idx), info.jobid{i}=ID{idx}; else info.jobid{i}='?'; end
            end
            varargout={info};
            
        case 'waitfor',
            info=varargin{1};
            [info,ok]=conn_jobmanager_gui(info,{},{},'nogui');
            if nargout, varargout={info,ok}; end

        case 'cleardmat'
            tpath=strvcat(conn_dir(conn_prepend('',conn_fullfile(CONN_x.filename),'.*.dmat'),'-R'),conn_dir(conn_prepend('',conn_fullfile(CONN_x.filename),'.*.emat'),'-R'));
            if ~isempty(tpath),
                tpath=cellstr(tpath);
                for n=1:numel(tpath)
                    if ispc,
                        [ok,nill]=system(sprintf('del "%s"',tpath{n}));
                    else
                        [ok,nill]=system(sprintf('rm -f ''%s''',tpath{n}));
                    end
                end
            end
            
        case 'clearqlog',
            if nargin>1&&~isempty(varargin{1}), 
                info=varargin{1};
                tpath={info.pathname}; % removes .qlog folder
            else
                tpath=conn_prepend('',conn_fullfile(CONN_x.filename),'.qlog');
                dirs=dir(fullfile(tpath,'*'));
                dirs=dirs([dirs.isdir]);
                dirs=dirs(cellfun('length',regexp({dirs.name},'^\d+$'))>0);
                tpath=cellfun(@(x)fullfile(tpath,x),{dirs.name},'uni',0);
            end
            for n=1:numel(tpath)
                if ispc,
                    [ok,nill]=system(sprintf('del "%s"\*',tpath{n}));
                    [ok,nill]=system(sprintf('rmdir "%s"',tpath{n}));
                else
                    [ok,nill]=system(sprintf('rm -f ''%s''/*',tpath{n}));
                    [ok,nill]=system(sprintf('rmdir ''%s''',tpath{n}));
                end
%             % removes .dmat .emat
%             for n=1:numel(info.nodes)
%                 tfile=conn_projectmanager('projectfile',regexprep(info.private{n}(1).project,'\?.*$',''),struct('isextended',true,'id',info.nodes{n}));
%                 if ispc, [ok,nill]=system(sprintf('del "%s"',tfile));
%                 else [ok,nill]=system(sprintf('rm ''%s''',tfile));
%                 end
%             end
            end
            varargout={info};
            
        % internal use
        case 'job', %('job','batch',batch) ('job','process',cmdstr,...)
            if nargin>1&&~isempty(varargin{1}), jtype=varargin{1};
            else jtype='process';
            end
            if nargin>2&&~isempty(varargin{2}), fcn=varargin{2};
            else fcn=[];
            end
            if nargin>3, args=varargin(3:end);
            else args={};
            end
            job=struct('type',jtype,'fcn',fcn,'args',{args});
            varargout={job};
            
        case 'tag', % submitted/started/finished
            filename=varargin{1};
            if nargin>2&&~isempty(varargin{2})
                tag=varargin{2};
                disp(sprintf('%s %s',filename,tag));
                if ispc, [ok,nill]=system(sprintf('del "%s"',conn_prepend('',filename,'.status.*')));
                else [ok,nill]=system(sprintf('rm ''%s''*',conn_prepend('',filename,'.status.')));
                end
                fclose(fopen(conn_prepend('',filename,['.status.' tag]),'wt'));
                varargout={tag};
            else
                tfiles=dir(conn_prepend('',filename,'.status.*'));
                info=regexp({tfiles.name},'^node\.(\d+).status\.(\w+)$','tokens','once');
                info=info(cellfun('length',info)==2);
                if isempty(info), varargout={{},{}};
                else varargout=fliplr(info{1});
                end
            end
            
        case {'exec','rexec'}
            me=[];
            filename=varargin{1};
            try
                load(filename,'job','-mat');
                conn_jobmanager('tag',job(1).tag,'running'); 
                %if strcmp(lower(option),'rexec'), conn_jobmanager('tag',job(1).tag,'running'); end
                for n=1:numel(job)
                    switch(job(n).type)
                        case 'process'
                            fprintf('Processing %s job %d/%d\n',job(n).project,n,numel(job));
                            conn('load',job(n).project);
                            conn save;
                            CONN_x.gui=struct('overwrite','Yes','display',0);
                            if numel(job(n).args)>=1&&~isempty(job(n).args)&&~isempty(job(n).args{1}), CONN_x.gui=job(n).args{1}; end
                            conn_process(job(n).fcn,job(n).args{2:end});
                            conn save;
                        case 'batch'
                            job(n).fcn.filename=job(n).project;
                            conn_batch(job(n).fcn);
                            conn save;
                        case 'test'
                            pause(5);
                            disp('TEST RUN SUCCESSFULLY');
                    end
                end
                conn_jobmanager('tag',job(1).tag,'finished'); 
                %if strcmp(lower(option),'rexec'), conn_jobmanager('tag',job(1).tag,'finished'); end
                %if strcmp(lower(option),'rexec'), exit(0); end
                
            catch me
                conn_jobmanager('tag',job(1).tag,'error');
                str=conn_errormessage(me,job(1).tag);
                fprintf(2,'%s\n',str{:}); 
                %if strcmp(lower(option),'rexec'), exit(1); end
            end
                        
        case 'conn_x_filename',
            if isempty(CONN_x), CONN_x_filename='';
            else CONN_x_filename=CONN_x.filename;
            end
            varargout={CONN_x_filename};
            
        case 'createjob', % ('createjob',job,N) ('createjob',job,Isubjects)
            job=varargin{1};
            if nargin>2&&~isempty(varargin{2}), N=varargin{2};
            else N=min(50,CONN_x.Setup.nsubjects);
            end
            
            if iscell(N), Isubjects=N; N=numel(Isubjects); 
            else
                Isubjects={};
                Ns=CONN_x.Setup.nsubjects;
                %N=min(Ns,N);
                ns=Ns/N;
            end
            tag=datestr(now,'yymmddHHMMSSFFF');
            pathname=fullfile(conn_prepend('',CONN_x.filename,'.qlog'),tag);
            [ok,nill]=mkdir(pathname);
            pathname=conn_fullfile(pathname);
            [job.pathname]=deal(pathname);
            isdep=false;
            try, isdep=isdeployed; end
            if CFG.cmd_rundeployed, isdep=true; end
            if isdep, isdep_callback=conn_jobmanager_checkdeployedname; end
            
            info=struct('pathname',pathname,'scripts',{{}},'nodes',{{}},'private',{{}});
            for n=1:N
                if isempty(Isubjects), subjects=floor(ns*(n-1))+1:min(Ns,floor(ns*n));
                else subjects=Isubjects{n};
                end
                ID=sprintf('%04d%s',n,tag);
                SUBJECTS=mat2str(subjects);
                REF=conn_fullfile(sprintf('%s?id=%s,subjects=%s,partition=%d-%d',CONN_x.filename,ID,SUBJECTS,n,N));
                [job.id]=deal(ID);
                [job.project]=deal(REF);
                filename_mat=fullfile(pathname,sprintf('node.%s.mat',ID));
                filename_m=fullfile(pathname,sprintf('node_%s.m',ID));
                if ispc, filename_sh=fullfile(pathname,sprintf('node.%s.bat',ID)); 
                else filename_sh=fullfile(pathname,sprintf('node.%s.sh',ID)); 
                end
                info.scripts{n}=filename_sh;
                info.nodes{n}=ID;
                info.private{n}=job;
                info.joblabel{n}=['conn_',ID];
                info.jobid{n}='';
                info.stdout{n}=conn_prepend('',info.scripts{n},'.stdout');
                info.stderr{n}=conn_prepend('',info.scripts{n},'.stderr');
                info.stdlog{n}=conn_prepend('',info.scripts{n},'.stdlog');
                if ispc
                    fh=fopen(filename_sh,'wt');
                    if ~isempty(CFG.cmd_submitoptions_infile)
                        cmd_submitoptions=CFG.cmd_submitoptions_infile;
                        for ncmd_submitoptions=1:numel(cmd_submitoptions), fprintf(fh,'%s\n',cmd_submitoptions{ncmd_submitoptions}); end
                    end
                    if isdep,   fprintf(fh,'%s jobmanager rexec "%s"\n',isdep_callback,filename_mat);
                    else        fprintf(fh,'%s -nodesktop -noFigureWindows -nosplash -automation -singleCompThread -logfile "%s" -r "addpath %s; addpath %s; cd %s; conn_jobmanager(''rexec'',''%s''); exit"\n',...
                            fullfile(CFG.matlabpath,'matlab'), info.stdlog{n}, fileparts(which('spm')), fileparts(which('conn')), pathname, filename_mat);
                    end
                    fprintf(fh,'exit\n');
                    fclose(fh);
                    fh=fopen(filename_m,'wt');
                    fprintf(fh,' addpath %s;\n addpath %s;\n cd %s;\n conn_jobmanager(''rexec'',''%s'');\n',...
                            fileparts(which('spm')), fileparts(which('conn')), pathname, filename_mat);
                    fclose(fh);
                else
                    fh=fopen(filename_sh,'wt');
                    fprintf(fh,'#!/bin/bash\n');
                    if ~isempty(CFG.cmd_submitoptions_infile)
                        cmd_submitoptions=cellstr(CFG.cmd_submitoptions_infile);
                        for ncmd_submitoptions=1:numel(cmd_submitoptions), fprintf(fh,'%s\n',cmd_submitoptions{ncmd_submitoptions}); end
                    end
                    if isdep,   fprintf(fh,'%s jobmanager rexec ''%s''\n',isdep_callback,filename_mat);
                    else        fprintf(fh,'%s -nodesktop -nodisplay -nosplash -singleCompThread -logfile ''%s'' -r "addpath %s; addpath %s; cd %s; conn_jobmanager(''rexec'',''%s''); exit"\n',...
                            fullfile(CFG.matlabpath,'matlab'), info.stdlog{n}, fileparts(which('spm')), fileparts(which('conn')), pathname, filename_mat);
                    end
                    fprintf(fh,'echo _NODE END_\n');
                    fclose(fh);
                    fh=fopen(filename_m,'wt');
                    fprintf(fh,' addpath %s;\n addpath %s;\n cd %s;\n conn_jobmanager(''rexec'',''%s'');\n',...
                            fileparts(which('spm')), fileparts(which('conn')), pathname, filename_mat);
                    fclose(fh);
                end
                [job.tag]=deal(filename_sh);
                save(filename_mat,'job');
            end
            filename_m=fullfile(pathname,'node_merge.m');
            fh=fopen(filename_m,'wt');
            fprintf(fh,'%% auto-generated by conn_jobmanager\n%% this script can be used in combination with node_###.m (from Matlab), .sh (from Mac or Unix OS), or .bat (from DOS/Windows OS) scripts to run this process across several computers in a shared-storage local network or HPC environment\n%% this script should only be run after all individual node_### scripts have finished\n\n');
            fprintf(fh,'%% merges job outputs with conn project\nconn load ''%s'';\nconn save;', CONN_x.filename);
            fclose(fh);
            filename_m=fullfile(pathname,'run_all.m');
            fh=fopen(filename_m,'wt');
            fprintf(fh,'%% auto-generated by conn_jobmanager\n%% this script can be used to run this process from Matlab locally on this machine (or in a Matlab parallel toolbox environment)\n\n');
            fprintf(fh,'addpath %s;\naddpath %s;\ncd %s;\n\n',...
                fileparts(which('spm')), fileparts(which('conn')), pathname);
            fprintf(fh,'jobs={');
            for n=1:N
                ID=sprintf('%04d%s',n,tag);
                filename_mat=fullfile(pathname,sprintf('node.%s.mat',ID));
                fprintf(fh,'''%s''',filename_mat);
                if n<N, fprintf(fh,','); end
            end
            fprintf(fh,'};\n');
            fprintf(fh,'%% runs individual jobs\nparfor n=1:numel(jobs)\n  conn_jobmanager(''exec'',jobs{n});\nend\n\n');
            fprintf(fh,'%% merges job outputs with conn project\nconn load ''%s'';\nconn save;', CONN_x.filename);
            fclose(fh);
            varargout={info};
            
        otherwise,
            fprintf('Warning: unknwon conn_jobmanager option %s\n',lower(option));
    end
end
end

function [profiles,default]=conn_jobmanager_settings(profiles,default,varargin)
iprofile=max(1,min(numel(profiles), default));
if nargin>2, 
    conn_jobmanager_settings_update(varargin{:});
    return;
end
handles.hfig=figure('units','norm','position',[.3 .15 .35 .75],'name','Distributed computing settings','numbertitle','off','menubar','none','color','w');
uicontrol(handles.hfig,'style','frame','units','norm','position',[0 .825 1 .175],'foregroundcolor',.9*[1 1 1],'backgroundcolor',.9*[1 1 1]);
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .95 .8 .04],'string','Profiles:','fontweight','bold','backgroundcolor',.9*[1 1 1],'horizontalalignment','left');
handles.profiles=uicontrol(handles.hfig,'style','popupmenu','units','norm','position',[.1 .9 .8 .05],'string','','value',default,'backgroundcolor',.9*[1 1 1],'callback',@(varargin)conn_jobmanager_settings_update('profile'),'tooltipstring','Select among predefined parallelization profiles');
handles.test=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.1,.85,.4,.05],'string','Test profile','callback',@(varargin)conn_jobmanager_settings_update('test'),'tooltipstring','<HTML>Runs diagnostic test to evaluate whether selected profile works correctly on this machine<br/>The test will submit two null jobs and track their status to completion (the test may take up to a few minutes, depending on your job scheduler load status)</HTML>');
handles.isdefault=uicontrol(handles.hfig,'style','checkbox','units','norm','position',[.6,.85,.3,.05],'string','Select as default profile','backgroundcolor',.9*[1 1 1],'callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>Select the parallelization profile that you wish to use by default when using CONN''s parallelization options</HTML>');
handles.new=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.10,.025,.2,.05],'string','New','callback',@(varargin)conn_jobmanager_settings_update('new'),'tooltipstring','Define new parallelization profile (copy current profile)');
handles.delete=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.30,.025,.2,.05],'string','Delete','callback',@(varargin)conn_jobmanager_settings_update('delete'),'tooltipstring','Delete current parallelization profile');
handles.save=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.55,.025,.2,.05],'string','Save','callback',@(varargin)conn_jobmanager_settings_update('save'),'tooltipstring','Save all profile changes for future Matlab sessions');
handles.exit=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.75,.025,.2,.05],'string','Exit','callback','close(gcbf)');

uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .76 .8 .04],'string','Profile name','fontweight','bold','backgroundcolor','w','horizontalalignment','left');
handles.name=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.72,.8,.04],'string','','backgroundcolor','w','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'));
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .66 .8 .04],'string','Command used to submit a job','fontweight','bold','backgroundcolor','w','horizontalalignment','left');
handles.cmd_submit=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.62,.8,.04],'string','','backgroundcolor','w','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>System command for submitting/executing a job<br/>This command (or alternatively the check-status command below) is expected to return a numeric job identifier string output (JOBID)<br/> - Enter <i>SCRIPT</i> to indicate the name of the script to be submitted/executed<br/> - Enter <i>JOBLABEL</i> to indicate a job name (autogenerated for each node)/label<br/> - Enter <i>STDOUT</i> to indicate the file where the stdout stream should be stored<br/> - Enter <i>STDERR</i> to indicate the file where the stderr stream should be stored<br/> - Enter <i>OPTS</i> to indicate additional optional arguments (see <i>additional submit options</i> below)<br/></HTML>');
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .54 .8 .04],'string','Command used to delete a submitted job (optional)','fontweight','bold','backgroundcolor','w','horizontalalignment','left');
handles.cmd_deletejob=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.50,.8,.04],'string','','backgroundcolor','w','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>System command for deleting a submitted job<br/>Leaving this field blank will not allow users to delete or restart submitted jobs<br/> - Enter <i>SCRIPT</i> to indicate the name of the script to be submitted/executed<br/> - Enter <i>JOBLABEL</i> to indicate a job name (autogenerated for each node)/label<br/> - Enter <i>JOBID</i> to indicate a job identifier (output of submit or check-status commands)<br/> - Enter <i>STDOUT</i> to indicate the file where the stdout stream should be stored<br/> - Enter <i>STDERR</i> to indicate the file where the stderr stream should be stored<br/></HTML>');
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .44 .8 .04],'string','Command used to check the status of a submitted job (optional)','fontweight','bold','backgroundcolor','w','horizontalalignment','left');
handles.cmd_checkstatus=uicontrol(handles.hfig,'style','edit','units','norm','position',[.1,.40,.8,.04],'string','','backgroundcolor','w','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>System command to check the status of a submitted job<br/>Leaving this field blank will not allow users to check the scheduler queue to evaluate the status of submitted jobs<br/>This command is expected to produce a exit(0) status if the job exists<br/>This command (or alternatively the submit command above) is also expected to return a numeric job identifier string output (JOBID)<br/> - Enter <i>SCRIPT</i> to indicate the name of the script to be submitted/executed<br/> - Enter <i>JOBLABEL</i> to indicate a job name (autogenerated for each node)/label<br/> - Enter <i>JOBID</i> to indicate a job identifier (output of submit or check-status commands)<br/> - Enter <i>STDOUT</i> to indicate the file where the stdout stream should be stored<br/> - Enter <i>STDERR</i> to indicate the file where the stderr stream should be stored<br/></HTML>');
uicontrol(handles.hfig,'style','text','units','norm','position',[.1 .34 .8 .04],'string','Additional submit settings (optional)','fontweight','bold','backgroundcolor','w','horizontalalignment','left');
uicontrol(handles.hfig,'style','text','units','norm','position',[.15 .30 .15 .04],'string','in-line:','backgroundcolor','w','horizontalalignment','left');
uicontrol(handles.hfig,'style','text','units','norm','position',[.15 .24 .15 .04],'string','in-file:','backgroundcolor','w','horizontalalignment','left');
handles.cmd_submitoptions=uicontrol(handles.hfig,'style','edit','units','norm','position',[.3,.30,.6,.04],'string','','max',1,'backgroundcolor','w','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'));
handles.cmd_submitoptions_infile=uicontrol(handles.hfig,'style','edit','units','norm','position',[.3,.20,.6,.08],'string','','max',2,'backgroundcolor','w','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring',['<HTML>Additional submit options (in-script configuration or executable lines)<br/>Entries in this field will be included as additional lines in the submitted script before the call to Matlab/CONN<br/>Use this to override your system default settings, pre-load modules or containers, etc<br/> <br/>Example:<br/>#$ -m ae<br/>#$ -M mymail@gmail.com<br/>module load mcr/9.0.1_2016a</HTML>']);
handles.cmd_checkstatus_automatic=uicontrol(handles.hfig,'style','checkbox','units','norm','position',[.1,.16,.8,.04],'string','check job status automatically','backgroundcolor','w','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>When checked CONN will regularly execute the above check-status command to check for unexpected changes in job status (e.g. node crashes)<br/> (warning: this may result in increased network traffic and increased load to the scheduler software particularly at the beginning and end of each job)<br/>When unchecked CONN will only execute the above check-status command when users manually request to refresh the job status list</HTML>');
handles.cmd_rundeployed=uicontrol(handles.hfig,'style','checkbox','units','norm','position',[.1,.12,.8,.04],'string','nodes use pre-compiled CONN only','backgroundcolor','w','horizontalalignment','left','callback',@(varargin)conn_jobmanager_settings_update('edit'),'tooltipstring','<HTML>When checked individual nodes will always use the pre-compiled standalone version of CONN (this requires MCR and standalone-CONN installed in your cluster)<br/>When unchecked CONN will automatically detect which CONN implementation (either Matlab or standalone) is used to initiate the parallelization procedure, and all nodes will use this same implementation</HTML>');
conn_jobmanager_settings_update('refresh');
waitfor(handles.hfig);

    function conn_jobmanager_settings_update(option,varargin)
        switch(option)
            case 'refresh',
                set(handles.profiles,'string',cellfun(@(x)x.name,profiles,'uni',0),'value',max(1,min(numel(profiles), iprofile)));
                set(handles.name,'string',profiles{iprofile}.name);
                set(handles.cmd_submit,'string',profiles{iprofile}.cmd_submit);
                set(handles.cmd_submitoptions,'string',profiles{iprofile}.cmd_submitoptions);
                set(handles.cmd_submitoptions_infile,'string',profiles{iprofile}.cmd_submitoptions_infile);
                set(handles.cmd_deletejob,'string',profiles{iprofile}.cmd_deletejob);
                set(handles.cmd_checkstatus,'string',profiles{iprofile}.cmd_checkstatus);
                set(handles.cmd_rundeployed,'value',profiles{iprofile}.cmd_rundeployed);
                set(handles.cmd_checkstatus_automatic,'value',profiles{iprofile}.cmd_checkstatus_automatic);
                set(handles.cmd_submitoptions,'tooltipstring',['<HTML>Additional submit options (in-line arguments to submit command)<br/>The keyword OPTS included as part of the submit command string above will be replaced by the values in this field<br/>Use this to override your system default walltime settings, request specific resources, specify the submission queue, etc.<br/> - Enter <i>SCRIPT</i> to indicate the name of the script to be submitted/executed<br/> - Enter <i>JOBLABEL</i> to indicate a job name (autogenerated for each node)/label<br/> - Enter <i>JOBID</i> to indicate a job identifier (output of submit or check-status commands)<br/> - Enter <i>STDOUT</i> to indicate the file where the stdout stream should be stored<br/> - Enter <i>STDERR</i> to indicate the file where the stderr stream should be stored<br/> <br/>Example: <br/>',profiles{iprofile}.cmd_submitoptions_example,'<br/><br/> - note: Ending the "additional submit options" string with the character ? will prompt users to confirm or manually edit these additional submit options each time this profile is used</HTML>']);
                set(handles.name,'tooltipstring',profiles{iprofile}.comments);
                set(handles.isdefault,'value',iprofile==default);
                if numel(profiles)>1, set(handles.delete,'enable','on'); else set(handles.delete,'enable','off'); end
                if strcmp(profiles{iprofile}.name,'Null profile'), set([handles.delete handles.name handles.cmd_submit handles.cmd_submitoptions handles.cmd_submitoptions_infile handles.cmd_deletejob handles.cmd_checkstatus handles.cmd_checkstatus_automatic handles.isdefault handles.cmd_rundeployed],'enable','off'); 
                else set([handles.name handles.cmd_submit handles.cmd_submitoptions handles.cmd_submitoptions_infile handles.cmd_deletejob handles.cmd_checkstatus handles.cmd_checkstatus_automatic handles.isdefault handles.cmd_rundeployed],'enable','on'); 
                end
            case 'profile',
                iprofile=get(handles.profiles,'value');
                conn_jobmanager_settings_update('refresh');
            case 'edit',
                profiles{iprofile}.name=get(handles.name,'string');
                profiles{iprofile}.cmd_submit=get(handles.cmd_submit,'string');
                profiles{iprofile}.cmd_submitoptions=get(handles.cmd_submitoptions,'string');
                profiles{iprofile}.cmd_submitoptions_infile=get(handles.cmd_submitoptions_infile,'string');
                if isempty(profiles{iprofile}.cmd_submitoptions_infile), profiles{iprofile}.cmd_submitoptions_infile={}; end
                if ~iscell(profiles{iprofile}.cmd_submitoptions_infile), profiles{iprofile}.cmd_submitoptions_infile={profiles{iprofile}.cmd_submitoptions_infile}; end
                profiles{iprofile}.cmd_deletejob=get(handles.cmd_deletejob,'string');
                profiles{iprofile}.cmd_checkstatus=get(handles.cmd_checkstatus,'string');
                profiles{iprofile}.cmd_checkstatus_automatic=get(handles.cmd_checkstatus_automatic,'value')>0;
                profiles{iprofile}.cmd_rundeployed=get(handles.cmd_rundeployed,'value')>0;
                if get(handles.isdefault,'value'), default=iprofile; end
                conn_jobmanager_settings_update('refresh');
            case 'new'
                profiles=[profiles profiles(iprofile)];
                iprofile=numel(profiles);
                profiles{iprofile}.name=[profiles{iprofile}.name ' (copy)'];
                conn_jobmanager_settings_update('refresh');
            case 'delete'
                if numel(profiles)>1
                    answ=conn_questdlg(sprintf('Delete profile %s?',profiles{iprofile}.name),'Warning','Yes','No','Yes');
                    if ~isequal(answ,'Yes'), return; end
                    profiles=profiles(setdiff(1:numel(profiles),iprofile));
                    if default>iprofile, default=default-1; end
                    iprofile=max(1,min(numel(profiles),iprofile));
                    conn_jobmanager_settings_update('refresh');
                end
            case 'test'
                dogui=nargin<=1;
                if dogui&&isempty(conn_jobmanager('conn_x_filename'))&&~isdir(fullfile(pwd,'.qlog')), 
                    answ=conn_questdlg({'CONN project: undefined',sprintf('Log files for this test will be stored in folder %s',pwd)},'','Continue','Modify','Cancel','Continue');
                    if isempty(answ)||strcmp(answ,'Cancel'), return; end
                    if strcmp(answ,'Modify'), try, cd(uigetdir(pwd)); catch, return; end; end
                end
                conn_jobmanager('options','profile',iprofile);
                for n=reshape(fieldnames(profiles{iprofile}),1,[])
                    conn_jobmanager('options',n{1},profiles{iprofile}.(n{1}));
                end
                info=conn_jobmanager('submit',[],[],2); 
                if dogui, info=conn_jobmanager(info,'Testing. Please wait...','donotupdate');
                else info=conn_jobmanager(info,'Testing. Please wait...','donotupdate','nogui');
                end
                if all(strcmp(info.tagmsg,'finished')), 
                    if dogui, conn_msgbox({'Congratulations. Test finished correctly',' ',['Profile ' char(conn_jobmanager('profiles',iprofile)) ' is correctly configured in your system'],'Set it as default if you wish to enable this profile in CONN data processing pipeline GUI'},'',true);
                    else fprintf('Test finished correctly. Profile ''%s'' tested. See %s for test log information and additional details\n',char(conn_jobmanager('profiles',iprofile)),info.pathname);
                    end
                else
                    if dogui, conn_msgbox('Sorry. Test did NOT finish correctly','error',true);
                    else error('Test did not finish correctly. See %s for test log information and additional details',info.pathname);
                    end
                end
            case 'save'
                if nargin>1, answ=varargin{1};
                else answ=conn_questdlg('Save parallelization profiles for all users or current user only?','','All','Current','None','Current');
                end
                if ~(isempty(answ)||strcmpi(answ,'none')), 
                    if strcmpi(answ,'all'),
                        if isdeployed,
                            [nill,tfolder]=conn_jobmanager_checkdeployedname;
                            filename=fullfile(tfolder,'conn_jobmanager.mat');
                        else filename=fullfile(fileparts(which(mfilename)),'conn_jobmanager.mat');
                        end
                    else
                        filename=conn_fullfile('~/conn_jobmanager.mat');
                    end
                    try
                        save(filename,'profiles','default');
                        if nargin<=1, conn_msgbox({sprintf('Parallelization profiles saved to %s',filename),'Changes will apply to current and future Matlab sessions'},'',true); 
                        else fprintf('Parallelization profiles saved to %s\n',filename); 
                        end
                    catch
                        if ~nargin<=1, conn_msgbox({sprintf('Unable to save file %s. Check permissions and try again',filename),'Changes will only apply to the current Matlab session'},'',true); 
                        else fprintf('Unable to save file %s. Check permissions and try again\n',filename); 
                        end
                    end
                end
        end
    end
end



function [info,ok]=conn_jobmanager_gui(info,files,filedates,varargin)
ok=0;
donotupdate=nargin>3&&any(strcmpi(varargin,'donotupdate'));
varargin=varargin(~strcmpi(varargin,'donotupdate')); 
nogui=nargin>3&&any(strcmpi(varargin,'nogui'));
varargin=varargin(~strcmpi(varargin,'nogui')); 
if nogui, visible='off'; else visible='on'; end
if numel(files)>0,
    [nill,tidx]=conn_jobmanager('profiles'); 
    conn_jobmanager('setprofile',tidx);
end
handles.hfig=figure('units','norm','position',[.3 .3 .4 .6],'name',sprintf('job manager (%s)',conn_jobmanager('getprofile')),'numbertitle','off','menubar','none','color','w','visible',visible,'handlevisibility','callback');

if ~isempty(varargin), uicontrol(handles.hfig,'style','text','units','norm','position',[.2,.9,.6,.04],'string',varargin{1},'backgroundcolor','w','foregroundcolor','k'); end
handles.axes=axes('units','norm','position',[.2 .15 .6 .05],'parent',handles.hfig);
handles.img=image(shiftdim([1 1 1],-1),'parent',handles.axes);
set(handles.axes,'visible','off');
hold(handles.axes,'on');
handles.txt=text(.5,1,'','horizontalalignment','center','color','w','parent',handles.axes);
hold(handles.axes,'off');
handles.stopall=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.4,.075,.2,.05],'string','Cancel job','callback',@(varargin)conn_jobmanager_update('stopall'),'tooltipstring','Stop all nodes and delete this job pipeline');
handles.enable=uicontrol(handles.hfig,'style','checkbox','value',1,'units','norm','position',[.7,.075,.3,.05],'string','Advanced options','backgroundcolor','w','callback',@(varargin)conn_jobmanager_update('enable'));

handles.panel=uipanel(handles.hfig,'units','norm','position',[0 .3 1 .7],'backgroundcolor',.9*[1 1 1]);
handles.files=[];
if numel(files)>0,
    %uicontrol(handles.panel,'style','text','units','norm','position',[.0 .05 .10 .05],'string','Jobs:  ','fontweight','bold','backgroundcolor',.9*[1 1 1],'horizontalalignment','right');
    uicontrol(handles.hfig,'style','text','units','norm','position',[.0 .25 .10 .05],'string','Jobs:  ','fontweight','bold','backgroundcolor',1*[1 1 1],'horizontalalignment','right');
    handles.files=uicontrol(handles.hfig,'style','popupmenu','units','norm','position',[.1 .25 .9 .05],'string',filedates,'value',numel(files),'backgroundcolor',1*[1 1 1],'callback',@(varargin)conn_jobmanager_update('updatefile'));
end
%txt=sprintf('<HTML>%-13s<b>%-13s</b>%-1000s</HTML>','node','status','job id');
handles.order(1)=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.1,.90,.7,.05],'string','node','userdata',1,'foregroundcolor','k','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_update('order',1));
if ~nogui, set(handles.order(1),'units','characters'); temp=get(handles.order(1),'position'); set(handles.order(1),'position',[temp(1:2) 13 max(1,temp(4))],'units','norm'); end
handles.order(2)=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.1,.90,.7,.05],'string','status','userdata',0,'foregroundcolor','k','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_update('order',2));
if ~nogui, set(handles.order(2),'units','characters'); set(handles.order(2),'position',[temp(1)+13 temp(2) 13 max(1,temp(4))],'units','norm'); end
handles.order(3)=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.1,.90,.7,.05],'string','job id','userdata',0,'foregroundcolor','k','fontname','monospaced','horizontalalignment','left','callback',@(varargin)conn_jobmanager_update('order',3));
if ~nogui, set(handles.order(3),'units','characters'); set(handles.order(3),'position',[temp(1)+2*13 temp(2) max(1,temp(3)-2*13) max(1,temp(4))],'units','norm'); end
handles.jobs=uicontrol(handles.panel,'style','listbox','units','norm','position',[.1,.15,.7,.75],'string','','max',2,'backgroundcolor',.9*[1 1 1],'foregroundcolor','k','fontname','monospaced');
handles.refresh=uicontrol(handles.panel,'style','checkbox','units','norm','position',[.825,.825,.15,.075],'string','Refresh','backgroundcolor',.9*[1 1 1],'callback',@(varargin)conn_jobmanager_update('togglerefresh',true),'tooltipstring','Refreshes node''s status information');
handles.details=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.825,.75,.15,.075],'string','See logs','callback',@(varargin)conn_jobmanager_update('details'),'tooltipstring','See selected node(s) log files');
handles.stop=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.825,.65,.15,.075],'string','Stop','callback',@(varargin)conn_jobmanager_update('stop'),'tooltipstring','Stop selected node(s)');
handles.restart=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.825,.575,.15,.075],'string','Restart','callback',@(varargin)conn_jobmanager_update('restart'),'tooltipstring','Restart selected node(s)');
fliporder=0;
order=[];

if ~numel(files)
    handles.continue=[];%handles.continue=uicontrol(handles.hfig,'style','pushbutton','units','norm','position',[.5,.025,.45,.05],'string','Continue (merge results now)','callback',@(varargin)conn_jobmanager_update('finish'));
    handles.cancel=uicontrol(handles.panel,'style','pushbutton','units','norm','position',[.825,.475,.15,.075],'string','Background','callback','close(gcbf)','tooltipstring','<HTML>Close this jobmanager window and handle merging the results of this job later<br/> - processes will continue running in the background/cluster<br/> - visit Tools.Cluster/HPC.PendingJobs to see this job progress, and merge it when finished<br/> - until this job is finished&merged <b>you may queue but not run/submit other jobs</b> (any modifications will be overwritten when this job is merged)<br/> - note: after one job has finished, re-loading your project will also result in this job being automatically merged (remember to save your project again to keep those changes)</HTML>');
    %set(handles.continue,'enable','off','visible','off');
    handles.timer=timer('name','jobmanager','startdelay',.1,'period',2,'executionmode','fixedspacing','taskstoexecute',inf,'busymode','drop','timerfcn',@(varargin)conn_jobmanager_update('refresh'));
    set(handles.refresh,'value',1);
    set(handles.hfig,'closerequestfcn',@(varargin)conn_jobmanager_update('end'));
    set(handles.enable,'value',0); 
    conn_jobmanager_update('enable');
    handles.finished=false;
    start(handles.timer);
    if nogui, 
        warning('off','MATLAB:hg:NoDisplayNoFigureSupportSeeReleaseNotes');
        fprintf('Waiting for grid/cluster jobs to finish...\n');
    end
    waitfor(handles.hfig);
    if nogui, warning('on','MATLAB:hg:NoDisplayNoFigureSupportSeeReleaseNotes'); end
else
    handles.continue=[];
    handles.cancel=[];
    handles.timer=[];
    set(handles.refresh,'value',0);
    %handles.timer=timer('name','jobmanager','period',1,'executionmode','fixedspacing','taskstoexecute',inf,'busymode','drop','timerfcn',@(varargin)conn_jobmanager_update('refresh'));
    set(handles.hfig,'closerequestfcn',@(varargin)conn_jobmanager_update('end'));
    set(handles.enable,'value',0);
    set(handles.stopall,'string','Delete job');
    conn_jobmanager_update('enable');
    handles.finished=false;
    %start(handles.timer);
    conn_jobmanager_update('refresh');
end
ok=1+handles.finished;

    function conn_jobmanager_update(option,varargin)
        switch(option)
            case 'updatefile' 
                n=get(handles.files,'value');
                data=load(files{n},'info');
                info=data.info;
                conn_jobmanager_update('refresh');
                
            case 'togglerefresh'
                v=get(handles.refresh,'value');
                try
                    if ~isempty(handles.timer),
                        stop(handles.timer);
                        delete(handles.timer);
                    end
                end
                if v&&isempty(handles.timer)
                    handles.timer=timer('name','jobmanager','startdelay',2,'period',2,'executionmode','fixedspacing','taskstoexecute',inf,'busymode','drop','timerfcn',@(varargin)conn_jobmanager_update('refresh'));
                    conn_jobmanager_update('refresh',true);
                    start(handles.timer);
                elseif ~v&&~isempty(handles.timer)
                    handles.timer=[];
                end

            case 'refresh'
                try
                    if nargin==1||varargin{1}==1, info=conn_jobmanager('statusjob',info,[],varargin{:}); end
                    txt=cellfun(@(a,b,c)sprintf('%-13s%-13s%-32s',a(1:min(numel(a),9)),b(1:min(numel(b),12)),c(1:min(numel(c),32))),info.joblabel,info.tagmsg,info.statusmsg,'uni',0);
                    
                    sortedlabels={'finished','finishing','running','submitted','stopping','stopped','queued','error','failed','crashed'};
                    [nill,st]=ismember(info.tagmsg,sortedlabels);
                    if get(handles.order(2),'userdata'), [nill,order]=sort(st);
                    elseif get(handles.order(3),'userdata'), [nill,order]=sort(info.statusmsg);
                    else order=1:numel(st); 
                    end
                    if fliporder, order=order(end:-1:1); end
                    set(handles.jobs,'string',txt(order));
                    set(handles.img,'cdata',ind2rgb(1+sort(st),[0 0 0;linspace(0,1,6)'*[5/6,2/6,1.5/6]+linspace(1,0,6)'*[1.5/6,5/6,2/6];1 0 0;1 0 0;1 0 0]));
                    nl=accumarray(reshape(st(st>0),[],1),1,[numel(sortedlabels),1])';
                    txt=cellfun(@(a,b)sprintf(' %s (%d) ',a,b),reshape(sortedlabels(nl>0),1,[]),num2cell(reshape(nl(nl>0),1,[])),'uni',0);
                    set(handles.txt,'position',[1+(numel(st)-1)/2,1,1],'string',sprintf( '%s',txt{:}));
                    set(handles.axes,'xlim',[.5 numel(st)+.5001],'ylim',[.5 1.5]);
                    
                    validlabels={'finished'}; %{'finished','stopped'};
                    if all(ismember(info.tagmsg,validlabels))
                        set(handles.continue,'enable','on'); 
                        if ~numel(files)&&~handles.finished, conn_jobmanager_update('finish'); end
                    end
%                 catch
%                     fprintf('.');
                end
                
            case 'details'
                clear h;
                thisjob=get(handles.jobs,'value');
                if isempty(thisjob)||numel(order)<thisjob(1), thisjob=1;
                else thisjob=order(thisjob(1));
                end
                tfiles={info.stdout, info.stderr, info.stdlog, info.scripts};
                [nill,names]=cellfun(@fileparts,tfiles{1},'uni',0);
                names=regexp(names,'^.{9}','match','once');
                h.hfig=figure('units','norm','position',[.7 .3 .3 .6],'name','log details','numbertitle','off','menubar','none','color','w');
                h.files=uicontrol(h.hfig,'style','popupmenu','units','norm','position',[.1 .95 .9 .05],'string',names,'value',thisjob,'callback',@conn_projectmanager_update_details); %'uiresume(gcbf)');
                h.types=uicontrol(h.hfig,'style','popupmenu','units','norm','position',[.1 .90 .9 .05],'string',{'console output (stdout)','error output (stderr)','Matlab log','submission script','submission command','submission command output','status command output'},'value',1,'callback',@conn_projectmanager_update_details); %'uiresume(gcbf)');
                h.str=uicontrol(h.hfig,'style','listbox','units','norm','position',[.05 .1 .9 .75],'string','','max',2,'horizontalalignment','left','fontname','monospaced');
                h.refresh=uicontrol(h.hfig,'style','pushbutton','units','norm','position',[.25 .025 .5 .05],'string','refresh','callback',@conn_projectmanager_update_details); %'uiresume(gcbf)');
                if ishandle(h.hfig), conn_projectmanager_update_details; end
                
            case 'order',
                n=varargin{1};
                if get(handles.order(n),'userdata'), fliporder=~fliporder; end
                set(handles.order,'userdata',0);
                set(handles.order(n),'userdata',1);
                conn_jobmanager_update('refresh',false);
                
            case 'stopall'
                handles.finished=true;
                tstr=get(handles.stopall,'string');
                set(handles.stopall,'string','Canceling...');
                conn_jobmanager('deletejob',info);
                conn_jobmanager('clearqlog',info);
                if ~donotupdate
                    filename=regexprep(info.private{1}(1).project,'\?.*$','');
                    conn('load',filename);
                    conn save;
                end
                set(handles.stopall,'string',tstr);
                if numel(files)>0, 
                    n=get(handles.files,'value');
                    tstr=get(handles.files,'string');
                    files=files([1:n-1,n+1:numel(files)]);
                    tstr=tstr([1:n-1,n+1:numel(tstr)]);
                    if isempty(files), close(handles.hfig)
                    else
                        set(handles.files,'string',tstr,'value',max(1,min(numel(files), n)));
                        conn_jobmanager_update('updatefile');
                    end
                else close(handles.hfig);
                end
                
            case 'stop'
                n=get(handles.jobs,'value');
                n=find(order==n);
                conn_jobmanager('deletejob',info,n);
                conn_jobmanager_update('refresh');
                
            case 'restart'
                n=get(handles.jobs,'value');
                n=find(order==n);
                conn_jobmanager('submitjob',info,n);
                handles.finished=false;
                conn_jobmanager_update('refresh');
                
            case 'finish'
                handles.finished=true;
                if ~donotupdate
                    set(handles.stopall,'string','Finish','callback','close(gcbf)','tooltipstring','Close this window (results already imported)');
                    filename=regexprep(info.private{1}(1).project,'\?.*$','');
                    conn('load',filename);
                    conn save;
                else
                    set(handles.stopall,'string','Finish','callback','close(gcbf)','tooltipstring','Close this window and import results');
                end
                if ~get(handles.enable,'value'), close(handles.hfig); end
                
            case 'exit'
                close(handles.hfig);
                
            case 'enable',
                st=get(handles.enable,'value');
                try
                    htemp1=get(handles.hfig,'children');
                    htemp2=get(htemp1,'units');
                    set(htemp1,'units','pixels');
                    if st, set(handles.hfig,'units','norm'); pos=get(handles.hfig,'position'); set(handles.hfig,'position',[pos(1:3) .6]);
                    else set(handles.hfig,'units','norm'); pos=get(handles.hfig,'position'); set(handles.hfig,'position',[pos(1:3) .6*.3]);
                    end
                    for ntemp1=1:numel(htemp1), set(htemp1(ntemp1),'units',htemp2{ntemp1}); end
                end
                vl={'off','on'};
                set([handles.refresh, handles.details, handles.stop, handles.restart, handles.continue, handles.cancel],'visible',vl{1+st});
                
            case 'end'
                try
                    stop(handles.timer);
                    delete(handles.timer);
                end
                delete(handles.hfig);
        end
        
        function conn_projectmanager_update_details(varargin)
            i=get(h.files,'value');
            j=get(h.types,'value');
            switch(j)
                case {1,2,3,4},
                    fh=fopen(tfiles{j}{i},'rt');
                    if ~isequal(fh,-1)
                        str=fread(fh,inf,'uchar');
                        fclose(fh);
                        str=char(str(:)');
                        b=find(diff([0 str==8 0]));
                        for n=1:2:numel(b)-1,
                            str(max(1,b(n)-(b(n+1)-b(n))):b(n+1)-1)=0;
                        end
                        str=str(str~=0);
                        str=regexp(str,'\n','split');
                    else str={' '};
                    end
                case 5,
                    if isfield(info,'submitcmd')&&numel(info.submitcmd)>=i, str=regexp(info.submitcmd{i},'\n','split');
                    else str={' '};
                    end
                case 6,
                    if isfield(info,'submitmsg')&&numel(info.submitmsg)>=i, str=regexp(info.submitmsg{i},'\n','split');
                    else str={' '};
                    end
                case 7,
                    if isfield(info,'statemsg')&&numel(info.statemsg)>=i, str=regexp(info.statemsg{i},'\n','split');
                    else str={' '};
                    end
            end
            set(h.str,'string',str,'value',numel(str),'listboxtop',numel(str));
            %uiwait(h.hfig);
        end
    end
end

function [isdep_callback,isdep_folder]=conn_jobmanager_checkdeployedname(varargin)
% for deployed standalone versions (CONN or SPM+toolboxes):
%   returns name of system-level call to invoque conn
%   e.g. run_conn.sh [MCRfolder]
%        run_spm12.sh [MCRfolder] function conn
%        

idx=1;
isdep_folder='';
isdep_callback={'%s','%s function conn','%s function conn'};
isdep_checkexists={'conn','spm','spm12'};
if ~ispc
    if isdeployed, mcrroot=matlabroot;
    else mcrroot=getenv('MCRROOT'); if isempty(mcrroot), mcrroot=getenv('MCR'); end
    end
    isdep_callback=[{sprintf('%s %s','%s',mcrroot),sprintf('%s %s function conn','%s',mcrroot),sprintf('%s %s function conn','%s',mcrroot)} isdep_callback];
    isdep_checkexists=[{'run_conn.sh','run_spm.sh','run_spm12.sh'} isdep_checkexists];
end
try,
    [ko,nill]=cellfun(@(x)system(sprintf('which %s',x)),isdep_checkexists,'uni',0);
    ko=[ko{:}];
    ko=find(~ko,1);
    if ~isempty(ko), idx=ko; end
end
[ok,msg]=system(sprintf('which %s',isdep_checkexists{idx}));
if ~ok&&conn_existfile(msg(msg>=32)), 
    isdep_callback=sprintf(isdep_callback{idx},msg(msg>=32)); % full-path to executable
    isdep_folder=fileparts(msg(msg>=32));
else isdep_callback=sprintf(isdep_callback{idx},isdep_checkexists{idx});
end
end


