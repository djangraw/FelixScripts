
function h=conn_filesearchtool(varargin)
persistent cwd;
global CONN_gui;
if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
if ~isfield(CONN_gui,'parse_html'), CONN_gui.parse_html={'<HTML><FONT color=rgb(100,100,100)>','</FONT></HTML>'}; end
if ~isfield(CONN_gui,'rightclick'), CONN_gui.rightclick='right'; end
if isempty(cwd), cwd=pwd; end

if nargin<1 || ischar(varargin{1}),
    fields={'position',[.5,.1,.4,.8],...
        'backgroundcolor',.9*[1,1,1],...
        'foregroundcolor',[0,0,0],...
        'title','File search tool',...
        'folder',cwd,...
        'filter','*',...
        'regexp','.',...
        'callback','',...
        'localcopy',[],...
        'max',2};
    params=[];
    for n1=1:2:nargin, params=setfield(params,lower(varargin{n1}),varargin{n1+1}); end
    for n1=1:2:length(fields), if ~isfield(params,fields{n1}) | isempty(getfield(params,fields{n1})), params=setfield(params,fields{n1},fields{n1+1}); end; end;
    M=[params.position(1),params.position(3),0,0,0;params.position(2),0,params.position(4),0,0;0,0,0,params.position(3),0;0,0,0,0,params.position(4)]';
    h.frame=conn_menu('frame2',[1,0,0,1,1]*M);
    %uicontrol('style','frame','units','norm','position',[1,0,0,1,1]*M,'backgroundcolor',params.backgroundcolor);
    %axes('units','norm','position',[1,0,0,1,1]*M,'color',params.backgroundcolor,'xcolor',min(1,1*params.backgroundcolor),'ycolor',min(1,1*params.backgroundcolor),'xtick',[],'ytick',[],'box','on');
    uicontrol('style','text','units','norm','position',[1,.05,.8,.9,.175]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string',params.title,'fontname','default','fontsize',8+CONN_gui.font_offset,'fontweight','bold','horizontalalignment','left');
    %uicontrol('style','text','units','norm','position',[1,.05,.85,.2,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','Folder','fontangle','normal','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
    %uicontrol('style','text','units','norm','position',[1,.05,.15,.2,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','Filter','fontangle','normal','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
    %uicontrol('style','text','units','norm','position',[1,.05,.10,.2,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','Regexp','fontangle','normal','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
    %h.filter=uicontrol('style','edit','units','norm','position',[1,.25,.8,.7,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string',params.filter,'tooltipstring','Select a file name filter (wildcards may be used)','fontsize',8+CONN_gui.font_offset);
    %h.folder=uicontrol('style','edit','units','norm','position',[1,.25,.85,.7,.05]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string',params.folder,'fontname','default','fontsize',8+CONN_gui.font_offset,'tooltipstring','Select the root folder');
    h.selectfile=uicontrol('style','edit','position',[1,.25,.85,.7,.05]*M,'string','','max',2,'visible','off');
    %h.find=uicontrol('style','togglebutton','units','norm','position',[1,.7,.925,.25,.05]*M,'value',0,'string','Find','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center','tooltipstring','Recursively searchs file names matching the filter starting from the current folder');
    %h.files=uicontrol('style','listbox','units','norm','position',[1,.05,.2,.9,.55]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','','max',params.max,'fontname','default','fontsize',8+CONN_gui.font_offset,'tooltipstring','Displays file matches. Double-click a folder for browsing to a different location. Double-click a file to import it to the toolbox');
    h.files=conn_menu('listbox2',[1,.05,.38,.9,.50]*M,'',''); %,'<HTML>Displays file matches<br/> - Double-click a folder for browsing to a different location<br/> - Double-click a file to import it to the toolbox</HTML>');
    set(h.files,'max',params.max);
    h.selected=uicontrol('style','text','units','norm','position',[1,.04,.23,.9,.10]*M,'foregroundcolor',params.foregroundcolor,'backgroundcolor',params.backgroundcolor,'string','','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center');
    %h.select=uicontrol('style','pushbutton','units','norm','position',[1,.7,.14,.25,.05]*M,'string','Select','fontname','default','fontsize',8+CONN_gui.font_offset,'horizontalalignment','center','tooltipstring','Enter selected file(s) or open selected folder','callback',{@conn_filesearchtool,'files',true});
    h.select=conn_menu('pushbuttonblue2',[1,.05,.33,.45,.05]*M,'','Select','Imports selected file(s) or open selected folder',{@conn_filesearchtool,'files',true});
    set(h.select,'fontsize',10+CONN_gui.font_offset);
    h.find=conn_menu('pushbutton2',[1,.50,.33,.45,.05]*M,'','Find','Recursively searchs file names matching the filter starting from the current folder');
    set(h.find,'value',0,'fontsize',10+CONN_gui.font_offset);
    h.find_state=0;
    h.folder=conn_menu('edit2',[1,.05,.175,.9,.05]*M,'',params.folder,'<HTML>Current folder<br/> - Type a full path to change to a different folder</HTML>');
    %set(h.folder,'visible','off');
    str=conn_filesearch_breakfolder(params.folder);
    h.folderpopup=conn_menu('popup2',[1,.05,.88,.9,.04]*M,'',regexprep(str,'(.+)[\/\\]$','$1'),'<HTML>Current folder<br/> - Select to change to a different location in current directory tree</HTML>');
    set(h.folderpopup,'value',numel(str));
    h.filter=conn_menu('edit2',[1,.05,.125,.9,.05]*M,'',params.filter,'<HTML>File name filter (standard format)<br/> - Show only files with names matching any of these patterns<br/> - Use ";" to separate multiple filters</HTML>');
    h.regexp=conn_menu('edit2',[1,.05,.075,.9,.05]*M,'',params.regexp,'<HTML>Additional full-path filename filter (regexp format)<br/> - Show only files with full-path filename matching this pattern<br/> - See <i>help regexp</i> for additional information');
    if ~isempty(params.localcopy),  h.localcopy=conn_menu('popup2',[1,.05,.025,.9,.05]*M,'',{'import selected files','copy first to local BIDS folder'},'<HTML>Controls behavior of ''Select'' button:<br/> - <i>import selected files</i> : (default) selected files will be imported into your CONN project directly from their original locations/folders<br/> - <i>copy first to local BIDS folder</i> : selected files will be first copied to your local conn_*/data/BIDS folder and then imported into your CONN project <br/>(e.g. use this when importing data from read-only folders if the files need to be further modified or processed)</HTML>'); set(h.localcopy,'value',params.localcopy);
    else h.localcopy=[];
    end
    h.selectspm=conn_menu('pushbutton2',[1,.7,.94,.29,.05]*M,'','ALTselect','<HTML>Alternative GUIs for file selection (OS-specific, spm_select GUI, select data from this or other CONN projects, etc.)</HTML>');
%     hc1=uicontextmenu;
%     h.selectspmalt0=uimenu(hc1,'Label','<HTML>Use OS gui to select individual file(s)</HTML>');%,'callback',{@conn_filesearchtool,'selectspmalt2'});
%     h.selectspmalt1=uimenu(hc1,'Label','<HTML>Use SPM gui to select individual file(s) (disregards filter field)</HTML>');%,'callback',{@conn_filesearchtool,'selectspmalt2'});
%     h.selectspmalt2=uimenu(hc1,'Label','<HTML>Use SPM gui to select individual volume(s) from 4d nifti files</HTML>');%,'callback',{@conn_filesearchtool,'selectspmalt2'});
%     h.selectspmalt3=uimenu(hc1,'Label','<HTML>Select file(s) already entered in this or a different CONN project</HTML>');%,'callback',{@conn_filesearchtool,'selectspmalt2'});
%     set(h.selectspm,'uicontextmenu',hc1);
    h.callback=params.callback;
    set([h.files,h.find,h.folder,h.folderpopup,h.filter,h.regexp,h.localcopy,h.select,h.selectspm],'userdata',h);
    names={'files','find','selectspm'}; for n1=1:length(names), set(h.(names{n1}),'callback',{@conn_filesearchtool,names{n1}}); end
    names={'folder','folderpopup','filter','regexp'}; for n1=1:length(names), set(h.(names{n1}),'callback',{@conn_filesearchtool,names{n1},true}); end
    set([h.find h.select h.selectspm h.filter h.regexp h.localcopy h.folder],'visible','off');
    conn_menumanager('onregion',[h.find h.select h.selectspm h.filter h.regexp h.localcopy h.folder],1,params.position,h.files);
    conn_filesearchtool(h.folder,[],'folder',true);
else,
    h=get(varargin{1},'userdata');
    set(h.selected,'string','');
    doubleclick=nargin>3|strcmp(get(gcbf,'SelectionType'),'open');
    if strcmp(varargin{3},'selectspm'),
        opts={'Use SPM gui to select individual file(s)',...
            'Use SPM gui to select individual volume(s) from 4d nifti files',...
            'Use OS gui to select individual file(s)',...
            'Select file(s) entered in this or a different CONN project'};
        optsnames={'selectspmalt','selectspmalt2','selectspmalt0','selectspmalt3'};
        answ=conn_questdlg('','select files',opts{:},opts{1});
        if isempty(answ), return; end
        [nill,idx]=ismember(answ,opts);
        varargin{3}=optsnames{idx};
    end
    switch(varargin{3}),
        case {'selectspmalt','selectspmalt1','selectspmalt2','selectspmalt3','selectspmalt0'}
            if strcmp(varargin{3},'selectspmalt'), 
                regfilter=regexprep(get(h.filter,'string'),{'\s*',';([^;]+)',';','\.','*','([^\$])$'},{'','\$|$1','','\\.','.*','$1\$'});
                names=spm_select(inf,regfilter,[],[],get(h.folder,'string'));
            elseif strcmp(varargin{3},'selectspmalt1'), 
                names=spm_select(inf,'any',[],[],get(h.folder,'string'));
            elseif strcmp(varargin{3},'selectspmalt2'), 
                names=spm_select(inf,'image',[],[],get(h.folder,'string'));
            elseif strcmp(varargin{3},'selectspmalt3'), 
                names=conn_filesearch_selectconn(get(h.filter,'string'));
            elseif strcmp(varargin{3},'selectspmalt0'), 
                filter=regexp(get(h.filter,'string'),';','split');
                [tname,tpath]=uigetfile(filter','Select file(s)',get(h.folder,'string'),'multiselect','on');
                if isequal(tname,0), return; end
                tname=cellstr(tname);
                names=char(cellfun(@(x)fullfile(tpath,x),tname,'uni',0));
            end
            if ~isempty(names)
                if iscell(h.callback),
                    if length(h.callback)>1, feval(h.callback{1},h.callback{2:end},names); else, feval(h.callback{1},names); end
                else, feval(h.callback,names); end
            end
        case {'folder','folderpopup','filter','regexp','files'},
            parse={[regexprep(CONN_gui.parse_html{1},'<FONT color=rgb\(\d+,\d+,\d+\)>','<FONT color=rgb(150,100,100)><i>'),'-'],regexprep(CONN_gui.parse_html{2},'<\/FONT>','</FONT></i>')};
            pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
            if strcmp(pathname,'.')||strncmp(pathname,['.' filesep],2), pathname=conn_fullfile(pwd,pathname(3:end)); end
            if ~isdir(pathname), pathname=cwd; end
            if strcmp(varargin{3},'folderpopup')
                str=conn_filesearch_breakfolder(pathname);
                set(h.folder,'string',[str{1:get(h.folderpopup,'value')}]);
                pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
            end
            cwd=pathname;
            if strcmp(varargin{3},'files'),
				%disp(get(h.files,'value'))
                filename=get(h.files,'string');
                filename=filename(get(h.files,'value'),:);
                if isempty(filename), return; end
                filename=fliplr(deblank(fliplr(deblank(filename(1,:)))));
                if strncmp(filename,parse{1},numel(parse{1})), filename=fliplr(deblank(fliplr(deblank(filename(numel(parse{1})+1:end-numel(parse{2})))))); end
                if strcmp(filename,'..'),
                    idx=find(pathname==filesep); idx(idx==length(pathname))=[];
                    if ~isempty(idx), pathname=pathname(1:idx(end)); else return; end
                else
                    pathname=fullfile(pathname,filename);
                end
            end
            isdirectory=(isdir(pathname) || isempty(dir(pathname)));
            if isdirectory&&doubleclick,
                results={[parse{1},'   ..',parse{2}]}; 
                names=dir(pathname);
                for n1=1:length(names), if names(n1).isdir&&~strcmp(names(n1).name,'.')&&~strcmp(names(n1).name,'..'), results{end+1}=[parse{1},'   ',names(n1).name,parse{2}]; end; end
                filter=get(h.filter,'string');
                filter2=get(h.regexp,'string');
                if isempty(filter), filter='*'; end
                if isempty(filter2), filter2='.'; end
                [filternow,filter]=strtok(filter,';');
                while ~isempty(filternow),
                    filename=fullfile(pathname,fliplr(deblank(fliplr(deblank(filternow)))));
                    names=dir(filename);
                    for n1=1:length(names), 
                        if ~names(n1).isdir&&~isempty(regexp(names(n1).name,filter2)), results{end+1}=names(n1).name; end; 
                    end
                    [filternow,filter]=strtok(filter,';');
                end
                idx=[];
                selectfile=get(h.selectfile,'string');
                if ~isempty(selectfile), idx=find(ismember(results,selectfile)); end
                if isempty(idx), idx=1; end
                idx=unique(max(1,min(numel(results),idx)));
                set(h.files,'string',char(results),'value',idx,'listboxtop',1);
                set(h.folder,'string',pathname); %fullfile(pathname,filesep));
                str=conn_filesearch_breakfolder(pathname);
                set(h.folderpopup,'string',regexprep(str,'(.+)[\/\\]$','$1'),'value',numel(str));
                set(h.selectfile,'string','');
                cwd=pathname; %fullfile(pathname,filesep);
            elseif ~isdirectory&&~isempty(h.callback)&&doubleclick, 
                idx=get(h.files,'value');
                names=get(h.files,'string');
                if ~isempty(idx) & size(names,1)>=max(idx),
                    names=names(idx,:);
                    pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
                    if isempty(pathname)||pathname(end)~=filesep, pathname=[pathname,filesep]; end
                    names=[repmat(pathname,[size(names,1),1]),names];
                    if iscell(h.callback),
                        if length(h.callback)>1, feval(h.callback{1},h.callback{2:end},names); else, feval(h.callback{1},names); end
                    else, feval(h.callback,names); end
                end
            elseif ~doubleclick&&~isdirectory, 
                idx=get(h.files,'value');
                names=get(h.files,'string');
                strselected=sprintf('%d files selected',numel(idx)); 
                if ~isempty(idx) & size(names,1)>=max(idx),
                    names=names(idx,:);
                    pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
                    if isempty(pathname)||pathname(end)~=filesep, pathname=[pathname,filesep]; end
                    names=[repmat(pathname,[size(names,1),1]),names];
                    try
                        if size(names,1)>4,
                            strselected={sprintf('[%d files]',size(names,1))};
                            strselected{end+1}=['First: ',deblank(names(1,:))]; strselected{end+1}=['Last : ',deblank(names(end,:))];
                            for n1=1:length(strselected), if length(strselected{n1})>25+9, strselected{n1}=[strselected{n1}(1:4),' ... ',strselected{n1}(end-25+1:end)]; end; end; 
                        else
                            temp=conn_file(names,false);
                            if ~isempty(temp{3}), strselected=temp{2};
                            elseif ~isempty(temp{2}), strselected=temp{2};
                            else, strselected='unrecognized format';
                            end
                        end
                    catch
                        strselected='unrecognized format';
                    end
                end
                set(h.selected,'string',strselected);
            end
        case {'find'}
            state=xor(1,h.find_state);%get(h.find,'value');
            h.find_state=state;
            set(h.find,'userdata',h);
            if state,
                results=get(h.files,'string');
                results=results(find(results(:,1)=='<'),:);
                resultsnew=[];
                set(h.find,'string','Cancel');
                pathname=fliplr(deblank(fliplr(deblank(get(h.folder,'string')))));
                filter=get(h.filter,'string');
                filter2=get(h.regexp,'string');
                if strcmp(filter2,'.'), filter2=''; end
                set(h.files,'string',resultsnew,'value',1);
                dirtree(pathname,filter,filter2,h,length(pathname));
                resultsnew=get(h.files,'string');
                set(h.files,'string',strvcat(results,resultsnew));
                h.find_state=0;
                set(h.find,'value',0,'string','Find','userdata',h);                
            else
                set(h.find,'value',0,'string','Find');
            end
    end
end
end

function dirtree(pathname,filter,filter2,h,L)
persistent dcharcount
if isempty(dcharcount), dcharcount=0; end

if ~get(h.find,'value'), return; end
dchar=' ...    ';
filterrest=filter;
[filternow,filterrest]=strtok(filterrest,';');
txt1=get(h.files,'string');
txt={};
while ~isempty(filternow),
    if size(txt1,1)>1e5, % Change this value to increase the maximum number of files displayed
        txt=strvcat(txt1,txt{:});
        set(h.files,'string',txt,'value',1);
        set(h.selected,'string',sprintf('(%d files found) %s',size(txt,1),dchar(ones(1,8))));
        return;
    end
    filename=fullfile(pathname,fliplr(deblank(fliplr(deblank(filternow)))));
    dir0=dir(filename);
    [names,idx]=sortrows(strvcat(dir0(:).name));
    for n1=1:length(dir0),
        if ~dir0(idx(n1)).isdir
            tfilename=fullfile(pathname(L+1:end),dir0(idx(n1)).name);
            if isempty(filter2)||~isempty(regexp(tfilename,filter2)), txt{end+1}=tfilename; end
        end
    end
    [filternow,filterrest]=strtok(filterrest,';');
end
txt=strvcat(txt1,txt{:});
set(h.files,'string',txt);
set(h.selected,'string',sprintf('(%d files found) %s',size(txt,1),dchar(mod(dcharcount+(1:8),length(dchar))+1)));
dcharcount=rem(dcharcount-1,8);
drawnow;
set(h.selected,'string',sprintf('(%d files found) %s',size(txt,1),dchar(ones(1,8))));
dir0=dir(pathname);
[names,idx]=sortrows(strvcat(dir0(:).name));
for n1=1:length(dir0),
    if dir0(idx(n1)).isdir && ~strcmp(dir0(idx(n1)).name,'.') && ~strcmp(dir0(idx(n1)).name,'..'),
        dirtree(fullfile(pathname,dir0(idx(n1)).name),filter,filter2,h,L);
    end
end
end

function str=conn_filesearch_breakfolder(pathname)
idx=find(pathname==filesep);
str=mat2cell(pathname,1,diff([0 idx(:)' numel(pathname)]));
% str={pathname};
% pbak='';
% while ~isempty(pathname)
%     [pathname,temp]=fileparts(pathname);
%     if isequal(pbak,pathname), str{end+1}=pathname; break; end
%     str{end+1}=pathname;
%     pbak=pathname;
% end
str=str(cellfun('length',str)>0);
end

function names=conn_filesearch_selectconn(varargin)
global CONN_x CONN_gui;
if isfield(CONN_gui,'font_offset'),font_offset=CONN_gui.font_offset; else font_offset=0; end
opt0_vals=[];
if nargin>=1&&ischar(varargin{1}), 
    [ok,iok]=ismember(varargin{1},{'*.img; *.nii; *.mgh; *.mgz; *.gz','*.img; *.nii; *.gz','*.img; *.nii; *.tal; *.mgh; *.mgz; *.annot; *.gz','*.mat; *.txt; *.par'});
    if ok, opt0_vals=iok; end
end
names={};
a.CONN_x=CONN_x;
dlg.fig=figure('units','norm','position',[.4,.3,.2,.4],'menubar','none','numbertitle','off','name','Select data from CONN project','color','w');
dlg.m0=uicontrol('style','popupmenu','units','norm','position',[.1,.90,.8,.05],'string',{'From current CONN project','From other CONN project'},'callback',@conn_filesearch_selectconn_select,'fontsize',9+font_offset);
dlg.m1=uicontrol('style','popupmenu','units','norm','position',[.1,.825,.8,.05],'string',{'Structural','Functional','ROIs','Covariates'},'callback',@conn_filesearch_selectconn_update,'fontsize',9+font_offset);
dlg.m2=uicontrol('style','popupmenu','units','norm','position',[.1,.75,.8,.05],'string',a.CONN_x.Setup.rois.names(1:end-1),'callback',@conn_filesearch_selectconn_update,'fontsize',9+font_offset,'visible','off');
dlg.m3=uicontrol('style','popupmenu','units','norm','position',[.1,.75,.8,.05],'string',a.CONN_x.Setup.l1covariates.names(1:end-1),'callback',@conn_filesearch_selectconn_update,'fontsize',9+font_offset,'visible','off');
dlg.m9=uicontrol('style','popupmenu','units','norm','position',[.1,.75,.8,.05],'string',arrayfun(@(n)sprintf('dataset %d',n),0:numel(a.CONN_x.Setup.roifunctional),'uni',0),'callback',@conn_filesearch_selectconn_update,'fontsize',9+font_offset,'visible','off');
dlg.m4=uicontrol('style','checkbox','units','norm','position',[.1,.65,.4,.05],'value',1,'string','All subjects','backgroundcolor','w','callback',@conn_filesearch_selectconn_update,'fontsize',9+font_offset);
dlg.m5=uicontrol('style','listbox','units','norm','position',[.1,.3,.4,.35],'max',2,'string',arrayfun(@(n)sprintf('Subject%d',n),1:a.CONN_x.Setup.nsubjects,'uni',0),'backgroundcolor','w','tooltipstring','Select subjects','visible','off','callback',@conn_filesearch_selectconn_update,'fontsize',9+font_offset);
dlg.m6=uicontrol('style','checkbox','units','norm','position',[.5,.65,.8,.05],'value',1,'string','All sessions','backgroundcolor','w','callback',@conn_filesearch_selectconn_update,'fontsize',9+font_offset);
dlg.m7=uicontrol('style','listbox','units','norm','position',[.5,.3,.4,.35],'max',2,'string',arrayfun(@(n)sprintf('Session%d',n),1:max(a.CONN_x.Setup.nsessions),'uni',0),'backgroundcolor','w','tooltipstring','Select subjects','visible','off','callback',@conn_filesearch_selectconn_update,'fontsize',9+font_offset);
dlg.m8=uicontrol('style','text','units','norm','position',[.1,.20,.8,.05],'string','','horizontalalignment','center','fontsize',9+font_offset);
dlg.m11=uicontrol('style','pushbutton','units','norm','position',[.55,.04,.2,.1],'string','Select','callback','uiresume(gcbf)','fontsize',9+font_offset);
dlg.m12=uicontrol('style','pushbutton','units','norm','position',[.75,.04,.2,.1],'string','Cancel','callback','delete(gcbf)','fontsize',9+font_offset);
if ~isempty(opt0_vals), set(dlg.m1,'value',opt0_vals); end
conn_filesearch_selectconn_update;
uiwait(dlg.fig);
if ~ishandle(dlg.fig), return; end

opt0=get(dlg.m1,'value');
if get(dlg.m4,'value'), nsubs=1:a.CONN_x.Setup.nsubjects; set(dlg.m5,'visible','off'); else set(dlg.m5,'visible','on'); nsubs=get(dlg.m5,'value'); end
if get(dlg.m6,'value'), nsessall=1:max(a.CONN_x.Setup.nsessions); set(dlg.m7,'visible','off'); else set(dlg.m7,'visible','on'); nsessall=get(dlg.m7,'value'); end
nsessmax=a.CONN_x.Setup.nsessions(min(length(a.CONN_x.Setup.nsessions),nsubs));
nfields=sum(sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)')));
nroi=get(dlg.m2,'value');
ncov=get(dlg.m3,'value');
nset=get(dlg.m9,'value')-1;
delete(dlg.fig);
switch(opt0)
    case 1,
        n0=0;
        if ~a.CONN_x.Setup.structural_sessionspecific, nsess=1;
        else nsess=nsessall;
        end
        for n1=1:length(nsubs),
            nsub=nsubs(n1);
            for nses=intersect(nsess,1:nsessmax(n1))
                n0=n0+1;
                names{n0}=a.CONN_x.Setup.structural{nsub}{nses}{1};
            end
        end
    case 2,
        n0=0;
        for n1=1:length(nsubs),
            nsub=nsubs(n1);
            for nses=intersect(nsessall,1:nsessmax(n1))
                n0=n0+1;
                Vsource=a.CONN_x.Setup.functional{nsub}{nses}{1};
                if nset
                    try
                        if a.CONN_x.Setup.roifunctional(nset).roiextract==4
                            VsourceUnsmoothed=cellstr(a.CONN_x.Setup.roifunctional(nset).roiextract_functional{nsub}{nses}{1});
                        else
                            Vsource1=cellstr(Vsource);
                            VsourceUnsmoothed=conn_rulebasedfilename(Vsource1,a.CONN_x.Setup.roifunctional(nset).roiextract,a.CONN_x.Setup.roifunctional(nset).roiextract_rule);
                        end
                        existunsmoothed=conn_existfile(VsourceUnsmoothed); %existunsmoothed=cellfun(@conn_existfile,VsourceUnsmoothed);
                        if ~all(existunsmoothed),
                            fprintf('warning: set-%d data for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nset,nsub,nses);
                        else
                            Vsource=char(VsourceUnsmoothed);
                        end
                    catch
                        fprintf('warning: error in CONN_x.Setup.roiextract for subject %d session %d not found. Using set-0 functional data instead for ROI extraction\n',nsub,nses);
                    end
                end
                names{n0}=Vsource; %a.CONN_x.Setup.functional{nsub}{nses}{1};
            end
        end
    case 3,
        n0=0;
        if nroi<=3, subjectspecific=1; sessionspecific=a.CONN_x.Setup.structural_sessionspecific;
        else subjectspecific=a.CONN_x.Setup.rois.subjectspecific(nroi); sessionspecific=a.CONN_x.Setup.rois.sessionspecific(nroi);
        end
        if ~subjectspecific, nsubs=1; end
        if ~sessionspecific, nsess=1;
        else nsess=nsessall;
        end
        for n1=1:length(nsubs),
            nsub=nsubs(n1);
            for nses=intersect(nsess,1:nsessmax(n1))
                n0=n0+1;
                names{n0}=a.CONN_x.Setup.rois.files{nsub}{nroi}{nses}{1};
            end
        end
    case 4,
        n0=0;
        for n1=1:length(nsubs),
            nsub=nsubs(n1);
            for nses=intersect(nsessall,1:nsessmax(n1))
                n0=n0+1;
                names{n0}=a.CONN_x.Setup.l1covariates.files{nsub}{ncov}{nses}{1};
            end
        end
end

    function conn_filesearch_selectconn_select(varargin)
        if get(dlg.m0,'value')==1, a.CONN_x=CONN_x;
        else
            [filename,pathname]=uigetfile({'*.mat','conn-project files (conn_*.mat)';'*','All Files (*)'},'Select CONN project','conn_*.mat');
            if ischar(filename), a=load(fullfile(pathname,filename),'CONN_x'); end
        end
        set(dlg.m2,'string',a.CONN_x.Setup.rois.names(1:end-1),'value',min(numel(a.CONN_x.Setup.rois.names)-1,get(dlg.m2,'value')));
        set(dlg.m3,'string',a.CONN_x.Setup.l1covariates.names(1:end-1),'value',min(numel(a.CONN_x.Setup.l1covariates.names)-1,get(dlg.m3,'value')));
        set(dlg.m9,'string',arrayfun(@(n)sprintf('dataset %d',n),0:numel(a.CONN_x.Setup.roifunctional),'uni',0),'value',min(numel(numel(a.CONN_x.Setup.roifunctional))+1,get(dlg.m9,'value')));
        set(dlg.m5,'string',arrayfun(@(n)sprintf('Subject%d',n),1:a.CONN_x.Setup.nsubjects,'uni',0),'value',unique(min(a.CONN_x.Setup.nsubjects,get(dlg.m5,'value'))));
        set(dlg.m7,'string',arrayfun(@(n)sprintf('Session%d',n),1:max(a.CONN_x.Setup.nsessions),'uni',0),'value',unique(min(max(a.CONN_x.Setup.nsessions),get(dlg.m7,'value'))));
        conn_filesearch_selectconn_update;
    end

    function names=conn_filesearch_selectconn_update(varargin)
        opt0=get(dlg.m1,'value');
        if opt0==2, set([dlg.m9],'visible','on');
        else set([dlg.m9],'visible','off');
        end
        if opt0<=2, set([dlg.m2 dlg.m3],'visible','off');
        elseif opt0==3, set(dlg.m2,'visible','on');set(dlg.m3,'visible','off');
        elseif opt0==4, set(dlg.m2,'visible','off');set(dlg.m3,'visible','on');
        end
        if get(dlg.m4,'value'), nsubs=1:a.CONN_x.Setup.nsubjects; set(dlg.m5,'visible','off'); else set(dlg.m5,'visible','on'); nsubs=get(dlg.m5,'value'); end
        if get(dlg.m6,'value'), nsessall=1:max(a.CONN_x.Setup.nsessions); set(dlg.m7,'visible','off'); else set(dlg.m7,'visible','on'); nsessall=get(dlg.m7,'value'); end
        
        nsessmax=a.CONN_x.Setup.nsessions(min(length(a.CONN_x.Setup.nsessions),nsubs));
        nfields=sum(sum(conn_bsxfun(@le,nsessall(:),nsessmax(:)')));
        nroi=get(dlg.m2,'value');
        ncov=get(dlg.m3,'value');
        nset=get(dlg.m9,'value')-1;
        if opt0==1&&~a.CONN_x.Setup.structural_sessionspecific, nfields=numel(nsubs);
        elseif opt0==3
            if nroi<=3, subjectspecific=1; sessionspecific=a.CONN_x.Setup.structural_sessionspecific;
            else subjectspecific=a.CONN_x.Setup.rois.subjectspecific(nroi); sessionspecific=a.CONN_x.Setup.rois.sessionspecific(nroi);
            end
            if subjectspecific&&~sessionspecific, nfields=numel(nsubs);
            elseif ~subjectspecific&&~sessionspecific, nfields=1;
            elseif ~subjectspecific&&sessionspecific, nfields=numel(nsessall);
            end
        end
        set(dlg.m8,'string',sprintf('%d files',nfields));
    end
end


