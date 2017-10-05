function fh=conn_qaplotsexplore(varargin)
% CONN_QAPLOTSEXPLORE QA plots display
%

global CONN_x CONN_gui;

if isfield(CONN_gui,'font_offset'),font_offset=CONN_gui.font_offset; else font_offset=0; end
if ~isfield(CONN_x,'folders')||~isfield(CONN_x.folders,'qa')||isempty(CONN_x.folders.qa), 
    qafolder=pwd;
    isCONN=false;
else qafolder=CONN_x.folders.qa; 
    isCONN=true;
end
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'initdenoise')), dlg.forceinitdenoise=true;
else dlg.forceinitdenoise=false;
end
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'createdenoise')), dlg.forceinitdenoise=true; dlg.createdenoise=true;
else dlg.createdenoise=false;
end
fh=@(varargin)conn_qaplotsexplore_update([],[],varargin{:});
if nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'thesefolders')), 
    qafolder=pwd;
    qagroups=dir(qafolder);
    qagroups=qagroups([qagroups.isdir]>0);
    qagroups=qagroups(cellfun('length',regexp({qagroups.name},'^QA_'))>0);
    dlg.sets={qagroups.name};
    isCONN=false; 
elseif nargin&&any(strcmp(varargin(cellfun(@ischar,varargin)),'thisfolder')), 
    [qafolder,qagroups]=fileparts(pwd);
    dlg.sets={qagroups};
    isCONN=false; 
else
    qagroups=dir(qafolder);
    qagroups=qagroups([qagroups.isdir]>0);
    qagroups=qagroups(cellfun('length',regexp({qagroups.name},'^QA_'))>0);
    dlg.sets={qagroups.name};
end
if dlg.forceinitdenoise&&(dlg.createdenoise||isempty(dlg.sets)),
    conn_qaplotsexplore_update([],[],'newsetinit');
end
dlg.iset=numel(dlg.sets);
dlg.dispsize=[];
dlg.showavg=1;
bgc=.9*[1 1 1];
dlg.handles.fh=fh;
dlg.handles.hfig=figure('units','norm','position',[.1,.3,.8,.6],'menubar','none','numbertitle','off','name','Quality Assurance plots','color',.995*[1 1 1],'colormap',gray(256),'interruptible','off','busyaction','cancel');
dlg.handles.menuprint=uimenu(dlg.handles.hfig,'Label','Print','callback',@(varargin)conn_print);
uicontrol('style','frame','units','norm','position',[0,.85,1,.15],'backgroundcolor',bgc,'foregroundcolor',bgc,'fontsize',9+font_offset);
uicontrol('style','text','units','norm','position',[.05,.925,.1,.05],'backgroundcolor',bgc,'foregroundcolor','k','horizontalalignment','left','string','QA set:','fontweight','bold','fontsize',9+font_offset);
uicontrol('style','text','units','norm','position',[.05,.865,.1,.05],'backgroundcolor',bgc,'foregroundcolor','k','horizontalalignment','left','string','Plots:','fontweight','bold','fontsize',9+font_offset);
dlg.handles.set=uicontrol('style','popupmenu','units','norm','position',[.15,.925,.5,.05],'string',dlg.sets,'value',dlg.iset,'backgroundcolor',bgc,'foregroundcolor','k','tooltipstring','<HTML>Select a Quality Assurance set<br/> - each set contains one or multiple plots created to visually assess the quality of the structural/functional data<br/> and/or easily identify potential outlier subjects or failed preprocessing steps<br/> - choose one existing set from this list, or select <i>add new set</i> to create a new set instead</HTML>','callback',{@conn_qaplotsexplore_update,'set'},'fontsize',9+font_offset,'interruptible','off');
dlg.handles.settxt=uicontrol('style','text','units','norm','position',[.15,.925,.5,.05],'string','No QA sets found in this CONN project. Select ''Add new set'' to get started','backgroundcolor',bgc,'foregroundcolor','k','fontsize',9+font_offset,'visible','off');
dlg.handles.analysis=uicontrol('style','popupmenu','units','norm','position',[.15,.865,.5,.05],'string',' ','backgroundcolor',bgc,'foregroundcolor','k','tooltipstring','<HTML>Select a Quality Assurance plot within this set<br/> - each set may contain one or multiple plots<br/> - choose one existing plot from this set, or select <i>add new plot</i> to create a new plot and add it to this set</HTML>','callback',{@conn_qaplotsexplore_update,'plot'},'fontsize',9+font_offset,'interruptible','off');
dlg.handles.analysistxt=uicontrol('style','text','units','norm','position',[.15,.865,.5,.05],'string','No plots found in this QA set. Select ''Add new plot'' to get started','backgroundcolor',bgc,'foregroundcolor','k','fontsize',9+font_offset,'visible','off');
dlg.handles.addnewset=uicontrol('style','pushbutton','units','norm','position',[.8 .925 .15 .05],'string','Add new set','tooltipstring','Creates a new QA set','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'newset'},'interruptible','off');
dlg.handles.addnewplot=uicontrol('style','pushbutton','units','norm','position',[.8 .865 .15 .05],'string','Add new plot','tooltipstring','Creates a new plot within the current set','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'newplot'},'interruptible','off');
dlg.handles.deleteset=uicontrol('style','pushbutton','units','norm','position',[.65 .925 .15 .05],'string','Delete set','tooltipstring','Deletes this set','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'deleteset'},'interruptible','off');
dlg.handles.deleteplot=uicontrol('style','pushbutton','units','norm','position',[.65 .865 .15 .05],'string','Delete plot','tooltipstring','Deletes this plot','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'deleteplot'},'interruptible','off');

%uicontrol('style','frame','units','norm','position',[0,0,.17,.86],'backgroundcolor',.995*[1 1 1],'foregroundcolor',.995*[1 1 1],'fontsize',9+font_offset);
dlg.handles.subjects=uicontrol('style','listbox','units','norm','position',[.035,.41,.1,.34],'max',2,'backgroundcolor',.995*[1 1 1],'foregroundcolor','k','string','','tooltipstring','Select one or multiple subjects for display','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'subjects'},'interruptible','off');
dlg.handles.sessions=uicontrol('style','listbox','units','norm','position',[.035,.25,.1,.10],'max',2,'backgroundcolor',.995*[1 1 1],'foregroundcolor','k','string','','tooltipstring','Select one or multiple sessions for display','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'sessions'},'interruptible','off');
dlg.handles.selectall1=uicontrol('style','pushbutton','units','norm','position',[.035 .36 .1 .05],'string','Select all','tooltipstring','Selects all subjects','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'allsubjects'},'interruptible','off');
dlg.handles.selectall2=uicontrol('style','pushbutton','units','norm','position',[.035 .20 .1 .05],'string','Select all','tooltipstring','Selects all sessions','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'allsessions'},'interruptible','off');
dlg.handles.showdiff=uicontrol('style','checkbox','units','norm','position',[.02 .10 .115 .05],'string','show diff','backgroundcolor',.995*[1 1 1],'foregroundcolor','k','fontsize',9+font_offset,'tooltipstring','<HTML>Show z score maps: normalized differences between each image and the average of all images in this plot<br/>this can be useful to highlight differences between a selected subject and the group</HTML>','value',0,'callback',{@conn_qaplotsexplore_update,'subjects'},'interruptible','off');
dlg.handles.showannot=uicontrol('style','checkbox','units','norm','position',[.02 .05 .115 .05],'string','show annotations','backgroundcolor',.995*[1 1 1],'foregroundcolor','k','tooltipstring','show/hide plot annotations','fontsize',9+font_offset,'callback',{@conn_qaplotsexplore_update,'subjects'},'interruptible','off','visible','on');
dlg.handles.hax=[];%axes('units','norm','position',[.20 .10 .75 .70],'visible','off');
dlg.handles.han=[];
dlg.handles.text=uicontrol('style','text','units','norm','position',[.30,.025,.52,.05],'backgroundcolor',.995*[1 1 1],'foregroundcolor','k','horizontalalignment','center','string','','fontsize',9+font_offset);
dlg.handles.textoptions=uicontrol('style','popupmenu','units','norm','position',[.45,.025,.2,.05],'backgroundcolor',.995*[1 1 1],'foregroundcolor','k','horizontalalignment','center','string','','fontsize',9+font_offset,'tooltipstring','<HTML>Choose what to display when selecting multiple subjects/sessions<br/> -<i>average/variability</i> computes the average/variability of the selected plots (e.g. across multiple subjects or sessions)</HTML>','visible','off','callback',{@conn_qaplotsexplore_update,'textoptions'},'interruptible','off');
dlg.handles.details=uicontrol('style','pushbutton','units','norm','position',[.825 .015 .15 .07],'string','Explore','tooltipstring','go to interactive version of this subject plot (slice viewer)','fontsize',10+font_offset,'fontweight','bold','callback',{@conn_qaplotsexplore_update,'details'},'visible','off');
conn_qaplotsexplore_update([],[],'set',dlg.iset);
conn_qaplotsexplore_update([],[],'allsubjects');
conn_qaplotsexplore_update([],[],'allsessions');
dlg.handles.hlabel=uicontrol('style','text','horizontalalignment','left','visible','off','fontsize',9+font_offset);
if ~ishandle(dlg.handles.hfig), return; end
set(dlg.handles.hfig,'units','pixels','windowbuttonmotionfcn',@conn_qaplotsexplore_figuremousemove,'resizefcn',{@conn_qaplotsexplore_update,'resize'});

    function conn_qaplotsexplore_update(hObject,eventdata,option,varargin)
        if isfield(dlg,'handles')&&isfield(dlg.handles,'hfig')&&~ishandle(dlg.handles.hfig), return; end
        switch(lower(option))
            case 'resize',
                try
                    if dlg.dispsize(end)>1, conn_qaplotsexplore_update([],[],'refresh'); end
                end
            case 'annotate'
                descr=get(dlg.handles.han(end),'string');
                fname=fullfile(qafolder,dlg.sets{dlg.iset},dlg.files_txt{dlg.dataIDXplots(dlg.dataIDXsubjects)});
                dlg.txtA{dlg.dataIDXsubjects}=descr;
                fh=fopen(fname,'wt');
                for n=1:numel(descr), fprintf(fh,'%s\n',regexprep(descr{n},'\n','')); end
                fclose(fh);
            case 'allsubjects'
                set(dlg.handles.subjects,'value',1:numel(cellstr(get(dlg.handles.subjects,'string'))));
                conn_qaplotsexplore_update([],[],'subjects');
            case 'allsessions'
                set(dlg.handles.sessions,'value',1:numel(cellstr(get(dlg.handles.sessions,'string'))));
                conn_qaplotsexplore_update([],[],'sessions');
            case 'textoptions',
                dlg.showavg=get(dlg.handles.textoptions,'value');
                conn_qaplotsexplore_update([],[],'subjects');
            case {'deleteset','newset','newsetinit'}
                if strcmp(lower(option),'deleteset')
                    answ=conn_questdlg(sprintf('Are you sure you want to delete set %s?',dlg.sets{dlg.iset}),'','Delete','Cancel','Delete');
                    if ~isequal(answ,'Delete'), return; end
                    f=conn_dir(fullfile(qafolder,dlg.sets{dlg.iset},'*'));
                    if ~isempty(f),
                        f=cellstr(f);
                        spm_unlink(f{:});
                    end
                    [ok,nill]=rmdir(fullfile(qafolder,dlg.sets{dlg.iset}));
                    tag='';
                else
                    if numel(varargin)>=1, answ={varargin{1}};
                    elseif strcmp(lower(option),'newsetinit'), answer={[]};
                    else answer=inputdlg({'Name of new QA set: (must be valid folder name)'},'',1,{datestr(now,'yyyy_mm_dd_HHMMSSFFF')});
                    end
                    if isempty(answer), return; end
                    if isempty(answer{1}), answer={datestr(now,'yyyy_mm_dd_HHMMSSFFF')}; end
                    tag=['QA_',answer{1}];
                    [ok,nill]=mkdir(qafolder,tag);
                end
                qagroups=dir(qafolder);
                qagroups=qagroups([qagroups.isdir]>0);
                qagroups=qagroups(cellfun('length',regexp({qagroups.name},'^QA_'))>0);
                dlg.sets={qagroups.name};
                dlg.iset=find(strcmp(dlg.sets,tag),1);
                if isempty(dlg.iset), dlg.iset=1; end
                if ~strcmp(lower(option),'newsetinit')
                    set(dlg.handles.set,'string',dlg.sets);
                    conn_qaplotsexplore_update([],[],'set',dlg.iset);
                end
            case 'deleteplot'
                answ=conn_questdlg(sprintf('Are you sure you want to delete plot %s?',dlg.uanalyses_long{dlg.ianalysis}),'','Delete','Cancel','Delete');
                if ~isequal(answ,'Delete'), return; end
                in=find(ismember(dlg.ianalyses,dlg.ianalysis));
                tfiles={};
                for n=1:numel(in),
                    tfiles{end+1}=fullfile(qafolder,dlg.sets{dlg.iset},dlg.files_jpg{in(n)});
                    tfiles{end+1}=fullfile(qafolder,dlg.sets{dlg.iset},dlg.files{in(n)});
                end
                spm_unlink(tfiles{:});
                conn_qaplotsexplore_update([],[],'set');
            case 'newplot'
                if ~isCONN, conn_msgbox('Load existing CONN project before proceeding','Error',2); return; end
                tag=dlg.sets{dlg.iset};
                analyses={'QA_NORM_structural','QA_NORM_functional','QA_NORM_ROI','QA_REG__structural','QA_REG__functional','QA_REG__mni','QA_COREG_functional','QA_TIME_functional','QA_TIMEART_functional','QA_DENOISE_timeseries','QA_DENOISE'};
                analyses_numbers=[1,2,3,4,5,6,7,8,9,12,11];
                if ~isfield(CONN_x,'isready')||~CONN_x.isready(2), 
                    analyses=analyses(1:end-2);analyses_numbers=analyses_numbers(1:end-2); % disable analyses that require having run Setup step
                end
                uanalyses_long = regexprep(analyses,...
                    {'^QA_NORM_(.*)','^QA_REG_(.*?)_?functional','^QA_REG_(.*?)_?structural','^QA_REG_(.*?)_?mni','^QA_COREG_(.*)','^QA_TIME_(.*)','^QA_TIMEART_(.*)','^QA_DENOISE_timeseries','^QA_DENOISE'},...
                    {'QA normalization: $1 data + outline of MNI TPM template','QA registration: functional data + outline of ROI $1','QA registration: structural data + outline of ROI $1','QA registration: mni reference template + outline of ROI $1','QA realignment: $1 center-slice across multiple sessions/datasets','QA artifacts: $1 movie across all timepoints/acquisitions','QA artifacts: ART GS changes & movement timeseries with $1 movie','QA denoising: BOLD signal traces before and after denoising + ART timeseries','QA denoising: distribution of functional correlations before and after denoising'});
                answ=listdlg('liststring',uanalyses_long,'selectionmode','multiple','initialvalue',[],'promptstring','Select plot(s) to create:','ListSize',[400 200]);
                if isempty(answ), return; end
                procedures=analyses_numbers(answ);
                validsets=[];
                if any(ismember(procedures,[2,7,8,9]))&&numel(CONN_x.Setup.roifunctional)>0,
                    nalt=listdlg('liststring',arrayfun(@(n)sprintf('dataset %d',n),0:numel(CONN_x.Setup.roifunctional),'uni',0),'selectionmode','multiple','initialvalue',1,'promptstring',{'Select functional dataset(s)','to include in functional data plots:'},'ListSize',[300 200]);
                    if isempty(nalt), return; end
                    validsets=nalt-1;
                end
                validrois=[];
                if any(ismember(procedures,[3:6])),
                    %nalt=listdlg('liststring',CONN_x.Setup.rois.names(1:end-1),'selectionmode','multiple','initialvalue',2,'promptstring',{'Select ROI(s)','to include in ROI data plots:'},'ListSize',[300 200]);
                    nalt=listdlg('liststring',[CONN_x.Setup.rois.names(1:end-1), regexprep(CONN_x.Setup.rois.names(1:3),'^(.*)$','eroded $1')],'selectionmode','multiple','initialvalue',2,'promptstring',{'Select ROI(s)','to include in ROI data plots:'},'ListSize',[300 200]);
                    if isempty(nalt), return; end
                    temp=numel(CONN_x.Setup.rois.names)-1;
                    nalt(nalt>temp)=-(nalt(nalt>temp)-temp);
                    validrois=nalt;
                end
                nalt=listdlg('liststring',arrayfun(@(n)sprintf('subject %d',n),1:CONN_x.Setup.nsubjects,'uni',0),'selectionmode','multiple','initialvalue',1:CONN_x.Setup.nsubjects,'promptstring',{'Select subject(s)','to include in these plots:'},'ListSize',[300 200]);
                if isempty(nalt), return; end
                validsubjects=nalt;
                conn_qaplots(fullfile(qafolder,tag),procedures,validsubjects,validrois,validsets);
                conn_qaplotsexplore_update([],[],'set');
                figure(dlg.handles.hfig);
                
            case 'details'
                filename=fullfile(qafolder,dlg.sets{dlg.iset},dlg.filethis);
                if isempty(filename)||~conn_existfile(filename), conn_msgbox(sprintf('Data file %s not found',filename),'Details not available',2); 
                else
                    conn_bookmark('open',filename);
                    %load(filename,'state');
                    %conn_slice_display(state);
                end
                return;
                
            case 'set'
                if numel(varargin)>=1&&~isempty(varargin{1}), dlg.iset=varargin{1}; set(dlg.handles.set,'value',dlg.iset);
                else dlg.iset=get(dlg.handles.set,'value');
                end
                if isempty(dlg.sets), 
                    set(dlg.handles.settxt,'visible','on');
                    set([dlg.handles.set dlg.handles.deleteset],'visible','off');
                    set(dlg.handles.addnewset,'fontweight','bold'); 
                    set([dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.subjects dlg.handles.sessions dlg.handles.showdiff dlg.handles.showannot dlg.handles.analysis dlg.handles.analysistxt dlg.handles.addnewplot dlg.handles.deleteplot dlg.handles.text dlg.handles.textoptions dlg.handles.details],'visible','off');
                    delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                    dlg.dispsize=[];
                    return
                else
                    set(dlg.handles.settxt,'visible','off');
                    set([dlg.handles.set dlg.handles.deleteset],'visible','on');
                    set(dlg.handles.addnewset,'fontweight','normal'); 
                end
                qafiles=dir(fullfile(qafolder,dlg.sets{dlg.iset},'*.mat'));
                qanames={qafiles.name};
                jpgok=cellfun(@(x)conn_existfile(fullfile(qafolder,dlg.sets{dlg.iset},x))|~isempty(regexp(x,'^QA_DENOISE\.')),conn_prepend('',qanames,'.jpg'));
                txtok=cellfun(@(x)conn_existfile(fullfile(qafolder,dlg.sets{dlg.iset},x)),conn_prepend('',qanames,'.txt'));
                qanames=qanames(jpgok);
                txtok=txtok(jpgok);
                dlg.files=qanames;
                dlg.files_jpg=conn_prepend('',qanames,'.jpg');
                dlg.files_txt=conn_prepend('',qanames,'.txt');
                if ~all(txtok),cellfun(@(s)fclose(fopen(fullfile(qafolder,dlg.sets{dlg.iset},s),'wt')),dlg.files_txt(~txtok),'uni',0); end
                if isempty(qanames)
                    qanames_parts1={};qanames_parts2={};qanames_parts3={};
                else
                    qanames=regexp(qanames,'\.','split');

                    qanames_parts=repmat({''},numel(qanames),3);
                    for n=1:numel(qanames), i=1:min(3,numel(qanames{n})-1); qanames_parts(n,i)=qanames{n}(i); end % analyses / subject /session
                    if 1
                        qanames_parts1=qanames_parts(:,1);
                        qanames_parts2=str2double(regexprep(qanames_parts(:,2),'^subject',''));
                        qanames_parts3=str2double(regexprep(qanames_parts(:,3),'^session',''));
                        qanames_parts2(isnan(qanames_parts2))=0;
                        qanames_parts3(isnan(qanames_parts3))=0;
                    else
                        qanames_parts1=qanames_parts(:,1);
                        qanames_parts2=qanames_parts(:,2);
                        qanames_parts3=qanames_parts(:,3);
                    end
                end
                [dlg.uanalyses,nill,dlg.ianalyses]=unique(qanames_parts1);
                [dlg.usubjects,nill,dlg.isubjects]=unique(qanames_parts2);
                [dlg.usessions,nill,dlg.isessions]=unique(qanames_parts3);
                dlg.uanalysestype=ones(size(dlg.uanalyses)); % QA_NORM/QA_REG/QA_COREG/QA_TIME/QA_TIMEART
                dlg.uanalysestype(cellfun('length',regexp(dlg.uanalyses,'^QA_DENOISE$'))>0)=2; %QA_DENOISE
                if 1
                    dlg.usubjects=regexprep(arrayfun(@(n)sprintf('subject %d',n),dlg.usubjects,'uni',0),'^subject 0$','---');
                    dlg.usessions=regexprep(arrayfun(@(n)sprintf('session %d',n),dlg.usessions,'uni',0),'^session 0$','---');
                end
                if dlg.forceinitdenoise, 
                    dlg.forceinitdenoise=false;
                    dlg.ianalysis=find(dlg.uanalysestype>1,1);
                    if ~dlg.createdenoise&&~isempty(dlg.ianalysis)
                        answ=conn_questdlg({'Overwrite existing denoising plot?'},'','Yes','No','Yes');
                        if strcmp(answ,'Yes'), dlg.createdenoise=true; end
                    end
                    if dlg.createdenoise||isempty(dlg.ianalysis)
                        conn_qaplots(fullfile(qafolder,dlg.sets{dlg.iset}));
                        conn_qaplotsexplore_update([],[],'set');
                        return;
                    end
                else
                    temp=find(dlg.uanalysestype>1,1); % note: tries loading denoising by default (faster)
                    if ~isempty(temp), dlg.ianalysis=temp; end
                end
                if ~isfield(dlg,'ianalysis')||isempty(dlg.ianalysis)||dlg.ianalysis<1||dlg.ianalysis>numel(dlg.uanalyses), dlg.ianalysis=1; end
                dlg.uanalyses_long = regexprep(dlg.uanalyses,...
                    {'^QA_NORM_(.*)','^QA_REG_(.*?)_?functional','^QA_REG_(.*?)_?structural','^QA_REG_(.*?)_?mni','^QA_COREG_(.*)','^QA_TIME_(.*)','^QA_TIMEART_(.*)','^QA_DENOISE_timeseries','^QA_DENOISE'},...
                    {'QA normalization: $1 data + outline of MNI TPM template','QA registration: functional data + outline of ROI $1','QA registration: structural data + outline of ROI $1','QA registration: mni reference template + outline of ROI $1','QA realignment: $1 center-slice across multiple sessions/datasets','QA artifacts: $1 movie across all timepoints/acquisitions','QA artifacts: ART GS changes & movement timeseries with $1 movie','QA denoising: BOLD signal traces before and after denoising + ART timeseries','QA denoising: distribution of functional correlations before and after denoising'});
                dlg.uanalyses_long=arrayfun(@(n,m)sprintf('%s (%d)',dlg.uanalyses_long{n},m),1:numel(dlg.uanalyses_long),accumarray(dlg.ianalyses(:),1)','uni',0);
                set(dlg.handles.analysis,'string',dlg.uanalyses_long,'value',dlg.ianalysis);
                conn_qaplotsexplore_update([],[],'plot');
                
            case 'plot'
                if isempty(dlg.sets)||isempty(dlg.uanalyses),
                    set([dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.subjects dlg.handles.sessions dlg.handles.showdiff dlg.handles.showannot dlg.handles.analysis dlg.handles.text dlg.handles.textoptions dlg.handles.details],'visible','off'); 
                    delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                    set([dlg.handles.analysis dlg.handles.deleteplot],'visible','off')
                    set(dlg.handles.analysistxt,'visible','on'); 
                    set(dlg.handles.addnewplot,'fontweight','bold','visible','on'); 
                    dlg.dispsize=[];
                    return;
                else
                    set([dlg.handles.selectall1 dlg.handles.selectall2 dlg.handles.subjects dlg.handles.sessions dlg.handles.analysis dlg.handles.deleteplot],'visible','on')
                    set(dlg.handles.analysistxt,'visible','off');
                    set(dlg.handles.addnewplot,'fontweight','normal','visible','on');
                end
                if numel(varargin)>=1, dlg.ianalysis=varargin{1}; set(dlg.handles.analysis,'value',dlg.ianalysis);
                else dlg.ianalysis=get(dlg.handles.analysis,'value');
                end
                if dlg.uanalysestype(dlg.ianalysis)==1 % QA_NORM/QA_REG/QA_COREG/QA_TIME/QA_TIMEART
                    set([dlg.handles.showdiff dlg.handles.showannot dlg.handles.analysis],'visible','on'); 
                    set(dlg.handles.hfig,'pointer','watch');
                    in=find(ismember(dlg.ianalyses,dlg.ianalysis));% & ismember(dlg.isubjects, dlg.isubject) & ismember(dlg.isessions, dlg.isession);
                    ht=conn_msgbox(sprintf('Loading %d plots. Please wait...',numel(in)),'');
                    dlg.dataA=[];
                    dlg.txtA={};
                    dlg.dataIDXplots=in;
                    for n=1:numel(in),
                        data=imread(fullfile(qafolder,dlg.sets{dlg.iset},dlg.files_jpg{in(n)}));
                        if isa(data,'uint8'), data=double(data)/255; end
                        if isempty(dlg.dataA), dlg.dataA=zeros([size(data,1),size(data,2),size(data,3),numel(in)]); end
                        dlg.dataA(:,:,:,n)=data;
                        descr = fileread(fullfile(qafolder,dlg.sets{dlg.iset},dlg.files_txt{in(n)}));
                        if isempty(descr), dlg.txtA{n}={'[empty]'}; 
                        else dlg.txtA{n}=regexp(descr,'\n+','split');
                        end
                    end
                    dlg.dataM=mean(dlg.dataA,4);
                    dlg.dataD=abs(dlg.dataA-repmat(dlg.dataM,[1,1,1,size(dlg.dataA,4)]));
                    dlg.dataS=sqrt(mean(dlg.dataD.^2,4)); %std(dlg.dataA,1,4);
                    temp=repmat(convn(convn(sum(dlg.dataS.^2,3),conn_hanning(3)/2,'same'),conn_hanning(3)'/2,'same'),[1,1,1,size(dlg.dataA,4)]);
                    dlg.dataD=sqrt(convn(convn(sum(dlg.dataD.^2,3),conn_hanning(3)/2,'same'),conn_hanning(3)'/2,'same')./max(eps,.01*mean(temp(:))+temp));
                    [dlg.dataDmax,dlg.dataDidx]=max(dlg.dataD,[],4);
                    if ishandle(ht),delete(ht); end
                    if ~ishandle(dlg.handles.hfig), return; end
                    dlg.usubjects_shown=unique(dlg.isubjects(in));
                    set(dlg.handles.subjects,'string',dlg.usubjects(dlg.usubjects_shown),'value',unique(max(1,min(numel(dlg.usubjects_shown),get(dlg.handles.subjects,'value')))));
                    dlg.usessions_shown=unique(dlg.isessions(in));
                    set(dlg.handles.sessions,'string',dlg.usessions(dlg.usessions_shown),'value',unique(max(1,min(numel(dlg.usessions_shown),get(dlg.handles.sessions,'value')))));
                    conn_qaplotsexplore_update([],[],'subjects');
                    set(dlg.handles.hfig,'pointer','arrow');
                elseif dlg.uanalysestype(dlg.ianalysis)==2 %QA_DENOISE
                    set([dlg.handles.showdiff dlg.handles.text dlg.handles.textoptions dlg.handles.details],'visible','off'); 
                    set(dlg.handles.showannot,'visible','on');
                    set(dlg.handles.hfig,'pointer','watch');
                    in=find(ismember(dlg.ianalyses,dlg.ianalysis));% & ismember(dlg.isubjects, dlg.isubject) & ismember(dlg.isessions, dlg.isession);
                    ht=conn_msgbox(sprintf('Loading %d plots. Please wait...',numel(in)),'');
                    dlg.dataA={};
                    %dlg.dataB={};
                    dlg.dataIDXplots=in;
                    for n=1:numel(in),
                        data=load(fullfile(qafolder,dlg.sets{dlg.iset},dlg.files{in(n)}));
                        dlg.dataA{n}=data.results_patch;
                        %dlg.dataB{n}=data.results_label;
                        descr = fileread(fullfile(qafolder,dlg.sets{dlg.iset},dlg.files_txt{in(n)}));
                        if isempty(descr), dlg.txtA{n}={'[empty]'}; 
                        else dlg.txtA{n}=regexp(descr,'\n+','split');
                        end
                    end
                    maxy2=0;maxy3=0;
                    for n=1:numel(dlg.dataA), maxy2=max(maxy2,max(dlg.dataA{n}{2})); maxy3=max(maxy3,max(dlg.dataA{n}{3})); end
                    dlg.plothistinfo=[0 maxy2*1.1 (maxy2+maxy3)*1.1 max(maxy2,maxy3)];
                    if ishandle(ht),delete(ht); end
                    if ~ishandle(dlg.handles.hfig), return; end
                    dlg.usubjects_shown=unique(dlg.isubjects(in));
                    set(dlg.handles.subjects,'string',dlg.usubjects(dlg.usubjects_shown),'value',unique(max(1,min(numel(dlg.usubjects_shown),get(dlg.handles.subjects,'value')))));
                    dlg.usessions_shown=unique(dlg.isessions(in));
                    set(dlg.handles.sessions,'string',dlg.usessions(dlg.usessions_shown),'value',unique(max(1,min(numel(dlg.usessions_shown),get(dlg.handles.sessions,'value')))));
                    conn_qaplotsexplore_update([],[],'subjects');
                    set(dlg.handles.hfig,'pointer','arrow');
                end
                
            case {'subjects','sessions','selectannotation','refresh'}
                if isempty(dlg.sets)||isempty(dlg.uanalyses), return; end
                if isempty(dlg.usubjects_shown)||isempty(dlg.usessions_shown), 
                        delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                        delete(dlg.handles.han(ishandle(dlg.handles.han)));
                        set([dlg.handles.text dlg.handles.textoptions dlg.handles.details],'visible','off');
                    return; 
                end
                if strcmp(lower(option),'selectannotation')
                   n=get(dlg.handles.han(end),'value');
                   subjects=dlg.isubjects(dlg.dataIDXplots(dlg.dataIDXsubjects(n)));
                   sessions=dlg.isessions(dlg.dataIDXplots(dlg.dataIDXsubjects(n)));
                   set(dlg.handles.subjects,'value',find(dlg.usubjects_shown==subjects));
                   set(dlg.handles.sessions,'value',find(dlg.usessions_shown==sessions));
                 else
                    subjects=get(dlg.handles.subjects,'value');
                    sessions=get(dlg.handles.sessions,'value');
                    if isempty(subjects)||any(subjects>numel(dlg.usubjects_shown)), subjects=1:numel(dlg.usubjects_shown); set(dlg.handles.subjects,'value',subjects); end
                    if isempty(sessions)||any(sessions>numel(dlg.usessions_shown)), sessions=1:numel(dlg.usessions_shown); set(dlg.handles.sessions,'value',sessions); end
                    subjects=dlg.usubjects_shown(subjects);
                    sessions=dlg.usessions_shown(sessions);
                end
                in=find(ismember(dlg.isubjects(dlg.dataIDXplots),subjects)&ismember(dlg.isessions(dlg.dataIDXplots),sessions));
                dlg.dataIDXsubjects=in;
                switch(dlg.uanalysestype(dlg.ianalysis))
                    case 1,
                        if numel(in)>1, set(dlg.handles.text,'string','computing. please wait...','visible','on');set(dlg.handles.textoptions,'visible','off');drawnow; end
                        showdiff=get(dlg.handles.showdiff,'value');
                        val=(numel(in)>1)*dlg.showavg + (numel(in)<=1);
                        delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                        pos=[.20 .10 .75 .70]; 
                        if get(dlg.handles.showannot,'value'), pos=[pos(1)+.225 pos(2) pos(3)-.20 pos(4)]; end
                        dlg.handles.hax=axes('units','norm','position',pos,'visible','off','parent',dlg.handles.hfig);
                        switch(val)
                            case {1,2,3},
                                if showdiff, data=dlg.dataD;
                                else data=dlg.dataA;
                                end
                                if val==1,
                                    if ~showdiff&&isequal(in(:)',1:size(data,4)), data=dlg.dataM;
                                    else data=mean(data(:,:,:,in),4);
                                    end
                                    dlg.dispsize=[size(data,2) size(data,1)];
                                elseif val==2,
                                    if ~showdiff&&isequal(in(:)',1:size(data,4)), data=dlg.dataS;
                                    else data=std(data(:,:,:,in),1,4);
                                    end
                                    data=sqrt(sum(data.^2,3));
                                    data=data/max(data(:));
                                    dlg.dispsize=[size(data,2) size(data,1)];
                                elseif val==3,
                                    data=data(:,:,:,in);
                                end
                                [data,dlg.dispsize]=conn_menu_montage(dlg.handles.hax,data);
                                cla(dlg.handles.hax); him=imagesc(data,'parent',dlg.handles.hax);
                                axis(dlg.handles.hax,'equal');
                                set(dlg.handles.hax,'ydir','reverse','visible','off');
                                %if numel(in)==1, set(him,'buttondownfcn',{@conn_qaplotsexplore_update,'details'} ); 
                                %else set(him,'buttondownfcn','disp(''select individual subject/session first'')'); 
                                %end
                            case 4, % placeholder
                                data=reshape(dlg.dataD(:,:,:,in),[],numel(in));
                                cla(dlg.handles.hax);
                                for n=1:size(data,2),
                                    [b,a]=hist(log10(data(data(:,n)>0,n)),linspace(-3,1,100));
                                    plot(a,b,'parent',dlg.handles.hax);
                                    hold(dlg.handles.hax,'on');
                                end
                                hold(dlg.handles.hax,'off');
                        end
                        if numel(in)==1,
                            if showdiff, str='z-map of '; else str=''; end
                            set(dlg.handles.text,'string',[str,dlg.files_jpg{dlg.dataIDXplots(in)}],'visible','on');
                            set(dlg.handles.textoptions,'visible','off');
                            dlg.filethis=dlg.files{dlg.dataIDXplots(in)};
                            set([dlg.handles.details],'visible','on');
                            %if conn_existfile(fullfile(qafolder,dlg.sets{dlg.iset},conn_prepend('',dlg.filethis,'.mat'))), set(dlg.handles.details,'visible','on'); else set(dlg.handles.details,'visible','on'); end
                        else set(dlg.handles.text,'visible','off');
                            if showdiff, str='z-maps'; else str='images'; end
                            set(dlg.handles.textoptions,'visible','on','value',dlg.showavg,'string',{sprintf('average of %d %s',numel(in),str),sprintf('variability of %d %s',numel(in),str),sprintf('Montage of %d %s',numel(in),str)});
                            set([dlg.handles.details],'visible','off');
                            dlg.filethis='';
                        end
                        
                    case 2
                        delete(dlg.handles.hax(ishandle(dlg.handles.hax)));
                        pos=[.20 .15 .75 .65]; 
                        if get(dlg.handles.showannot,'value'), pos=[pos(1)+.225 pos(2) pos(3)-.20 pos(4)]; end
                        dlg.handles.hax=axes('units','norm','position',pos,'visible','off','parent',dlg.handles.hfig);
                        dlg.results_patch=dlg.dataA(in); %%%
                        %dlg.results_label=dlg.dataB(in);
                        dlg.handles.resultspatch=[];
                        for n=1:numel(dlg.results_patch),
                            dlg.handles.resultspatch(n,1)=patch(dlg.results_patch{n}{1},dlg.results_patch{n}{3}+dlg.plothistinfo(2),'k','edgecolor','k','linestyle',':','facecolor',.9*[1 1 .8],'facealpha',.25,'parent',dlg.handles.hax); % title('Connectivity histogram before denoising'); xlabel('Correlation (r)');
                            dlg.handles.resultspatch(n,2)=patch(dlg.results_patch{n}{1},dlg.results_patch{n}{2},'k','edgecolor','k','linestyle',':','facecolor',.9*[1 1 .8],'facealpha',.25); %title('Connectivity histogram after denoising'); xlabel('Correlation (r)');
                            %disp(results_str{n});
                        end
                        dlg.handles.resultspatch_add=[patch(dlg.results_patch{n}{1},dlg.results_patch{n}{2},'k','edgecolor','k','linestyle',':','facecolor','k','facealpha',.25','visible','off'),...
                            patch(dlg.results_patch{n}{1},dlg.results_patch{n}{2},'k','edgecolor','k','linestyle',':','facecolor','k','facealpha',.25,'visible','off')];
                        hold(dlg.handles.hax,'on');
                        %plot([-1 1;-1 1],[ylim;ylim]','k-',[-1 -1;1 1],[ylim;ylim],'k-');
                        text(0,-dlg.plothistinfo(3)*.1,'Correlation coefficients (r)','horizontalalignment','center','fontsize',12+font_offset);
                        text(-.95,dlg.plothistinfo(2)*.25,'Histogram after denoising','horizontalalignment','left','fontsize',10+font_offset,'fontweight','bold');
                        text(-.95,dlg.plothistinfo(2)+(dlg.plothistinfo(3)-dlg.plothistinfo(2))*.25,'Histogram before denoising','horizontalalignment','left','fontsize',10+font_offset,'fontweight','bold');
                        hold(dlg.handles.hax,'off');
                        set(dlg.handles.hax,'xlim',[-1,1],'ytick',[],'ycolor','w','ylim',dlg.plothistinfo([1 3]),'ydir','normal','visible','on');
                end
                if get(dlg.handles.showannot,'value')
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                    %idx=find(cellfun('length',dlg.txtA(in))>0);
                    if numel(in)==1
                        dlg.handles.han=[uicontrol('style','text','units','norm','position',[.20 .75 .20 .05],'string','annotations','horizontalalignment','center','backgroundcolor',.995*[1 1 1],'foregroundcolor','k'),...
                            uicontrol('style','edit','units','norm','position',[.20 .10 .20 .65],'max',2,'string',dlg.txtA{in},'horizontalalignment','left','backgroundcolor',.995*[1 1 1],'foregroundcolor','k','callback',{@conn_qaplotsexplore_update,'annotate'})];
                    elseif numel(in)>1
                        txt=arrayfun(@(n)sprintf('%s %s: %s',dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(n))},dlg.usessions{dlg.isessions(dlg.dataIDXplots(n))},sprintf('%s ',dlg.txtA{n}{:})),in,'uni',0);
                        dlg.handles.han=[uicontrol('style','text','units','norm','position',[.20 .75 .20 .05],'string','annotations','horizontalalignment','center','backgroundcolor',.995*[1 1 1],'foregroundcolor','k'),...
                                         uicontrol('style','listbox','units','norm','position',[.20 .10 .20 .65],'max',1,'string',txt,'horizontalalignment','left','backgroundcolor',.995*[1 1 1],'foregroundcolor','k','callback',{@conn_qaplotsexplore_update,'selectannotation'},'interruptible','off')];
                    end
                else
                    delete(dlg.handles.han(ishandle(dlg.handles.han)));
                end
                drawnow;

        end
    end

    function conn_qaplotsexplore_figuremousemove(varargin)
        try
            p1=get(0,'pointerlocation');
            p2=get(dlg.handles.hfig,'position');
            p3=get(0,'screensize');
            p4=p2(1:2)+p3(1:2)-1; % note: fix issue when connecting to external monitor/projector
            pos0=(p1-p4);
            set(dlg.handles.hfig,'currentpoint',pos0);
            pos=(get(dlg.handles.hax,'currentpoint')); 
            pos=pos(1,1:3);
            switch(dlg.uanalysestype(dlg.ianalysis))
                case 1, % QA_NORM/QA_REG            
                    pos=round(pos);
                    set(dlg.handles.hax,'units','pixels');posax=get(dlg.handles.hax,'position');set(dlg.handles.hax,'units','norm');
                    nX=dlg.dispsize;
                    if numel(nX)<5, return; end
                    txyz=conn_menu_montage('coords2xyz',nX,pos(1:2)');
                    if txyz(3)>=1&&txyz(3)<=nX(end)&&txyz(1)>=1&&pos(1)<=nX(3)*nX(1)&&pos(2)>=1&&pos(2)<=nX(4)*nX(2)
                        f1=dlg.dataDidx(txyz(2),txyz(1));
                        f2=dlg.dataDmax(txyz(2),txyz(1));
                        if f2>0||nX(end)>1,
                            tlabel={};
                            if nX(end)>1, tlabel=[{[dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(dlg.dataIDXsubjects(txyz(3))))},' ',dlg.usessions{dlg.isessions(dlg.dataIDXplots(dlg.dataIDXsubjects(txyz(3))))}],' '},tlabel];
                            elseif f2>0, tlabel=[tlabel {'Most different from average at this location:',sprintf('%s %s (diff z=%.2f)',dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(f1))},dlg.usessions{dlg.isessions(dlg.dataIDXplots(f1))},f2)}];
                            end
                            set(dlg.handles.hlabel,'units','pixels','position',[pos0+[10 -10] 20 20],'visible','on','string',tlabel);%,'fontsize',8+4*f2);
                            hext=get(dlg.handles.hlabel,'extent');
                            nlines=ceil(hext(3)/(p2(3)/2));
                            ntlabel=numel(tlabel);
                            newpos=[pos0+[-min(p2(3)/2,hext(3))/2 +10] min(p2(3)/2,hext(3)) nlines*hext(4)]; % text position figure coordinates
                            newpos(1)=max(posax(1),newpos(1)-max(0,newpos(1)+newpos(3)-posax(1)-posax(3)));
                            newpos(2)=max(posax(2),newpos(2)-max(0,newpos(2)+newpos(4)-posax(2)-posax(4)));
                            set(dlg.handles.hlabel,'position',newpos,'string',reshape([tlabel,repmat(' ',1,nlines*ceil(ntlabel/nlines)-ntlabel)]',[],nlines)');
                        else
                            set(dlg.handles.hlabel,'visible','off');
                        end
                    else
                        set(dlg.handles.hlabel,'visible','off');
                    end
                case 2, %QA_DENOISE
                    posb=pos;
                    if pos(2)>=dlg.plothistinfo(2)&&pos(2)<=dlg.plothistinfo(3), posb(2)=posb(2)-dlg.plothistinfo(2); labels=3;
                    elseif pos(2)>=dlg.plothistinfo(1)&&pos(2)<=dlg.plothistinfo(2), labels=2;
                    else pos=[];
                    end
                    if ~isempty(pos)
                        dwin=[];dmin=inf;
                        for n1=1:numel(dlg.results_patch)
                            [d,idx]=min(abs(dlg.results_patch{n1}{1}-posb(1))+abs((dlg.results_patch{n1}{labels}-posb(2))/dlg.plothistinfo(4)));
                            if d<dmin, dmin=d; dwin=n1; dpos=[dlg.results_patch{n1}{1}(idx) dlg.results_patch{n1}{labels}(idx)]; end
                        end
                        if ~isempty(dwin)&&max(abs(dpos-posb(1:2))./[1 dlg.plothistinfo(4)])<.10
                            tlabel=[dlg.usubjects{dlg.isubjects(dlg.dataIDXplots(dlg.dataIDXsubjects(dwin)))},' ',dlg.usessions{dlg.isessions(dlg.dataIDXplots(dlg.dataIDXsubjects(dwin)))}];
                            %tlabel=dlg.results_label{dwin};
                            set(dlg.handles.hlabel,'units','pixels','position',[pos0+[10 -10] 20 20],'visible','on','string',tlabel);
                            hext=get(dlg.handles.hlabel,'extent');
                            nlines=ceil(hext(3)/(p2(3)/2));
                            ntlabel=numel(tlabel);
                            set(dlg.handles.hlabel,'position',[pos0+[-min(p2(3)/2,hext(3))-10 -10] min(p2(3)/2,hext(3)) nlines*hext(4)],'string',reshape([tlabel,repmat(' ',1,nlines*ceil(ntlabel/nlines)-ntlabel)]',[],nlines)');
                            set(dlg.handles.resultspatch_add(1),'xdata',get(dlg.handles.resultspatch(dwin,1),'xdata'),'ydata',get(dlg.handles.resultspatch(dwin,1),'ydata'),'zdata',get(dlg.handles.resultspatch(dwin,1),'zdata'),'visible','on');
                            set(dlg.handles.resultspatch_add(2),'xdata',get(dlg.handles.resultspatch(dwin,2),'xdata'),'ydata',get(dlg.handles.resultspatch(dwin,2),'ydata'),'zdata',get(dlg.handles.resultspatch(dwin,2),'zdata'),'visible','on');
                        else set(dlg.handles.hlabel,'visible','off','string','');
                            set(dlg.handles.resultspatch_add,'visible','of');
                        end
                    else
                        set(dlg.handles.hlabel,'visible','off','string','');
                        set(dlg.handles.resultspatch_add,'visible','of');
                    end
            end
        end
    end
end

