function conn_displayroi(option,varargin)
global CONN_gui;
if ~nargin, option='init'; end
if ~ischar(option), option=varargin{2}; varargin=varargin(3:end); margin=nargin-2; 
else margin=nargin; 
end;
switch(lower(option)),
    case {'init','initfile'}
        if isempty(CONN_gui)||~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
        if margin>1, 
            data.source=varargin{2}; 
            data.side=3;
            %h=conn_msgbox('computing ROI-level results, please wait...','conn_displayroi');
            if strcmpi(option,'initfile'), 
                results=load(varargin{end});
                results=results.ROI;
                filepath=fileparts(varargin{end});
            else
                [results,filepath]=conn_process(varargin{1},varargin{3});
            end
            if isempty(filepath), data.defaultfilepath=pwd;
            else data.defaultfilepath=filepath;
            end
            %close(h);
        else
            data.side=3;
            [filename,filepath]=uigetfile('*ROI*.mat');
            if ~ischar(filename), return; end
            results=load(fullfile(filepath,filename));results=results.ROI;
            data.source=1:length(results);
            if isempty(filepath), data.defaultfilepath=pwd;
            else data.defaultfilepath=filepath;
            end
        end
        data.results=results;
        data.MVPAh=cat(1,results.MVPAh);
        data.MVPAF=cat(1,results.MVPAF);
        data.MVPAp=cat(1,results.MVPAp);
        temp={results.MVPAdof};
        if any(cellfun('length',temp)>1), temp=cellfun(@(x)[ones(1,max(0,2-length(x))),x(:)'],temp,'uni',0); end
        data.MVPAdof=cell2mat(temp(:));
        %data.MVPAdof=cat(1,results.MVPAdof);
        data.MVPAstatsname=results(1).MVPAstatsname;
        %data.MVPApcacov=cat(1,results.MVPApcacov);
        if size(data.MVPAdof,2)>1&&~any(diff(data.MVPAdof(:,1))), data.MVPAstatsname=[data.MVPAstatsname,'(',num2str(data.MVPAdof(1)),')']; end
        data.h=cat(1,results.h);
        data.F=cat(1,results.F);
        data.p=cat(1,results.p);
        data.dof=cat(1,results.dof);
        data.statsname=results(1).statsname;
        if strcmp(data.statsname,'T')&&all(data.dof(:)==data.dof(1)), data.p2=nan(size(data.p));data.p2(~isnan(data.F))=spm_Tcdf(data.F(~isnan(data.F)),data.dof(1)); 
        else data.p2=1-data.p; 
        end
        if size(data.dof,2)>1&&~any(diff(data.dof(:,1))), data.statsname=[data.statsname,'(',num2str(data.dof(1)),')']; end
        data.names=results(1).names;
        data.names=regexprep(data.names,{'_1_1$','^rs\.','^rsREL\.','^aal\.','^atlas\.'},'');
        data.namesreduced=regexprep(data.names,{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'});
        data.names2=results(1).names2;
        data.names2=regexprep(data.names2,{'_1_1$','^rsREL\.','^rs\.','^aal\.'},'');
        data.names2reduced=regexprep(data.names2,{'^BA\.(\d+) \(([LR])\)\. .*','^\((-?\d+),(-?\d+),(-?\d+)\)$','^SLrois\.|^aal\.|^atlas\.','([^\(\)]+)\(.+)\s*$'},{'$1$2','($1 $2 $3)','','$1'});
        data.xyz=cat(1,results(1).xyz{:});
        data.xyz2=cat(1,results(1).xyz2{:});
        data.thr=.05;
        data.thrtype=2;
        data.mvpathrmeasure=1;
        data.mvpasortresultsby=2;
        data.mvpathr=.05;
        data.mvpathrtype=2;
        %data.mvpaside=3;
        data.PERM=[];
        data.PERMenabled=false;
        data.clusters=[];
        data.view=0;
        data.proj=[];
        data.x=[];
        data.y=[];
        data.z=[];
        data.bgz=0;
        data.display='connectivity';
        %data.displayreduced=0;
        %data.displaytheserois=1:length(data.names2);
        data.displayreduced=1;
        data.displaytheserois=1:length(data.names);
        data.displaylabels=1;
        data.displaybrains=1;
        data.display3d=0;
        data.mvpaenablethr=0;
        data.enablethr=1;
        data.visible='on';
        data.plotconnoptions.menubar=true;
        data.plotconnoptions.LINEWIDTH=5;
        data.plotconnoptions.DOFFSET=1;
        data.plotconnoptions.BSCALE=.4;
        data.plotconnoptions.BTRANS=1;
        data.plotconnoptions.LTRANS=1;
        data.plotconnoptions.RSCALE=1;
        data.plotconnoptions.LCOLOR=3;
        data.plotconnoptions.LCOLORSCALE=1;
        data.plotconnoptions.LCURVE=2;
        data.plotconnoptions.FONTSIZE=7+CONN_gui.font_offset;
        data.plotconnoptions.FONTANGLE=0;
        data.plotconnoptions.BCOLOR=.15*[1,1,1];
        data.plotconnoptions.NPLOTS=12;
        data.plotconnoptions.Projections={[0,-1,0;0,0,1;-1,0,0],[1,0,0;0,0,1;0,1,0],[1,0,0;0,1,0;0,0,1]};
        data.plotconnoptions.nprojection=3;
        FSfolder=fullfile(fileparts(which('conn')),'utils','surf');
        rend(1)=reducepatch(conn_surf_readsurf(fullfile(FSfolder,'lh.pial.surf')),.02,'fast');
        rend(2)=reducepatch(conn_surf_readsurf(fullfile(FSfolder,'rh.pial.surf')),.02,'fast');
        %[xyz,faces]=read_surf(fullfile(FSfolder,'lh.cortex.surf'));
        %rend(1)=reducepatch(struct('vertices',xyz,'faces',faces+1),.02,'fast');
        %[xyz,faces]=read_surf(fullfile(FSfolder,'rh.cortex.surf'));
        %rend(2)=reducepatch(struct('vertices',xyz,'faces',faces+1),.02,'fast');
        data.plotconnoptions.rende=struct('vertices',cat(1,rend.vertices),'faces',[rend(1).faces; size(rend(1).vertices,1)+rend(2).faces]);
        data.xy2=200*[cos(2*pi*(0:numel(data.displaytheserois)-1)'/numel(data.displaytheserois)),sin(2*pi*(0:numel(data.displaytheserois)-1)'/numel(data.displaytheserois))]; 
        if isfield(CONN_gui,'refs')&&isfield(CONN_gui.refs,'canonical')&&isfield(CONN_gui.refs.canonical,'filename')&&~isempty(CONN_gui.refs.canonical.filename)
            filename=CONN_gui.refs.canonical.filename;
        else
            filename=fullfile(fileparts(which('spm')),'canonical','avg152T1.nii');
        end
        data.ref=spm_vol(filename);
        color1=.94*[1,1,1];
        color2=.94*[1,1,1];
        %color1=[.5/6,1/6,2/6];
        %color2=[.5/6,1/6,2/6];
        hmsg=[];%figure('units','norm','position',[.01,.1,.98,.8],'numbertitle','off','name','ROI second-level results. Initializing...','color',color1,'colormap',gray,'menubar','none','toolbar','none','interruptible','off');
        hfig=figure('visible','on','renderer','opengl');
        data.hfig=hfig;
        set(hfig,'units','norm','position',[.01,.05,.98,.9],'numbertitle','off','name',['ROI second-level results ',data.defaultfilepath],'color',color1,'colormap',gray,'menubar','none','toolbar','none','interruptible','off');
        %uicontrol('style','frame','units','norm','position',[.0,.95,.5,.05],'backgroundcolor',color2,'foregroundcolor',color2);
        uicontrol('style','frame','units','norm','position',[.5,0,.5,1],'backgroundcolor',color2,'foregroundcolor',color2);
        data.handles=[...
            uicontrol('style','popupmenu','units','norm','position',[.56,.55,.42,.04],'fontsize',8+CONN_gui.font_offset,'string',{'threshold ROI-to-ROI connections (by intensity)'},'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'fontweight','bold','horizontalalignment','left','tooltipstring','Threshold individual ROI-to-ROI connections based on their strength'),...
            uicontrol('style','edit','units','norm','position',[.56,.50,.04,.04],'fontsize',8+CONN_gui.font_offset,'string',num2str(data.thr),'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'interruptible','off','callback',{@conn_displayroi,'thr'},'tooltipstring','false positive (p-value) threshold'),...
            uicontrol('style','popupmenu','units','norm','position',[.61,.50,.25,.04],'fontsize',8+CONN_gui.font_offset,'string',{'p-uncorrected','p-FDR (seed-level correction)','p-FDR (analysis-level correction)'},'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'tooltipstring','<HTML>Type of connection-level false-positive control <br/> - Use <i>p-uncorrected</i> in combination with seed- or network- level thresholds for seed- or network- level inferences<br/> - Use <i>p-FDR (seed-level correction)</i> in combination with seed- or network- level threshold (false-discovery correction across number of target ROIs only)</i>  <br/> - Use <i>p-FDR (analysis-level correction)</i> for connection-level inferences (false-discovery correction over the total number of connections included in this analysis)</HTML>','interruptible','off','callback',{@conn_displayroi,'thrtype'},'value',data.thrtype),...
            uicontrol('style','popupmenu','units','norm','position',[.87,.50,.11,.04],'fontsize',8+CONN_gui.font_offset,'string',{'one-sided (positive)','one-sided (negative)','two-sided'},'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'interruptible','off','callback',{@conn_displayroi,'side'},'value',data.side),...
            uicontrol('style','text','units','norm','position',[.53,.85,.45,.04],'fontsize',8+CONN_gui.font_offset,'string','Select seed ROI(s):','foregroundcolor',color2,'backgroundcolor',1-.5*get(hfig,'color'),'fontweight','bold','horizontalalignment','left'),...
            uicontrol('style','listbox','units','norm','position',[.53,.75,.45,.10],'fontsize',8+CONN_gui.font_offset,'string',' ','max',2,'fontname','monospaced','foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'tooltipstring','Selecting one or several seed ROIs limits the analyses only to the connectivity between the selected seeds and all of the ROIs in the network','interruptible','off','callback',{@conn_displayroi,'list1'}),...
            uicontrol('style','text','units','norm','position',[.53,.30,.45,.04],'fontsize',8+CONN_gui.font_offset,'string',sprintf('%-30s  %-20s  %-6s  %-6s  %-6s','Analysis Unit','Statistic','p-unc','p-FDR','p-FWE'),'foregroundcolor',color2,'backgroundcolor',1-.5*get(hfig,'color'),'fontname','monospaced','horizontalalignment','left'),...
            uicontrol('style','listbox','units','norm','position',[.53,.01,.45,.29],'fontsize',8+CONN_gui.font_offset,'string',' ','fontname','monospaced','foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'tooltipstring','Statistics for each connection, seed ROI, or network. Right-click to export table to .txt file','max',2,'interruptible','off','callback',{@conn_displayroi,'list2'}),...
            uicontrol('style','text','units','norm','position',[.53,.60,.45,.04],'fontsize',8+CONN_gui.font_offset,'string','Define thresholds:','foregroundcolor',color2,'backgroundcolor',1-.5*get(hfig,'color'),'fontweight','bold','horizontalalignment','left'),...
            uicontrol('style','pushbutton','units','norm','position',[.83,.35,.15,.04],'fontsize',8+CONN_gui.font_offset,'string','Enable permutation tests','callback',{@conn_displayroi,'enableperm'},'tooltipstring','Enables permutation-test based statistics (Seed and Network Intensity/Size statistics)'),...
            uicontrol('style','text','units','norm','position',[.53,.95,.45,.04],'fontsize',8+CONN_gui.font_offset,'string','Define connectivity matrix:','foregroundcolor',color2,'backgroundcolor',1-.5*get(hfig,'color'),'fontweight','bold','horizontalalignment','left'),...
            uicontrol('style','popupmenu','units','norm','position',[.53,.91,.45,.04],'fontsize',8+CONN_gui.font_offset,'string',{sprintf('Targets are all ROIs (connectivity matrix: %dx%d ROIs)',numel(data.names),numel(data.names2)),sprintf('Targets are source ROIs only (connectivity matrix: %dx%d ROIs)',numel(data.names),numel(data.names)),'manually-defined subset of ROIs'},'value',data.displayreduced+1,'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'tooltipstring','Defines a subset of ROIs to include in these analyses','interruptible','off','callback',{@conn_displayroi,'displayreduced'}),...
            uicontrol('style','pushbutton','units','norm','position',[.53,.70,.45,.04],'fontsize',8+CONN_gui.font_offset,'string','Select all','tooltipstring','Looks at the connectivity between all ROIs in the network','interruptible','off','callback',{@conn_displayroi,'selectall'}),...
            uicontrol('style','popupmenu','units','norm','position',[.56,.45,.42,.04],'fontsize',8+CONN_gui.font_offset,'string',{'threshold seed ROIs (F-test)','threshold seed ROIs (NBS; by intensity)','threshold seed ROIs (NBS; by size)','threshold networks (NBS; by intensity)','threshold networks (NBS; by size)'},'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'fontweight','bold','horizontalalignment','right','value',data.mvpathrmeasure,'tooltipstring','Threshold individual seed ROIs or individual networks (subsets of connected ROIs)','interruptible','off','callback',{@conn_displayroi,'mvpathrmeasure'}),...
            uicontrol('style','edit','units','norm','position',[.56,.40,.04,.04],'fontsize',8+CONN_gui.font_offset,'string',num2str(data.mvpathr),'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'interruptible','off','callback',{@conn_displayroi,'mvpathr'},'tooltipstring','false positive (p-value) threshold'),...
            uicontrol('style','popupmenu','units','norm','position',[.61,.40,.25,.04],'fontsize',8+CONN_gui.font_offset,'string',{'p-uncorrected','p-FDR','p-FWE'},'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'tooltipstring','<HTML>Type of seed- or network- level false-positive control <br/> - Use <i>p-FDR</i> or <i>p-FWE</i> for seed- or network- level inferences (false-discovery/positive correction across total number of seeds or networks in this analysis)</HTML>','interruptible','off','callback',{@conn_displayroi,'mvpathrtype'},'value',data.mvpathrtype),...
            0,...%uicontrol('style','popupmenu','units','norm','position',[.68,.34,.15,.04],'fontsize',8+CONN_gui.font_offset,'string',{'connection-level results','seed-level results','network-level results'},'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'tooltipstring','Criteria for sorting results in statistics table','interruptible','off','callback',{@conn_displayroi,'mvpasort'},'value',data.mvpasortresultsby),...
            uicontrol('style','checkbox','units','norm','position',[.53,.45,.03,.04],'fontsize',8+CONN_gui.font_offset,'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'interruptible','off','callback',{@conn_displayroi,'mvpaenablethr'},'value',data.mvpaenablethr,'tooltipstring','Enable Seed/Network threshold')...
            uicontrol('style','checkbox','units','norm','position',[.53,.55,.03,.04],'fontsize',8+CONN_gui.font_offset,'foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color2,'interruptible','off','callback',{@conn_displayroi,'enablethr'},'value',data.enablethr,'tooltipstring','Enable ROI-to-ROI connections threshold')...
            0,...%uicontrol('style','pushbutton','units','norm','position',[0,0,.10,.025],'fontsize',8+CONN_gui.font_offset,'backgroundcolor',get(hfig,'color'),'string','display options','tooltipstring','Controls the way functional results are displayed (right-click on figure to get this same menu and remove this button)','callback','set(findobj(gcbf,''type'',''uicontextmenu'',''tag'',''conn_displayroi_plot''),''visible'',''on'')'),...
            uicontrol('style','text','units','norm','position',[0,0,.5,.03],'string','','foregroundcolor','k','backgroundcolor',color2);
            ];
        ht=uimenu(hfig,'Label','View','tag','donotdelete');
        uimenu(ht,'Label','connectome ring','callback',{@conn_displayroi,'view-ring'},'tag','donotdelete');
        uimenu(ht,'Label','axial view (x-y)','callback',{@conn_displayroi,'view-axial'},'tag','donotdelete');
        uimenu(ht,'Label','coronal view (x-z)','callback',{@conn_displayroi,'view-coronal'},'tag','donotdelete');
        uimenu(ht,'Label','sagittal view (y-z)','callback',{@conn_displayroi,'view-sagittal'},'tag','donotdelete');
        uimenu(ht,'Label','3d display','callback',{@conn_displayroi,'display3d'},'tag','donotdelete');
        hc1=uicontextmenu('parent',hfig);
        uimenu(hc1,'Label','Export table','callback',@(varargin)conn_exportlist(data.handles(8),'',get(data.handles(7),'string')),'tag','donotdelete');
        hc2=uimenu(hc1,'Label','Sort rows by','tag','donotdelete');
        uimenu(hc2,'Label','Connections','callback',@(varargin)conn_displayroi('mvpasort',1),'tag','donotdelete');
        uimenu(hc2,'Label','Seeds','callback',@(varargin)conn_displayroi('mvpasort',2),'tag','donotdelete');
        uimenu(hc2,'Label','Networks','callback',@(varargin)conn_displayroi('mvpasort',3),'tag','donotdelete');
        set(data.handles(8),'uicontextmenu',hc1);
        %set(data.handles(7),'string',sprintf('%-6s %-6s  %6s  %6s  %4s  %8s  %8s','Seed','Target','beta',[data.MVPAstatsname,'/',data.statsname],'dof','p-unc','p-FDR'));
        %uicontrol('style','text','units','norm','position',[.53,.50,.45,.04],'string','second-level analysis results','foregroundcolor','b','backgroundcolor',color2,'fontname','monospaced','fontweight','bold','horizontalalignment','center');
        %uicontrol('style','text','units','norm','position',[.03,.01,.05,.04],'string','view:  ','foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color1,'fontweight','bold','horizontalalignment','right');
        %uicontrol('style','text','units','norm','position',[.35,.01,.02,.04],'string','q','fontname','symbol','horizontalalignment','right','foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color1,'fontweight','bold','horizontalalignment','right');
        %uicontrol('style','text','units','norm','position',[.20,.01,.02,.04],'string','z','horizontalalignment','right','foregroundcolor',1-get(hfig,'color'),'backgroundcolor',color1,'fontweight','bold','horizontalalignment','right');
        rcircle=sign([sin(linspace(0,2*pi,64)'),cos(linspace(0,2*pi,64))'])*diag([5,5]);
        h=subplot(121);set(h,'units','norm','position',[.1,.95,.31,.05],'xtick',[],'ytick',[],'box','on','xcolor',.5*[1,1,1],'ycolor',.5*[1,1,1]);axis equal;set(h,'xlim',[-10,200]);axis off;
        cmap=jet(256);cmap=cmap(32:224,:)*.8;
        data.legend=[patch(100+rcircle(:,1),0+rcircle(:,2),'w','edgecolor','none','facecolor',[1,.5,.5]),...
                     patch(150+rcircle(:,1),0+rcircle(:,2),'w','edgecolor','none','facecolor',[.5,.5,1]),...
                     text(0,0,'ROI-to-ROI effects:','horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'color',.5*[1,1,1]),...
                     text(100+10,0,'Positive','horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'color',.5*[1,1,1]),...
                     text(150+10,0,'Negative','horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'color',.5*[1,1,1]),...
                     text(100-5,0,'Negative','horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'color',.5*[1,1,1],'horizontalalignment','right'),...
                     text(150+5,0,'Positive','horizontalalignment','left','fontsize',8+CONN_gui.font_offset,'color',.5*[1,1,1],'horizontalalignment','left')];
        for n=1:size(cmap,1), data.legend=[data.legend patch(100+(n+[0 0 1 1])*50/size(cmap,1),[-5,5,5,-5],'w','edgecolor','none','facecolor',cmap(n,:),'tag','conn_displayroi_plotlegendcont')]; end

        if data.displayreduced
            set(hfig,'userdata',data);
            conn_displayroi('displayreduced',hfig);
            if ishandle(hmsg), delete(hmsg); end
            set(hfig,'visible','on');
            return;
        end
        if ishandle(hmsg), delete(hmsg); end
        set(hfig,'visible','on');
        
    case 'thr',
        hfig=gcbf;
        data=get(hfig,'userdata');
        str=get(data.handles(2),'string');
        if ~isempty(str2num(str)),
            data.thr=max(0,str2num(str));
        end
        data.visible='on';
    case 'thrtype',
        hfig=gcbf;
        data=get(hfig,'userdata');
        value=get(data.handles(3),'value');
        data.thrtype=value;
        data.visible='on';
    case 'side',
        hfig=gcbf;
        data=get(hfig,'userdata');
        value=get(data.handles(4),'value');
        data.side=value;
        %data.plotconnoptions.LCOLOR=1+(data.side<3);
        data.visible='on';
    case 'enableperm'
        hfig=gcbf;
        data=get(hfig,'userdata');
        data.PERMenabled=xor(true,data.PERMenabled);
        data.visible='on';
    case 'mvpathrmeasure',
        hfig=gcbf;
        data=get(hfig,'userdata');
        value=get(data.handles(14),'value');
        data.mvpathrmeasure=value;
        data.mvpasortresultsby=2+(value>3);
        data.visible='on';
    case 'mvpathr',
        hfig=gcbf;
        data=get(hfig,'userdata');
        str=get(data.handles(15),'string');
        if ~isempty(str2num(str)),
            data.mvpathr=max(0,str2num(str));
        end
        data.visible='on';
    case 'mvpathrtype',
        hfig=gcbf;
        data=get(hfig,'userdata');
        value=get(data.handles(16),'value');
        data.mvpathrtype=value;
        data.visible='on';
%     case 'mvpaside',
%         hfig=gcbf;
%         data=get(hfig,'userdata');
%         value=get(data.handles(17),'value');
%         data.mvpaside=value;
%         data.visible='on';
    case 'mvpasort',
        hfig=gcbf;
        data=get(hfig,'userdata');
        data.mvpasortresultsby=varargin{1};
        data.visible='on';
    case 'displayreduced',
        if margin>1, hfig=varargin{1};
        else         hfig=gcbf;
        end
        data=get(hfig,'userdata');
        value=get(data.handles(12),'value');
        olddisplaytheserois=data.displaytheserois;
        data.displayreduced=value-1;
        switch(data.displayreduced),
            case 0,
                data.displaytheserois=1:length(data.names2);
            case 1,
                data.displaytheserois=1:length(data.names);
            case 2,
                idxresortv=1:numel(data.names2);
                temp=regexp(data.names2,'BA\.(\d*) \(L\)','tokens'); itemp=~cellfun(@isempty,temp); idxresortv(itemp)=-2e6+cellfun(@(x)str2double(x{1}),temp(itemp));
                temp=regexp(data.names2,'BA\.(\d*) \(R\)','tokens'); itemp=~cellfun(@isempty,temp); idxresortv(itemp)=-1e6+cellfun(@(x)str2double(x{1}),temp(itemp));
                [nill,idxresort]=sort(idxresortv);
                [nill,tidx]=ismember(data.displaytheserois,idxresort);
                answ=listdlg('Promptstring','Select ROIs','selectionmode','multiple','liststring',data.names2(idxresort),'initialvalue',sort(tidx));
                if numel(answ)>1, data.displaytheserois=sort(idxresort(answ)); 
                else
                    if numel(answ)==1, disp('Please select more than one ROI'); end
                    return; 
                end
        end
        if ~isequal(olddisplaytheserois,data.displaytheserois), data.PERM=[]; end
        data.source=data.source(data.source==0 | data.source<=length(data.displaytheserois));if isempty(data.source),data.source=1;end
        %results=conn_process('results_roi',data.displaytheserois);
        h=conn_msgbox('computing ROI-level results, please wait...','conn_displayroi');
        for nresults=1:numel(data.results)
            domvpa=data.displaytheserois;
            ndims=ceil(size(data.results(nresults).y,1)/5);
            ndims=max(1,min(min(numel(domvpa),size(data.results(nresults).y,2)), ndims ));
            if ndims<numel(domvpa)
                y=data.results(nresults).y(:,domvpa,:);
                y(:,any(any(isnan(y),1),3),:)=[];
                sy=[size(y),1,1];
                y=reshape(permute(y,[1,3,2]),sy(1)*sy(3),sy(2));
                [Q,D,R]=svd(detrend(y,'constant'),0);
                y=y*R(:,1:ndims);
                data.results(nresults).MVPAy=permute(reshape(y,[sy(1),sy(3),ndims]),[1,3,2]);
                d=D(1:size(D,1)+1:size(D,1)*min(size(D))).^2;
                data.results(nresults).MVPApcacov=d(1:ndims)/sum(d);
            else
                y=data.results(nresults).y(:,domvpa,:);
                y=y(:,~any(any(isnan(y),1),3),:);
                data.results(nresults).MVPAy=y;
                data.results(nresults).MVPApcacov=[];
            end
            [data.results(nresults).MVPAh,data.results(nresults).MVPAF,data.results(nresults).MVPAp,data.results(nresults).MVPAdof,data.results(nresults).MVPAstatsname]=conn_glm(data.results(nresults).xX.X,data.results(nresults).MVPAy(:,:),data.results(nresults).c,kron(data.results(nresults).c2,eye(size(data.results(nresults).MVPAy,2))));
        end
        if ishandle(h), close(h); end
        data.MVPAF=cat(1,data.results.MVPAF);
        data.MVPAp=cat(1,data.results.MVPAp);
        temp={data.results.MVPAdof};
        if any(cellfun('length',temp)>1), temp=cellfun(@(x)[ones(1,max(0,2-length(x))),x(:)'],temp,'uni',0); end
        data.MVPAdof=cell2mat(temp(:));
        %data.MVPAdof=cat(1,data.results.MVPAdof);
        data.MVPAstatsname=data.results(1).MVPAstatsname;
        %data.MVPApcacov=cat(1,data.results.MVPApcacov);
        if size(data.MVPAdof,2)>1&&~any(diff(data.MVPAdof(:,1))), data.MVPAstatsname=[data.MVPAstatsname,'(',num2str(data.MVPAdof(1)),')']; end
        %set(data.handles(7),'string',sprintf('%-6s %-6s  %6s  %6s  %4s  %8s  %8s','Seed','Target','beta',[data.MVPAstatsname,'/',data.statsname],'dof','p-unc','p-FDR'));
        data.xy2=zeros(length(data.names2),2); data.xy2(data.displaytheserois,:)=200*[cos(2*pi*(0:numel(data.displaytheserois)-1)'/numel(data.displaytheserois)),sin(2*pi*(0:numel(data.displaytheserois)-1)'/numel(data.displaytheserois))]; 
        data.clusters=[];
        data.proj=[];data.x=[];data.y=[];data.z=[];
        data.bgz=0;
        data.visible='on';

    case 'exportroiconfiguration'
        answ=conn_questdlg('Export current ROI order to:','','Workspace','File','Workspace');
        hfig=gcbf;
        data=get(hfig,'userdata');
        ROIconfiguration=struct('xy2',data.xy2,'displaytheserois',data.displaytheserois,'clusters',data.clusters,'names2',{data.names2});
        if isequal(answ,'File')
            [tfilename,tfilepath]=uiputfile('connROIorder.mat','Save ROI order as');
            if ~isequal(tfilename,0)
                save(fullfile(tfilepath,tfilename),'ROIconfiguration','-mat');
            end
        elseif isequal(answ,'Workspace')
            assignin('base','ROIconfiguration',ROIconfiguration);
        end
        return
        
    case 'importroiconfiguration'
        hfig=gcbf;
        data=get(hfig,'userdata');
        answ=conn_questdlg('Import ROI order from:','','Workspace','File','Workspace');
        if isequal(answ,'File')
            [tfilename,tfilepath]=uigetfile('connROIorder.mat','Load ROI order from');
            if ~isequal(tfilename,0)
                load(fullfile(tfilepath,tfilename),'ROIconfiguration','-mat');
            end
        elseif isequal(answ,'Workspace')
            ROIconfiguration=evalin('base','ROIconfiguration');
        else return;
        end
        olddisplaytheserois=data.displaytheserois;
        [ok,idx]=ismember(data.names2,ROIconfiguration.names2(ROIconfiguration.displaytheserois));
        if ~nnz(ok), conn_msgbox('Unable to import ROI configuration information. No matching ROIs','',2); return; end
        data.displaytheserois=find(ok);
        data.xy2(:)=0;
        data.xy2(data.displaytheserois,:)=ROIconfiguration.xy2(ROIconfiguration.displaytheserois(idx(ok)),:);
        data.clusters(:)=0;
        data.clusters(data.displaytheserois)=ROIconfiguration.clusters(ROIconfiguration.displaytheserois(idx(ok)));
        %data.displaytheserois=ROIconfiguration.displaytheserois;
        %data.xy2=ROIconfiguration.xy2; 
        %data.clusters=ROIconfiguration.clusters;
        data.proj=[];data.x=[];data.y=[];data.z=[];
        data.bgz=0;
        data.visible='on';

        
        if ~isequal(olddisplaytheserois,data.displaytheserois), 
            data.displayreduced=2;
            set(data.handles(12),'value',data.displayreduced+1);
            data.PERM=[]; 
            data.source=data.source(data.source==0 | data.source<=length(data.displaytheserois));if isempty(data.source),data.source=1;end
            %results=conn_process('results_roi',data.displaytheserois);
            h=conn_msgbox('computing ROI-level results, please wait...','conn_displayroi');
            for nresults=1:numel(data.results)
                domvpa=data.displaytheserois;
                ndims=ceil(size(data.results(nresults).y,1)/5);
                ndims=max(1,min(min(numel(domvpa),size(data.results(nresults).y,2)), ndims ));
                if ndims<numel(domvpa)
                    y=data.results(nresults).y(:,domvpa,:);
                    y(:,any(any(isnan(y),1),3),:)=[];
                    sy=[size(y),1,1];
                    y=reshape(permute(y,[1,3,2]),sy(1)*sy(3),sy(2));
                    [Q,D,R]=svd(detrend(y,'constant'),0);
                    y=y*R(:,1:ndims);
                    data.results(nresults).MVPAy=permute(reshape(y,[sy(1),sy(3),ndims]),[1,3,2]);
                    d=D(1:size(D,1)+1:size(D,1)*min(size(D))).^2;
                    data.results(nresults).MVPApcacov=d(1:ndims)/sum(d);
                else
                    y=data.results(nresults).y(:,domvpa,:);
                    y=y(:,~any(any(isnan(y),1),3),:);
                    data.results(nresults).MVPAy=y;
                    data.results(nresults).MVPApcacov=[];
                end
                [data.results(nresults).MVPAh,data.results(nresults).MVPAF,data.results(nresults).MVPAp,data.results(nresults).MVPAdof,data.results(nresults).MVPAstatsname]=conn_glm(data.results(nresults).xX.X,data.results(nresults).MVPAy(:,:),data.results(nresults).c,kron(data.results(nresults).c2,eye(size(data.results(nresults).MVPAy,2))));
            end
            if ishandle(h), close(h); end
            data.MVPAF=cat(1,data.results.MVPAF);
            data.MVPAp=cat(1,data.results.MVPAp);
            temp={data.results.MVPAdof};
            if any(cellfun('length',temp)>1), temp=cellfun(@(x)[ones(1,max(0,2-length(x))),x(:)'],temp,'uni',0); end
            data.MVPAdof=cell2mat(temp(:));
            %data.MVPAdof=cat(1,data.results.MVPAdof);
            data.MVPAstatsname=data.results(1).MVPAstatsname;
            %data.MVPApcacov=cat(1,data.results.MVPApcacov);
            if size(data.MVPAdof,2)>1&&~any(diff(data.MVPAdof(:,1))), data.MVPAstatsname=[data.MVPAstatsname,'(',num2str(data.MVPAdof(1)),')']; end
        end
        
    case 'selectall',
        hfig=gcbf;
        data=get(hfig,'userdata');
        data.source=0;
        data.bgz=0;
        %set(data.handles(11),'value',max(0,min(1,data.bgz/200+.5)));
        if data.view>0, data.bgimage=spm_get_data(data.ref,pinv(data.ref.mat)*[data.proj(:,1:3)*[data.bgx(:),data.bgy(:),data.bgz+zeros(prod(size(data.bgx)),1)]';ones(1,prod(size(data.bgx)))]); end
    case 'list1',
        hfig=gcbf;
        data=get(hfig,'userdata');
        value=get(data.handles(6),'value');
        if all(value>0&value<=length(data.displaytheserois)), 
            data.source=value;
            data.bgz=mean(data.z(data.displaytheserois(data.source)));
            %set(data.handles(11),'value',max(0,min(1,data.bgz/200+.5)));
            if data.view>0, data.bgimage=spm_get_data(data.ref,pinv(data.ref.mat)*[data.proj(:,1:3)*[data.bgx(:),data.bgy(:),data.bgz+zeros(prod(size(data.bgx)),1)]';ones(1,prod(size(data.bgx)))]); end
            %set(data.refaxes,'cdata',convn(convn(reshape(data.bgimage,size(data.bgx)),conn_hanning(5),'same'),conn_hanning(5)','same'));
        else
            data.source=0; 
            data.bgz=0;
            %set(data.handles(11),'value',max(0,min(1,data.bgz/200+.5)));
            if data.view>0, data.bgimage=spm_get_data(data.ref,pinv(data.ref.mat)*[data.proj(:,1:3)*[data.bgx(:),data.bgy(:),data.bgz+zeros(prod(size(data.bgx)),1)]';ones(1,prod(size(data.bgx)))]); end
            %set(data.refaxes,'cdata',convn(convn(reshape(data.bgimage,size(data.bgx)),conn_hanning(5),'same'),conn_hanning(5)','same'));
        end
        data.visible='on';
    case 'list2',
        hfig=gcbf;
        data=get(hfig,'userdata');
        values=get(data.handles(8),'value');
        if data.view==0, props={'facealpha',.10,'facealpha',min(.99,max(.001,abs(data.plotconnoptions.LTRANS)))};
        else, props={'visible','off','visible','on'};
        end
        if any(values>size(data.list2,1))
            set(cat(2,data.plotsadd2{cellfun('length',data.plotsadd2)>0}),props{3:4});%'linewidth',data.plotconnoptions.LINEWIDTH,'edgealpha',data.plotconnoptions.LTRANS);
            set(cat(2,data.plotsadd3{cellfun('length',data.plotsadd3)>0}),props{3:4});
%             set(cat(2,data.plotsadd2{cellfun('length',data.plotsadd2)>0}),'visible','on');%'linewidth',data.plotconnoptions.LINEWIDTH,'edgealpha',data.plotconnoptions.LTRANS);
%             set(cat(2,data.plotsadd3{cellfun('length',data.plotsadd3)>0}),'visible','on');
        else
            
            set(cat(2,data.plotsadd2{:}),props{1:2});%'linewidth',data.plotconnoptions.LINEWIDTH/2,'edgealpha',data.plotconnoptions.LTRANS/2);
            set(cat(2,data.plotsadd3{:}),props{1:2});
%             set(cat(2,data.plotsadd2{cellfun('length',data.plotsadd2)>0}),props{1:2});%'linewidth',data.plotconnoptions.LINEWIDTH/2,'edgealpha',data.plotconnoptions.LTRANS/2);
%             set(cat(2,data.plotsadd3{cellfun('length',data.plotsadd3)>0}),props{1:2});
%             set(cat(2,data.plotsadd2{cellfun('length',data.plotsadd2)>0}),'visible','off');%'linewidth',data.plotconnoptions.LINEWIDTH/2,'edgealpha',data.plotconnoptions.LTRANS/2);
%             set(cat(2,data.plotsadd3{cellfun('length',data.plotsadd3)>0}),'visible','off');
            %set(cat(2,data.plotsadd2{cellfun('length',data.plotsadd2)>0}),'linewidth',data.plotconnoptions.LINEWIDTH,'edgealpha',data.plotconnoptions.LTRANS);
            for value=values(:)'
                if value>0&&value<=length(data.plotsadd2),%&&~isempty(data.plotsadd2{value}),
                    if data.list2(value,2)>0,     n2=find(data.list2(:,1)==data.list2(value,1)&data.list2(:,2)==data.list2(value,2)|data.list2(:,1)==data.list2(value,2)&data.list2(:,2)==data.list2(value,1));
                    elseif data.list2(value,1)>0, n2=find(data.list2(:,1)==data.list2(value,1)|data.list2(:,2)==data.list2(value,1));
                    else                          n2=find(data.list2(:,3)==data.list2(value,3));
                    end
                    set(cat(2,data.plotsadd2{n2}),props{3:4});%'linewidth',data.plotconnoptions.LINEWIDTH,'edgealpha',data.plotconnoptions.LTRANS);
                    %                 set(cat(2,data.plotsadd2{n2}),'visible','on');%'linewidth',data.plotconnoptions.LINEWIDTH,'edgealpha',data.plotconnoptions.LTRANS);
                    nall=unique(data.list2(n2,1:2));
                    set(cat(2,data.plotsadd3{nall(nall>0)}),props{3:4});
                    %                 set(cat(2,data.plotsadd3{nall(nall>0)}),'visible','on');
                    %set(cat(2,data.plotsadd2{n2}),'linewidth',2*data.plotconnoptions.LINEWIDTH,'edgealpha',min(1,10*data.plotconnoptions.LTRANS));
                    if 0 % stat-color
                        cmap=jet(256);cmap=cmap(32:224,:)*.8;
                        n1n2=data.list2(n2,1:2);
                        n1n2valid=find(all(n1n2>0,2));
                        j=data.F(n1n2(n1n2valid,1)+size(data.F,1)*(n1n2(n1n2valid,2)-1));
                        J=max([eps;abs(j)]);
                        for nt=1:numel(n1n2valid),
                            set(data.plotsadd2{nt},'edgecolor',cmap(ceil(size(cmap,1)/2)+round(floor(size(cmap,1)/2)*max(-1,min(1,j(nt)/J))),:));
                        end
                    end
                end
            end
%             if 0
%                 n1=data.list2(value,1);
%                 n2=data.list2(value,2);
%                 y=cat(3,data.results(n1).y);
%                 if ~n2, y=y(:,data.displaytheserois);
%                     yc=data.names2(data.displaytheserois);
%                     MVPAy=cat(3,data.results(n1).MVPAy);
%                 else    y=y(:,n2);
%                     yc=data.names2(n2);
%                     MVPAy=[];
%                 end
%                 data.exploreplot.X=data.results(1).xX.X;
%                 data.exploreplot.c=data.results(1).c;
%                 data.exploreplot.c2=data.results(1).c2;
%                 data.exploreplot.effects=data.results(1).xX.X*data.results(1).c';
%                 data.exploreplot.y=y;
%                 data.exploreplot.y_fit=data.results(1).xX.X*(pinv(data.results(1).xX.X)*y);
%                 data.exploreplot.yc=yc;
%                 data.exploreplot.MVPAy=MVPAy;
%                 data.exploreplot.MVPAy_fit=data.results(1).xX.X*(pinv(data.results(1).xX.X)*MVPAy);
%                 %kron(data.results(nresults).c2,eye(size(data.results(nresults).MVPAy,2)))
%             end
        end
        if get(data.handles(6),'listboxtop')>size(get(data.handles(6),'string'),1), set(data.handles(6),'listboxtop',1); end
        if get(data.handles(8),'listboxtop')>size(get(data.handles(8),'string'),1), set(data.handles(8),'listboxtop',1); end
        return;
        data.visible='on';
    case {'view','view-axial','view-coronal','view-sagittal','view-ring'}
        hfig=gcbf; 
        data=get(hfig,'userdata');
        switch(lower(option))
            case 'view-ring', data.view=0; %data.displaylabels=1;
            case 'view-axial', data.view=1; data.displaybrains=1;
            case 'view-coronal', data.view=2; data.displaybrains=1;
            case 'view-sagittal', data.view=3; data.displaybrains=1;
        end
        %data.view=get(data.handles(9),'value');
        data.proj=[];data.x=[];data.y=[];data.z=[];
        data.bgz=0;
%     case {'displayefffectsize-on','displayefffectsize-off','displayefffectsize-none'}
%         hfig=gcbf;
%         data=get(hfig,'userdata');
%         switch(lower(option))
%             case 'displayefffectsize-on', data.displayeffectsize=1;
%             case 'displayefffectsize-off', data.displayeffectsize=0;
%             case 'displayefffectsize-none', data.displayeffectsize=-1;
%         end
%         data.proj=[];data.x=[];data.y=[];data.z=[];
%         data.bgz=0;
    case 'display3d'
        hfig=gcbf;
        data=get(hfig,'userdata');
        if 1, % ring placeholder 0
            data.view=1;
            data.proj=[];data.x=[];data.y=[];data.z=[];
            data.bgz=0;
        end
        data.display3d=1;
    case 'changebackground',
        hfig=gcbf;
        data=get(hfig,'userdata');
        filename=spm_select(1,'\.img$|\.nii$',['Select background anatomical image'],{},fileparts(data.ref.fname));
        data.ref=spm_vol(filename);
        data.proj=[];data.x=[];data.y=[];data.z=[];
        data.bgz=0;
    case 'refresh',
        hfig=gcbf;
        data=get(hfig,'userdata');
        data.proj=[];data.x=[];data.y=[];data.z=[];
        data.bgz=0;
    case 'viewcycle'
        hfig=gcbf;
        if isempty(hfig), hfig=gcf; 
        else
            temp=get(hfig,'selectiontype');
            if ~isequal(temp,'open'), 
                conn_displayroi_menubuttondownfcn;
                hfig=[]; 
            end
        end
        if ishandle(hfig)
            data=get(hfig,'userdata');
            data.plotconnoptions.nprojection=1+mod(data.plotconnoptions.nprojection,3);
        else return;
        end
    case 'conndisplayoptions'
        hfig=gcbf;
        data=get(hfig,'userdata');
        answer=inputdlg({'Brain display size (0,inf)','Brain display orientation (0=automatic; 1=sagittal; 2=coronal; 3=axial)','Brain display contrast (0,1)','Connectivity lines width (-inf,inf; negative for proportional to stats)','Connectivity lines transparency (-1,1; negative for proportional to stats)','Connectivity lines curvature (-inf,inf)','ROI sphere size (0,inf)','Space reserved for labels (0,inf)','Fontsize for labels (pts)','Rotation of labels (degrees)','Image background color (rgb)'},'display options',1,...
            {num2str(data.plotconnoptions.BSCALE),num2str(data.plotconnoptions.nprojection),num2str(data.plotconnoptions.BTRANS),num2str(data.plotconnoptions.LINEWIDTH),num2str(data.plotconnoptions.LTRANS),num2str(data.plotconnoptions.LCURVE),num2str(data.plotconnoptions.RSCALE),num2str(data.plotconnoptions.DOFFSET),num2str(data.plotconnoptions.FONTSIZE),num2str(data.plotconnoptions.FONTANGLE),num2str(data.plotconnoptions.BCOLOR)});
        try
            data.plotconnoptions.BSCALE=str2num(answer{1});
            data.plotconnoptions.nprojection=str2num(answer{2});
            data.plotconnoptions.BTRANS=str2num(answer{3});
            data.plotconnoptions.LINEWIDTH=str2num(answer{4});
            data.plotconnoptions.LTRANS=str2num(answer{5});
            data.plotconnoptions.LCURVE=str2num(answer{6});
            data.plotconnoptions.RSCALE=str2num(answer{7});
            data.plotconnoptions.DOFFSET=str2num(answer{8});
            data.plotconnoptions.FONTSIZE=str2num(answer{9});
            data.plotconnoptions.FONTANGLE=str2num(answer{10});
            data.plotconnoptions.BCOLOR=str2num(answer{11});
        catch
        end
    case {'mvpaenablethr','enablethr'}
        hfig=gcbf;
        data=get(hfig,'userdata');
        data.enablethr=get(data.handles(19),'value');
        data.mvpaenablethr=get(data.handles(18),'value');
    case {'edgecolors1','edgecolors2','edgecolors3','edgecolors4','edgecolors5'}
        hfig=gcbf;
        data=get(hfig,'userdata');
        if strcmp(option,'edgecolors1'), data.plotconnoptions.LCOLOR=1;
        elseif strcmp(option,'edgecolors2'),  data.plotconnoptions.LCOLOR=2;
        elseif strcmp(option,'edgecolors3'),  data.plotconnoptions.LCOLOR=3;
        elseif strcmp(option,'edgecolors4'),  data.plotconnoptions.LCOLORSCALE=data.plotconnoptions.LCOLORSCALE/1.5;
        elseif strcmp(option,'edgecolors5'),  data.plotconnoptions.LCOLORSCALE=data.plotconnoptions.LCOLORSCALE*1.5;
        end
    case {'edgewidths1','edgewidths2','edgewidths3','edgewidths4'}
        hfig=gcbf;
        data=get(hfig,'userdata');
        if strcmp(option,'edgewidths1'), data.plotconnoptions.LINEWIDTH=abs(data.plotconnoptions.LINEWIDTH);
        elseif strcmp(option,'edgewidths2'), data.plotconnoptions.LINEWIDTH=-abs(data.plotconnoptions.LINEWIDTH);
        elseif strcmp(option,'edgewidths3'), data.plotconnoptions.LINEWIDTH=2*data.plotconnoptions.LINEWIDTH;
        elseif strcmp(option,'edgewidths4'), data.plotconnoptions.LINEWIDTH=1/2*data.plotconnoptions.LINEWIDTH;
        end
    case {'edgeopacity1','edgeopacity2','edgeopacity3','edgeopacity4'}
        hfig=gcbf;
        data=get(hfig,'userdata');
        if strcmp(option,'edgeopacity1'), data.plotconnoptions.LTRANS=abs(data.plotconnoptions.LTRANS);
        elseif strcmp(option,'edgeopacity2'), data.plotconnoptions.LTRANS=-abs(data.plotconnoptions.LTRANS);
        elseif strcmp(option,'edgeopacity3'), data.plotconnoptions.LTRANS=2*data.plotconnoptions.LTRANS;
        elseif strcmp(option,'edgeopacity4'), data.plotconnoptions.LTRANS=1/2*data.plotconnoptions.LTRANS;
        end
    case {'labelsoff','labelson','labelspartial'}
        hfig=gcbf;
        data=get(hfig,'userdata');
        data.displaylabels=strcmpi(option,'labelson')+.5*strcmpi(option,'labelspartial');
    case {'labels1','labels2'}
        hfig=gcbf;
        data=get(hfig,'userdata');
        if strcmp(option,'labels1'), data.plotconnoptions.FONTSIZE=data.plotconnoptions.FONTSIZE+1;
        elseif strcmp(option,'labels2'), data.plotconnoptions.FONTSIZE=data.plotconnoptions.FONTSIZE-1;
        end
    case 'labelsedit',
        hfig=gcbf;
        data=get(hfig,'userdata');
        name=data.names2reduced;
        %name=get(state.handles.sphplots_txt,'string');
        ok=true;
        thfig=dialog('units','norm','position',[.3,.4,.6,.4],'windowstyle','normal','name','ROI labels','color','w','resize','on');
        uicontrol(thfig,'style','text','units','norm','position',[.1,.85,.8,.10],'string',sprintf('New ROI label names (%d)',numel(name)),'backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
        ht1=uicontrol(thfig,'style','edit','units','norm','position',[.1,.30,.8,.55],'max',2,'string',name,'fontsize',8+CONN_gui.font_offset,'horizontalalignment','left','tooltipstring','manually edit the ROI labels');
        ht2=uicontrol(thfig,'style','edit','units','norm','position',[.1,.20,.8,.1],'max',1,'string','','fontsize',8+CONN_gui.font_offset,'horizontalalignment','left','tooltipstring','enter Matlab command for fast-editing all ROIs simultaneously (str is input variable cell array; ouput is cell array; e.g. "lower(str)")','callback','ht1=get(gcbo,''userdata''); set(ht1,''string'',feval(inline(get(gcbo,''string''),''str''),get(ht1,''string'')))','userdata',ht1);
        uicontrol(thfig,'style','pushbutton','string','Apply','units','norm','position',[.1,.01,.38,.10],'callback','uiresume','fontsize',8+CONN_gui.font_offset);
        uicontrol(thfig,'style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.10],'callback','delete(gcbf)','fontsize',8+CONN_gui.font_offset);
        while ok
            uiwait(thfig);
            ok=ishandle(thfig);
            if ok,
                newname=get(ht1,'string');
                if numel(newname)~=numel(name), conn_msgbox(sprintf('Number of labels entered (%d) does not match expected value (%d)',numel(newname),numel(name)),'',2);
                else
                    delete(thfig);
                    data.names2reduced=newname;
                    ok=false;
                end
            else return;
            end
        end
    case {'brainsoff','brainson','brainspartial'}
        hfig=gcbf;
        data=get(hfig,'userdata');
        data.displaybrains=2*strcmpi(option,'brainson')+strcmpi(option,'brainspartial');
%     case 'slider1',
%         hfig=gcbf;
%         data=get(hfig,'userdata');
%         value=get(data.handles(10),'value');
%         ang=(value-.5)*pi;
%         switch(data.view),
%             case 1, data.proj=[1,0,0;0,cos(ang),-sin(ang);0,sin(ang),cos(ang)];
%             case 2, data.proj=[1,0,0;0,sin(ang),-cos(ang);0,cos(ang),sin(ang)];
%             case 3, data.proj=[0,sin(ang),cos(ang);1,0,0;0,cos(ang),-sin(ang)];
%         end
%         data.x=[];data.y=[];data.z=[];
    case 'slider2',
        hfig=gcbf;
        data=get(hfig,'userdata');
        value=get(data.handles(11),'value');
        data.bgz=(value-.5)*200;
        data.bgimage=spm_get_data(data.ref,pinv(data.ref.mat)*[data.proj(:,1:3)*[data.bgx(:),data.bgy(:),data.bgz+zeros(prod(size(data.bgx)),1)]';ones(1,prod(size(data.bgx)))]);
        set(data.refaxes,'cdata',reshape(data.bgimage,size(data.bgx)));%convn(convn(reshape(data.bgimage,size(data.bgx)),conn_hanning(5),'same'),conn_hanning(5)','same'));
        set(hfig,'userdata',data);
        return;

    case 'clusters',
        hfig=gcbf;
        data=get(hfig,'userdata');
        LAMBDAPOS=.05;
        NCLUSTERS=varargin{1};
        if ~ischar(NCLUSTERS)&&NCLUSTERS>0
            answer=inputdlg({'Number of brain displays / clusters','Hierarchical Clustering criteria: -1=Labels; 0=Functional; 1=Positional'},'clustering parameters',1,{num2str(NCLUSTERS),num2str(LAMBDAPOS)});
            try
                NCLUSTERS=str2num(answer{1});
                LAMBDAPOS=str2num(answer{2});
            catch
                return;
            end
        elseif ~ischar(NCLUSTERS)
            answer=inputdlg({'Number of brain displays / clusters'},'clustering parameters',1,{num2str(data.plotconnoptions.NPLOTS)});
            try
                data.plotconnoptions.NPLOTS=str2num(answer{1});
            catch
                return;
            end
        end
        if ischar(NCLUSTERS)
            N=length(data.names);
            N2=length(data.names2);
            i1=intersect(1:N,data.displaytheserois);
            i2=intersect(1:N2,data.displaytheserois);
            if data.thrtype>1, 
                p=data.P; 
            else
                if isequal(data.statsname,'T')
                    switch(data.side),
                        case 1,p=data.p;
                        case 2,p=data.p2;
                        case 3,p=2*min(data.p,data.p2);
                    end
                else
                    p=data.p;
                end
            end
            mask=p(i1,i2)<=data.thr;
            [Nr1,Nr2]=size(mask);
            [i,j,v]=find(mask);
            M=sparse(i,j,v,max(Nr1,Nr2),max(Nr1,Nr2)); % handles non-square matrices
            M=M|M';
            M=M|speye(size(M,1));
            if strcmp(NCLUSTERS,'hcnet'),
                maxrois=10;
                answer=inputdlg({'Maximum number of ROIs per brain display / cluster'},'display parameters',1,{num2str(maxrois)});
                try
                    maxrois=str2num(answer{1});
                end
                [idx0,Labels]=conn_hcnet(p(i1,i2));
                docluster=false;
                TT=[];%fliplr(Labels(:,1:end-1)); 
            elseif strcmp(NCLUSTERS,'symrcm'),
                maxrois=10;
                answer=inputdlg({'Maximum number of ROIs per brain display / cluster'},'display parameters',1,{num2str(maxrois)});
                try
                    maxrois=str2num(answer{1});
                end
                idx0=symrcm(M);
                docluster=false;
                TT=[];
            elseif strcmp(NCLUSTERS,'amd')
                maxrois=inf;
                answer=inputdlg({'Maximum number of ROIs per brain display /cluster (set to inf for one brain display per network)'},'display parameters',1,{num2str(maxrois)});
                try
                    maxrois=str2num(answer{1});
                end
                idx0=amd(M,struct('dense',sqrt(size(M,1))));
                docluster=true;
                TT=[];
            end
            if docluster
                [p,q,r,s]=dmperm(M(idx0,idx0));
                if ~isequal(p(:)',1:numel(p)),disp('warning, resorted ROIs'); end
                p=idx0(p);
            else
                p=idx0;
                aM=full(sum(M(:,p),1)>1);
                if all(aM)
                    r=[1,numel(p)+1];
                else
                    p=[p(~aM),p(aM)];
                    r=[1,sum(~aM)+1,numel(p)+1];
                end
            end
            n=diff(r);
            i=find(n>1);
            Nlabels=zeros(size(M,1),1); % node labels
            i0=0;
            for i1=1:numel(i)
                if n(i(i1))>maxrois
                    k=ceil(n(i(i1))/maxrois);
                    Nlabels(p(r(i(i1)):r(i(i1)+1)-1))=i0+ceil((1:n(i(i1)))/n(i(i1))*k);
                    i0=i0+k;
                else
                    Nlabels(p(r(i(i1)):r(i(i1)+1)-1))=i0+1;
                    i0=i0+1;
                end
            end
            if any(Nlabels==0)
                j=sum(Nlabels==0);
                if j>maxrois
                    k=ceil(j/maxrois);
                    Nlabels(Nlabels==0)=i0+ceil((1:j)/j*k);
                    i0=i0+k;
                else
                    Nlabels(Nlabels==0)=i0+1;
                    i0=i0+1;
                end
            end
            rankp=p;rankp(rankp)=1:numel(rankp);
            [nill,idx]=sortrows([Nlabels,rankp(:)]);
            data.clusters=zeros(N2,1);
            data.clusters(i2)=Nlabels+(min(Nlabels)==0);

            semic0=1-1/size(mask,2);
            if ~isempty(TT)
                TT=mean(detrend(cumsum([ones(1,size(TT,2));diff(TT(idx,:),1,1)~=0],1)./repmat(2:size(TT,2)+1,[size(TT,1),1]),'constant'),2)';
                xy=exp(1i*(linspace(-pi*(semic0-1e-4-semic0*.25/2),pi*(semic0-1e-4-semic0*.25/2),numel(i2))+semic0*.25*pi*TT));
            else
                xy=exp(1i*(linspace(-pi*(semic0-1e-4),pi*(semic0-1e-4),numel(i2))));
            end
            data.xy2=zeros(length(data.names2),2);
            data.xy2(data.displaytheserois(idx),:)=200*[real(xy)',imag(xy)'];
        elseif NCLUSTERS<1, 
            data.xy2=zeros(length(data.names2),2); data.xy2(data.displaytheserois,:)=200*[cos(2*pi*(0:numel(data.displaytheserois)-1)'/numel(data.displaytheserois)),sin(2*pi*(0:numel(data.displaytheserois)-1)'/numel(data.displaytheserois))]; 
            data.clusters=[];
        else
            %if isempty(which('dendrogram')), error('Sorry. This option requires matlab statistics toolbox'); end
            N=length(data.names);
            N2=length(data.names2);
            i1=intersect(1:N,data.displaytheserois);
            i2=intersect(1:N2,data.displaytheserois);
            if isequal(data.statsname,'T')
                switch(data.side),
                    case 1,p=data.p;
                    case 2,p=data.p2;
                    case 3,p=2*min(data.p,data.p2);
                end
                %set(data.handles(4),'enable','on','value',data.side);
            else
                p=data.p;
                %set(data.handles(4),'enable','off','value',3);
            end
            %X=data.h;
            if 1
                X=sign(data.h).*abs(data.F);
            else
                X=sign(data.h);
                switch(data.thrtype),
                    case 1, X(p>data.thr)=0;
                    case 2, X(data.P>data.thr)=0;
                end
            end
            X(isnan(X))=0;
            X(1:size(X,1)+1:size(X,1)*size(X,1))=0;
%             if size(data.results(1).xX.X,2)==1, 
%                 X(1:size(X,1)+1:size(X,1)*size(X,1))=1*max(max(abs(X(i1,i2))));
%             else X(1:size(X,1)+1:size(X,1)*size(X,1))=0;
%             end
            X=X(i1,i2);
            Xt=X;%[X;[1e2+zeros(1,N),zeros(1,N2-N)]];
            xyz2t=data.xyz2(i2,:);%[data.xyz2(i2,:),[1e2+zeros(N,1);zeros(N2-N,1)]];
            names2t=data.names2(i2);
            xyz2t=xyz2t*diag([2,1,1]); % bias x-dir
            
            [j1,j2,j3]=find(X);
            I=tril(ones(size(X,2)),-1);
            Y=sqrt(max(0,permute(sum(abs(conn_bsxfun(@minus,Xt,permute(Xt,[1 3 2]))).^2,1),[3 2 1])-sparse(j1,j2,j3.^2,size(X,2),size(X,2))-sparse(j2,j1,j3.^2,size(X,2),size(X,2)))); % removes diagonal elements of correlation matrix from distance computation
            Y=Y(I>0)';
            if LAMBDAPOS>=0
                Y2=sqrt(max(0,permute(sum(abs(conn_bsxfun(@minus,xyz2t,permute(xyz2t,[3 2 1]))).^2,2),[1 3 2])));
                Y2=Y2(I>0)';
            else
                Y2=conn_wordld(names2t,names2t);
                Y2=Y2(I>0)';
            end
            %figure
            %Y = sqrt(pdist(Xt', 'euclidean').^2-squareform(sparse(j1,j2,j3.^2,size(X,2),size(X,2))+sparse(j2,j1,j3.^2,size(X,2),size(X,2)))); % removes diagonal elements of correlation matrix from distance computation
            %Y2 = pdist(xyz2t, 'euclidean');
            Z = conn_statslinkage(sqrt((1-abs(LAMBDAPOS))*Y.^2/mean(Y.^2)+abs(LAMBDAPOS)*Y2.^2/mean(Y2.^2)), 'co');
            data.clusters_X=X;
            semic0=1-1/size(X,2);
            [H,t,idx]=conn_statsdendrogram(Z,0,'labels',data.names2(i2),'orientation','left');
            T = conn_statscluster(Z, 'maxclust', NCLUSTERS);
            data.clusters=zeros(N2,1); data.clusters(i2)=T;
            %for n1=1:NCLUSTERS,disp(' ');disp(['Cluster #',num2str(n1)]);disp(strvcat(data.names2{data.clusters==n1}));end
            TT=[]; for n1=1:min(size(X,2),NCLUSTERS), TT(:,n1) = conn_statscluster(Z, 'maxclust', n1); end; 
            if size(TT,2)>1, 
                TT=TT(:,2:end); TT=mean(detrend(cumsum([ones(1,size(TT,2));diff(TT(idx,:),1,1)~=0],1)./repmat(2:min(size(X,2),NCLUSTERS),[size(TT,1),1]),'constant'),2)';
                xy=exp(1i*(linspace(-pi*(semic0-1e-4-semic0*.25/2),pi*(semic0-1e-4-semic0*.25/2),numel(i2))+semic0*.25*pi*TT));
            else
                xy=exp(1i*(linspace(-pi*(semic0-1e-4),pi*(semic0-1e-4),numel(i2))));
            end
            data.xy2=zeros(length(data.names2),2);
            data.xy2(data.displaytheserois(idx),:)=200*[real(xy)',imag(xy)']; 
            figure(hfig);
        end
        data.proj=[];data.x=[];data.y=[];data.z=[];
        data.bgz=0;
        
%     case 'cluster',
%         hfig=gcf;
%         data=get(hfig,'userdata');
%         ncluster=varargin{1};
%         data.display='connectivity';
%         data.visible='on';
%         data.source=find(data.clusters==ncluster);
%         data.bgz=mean(data.z(data.source));
%         %set(data.handles(11),'value',max(0,min(1,data.bgz/200+.5)));
%         data.bgimage=spm_get_data(data.ref,pinv(data.ref.mat)*[data.proj(:,1:3)*[data.bgx(:),data.bgy(:),data.bgz+zeros(prod(size(data.bgx)),1)]';ones(1,prod(size(data.bgx)))]);
%         set(data.handles(6),'value',data.source);
%         %disp(['Cluster #',num2str(ncluster)]);disp(strvcat(data.names{data.source}));
end






% selects optimal view
if isempty(data.view),
    data.view=0;
end
% projector associated with view
if isempty(data.proj),
    switch(data.view),
        case 1, data.proj=[1,0,0;0,1,0;0,0,1];
        case 2, data.proj=[1,0,0;0,0,1;0,1,0];
        case 3, data.proj=[0,0,1;1,0,0;0,1,0];
        case 0, data.proj=[1,0,0;0,1,0;0,0,1];
    end
end
% projects coordinates and background image
scale=1;
if isempty(data.x)||isempty(data.y),
    if ~data.view
        data.x=data.xy2*data.proj(1:2,1);data.y=data.xy2*data.proj(1:2,2);data.z=zeros(size(data.xy2,1),1);
    else
        data.x=data.xyz2*data.proj(:,1);data.y=data.xyz2*data.proj(:,2);data.z=data.xyz2*data.proj(:,3);
        lim=[1,1,1;data.ref.dim];refminmax=sort([lim((dec2bin(0:7)-'0'+1)+repmat([0,2,4],[8,1])),ones(8,1)]*data.ref.mat(1:3,:)'*data.proj(:,1:2));
        [data.bgx,data.bgy]=meshgrid(refminmax(1,1):scale:refminmax(end,1),refminmax(1,2):scale:refminmax(end,2));
        data.bgimage=spm_get_data(data.ref,pinv(data.ref.mat)*[data.proj(:,1:3)*[data.bgx(:),data.bgy(:),data.bgz+zeros(prod(size(data.bgx)),1)]';ones(1,prod(size(data.bgx)))]);
    end
end
%if isequal(data.source,1:numel(data.displaytheserois)), data.source=0; end
N=length(data.names);
N2=length(data.names2);
switch(data.display),
    case 'connectivity',
        %cmap=jet(64);cmap=cmap(8:56,:);
        cmap=jet(256);cmap=cmap(32:224,:)*.8;
        maxdataclusters=max(data.clusters);
        if (numel(data.source)==1&&data.source>0), 
            set(data.handles([14 15 16 18]),'visible','off');
        else
            set(data.handles([14 15 16 18]),'visible','on');
        end
        if ~data.PERMenabled,
            set(data.handles(14),'string','threshold seed ROIs (F-test)','value',1);
            set(data.handles(10),'string','Enable permutation tests');
            data.mvpathrmeasure=1;
        else
            set(data.handles(14),'string',{'threshold seed ROIs (F-test)','threshold seed ROIs (NBS; by intensity)','threshold seed ROIs (NBS; by size)','threshold networks (NBS; by intensity)','threshold networks (NBS; by size)'});
            set(data.handles(10),'string','Disable permutation tests');
        end
        %if data.mvpathrmeasure==1, set(data.handles(16),'string',{'p-uncorrected','p-FDR'},'value',min(2,data.mvpathrtype)); data.mvpathrtype=min(2,data.mvpathrtype);
        %elseif data.mvpathrmeasure>3, set(data.handles(16),'string',{'p-uncorrected','p-FWE'},'value',min(2,data.mvpathrtype)); data.mvpathrtype=min(2,data.mvpathrtype);
        %else set(data.handles(16),'string',{'p-uncorrected','p-FDR','p-FWE'});
        %end
        if data.mvpathrmeasure==1, data.mvpathrtype=1+(data.mvpathrtype>1); set(data.handles(16),'value',data.mvpathrtype); 
        elseif data.mvpathrmeasure>3, data.mvpathrtype=1+2*(data.mvpathrtype>1); set(data.handles(16),'value',data.mvpathrtype); 
        end
        if data.mvpaenablethr, set(data.handles([14:16]),'enable','on');
        else set(data.handles([14:16]),'enable','off');
        end
        if data.enablethr, set(data.handles(1:4),'enable','on');
        else set(data.handles(1:4),'enable','off');
        end
        if isequal(data.statsname,'T')
            set(data.handles(4),'value',data.side); 
            if data.enablethr, set(data.handles(4),'enable','on'); end
        else
            set(data.handles(4),'enable','off','value',3);
        end
        %figure(hfig);
        set(0,'CurrentFigure',hfig);
        set(hfig,'pointer','watch');%drawnow;
        hcontrols=findobj(hfig,'enable','on');
        hcontrols=hcontrols(ishandle(hcontrols));
        set(hcontrols,'enable','off');
        th1=axes('units','norm','position',[0 0 .5 1]);th2=patch([0 0 1 1],[0 1 1 0],'k','edgecolor','none','facecolor',get(hfig,'color'),'facealpha',.5);set(th1,'xlim',[0 1],'ylim',[0 1],'visible','off'); drawnow; delete([th1 th2]);
        
        %set(data.handles(17),'value',data.mvpasortresultsby);
        mvpaenabled=data.mvpaenablethr&&~(numel(data.source)==1&&data.source>0);

        % computes stat threshold
        if isequal(data.statsname,'T')
            switch(data.side),
                case 1,p=data.p;
                case 2,p=data.p2;
                case 3,p=2*min(data.p,data.p2);
            end
        else
            p=data.p;
        end
        p(setdiff(1:N,data.displaytheserois),:)=nan;
        p(:,setdiff(1:N2,data.displaytheserois))=nan;
        if data.thrtype==3
            if any(~data.source), P=reshape(conn_fdr(p(:)),size(p));
            else P=nan(size(p)); tempidx=data.source(data.source>0&data.source<=length(data.displaytheserois)); temp=p(intersect(1:N,data.displaytheserois(tempidx)),:); temp(:)=conn_fdr(temp(:)); P(intersect(1:N,data.displaytheserois(tempidx)),:)=temp; 
            end
        else P=conn_fdr(p,2);
        end
        data.P=P;
        mvpap=data.MVPAp;
        mvpap(setdiff(1:N,data.displaytheserois))=nan;
        if any(~data.source), mvpaP=conn_fdr(mvpap); 
        else mvpaP=nan(size(mvpap)); tempidx=data.source(data.source>0&data.source<=length(data.displaytheserois)); temp=mvpap(intersect(1:N,data.displaytheserois(tempidx))); temp(:)=conn_fdr(temp(:)); mvpaP(intersect(1:N,data.displaytheserois(tempidx)))=temp; end;
        data.MVPAP=mvpaP;
        
        if data.PERMenabled&&(isempty(data.PERM)||~any(data.PERM.Pthr==data.thr&data.PERM.Pthr_type==data.thrtype&data.PERM.Pthr_side==data.side))
            % update permutation tests
            niterations=10000;
            Y=permute(cat(4,data.results.y),[1,3,4,2]);
            Y=Y(:,:,data.displaytheserois(data.displaytheserois<=N),data.displaytheserois);
            tthr=[.05 .01 .001 .0001 .20 .10 .05 .01];
            tthrtype=[1 1 1 1 2 2 2 2];
            tthrside=repmat(data.side,1,8);
            if data.thrtype==1, tthr=tthr(tthrtype==1);tthrside=tthrside(tthrtype==1);tthrtype=tthrtype(tthrtype==1); end
            if ~any(tthr==data.thr&tthrtype==data.thrtype&tthrside==data.side), tthr=[data.thr, tthr]; tthrtype=[data.thrtype, tthrtype]; tthrside=[data.side, tthrside]; end
            try
                data.PERM=conn_randomise(data.results(1).xX.X,Y,data.results(1).c,data.results(1).c2,tthr,tthrtype,tthrside,niterations,data.PERM);
            end
        end
        
        if data.enablethr
            if data.thrtype==1, show=p<=data.thr;
            else show=P<=data.thr;
            end
        else show=~isnan(p);
        end
        show(setdiff(1:N,data.displaytheserois),:)=0;
        show(:,setdiff(1:N2,data.displaytheserois))=0;
        V=double(show); V(show)=abs(data.F(show));
        % cluster-size & cluster-mass for each cluster
        [nclL,CLUSTER_labels]=conn_clusters(show);
        CLroi_labels=max(CLUSTER_labels,[],2);
        mask=CLUSTER_labels>0;
        mclL=accumarray(CLUSTER_labels(mask),V(mask),[max([0,max(CLUSTER_labels(mask))]),1]);
        % seed-size & seed-mass for each seed
        nsdL=sum(show,2);
        msdL=sum(V,2);
        if ~isempty(data.PERM)&&any(data.PERM.Pthr==data.thr&data.PERM.Pthr_type==data.thrtype&data.PERM.Pthr_side==data.side)
            data.iPERM=find(data.PERM.Pthr==data.thr&data.PERM.Pthr_type==data.thrtype&data.PERM.Pthr_side==data.side,1);
            if nnz(data.PERM.Hist_Seed_size{data.iPERM})<2, PERMp_seed_size_unc=double(1+nsdL<=find(data.PERM.Hist_Seed_size{data.iPERM})); 
            else PERMp_seed_size_unc=max(0,min(1,interp1(find(data.PERM.Hist_Seed_size{data.iPERM}),flipud(cumsum(flipud(nonzeros(data.PERM.Hist_Seed_size{data.iPERM})))),1+nsdL,'linear','extrap')));
            end
            PERMp_seed_size_unc(setdiff(1:N,data.displaytheserois))=nan;
            temp=PERMp_seed_size_unc;
            if any(~data.source), tempP=conn_fdr(temp);
            else tempP=nan(size(temp)); tempidx=data.source(data.source>0&data.source<=length(data.displaytheserois)); temp=temp(intersect(1:N,data.displaytheserois(tempidx))); temp(:)=conn_fdr(temp(:)); tempP(intersect(1:N,data.displaytheserois(tempidx)))=temp; end;
            PERMp_seed_size_FDR=tempP;
            PERMp_seed_size_FWE=mean(conn_bsxfun(@ge,data.PERM.Dist_Seed_sizemax{data.iPERM}',nsdL),2);
            PERMp_seed_size_FWE(setdiff(1:N,data.displaytheserois))=nan;
            if nnz(data.PERM.Hist_Seed_mass{data.iPERM})<2, PERMp_seed_mass_unc=double(1+round(data.PERM.maxT*msdL)<=find(data.PERM.Hist_Seed_mass{data.iPERM})); 
            else PERMp_seed_mass_unc=max(0,min(1,interp1(find(data.PERM.Hist_Seed_mass{data.iPERM}),flipud(cumsum(flipud(nonzeros(data.PERM.Hist_Seed_mass{data.iPERM})))),1+round(data.PERM.maxT*msdL),'linear','extrap')));
            end
            PERMp_seed_mass_unc(setdiff(1:N,data.displaytheserois))=nan;
            temp=PERMp_seed_mass_unc;
            if any(~data.source), tempP=conn_fdr(temp);
            else tempP=nan(size(temp)); tempidx=data.source(data.source>0&data.source<=length(data.displaytheserois)); temp=temp(intersect(1:N,data.displaytheserois(tempidx))); temp(:)=conn_fdr(temp(:)); tempP(intersect(1:N,data.displaytheserois(tempidx)))=temp; end;
            PERMp_seed_mass_FDR=tempP;
            PERMp_seed_mass_FWE=mean(conn_bsxfun(@ge,data.PERM.Dist_Seed_massmax{data.iPERM}',msdL),2);
            PERMp_seed_mass_FWE(setdiff(1:N,data.displaytheserois))=nan;

            if nnz(data.PERM.Hist_Cluster_size{data.iPERM})<2, PERMp_cluster_size_unc=double(1+nclL<=find(data.PERM.Hist_Cluster_size{data.iPERM})); 
            else PERMp_cluster_size_unc=max(0,min(1,interp1(find(data.PERM.Hist_Cluster_size{data.iPERM}),flipud(cumsum(flipud(nonzeros(data.PERM.Hist_Cluster_size{data.iPERM})))),1+nclL,'linear','extrap')));
            end
            PERMp_cluster_size_FDR=conn_fdr(PERMp_cluster_size_unc);
            PERMp_cluster_size_FWE=mean(conn_bsxfun(@ge,data.PERM.Dist_Cluster_sizemax{data.iPERM}',nclL),2);
            
            if nnz(data.PERM.Hist_Cluster_mass{data.iPERM})<2, PERMp_cluster_mass_unc=double(1+round(data.PERM.maxT*mclL)<=find(data.PERM.Hist_Cluster_mass{data.iPERM})); 
            else PERMp_cluster_mass_unc=max(0,min(1,interp1(find(data.PERM.Hist_Cluster_mass{data.iPERM}),flipud(cumsum(flipud(nonzeros(data.PERM.Hist_Cluster_mass{data.iPERM})))),1+round(data.PERM.maxT*mclL),'linear','extrap')));
            end
            PERMp_cluster_mass_FDR=conn_fdr(PERMp_cluster_mass_unc);
            PERMp_cluster_mass_FWE=mean(conn_bsxfun(@ge,data.PERM.Dist_Cluster_massmax{data.iPERM}',mclL),2);
            
            %disp('mass');disp(char(data.names(find(PERMp_seed_mass_FWE<=.05))));
            %disp('size');disp(char(data.names(find(PERMp_seed_size_FWE<=.05))));
        else
            data.iPERM=[];
        end
        if mvpaenabled,
            switch(data.mvpathrmeasure)
                case 1, % seeds (multivariate)
                    switch(data.mvpathrtype),
                        case 1, seedmask=data.MVPAp;
                        case {2,3}, seedmask=data.MVPAP;
                    end
                    netmask=zeros(size(nclL));
                case 2, % seeds (mass)
                    switch(data.mvpathrtype),
                        case 1, seedmask=PERMp_seed_mass_unc;
                        case 2, seedmask=PERMp_seed_mass_FDR;
                        case 3, seedmask=PERMp_seed_mass_FWE;
                    end
                    netmask=zeros(size(nclL));
                case 3, % seeds (size)
                    switch(data.mvpathrtype),
                        case 1, seedmask=PERMp_seed_size_unc;
                        case 2, seedmask=PERMp_seed_size_FDR;
                        case 3, seedmask=PERMp_seed_size_FWE;
                    end
                    netmask=zeros(size(nclL));
                case 4, % networks (mass)
                    switch(data.mvpathrtype),
                        case 1, netmask=PERMp_cluster_mass_unc;
                        case {2,3}, netmask=PERMp_cluster_mass_FWE;
                    end
                    seedmask=zeros(size(data.MVPAp));
                case 5, % networks (size)
                    switch(data.mvpathrtype),
                        case 1, netmask=PERMp_cluster_size_unc;
                        case {2,3}, netmask=PERMp_cluster_size_FWE;
                    end
                    seedmask=zeros(size(data.MVPAp));
            end
        else
            seedmask=zeros(size(data.MVPAp));
            netmask=zeros(size(nclL));
        end
        %if data.displayreduced, p=p(:,1:N); end
        %p=p(intersect(1:N,data.displaytheserois),data.displaytheserois);
        seedmask(setdiff(1:N,data.displaytheserois))=nan;
%         if isfield(data,'displayeffectsize')&&data.displayeffectsize>0
%             z=abs(data.h);
%         elseif isfield(data,'displayeffectsize')&&data.displayeffectsize<0
%             z=ones(size(data.h));
%         else
            z=abs(data.F);
%         end
        z(isnan(z))=0;
        seedz=data.MVPAF;
%         maxz=max(abs(z(:)));
%         if maxz>0, z(z>0)=z(z>0)/maxz; end
        if data.enablethr
            switch(data.thrtype),
                case 1, z(p>data.thr)=0;
                case {2,3}, z(P>data.thr)=0;
            end
        end
        %if ~isfield(data,'mvpathrtype'), data.mvpathrtype=2; end
        %if ~isfield(data,'mvpathr'), data.mvpathr=.05; end
        netz=ones(size(netmask));
        if mvpaenabled, 
            if data.mvpathrmeasure>3
                netz(netmask>data.mvpathr)=0;
                seedz(~ismember(CLroi_labels,find(netz)))=0;
            else
                seedz(seedmask>data.mvpathr)=0;
            end
        else
            seedz(~isnan(seedmask))=1;
        end
        z(seedz==0|isnan(seedz),:)=0;
        %if max(z(:))>0, z=ceil(z/max(z(:))*3); end
        z(isnan(p))=nan;
        seedz(isnan(mvpap))=nan;
        if ~any(~data.source), 
            z(setdiff(1:size(z,1),data.displaytheserois(data.source)),:)=nan; 
            seedz(setdiff(1:numel(seedz),data.displaytheserois(data.source)))=nan; 
        end
        maxz=max(abs(z(:)));
        if maxz>0, z(z>0)=z(z>0)/maxz; end
        
        if data.plotconnoptions.LCOLOR==1, 
            if isequal(data.statsname,'T'), set(data.legend(1:5),'visible','on'); 
            else set(data.legend([1 3 4]),'visible','on');set(data.legend([2 5]),'visible','off');
            end
            set(data.legend(6:end),'visible','off');
        elseif data.plotconnoptions.LCOLOR==2, set(data.legend,'visible','off');
        elseif data.plotconnoptions.LCOLOR==3, 
            set(data.legend(1:5),'visible','off'); set(data.legend([3 6:end]),'visible','on');
            set(data.legend(7),'string',num2str(maxz,'%.2f'));
            if isequal(data.statsname,'T'), 
                set(data.legend(6),'string',num2str(-maxz,'%.2f'));
                wtemp=linspace(-1,1,size(cmap,1));
            else 
                set(data.legend(6),'string','0');
                wtemp=linspace(0,1,size(cmap,1));
            end
            for ntemp=1:size(cmap,1), set(data.legend(7+ntemp),'facecolor',cmap(max(1,min(size(cmap,1), round(size(cmap,1)/2+size(cmap,1)/2*sign(wtemp(ntemp))*abs(wtemp(ntemp))^data.plotconnoptions.LCOLORSCALE) )) ,:)); end
        end
        
        % text lists
        if ~isfield(CONN_gui,'parse_html'), CONN_gui.parse_html={'<HTML><FONT color=rgb(100,100,100)>','</FONT></HTML>'}; end
        txt1={};for n1=1:length(data.displaytheserois),
            txt1{end+1}=(sprintf('%-s (%d)',data.names2{data.displaytheserois(n1)},n1));
            if data.displaytheserois(n1)>numel(data.names), txt1{end}=[CONN_gui.parse_html{1},txt1{end},CONN_gui.parse_html{2}]; end
        end;
        %txt1{end+1}=' ';
        txt1=char(txt1);%strvcat(txt1{:});
        %tp=[];sort2=[];txt2={};for n1=1:N,for n2=[1:n1-1,n1+1:N2+data.displayreduced*(N-N2)],
        tp3=[];sort3=[];txt3={};index3=[];
        parse_html1={'',''};%regexprep(CONN_gui.parse_html,{'<HTML>','</HTML>','<FONT color=rgb\(\d+,\d+,\d+\)>','</FONT>'},{'<HTML><pre>','</pre></HTML>','<b>','</b>'});
        parse_html2=regexprep(CONN_gui.parse_html,{'<HTML>','</HTML>','<FONT color=rgb\(\d+,\d+,\d+\)>'},{'<HTML><pre>','</pre></HTML>','<FONT color=rgb(128,0,0)>'});
        parse_html3=regexprep(CONN_gui.parse_html,{'<HTML>','</HTML>','<FONT color=rgb\(\d+,\d+,\d+\)>'},{'<HTML><pre>','</pre></HTML>','<FONT color=rgb(0,0,128)>'});
        tp4=[];txt4={};index4=[];
        switch(data.mvpathrmeasure)
            case 1, sortmeasure=-mclL;
            case {2,4}, sortmeasure=PERMp_cluster_mass_unc-1e-10*mclL;
            case {3,5}, sortmeasure=PERMp_cluster_size_unc-1e-10*nclL;
        end
        [nill,tidx]=sort(sortmeasure);
        for n1=1:numel(tidx),
            nb1=tidx(n1);
            if netz(nb1)>0
                if isempty(data.iPERM)||~data.PERMenabled,
                    txt4{end+1}=sprintf('%-30s  %-20s',sprintf('Network_%d/%d',n1,numel(netz)),['Intensity = ',num2str(mclL(nb1),'%0.2f')]);
                    tp4=cat(1,tp4,mclL(nb1));
                    index4(end+1)=nb1;
                    txt4{end+1}=sprintf('%-30s  %-20s','',['Size = ',num2str(nclL(nb1),'%d')]);
                    tp4=cat(1,tp4,mclL(nb1));
                    index4(end+1)=nb1;
                else
                    txt4{end+1}=sprintf('%-30s  %-20s  %6.4f  %6s  %6.4f',sprintf('Network_%d/%d',n1,numel(netz)),['Intensity = ',num2str(mclL(nb1),'%0.2f')],PERMp_cluster_mass_unc(nb1),'',PERMp_cluster_mass_FWE(nb1));
                    tp4=cat(1,tp4,mclL(nb1));
                    index4(end+1)=nb1;
                    txt4{end+1}=sprintf('%-30s  %-20s  %6.4f  %6s  %6.4f','',['Size = ',num2str(nclL(nb1),'%d')],PERMp_cluster_size_unc(nb1),'',PERMp_cluster_size_FWE(nb1));
                    tp4=cat(1,tp4,mclL(nb1));
                    index4(end+1)=nb1;
                end
            end
        end
        switch(data.mvpathrmeasure)
            case 1, sortmeasure=mvpaP-1e-10*abs(data.MVPAF);
            case {2,4}, sortmeasure=PERMp_seed_mass_unc-1e-10*msdL;
            case {3,5}, sortmeasure=PERMp_seed_size_unc-1e-10*nsdL;
        end
        for na1=1:length(data.displaytheserois),
            n1=data.displaytheserois(na1);
            if n1<=N&&seedz(n1)>0,
                %txt3{end+1}=sprintf('%-6s %6s  %6s  %6.2f  %4d  %6.4f  %6.4f',['(',num2str(na1),')'],'*   ','',data.MVPAF(n1),data.MVPAdof(n1,end),data.MVPAp(n1),data.MVPAP(n1));
                if numel(data.names2reduced{n1})<=30
                    txt3{end+1}=sprintf('%-30s  %-20s  %6.4f  %6.4f',[' Seed  ',data.names2reduced{n1}],[data.MVPAstatsname,'(',num2str(data.MVPAdof(n1,end)),') = ',num2str(data.MVPAF(n1),'%0.2f')],data.MVPAp(n1),data.MVPAP(n1));
                else
                    txt3{end+1}=sprintf('%-30s  %-20s  %6.4f  %6.4f',[' Seed  (',num2str(na1),')'],[data.MVPAstatsname,'(',num2str(data.MVPAdof(n1,end)),') = ',num2str(data.MVPAF(n1),'%0.2f')],data.MVPAp(n1),data.MVPAP(n1));
                end
                txt3{end}=[parse_html1{1},txt3{end},parse_html1{2}];
                tp3=cat(1,tp3,sortmeasure(n1)); sort3=cat(1,sort3,n1);
                index3(end+1)=na1;
                if isempty(data.iPERM)||~data.PERMenabled%||~permenabled
                    txt3{end+1}=sprintf('%-30s  %-20s',[''],['Intensity = ',num2str(msdL(n1),'%0.2f')]);
                    txt3{end}=[parse_html1{1},txt3{end},parse_html1{2}];
                    tp3=cat(1,tp3,sortmeasure(n1)); sort3=cat(1,sort3,n1);
                    index3(end+1)=na1;
                    txt3{end+1}=sprintf('%-30s  %-20s',[''],['Size = ',num2str(nsdL(n1),'%d')]);
                    txt3{end}=[parse_html1{1},txt3{end},parse_html1{2}];
                    tp3=cat(1,tp3,sortmeasure(n1)); sort3=cat(1,sort3,n1);
                    index3(end+1)=na1;
                else
                    txt3{end+1}=sprintf('%-30s  %-20s  %6.4f  %6.4f  %6.4f',[''],['Intensity = ',num2str(msdL(n1),'%0.2f')],PERMp_seed_mass_unc(n1),PERMp_seed_mass_FDR(n1),PERMp_seed_mass_FWE(n1));
                    txt3{end}=[parse_html1{1},txt3{end},parse_html1{2}];
                    tp3=cat(1,tp3,sortmeasure(n1)); sort3=cat(1,sort3,n1);
                    index3(end+1)=na1;
                    txt3{end+1}=sprintf('%-30s  %-20s  %6.4f  %6.4f  %6.4f',[''],['Size = ',num2str(nsdL(n1),'%d')],PERMp_seed_size_unc(n1),PERMp_seed_size_FDR(n1),PERMp_seed_size_FWE(n1));
                    txt3{end}=[parse_html1{1},txt3{end},parse_html1{2}];
                    tp3=cat(1,tp3,sortmeasure(n1)); sort3=cat(1,sort3,n1);
                    index3(end+1)=na1;
                        %nsdL(n1),PERMp_seed_size_unc(n1),PERMp_seed_size_FDR(n1),PERMp_seed_size_FWE(n1));
                end
            end
        end
        [nill,idxsort3]=sort(tp3); sort3=sort3(idxsort3,:); txt3=txt3(idxsort3); index3=index3(idxsort3);
        %[nill,idxsort3]=sort(tp3-10*(1+tp4(1+CLroi_labels(index3)))); sort3=sort3(idxsort3,:); txt3=txt3(idxsort3); index3=index3(idxsort3);
        
        tp2=[];sort2=[];txt2={};index2=[];
        sortmeasure=P-1e-10*abs(data.F);
        for na1=1:length(data.displaytheserois),
            n1=data.displaytheserois(na1);
            for na2=1:length(data.displaytheserois),
                n2=data.displaytheserois(na2);
                if n1<=N&&n1~=n2&&z(n1,n2)>0,
                    index2(end+1)=na1;
                    %txt2{end+1}=(sprintf('%-6s %-6s  %6.2f  %6.2f  %4d  %6.4f  %6.4f',['(',num2str(na1),')'],['(',num2str(na2),')'],data.h(n1,n2),data.F(n1,n2),data.dof(n1,end),p(n1,n2),P(n1,n2))); 
                    if numel(data.names2reduced{n1})<=13, tname1=data.names2reduced{n1}; else tname1=sprintf('(%d)',na1); end
                    if numel(data.names2reduced{n2})<=13, tname2=data.names2reduced{n2}; else tname2=sprintf('(%d)',na2); end
                    txt2{end+1}=sprintf('%-30s  %-20s  %6.4f  %6.4f',['  ',tname1,'-',tname2],sprintf('%s(%d) = %.2f',data.statsname,data.dof(n1,end),data.F(n1,n2)),p(n1,n2),P(n1,n2));
                    %if numel(data.names2reduced{n1})<=5, tname1=data.names2reduced{n1}; else tname1=['(',num2str(na1),')']; end
                    %if numel(data.names2reduced{n2})<=5, tname2=data.names2reduced{n2}; else tname2=['(',num2str(na2),')']; end
                    %txt2{end+1}=sprintf('%-20s  %-20s  %6.4f  %6.4f',['  conn ',tname1,'-',tname2],[data.statsname,'(',num2str(data.dof(n1,end)),') = ',num2str(data.F(n1,n2),'%0.2f')],p(n1,n2),P(n1,n2));
                    if data.h(n1,n2)>=0, txt2{end}=[parse_html2{1},txt2{end},parse_html2{2}];
                    else                 txt2{end}=[parse_html3{1},txt2{end},parse_html3{2}];
                    end
                    tp2=cat(1,tp2,sortmeasure(n1,n2)); sort2=cat(1,sort2,[n1,n2]);
                end
            end
        end
        [nill,idxsort2]=sort(tp2); sort2=sort2(idxsort2,:); txt2=txt2(idxsort2); index2=index2(idxsort2);
        
        txt={};
        data.list2=[];
        done2=ones(size(index2));
        done3=ones(size(index3));
        done4=ones(size(index4));
        if data.mvpasortresultsby==3,%data.PERMenabled&&mvpaenabled&&data.mvpathrmeasure>3
            for curcl=1:numel(txt4)
                if done4(curcl)>0
                    i=find(index4==index4(curcl));
                    if ~isempty(i)
                        txt=cat(2,txt,txt4(i));
                        data.list2=cat(1,data.list2,[zeros(numel(i),2),index4(curcl)+zeros(numel(i),1)]);
                        done4(i)=0;
                    end
                    for na1=find(CLroi_labels(index3)==index4(curcl))'
                        if done3(na1)>0
                            i=find(index3==index3(na1));
                            if ~isempty(i)
                                txt=cat(2,txt,txt3(i));
                                done3(i)=0;
                                data.list2=cat(1,data.list2,[sort3(i),zeros(numel(i),1),index4(curcl)+zeros(numel(i),1)]);
                            end
                            
                            idx2=find(index2==index3(na1)&done2);
                            if ~isempty(idx2)
                                txt=cat(2,txt,txt2(idx2));
                                done2(idx2)=0;%index2(idx2)=0;
                                data.list2=cat(1,data.list2,[sort2(idx2,:),index4(curcl)+zeros(numel(idx2),1)]);
                            end
                        end
                    end
                end
            end
        elseif data.mvpasortresultsby==2
            for na1=1:numel(txt3)
                if done3(na1)>0
                    i=find(index3==index3(na1));
                    if ~isempty(i)
                        txt=cat(2,txt,txt3(i));
                        done3(i)=0;
                        data.list2=cat(1,data.list2,[sort3(i),zeros(numel(i),2)]);
                    end
                    idx2=find(index2==index3(na1)&done2);
                    if ~isempty(idx2)
                        txt=cat(2,txt,txt2(idx2));
                        done2(idx2)=0;
                        data.list2=cat(1,data.list2,[sort2(idx2,:),zeros(numel(idx2),1)]);
                    end
                end
            end
        else
            txt=txt2;
            data.list2=[sort2,zeros(size(sort2,1),1)];
            done2(:)=0;
        end
        idx2=find(done2>0);
        if ~isempty(idx2)
            txt=cat(2,txt,txt2(idx2));
            index2(idx2)=0;
            data.list2=cat(1,data.list2,[sort2(idx2,:),zeros(numel(idx2),1)]);
        end
        txt{end+1}=' ';
        txt=char(txt);
        
%         [nill,idxsort]=sort(tp2); data.list2=sort2(idxsort,:); txt2=strvcat(txt2{idxsort},' ');
%         
        if isequal(data.source,0), set(data.handles(6),'string',txt1,'value',max(1,min(size(txt1,1), 1:numel(data.displaytheserois))));
        else set(data.handles(6),'string',txt1,'value',max(1,min(size(txt1,1), max(1,unique(data.source))))); %get(data.handles(6),'value'))));
        end
        if get(data.handles(6),'listboxtop')>size(get(data.handles(6),'string'),1), set(data.handles(6),'listboxtop',1); end
        set(data.handles(8),'string',txt,'value',max(1,min(size(txt,1), get(data.handles(8),'value'))));
        if get(data.handles(8),'listboxtop')>size(get(data.handles(8),'string'),1), set(data.handles(8),'listboxtop',1); end
        if ~isfield(data,'displaylabels'),data.displaylabels=0;end
        if ~isfield(data,'displaybrains'),data.displaybrains=0;end
        
        % plots
        EPS=1e-0;
        LABELONSIGNONLY=data.displaylabels<1;
        SQUAREALLROIS=false;
        OFFSET=.15;
        EMPH=2+2*(any(~data.source)|numel(data.source)>1);
        
        if ~data.view&&isfield(data,'displaybrains')&&data.displaybrains>1
            if isempty(data.clusters), NPLOTS=data.plotconnoptions.NPLOTS;
            else NPLOTS=max(data.clusters); 
            end
            offset=OFFSET+data.plotconnoptions.DOFFSET*(data.displaylabels>0);
            xy=data.x+1i*data.y;
            mr=mean(data.plotconnoptions.rende.vertices,1);
            data.xb=zeros(size(data.x));
            data.yb=zeros(size(data.y));
            data.zb=zeros(size(data.y));
            data.bclusters=zeros(size(data.x));
            for n1=1:NPLOTS,
                if isempty(data.clusters), idx=find(abs(angle(xy.*exp(-1i*2*pi/NPLOTS*n1)))<2*pi/NPLOTS/2);
                    %idx=find(max(1,min(NPLOTS,ceil((angle(xy)+pi)/2/pi*NPLOTS)))==n1);
                else idx=find(data.clusters==n1); 
                end
                if ~isempty(idx)
                    mx=mean(xy(idx));
                    px=cos(angle(mx));
                    py=sin(angle(mx));
                    if ~data.plotconnoptions.nprojection
                        cprojection=cellfun(@(x)sum(std(data.xyz2(idx,:)*x(1:2,:)',1,1).^2),data.plotconnoptions.Projections);
                        %cprojection(2)=nan;
                        [nill,nprojection]=max(cprojection);
                    else
                        nprojection=data.plotconnoptions.nprojection;
                    end
                    p=data.plotconnoptions.Projections{nprojection}'*(1+offset)*data.plotconnoptions.BSCALE;
                    if nprojection==1&&mean(data.xyz2(idx,1)>0)>.5, p(:,1)=-p(:,1); end
                    xy2=[data.xyz2(idx,:)-mr(ones(numel(idx),1),:),ones(numel(idx),1)]*[p;(1+offset)*(1+.75*data.plotconnoptions.BSCALE)*200*px,(1+offset)*(1+.75*data.plotconnoptions.BSCALE)*200*py,0];
                    data.xb(idx)=xy2(:,1);
                    data.yb(idx)=xy2(:,2);
                    data.zb(idx)=xy2(:,3);
                    data.bclusters(idx)=n1;
                end
            end
        end
        
%         figure(hfig);set(hfig,'pointer','watch');%drawnow;
%         th1=axes('units','norm','position',[.03,.06,.45,.88]);th2=patch([0 0 1 1],[0 1 1 0],'k');set(th2,'facealpha',.5);set(th1,'xlim',[0 1],'ylim',[0 1],'visible','off'); drawnow; delete([th1 th2]);
        if ~data.view, set(hfig,'color',data.plotconnoptions.BCOLOR); else set(hfig,'color','w'); end
        rcircle=(1+.25*(data.displaylabels>0)*(data.view>0))*[sin(linspace(0,2*pi,64)'),cos(linspace(0,2*pi,64))']*diag([5,5]);
        rtriang=[-1-1i*.5;0;-1+1i*.5];
        rsquare=([0,-.5;0,.5;1,.5;1,-.5])*diag([20,min(20,1.1*2*pi*200/length(data.displaytheserois))]);
        h=findobj(hfig,'tag','conn_displayroi_plot');
        if ~isempty(h),
            delete(h); 
        end
        h=axes('units','norm','position',[.01,.06,.48,.88]);
        if data.view
            lim=[1,1,1;data.ref.dim];refminmax=sort([lim((dec2bin(0:7)-'0'+1)+repmat([0,2,4],[8,1])),ones(8,1)]*data.ref.mat(1:3,:)'*data.proj(:,1:2));
            temp=reshape(data.bgimage,size(data.bgx)); %convn(convn(reshape(data.bgimage,size(data.bgx)),conn_hanning(5),'same'),conn_hanning(5)','same'); 
            temp(isnan(temp))=0;
            temp=round(1+(1-.2*temp/max(temp(:)))*(size(get(hfig,'colormap'),1)-1));
            data.refaxes=image(refminmax(1,1):scale:refminmax(end,1),refminmax(1,2):scale:refminmax(end,2),temp);hold on;
            set(data.refaxes,'cdatamapping','direct');
        else
            if ~SQUAREALLROIS&&data.displaybrains<2,
                xy0=200*(cos(2*pi*linspace(0,1,1e3))'+1i*sin(2*pi*linspace(0,1,1e3))');
                patch(1.10*real(xy0),1.10*imag(xy0),-20+zeros(size(xy0)),'w','facecolor','none','edgecolor',.25+.5*get(data.hfig,'color'));
                patch(real(xy0),imag(xy0),-10+zeros(size(xy0)),'w','facecolor','none','edgecolor',.25+.5*get(data.hfig,'color'));
            end
            data.refaxes=gca;
        end
        h=gca;data.buttondown=struct('h1',h);set(h,'tag','conn_displayroi_plot');
        if data.plotconnoptions.menubar, hc1=hfig;delete(findobj(hfig,'type','uimenu','-and','-not','tag','donotdelete'));%uimenu(hfig,'Label','Display options');
        else hc1=uicontextmenu; 
        end
        %set(hc1,'tag','conn_displayroi_plot','callback',@(varargin)set(data.handles(20),'visible','off'));
        if data.view>0
            ht=uimenu(hc1,'Label','ROIs');
            uimenu(ht,'Label','show ROI labels','callback',{@conn_displayroi,'labelson'});
            uimenu(ht,'Label','do not show ROI labels','callback',{@conn_displayroi,'labelsoff'});
            uimenu(ht,'Label','increase labels fontsize','callback',{@conn_displayroi,'labels1'});
            uimenu(ht,'Label','decrease labels fontsize','callback',{@conn_displayroi,'labels2'});
            uimenu(ht,'Label','edit ROI labels','callback',{@conn_displayroi,'labelsedit'});
            ht=uimenu(hc1,'Label','Connections');
            uimenu(ht,'Label','color: positive/negative = red/blue','callback',{@conn_displayroi,'edgecolors1'});
            uimenu(ht,'Label','color: proportional to stats (rgb colormap)','callback',{@conn_displayroi,'edgecolors3'});
            uimenu(ht,'Label','color: increase rgb colormap contrast','callback',{@conn_displayroi,'edgecolors4'});
            uimenu(ht,'Label','color: decrease rgb colormap contrast','callback',{@conn_displayroi,'edgecolors5'});
            uimenu(ht,'Label','thickness: fixed width','callback',{@conn_displayroi,'edgewidths1'},'separator','on');
            uimenu(ht,'Label','thickness: proportional to stats','callback',{@conn_displayroi,'edgewidths2'});
            uimenu(ht,'Label','thickness: increase','callback',{@conn_displayroi,'edgewidths3'});
            uimenu(ht,'Label','thickness: decrease','callback',{@conn_displayroi,'edgewidths4'});
            %uimenu(ht,'Label','arrow-widths scaled by T-values','callback',{@conn_displayroi,'displayefffectsize-off'});
            %uimenu(ht,'Label','arrow-widths scaled by beta-values','callback',{@conn_displayroi,'displayefffectsize-on'});
            %uimenu(ht,'Label','fixed arrow-widths','callback',{@conn_displayroi,'displayefffectsize-none'});
            ht=uimenu(hc1,'Label','Options');
            uimenu(ht,'Label','Change background anatomical image','callback',{@conn_displayroi,'changebackground'});
            %ht=uimenu(hc1,'Label','Menubar');
            %uimenu(ht,'Label','on','callback',['set(gcbf,''menubar'',''figure'');']);
            %uimenu(ht,'Label','off','callback',['set(gcbf,''menubar'',''none'');']);
            uimenu(ht,'Label','Refresh','callback',{@conn_displayroi,'refresh'});
            uimenu(ht,'Label','Print (high-res)','callback',@(varargin)conn_print(fullfile(data.defaultfilepath,'print01.jpg')));
        else
            ht=uimenu(hc1,'Label','ROIs');
            uimenu(ht,'Label','view: show ROIs in ring only','callback',{@conn_displayroi,'brainsoff'});
            uimenu(ht,'Label','view: show ROIs in reference brain displays only','callback',{@conn_displayroi,'brainson'});
            uimenu(ht,'Label','view: show ROIs in ring and in reference brain displays','callback',{@conn_displayroi,'brainspartial'});
            %ht=uimenu(hc1,'Label','ROIs display order');
            uimenu(ht,'Label','order: original order','callback',{@conn_displayroi,'clusters',0},'separator','on');
            %ht1=uimenu(ht,'Label','Define new ROI ordering criterium');
            uimenu(ht,'Label','order: close ROIs are functionally similar (hierarchical clustering alg.)','callback',{@conn_displayroi,'clusters',12});
            %uimenu(ht,'Label','order ROIs by networks (minimum degree algorithm)','callback',{@conn_displayroi,'clusters','amd'});
            uimenu(ht,'Label','order: ROIs in the same subnetwork are always contiguous (minimum degree alg.)','callback',{@conn_displayroi,'clusters','hcnet'});
            uimenu(ht,'Label','order: minimize connection lengths (reverse Cuthill-McKee alg.)','callback',{@conn_displayroi,'clusters','symrcm'});
            uimenu(ht,'Label','order: export current order to workspace/file','callback',{@conn_displayroi,'exportROIconfiguration'});
            uimenu(ht,'Label','order: import ROI order from workspace/file','callback',{@conn_displayroi,'importROIconfiguration'});
            %ht=uimenu(hc1,'Label','ROI labels');
            uimenu(ht,'Label','labels: show ROI labels','callback',{@conn_displayroi,'labelson'},'separator','on');
            uimenu(ht,'Label','labels: show ROI labels for seed ROIs only','callback',{@conn_displayroi,'labelspartial'});
            uimenu(ht,'Label','labels: do not show ROI labels','callback',{@conn_displayroi,'labelsoff'});
            uimenu(ht,'Label','labels: increase labels fontsize','callback',{@conn_displayroi,'labels1'});
            uimenu(ht,'Label','labels: decrease labels fontsize','callback',{@conn_displayroi,'labels2'});
            uimenu(ht,'Label','labels: edit ROI labels','callback',{@conn_displayroi,'labelsedit'});
            ht=uimenu(hc1,'Label','Connections');
            uimenu(ht,'Label','color: positive/negative = red/blue','callback',{@conn_displayroi,'edgecolors1'});
            uimenu(ht,'Label','color: ring colorwheel','callback',{@conn_displayroi,'edgecolors2'});
            uimenu(ht,'Label','color: proportional to stats (rgb colormap)','callback',{@conn_displayroi,'edgecolors3'});
            uimenu(ht,'Label','color: increase rgb colormap contrast','callback',{@conn_displayroi,'edgecolors4'});
            uimenu(ht,'Label','color: decrease rgb colormap contrast','callback',{@conn_displayroi,'edgecolors5'});
            uimenu(ht,'Label','thickness: fixed width','callback',{@conn_displayroi,'edgewidths1'},'separator','on');
            uimenu(ht,'Label','thickness: proportional to stats','callback',{@conn_displayroi,'edgewidths2'});
            uimenu(ht,'Label','thickness: increase','callback',{@conn_displayroi,'edgewidths3'});
            uimenu(ht,'Label','thickness: decrease','callback',{@conn_displayroi,'edgewidths4'});
            uimenu(ht,'Label','opacity: fixed opacity','callback',{@conn_displayroi,'edgeopacity1'},'separator','on');
            uimenu(ht,'Label','opacity: proportional to stats','callback',{@conn_displayroi,'edgeopacity2'});
            uimenu(ht,'Label','opacity: increase','callback',{@conn_displayroi,'edgeopacity3'});
            uimenu(ht,'Label','opacity: decrease','callback',{@conn_displayroi,'edgeopacity4'});
            ht=uimenu(hc1,'Label','Options');
            uimenu(ht,'Label','Advanced display options','callback',{@conn_displayroi,'conndisplayoptions'});
            %ht=uimenu(hc1,'Label','Menubar');
            %uimenu(ht,'Label','on','callback',['set(gcbf,''menubar'',''figure'');']);
            %uimenu(ht,'Label','off','callback',['set(gcbf,''menubar'',''none'');']);
            uimenu(ht,'Label','Refresh','callback',{@conn_displayroi,'refresh'});
            uimenu(ht,'Label','Print (high-res)','callback',@(varargin)conn_print(fullfile(data.defaultfilepath,'print01.jpg')));
        end            
        if ~data.plotconnoptions.menubar
            set(data.refaxes,'uicontextmenu',hc1);
            set(hfig,'uicontextmenu',hc1);
        end
        
        data.plotsadd2=cell(1,size(data.list2,1));
        data.plotsadd3=cell(1,numel(data.names2));
        idxtext=[];
        hold on;
        K=[];KK=[];%J=0;
        for na1=1:length(data.displaytheserois),%size(z,2),%N2,
            n1=data.displaytheserois(na1);
            temp=data.h(z(:,n1)>0,n1);
            if n1<=size(z,1), temp=[temp;data.h(n1,z(n1,:)>0)']; end
            if data.plotconnoptions.LCOLOR==1,
                K(na1)=sum(temp>0)-sum(temp<0);
            else
                K(na1)=mean(sign(temp).*abs(temp).^data.plotconnoptions.LCOLORSCALE);
            end
            if ~(data.mvpaenablethr&&n1<=numel(seedz)&&seedz(n1)>0||data.enablethr&&(any(z(:,n1)>0)||data.enablethr&&n1<=size(z,1)&&any(z(n1,:)))), K(na1)=nan; end
            KK(n1)=K(na1);
            %J=max([J;abs(data.h(z(:,n1)>0&(1:size(z,1))'~=n1,n1))]);
            %if na1<=size(z,1), K(na1)=K(na1)+(sum(data.h(n1,z(n1,:)>0)>0,2)'-sum(data.h(n1,z(n1,:)>0)<0,2)');
            %end
        end
        KK=KK/max(eps,max(abs(K)));
        K=K/max(eps,max(abs(K)));
        %K(K>0)=K(K>0)/max(eps,max(K));
        %K(K<0)=K(K<0)/max(eps,max(-K));
        semic0=pi/3;
        semic1=linspace(-1,1,64)+1i*(cos(linspace(-semic0,semic0,64))-cos(semic0));
        semic2=linspace(-1,1,64)-1i*(cos(linspace(-semic0,semic0,64))-cos(semic0));
        ssemic1=[semic1,fliplr(semic1)];
        rsemic1=struct('vertices',zeros(2*numel(semic1),3), 'faces',[reshape([1:numel(semic1)-1; 2:numel(semic1)],1,[])' reshape([2:numel(semic1); 2*numel(semic1)-1:-1:numel(semic1)+1],1,[])' reshape([2*numel(semic1):-1:numel(semic1)+2;2*numel(semic1):-1:numel(semic1)+2],1,[])']);
        sf=ones(1,length(data.displaytheserois));
        markthese=zeros(length(data.names2),1);
        if data.displaybrains==2
            datax=data.xb;
            datay=data.yb;
            dataz=data.zb;
        else
            datax=data.x;
            datay=data.y;
            dataz=data.z;
        end
        cumpatch('init');
%         set(data.hfig,'windowbuttonmotionfcn',[]);
        ringsquares=struct('x',[],'y',[],'z',[],'h',[],'gca',gca,'gcf',data.hfig);

        for na1=1:length(data.displaytheserois),%size(z,2),%N2,
            n1=data.displaytheserois(na1);
            if (~data.view&&SQUAREALLROIS)||(0&any(na1==data.source)||(n1<=size(z,1)&&(any(z(n1,:)>0)&&data.enablethr||n1<=numel(seedz)&&seedz(n1)>0&&data.mvpaenablethr))||any(z(:,n1)>0)&&data.enablethr),%((n1<=size(z,1)||~data.displayreduced)&&any(z(:,n1)>0)),
                markthese(n1)=1;
                %if n1<=size(z,1), sf(na1)=max(sf(na1),max(z(n1,:))); end
                %if n1<=size(z,2), sf(na1)=max(sf(na1),max(z(:,n1))); end
                %if any(na1==data.source), sf(na1)=1; else sf(na1)=sf(na1)/3; end
                if data.view>0
                    if (n1<=size(z,1)&&any(z(n1,:)>0))||any(z(:,n1)>0),%||data.z(n1)>0
                        h=patch(datax(n1)+rcircle(:,1)*max(.5,1+1e-3*data.z(n1))*sf(na1),datay(n1)+rcircle(:,2)*max(.5,1+1e-3*data.z(n1))*sf(na1),max(1,5*data.z(n1))*EPS+200+zeros(size(rcircle,1),1),'w');
                        k=K(na1);%(sum(data.h(z(:,n1)>0,n1)>0,1)-sum(data.h(z(:,n1)>0,n1)<0,1))/max(eps,sum(data.h(z(:,n1)>0,n1)>0,1)+sum(data.h(z(:,n1)>0,n1)<0,1));
                        if 1,%numel(data.source)==1&&data.source~=0
                            if isnan(k), set(h,'facecolor','none');
                            else set(h,'facecolor',cmap(round(1+(size(cmap,1)-1)*(1+k)/2),:));
                            end
                            if n1<=size(z,1)&&seedz(n1)>0, set(h,'linewidth',2);
                            elseif any(na1==data.source)
                                if any(z(:,n1)>0)||(n1<=size(z,1)&&any(z(n1,:)>0)), set(h,'linewidth',2);
                                else set(h,'facecolor','w','zdata',get(h,'zdata')-max(1,5*data.z(n1))*EPS-200);%,'edgecolor','k','linewidth',1);
                                end
                            else set(h,'edgecolor','w','linewidth',1);
                            end
                        else
                            set(h,'facecolor','w');
                            if any(na1==data.source), set(h,'edgecolor','k','linewidth',2); else, set(h,'edgecolor','k','linewidth',1); end
                        end
                        hold on;
                        set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data.hfig,'interruptible','off');
                        data.plotsadd3{n1}=h;
                    end
                else
                    if data.displaybrains<2, % ring
                        k=K(na1);
                        zinc=200; %200;
                        tx=datax(n1)+rsquare*[(1+0*data.MVPAF(min(size(z,1),n1))*(n1<=size(z,1)&&seedz(n1)>=0))*datax(n1)/200;-datay(n1)/200]*max(.5,1+1e-3*data.z(n1))*sf(na1);
                        ty=datay(n1)+rsquare*[(1+0*data.MVPAF(min(size(z,1),n1))*(n1<=size(z,1)&&seedz(n1)>=0))*datay(n1)/200;datax(n1)/200]*max(.5,1+1e-3*data.z(n1))*sf(na1);
                        tz=max(1,5*data.z(n1))*EPS+zinc+zeros(size(rsquare,1),1);
                        h=patch(tx,ty,tz,1-get(data.hfig,'color'),'edgecolor','none');
                        if n1<=size(z,1)&&seedz(n1)>0, markthese(n1)=2; %set(h,'facecolor',1-get(data.hfig,'color')); 
                        elseif any(na1==data.source), %set(h,'facecolor',.4+.2*get(data.hfig,'color'));
                        else %set(h,'facecolor',.3+.4*get(data.hfig,'color'));
                        end
                        if isnan(k), set(h,'facecolor','none');
                        else set(h,'facecolor',cmap(round(1+(size(cmap,1)-1)*(1+k)/2),:));
                        end
                        hold on;
                        set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data.hfig,'interruptible','off');
                        ringsquares.x(:,end+1)=tx;
                        ringsquares.y(:,end+1)=ty;
                        ringsquares.z(:,end+1)=tz;
                        ringsquares.h(end+1)=h;
                        data.plotsadd3{n1}=h;
                    else
                        if n1<=size(z,1)&&seedz(n1)>0, markthese(n1)=2; end
                    end
                end
                %if all(data.h(z(:,n1)>0,n1)>0), set(h,'facecolor',[1,0,0]);%*(.5+.5*k/max(eps,max(sum(z>0,1)))));
                %elseif all(data.h(z(:,n1)>0,n1)<0), k=sum(data.h(z(:,n1)>0,n1)<0,1);set(h,'facecolor',[0,0,1]);%*(.5+.5*k/max(eps,max(sum(z>0,1)))));
                %else, set(h,'facecolor',[0,1,0]); end
            end
            if n1<=N,
                for na2=1:length(data.displaytheserois), % connections
                    n2=data.displaytheserois(na2); %n2=[1:n1-1,n1+1:N2],
                    %if n1~=n2&&((n1<n2&&z(n1,n2)>0)||(n1>n2&&z(n1,n2)>0&&n2<=N&&~(z(n2,n1)>0))), %(n2<=N||~data.displayreduced)&&(z(n1,n2)>0),
                    if n1~=n2&&z(n1,n2)>0, %(n2<=N||~data.displayreduced)&&(z(n1,n2)>0),
                        if n2<n1&&z(n2,n1)>0
                            idxplotsadd1=find(data.list2(:,1)==n1&data.list2(:,2)==n2);
                            idxplotsadd2=find(data.list2(:,1)==n2&data.list2(:,2)==n1);
                            if ~isempty(idxplotsadd1)&&~isempty(idxplotsadd2), data.plotsadd2(idxplotsadd1)=data.plotsadd2(idxplotsadd2); end
                        else
                            x=[datax([n1;n2]),datay([n1;n2])];
                            dx=([data.x([n2;n1]),data.y([n2;n1])]-[data.x([n1;n2]),data.y([n1;n2])])/200;
                            if data.view>0
                                dx=dx./repmat(max(eps,sqrt(sum(abs(dx).^2,2))),[1,2]);
                                %h=patch(x(:,1)+dx(:,1).*5,x(:,2)+dx(:,2).*5,0*max(1,data.z([n1;n2]))*EPS+.5,'r-','linewidth',round(1+3*z(n1,n2)),'facecolor','none','edgecolor',[1,.5,.5]+0*[0,1,1]*z(n1,n2),'edgealpha',.5,'visible',data.visible);
                                linewidth=max(1,abs(data.plotconnoptions.LINEWIDTH)*(4*(data.plotconnoptions.LINEWIDTH<0)*abs(z(n1,n2))+1*(data.plotconnoptions.LINEWIDTH>0))); % round(1+3*z(n1,n2))
                                h=plot3(x(:,1)+dx(:,1).*5,x(:,2)+dx(:,2).*5,0*max(1,data.z([n1;n2]))*EPS+.5,'r-','linewidth',linewidth,'color',[1,.5,.5]+0*[0,1,1]*z(n1,n2),'visible',data.visible);
                                idxplotsadd2=find((data.list2(:,1)==n1&data.list2(:,2)==n2)|(data.list2(:,1)==n2&data.list2(:,2)==n1));
                                if ~isempty(idxplotsadd2), data.plotsadd2(idxplotsadd2)={h}; end
                                %idxplotsadd2=find((data.list2(:,1)==n1&data.list2(:,2)==0)|(data.list2(:,1)==n2&data.list2(:,2)==0));
                                %for nt=1:numel(idxplotsadd2),data.plotsadd2{idxplotsadd2(nt)}=cat(2,data.plotsadd2{idxplotsadd2(nt)},h); end
                                %if data.h(n1,n2)<0, set(h,'color',[.5,.5,1]+0*[1,1,0]*z(n1,n2)); end
                                if data.plotconnoptions.LCOLOR==1
                                    if data.h(n1,n2)<0, set(h,'color',[.5,.5,1]); end
                                    %set(h,'edgecolor',cmap(ceil(size(cmap,1)/2)+round(floor(size(cmap,1)/2)*data.h(n1,n2)/J),:));
                                elseif data.plotconnoptions.LCOLOR==2
                                    tempc=(hsv2rgb([(1+angle(x(1))/pi)/2,1,1])+hsv2rgb([(1+angle(x(2))/pi)/2,1,1]))/2;
                                    set(h,'color',tempc);
                                else
                                    tempc=cmap(max(1,min(size(cmap,1), round(size(cmap,1)/2+sign(data.h(n1,n2))*abs(z(n1,n2))^data.plotconnoptions.LCOLORSCALE*size(cmap,1)/2))),:);
                                    set(h,'color',tempc);
                                end
                                %%set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data);
                                %rangle=rtriang*exp(j*angle(diff(datax([n1;n2])+j*datay([n1;n2]),1,1)))*(1/2+1/2*z(n1,n2));
                                %h=patch(x(2,1)+dx(2,1)*7+5*real(rangle),x(2,2)+dx(2,2)*7+5*imag(rangle),0*max(1,data.z(n2))*EPS+.5+zeros(size(rangle)),'w'); set(h,'edgecolor','none','facecolor',[1,.5,.5]+0*[0,1,1]*z(n1,n2),'visible',data.visible);
                                %if data.h(n1,n2)<0, set(h,'facecolor',[.5,.5,1]+0*[1,1,0]*z(n1,n2)); end
                            else
                                x=x*[1;1i];
                                dx=dx(1,:)*[1;1i];
                                if data.displaybrains==2&&isfield(data,'bclusters')&&length(data.bclusters)>=max(n1,n2)&&data.bclusters(n1)==data.bclusters(n2), lcurve=0;
                                else lcurve=data.plotconnoptions.LCURVE;
                                end
                                %lcurve=lcurve*sign(data.h(n1,n2));
                                if 1,
                                    xtracurve=(1+2*exp(-abs(dx)*20));
                                    temp=(real(semic1)+xtracurve*lcurve*1i*imag(semic1)*((1-(.98+.01*rand)*abs(dx(1)/2).^2)));
                                    xt1=(x(1)+x(2))/2 + (x(2)-x(1))/2 * temp;
                                    xt2=(x(1)+x(2))/2 - (x(2)-x(1))/2 * temp(end:-1:1);
                                elseif 0 %lcurve<0,
                                    xt1=(x(1)+(1+real(semic1))/2*(x(2)-x(1)))./(1-lcurve/4*(1-abs(real(semic1)).^2));
                                    xt2=xt1;
                                else
                                    tlcurve=1+lcurve*abs(dx(1)/2)*.5;
                                    w0=(.5+real(semic1)/2).^tlcurve;
                                    w1=x(1)*w0;
                                    w2=x(2)*fliplr(w0);
                                    xt1=w1+w2;
                                    xt2=xt1;
                                end
                                if lcurve*min(abs(xt1))<lcurve*min(abs(xt2)), xt=xt1; else xt=xt2; end
                                %h=patch(1*[real(xt),fliplr(real(xt))],1*[imag(xt),fliplr(imag(xt))],[linspace(data.xyz2(n1,3),data.xyz2(n2,3),numel(xt)),linspace(data.xyz2(n2,3),data.xyz2(n1,3),numel(xt))],'r','edgecolor',[1,.25,.25],'facecolor','none','edgealpha',.05+.95*z(n1,n2).^EMPH,'linewidth',data.plotconnoptions.LINEWIDTH*(1+0*(n1<=numel(seedz)&seedz(min(numel(seedz),n1))>0&n2<=numel(seedz)&seedz(min(numel(seedz),n2))>0)));
                                linewidth=max(1,abs(data.plotconnoptions.LINEWIDTH)*(4*(data.plotconnoptions.LINEWIDTH<0)*abs(z(n1,n2))+1*(data.plotconnoptions.LINEWIDTH>0)));
                                linetrans=min(1,max(.001,abs(data.plotconnoptions.LTRANS)*((data.plotconnoptions.LTRANS<0)*abs(z(n1,n2))+(data.plotconnoptions.LTRANS>0))));
                                %h=patch(1*[real(xt),fliplr(real(xt))],1*[imag(xt),fliplr(imag(xt))],(xy2(n1,3)+xy2(n2,3))/2+(xy2(n2,3)-xy2(n1,3))/2*real([semic1,fliplr(semic1)])+z(n1,n2)*EPS+.5+1000*abs(z(n1,n2))*[imag(semic1),fliplr(imag(semic1))],'r','edgecolor',[1,.25,.25],'facecolor','none','edgealpha',linetrans,'linewidth',linewidth); %max(1,data.plotconnoptions.LINEWIDTH*(1+0*(n1<=numel(seedz)&seedz(min(numel(seedz),n1))>0&n2<=numel(seedz)&seedz(min(numel(seedz),n2))>0)))));
                                tempc=[1 .25 .25];
                                if data.plotconnoptions.LCOLOR==1
                                    if data.h(n1,n2)<0, tempc=[.25,.25,1]; end
                                elseif data.plotconnoptions.LCOLOR==2
                                    tempc=(hsv2rgb([(1+angle(x(1))/pi)/2,1,1])+hsv2rgb([(1+angle(x(2))/pi)/2,1,1]))/2;
                                else
                                    tempc=cmap(max(1,min(size(cmap,1), round(size(cmap,1)/2+sign(data.h(n1,n2))*abs(z(n1,n2))^data.plotconnoptions.LCOLORSCALE*size(cmap,1)/2))),:);
                                end
                                %dwidth=1i*(xt(end)-xt(1));dwidth=1*linewidth*dwidth/abs(dwidth);
                                dwidth=1i*[xt(2)-xt(1) xt(3:end)-xt(1:end-2) xt(end)-xt(end-1)]; 
                                dwidth=max(2,(8+(linewidth-8)*(2*max(0,imag(semic1))).^.5)).*dwidth./abs(dwidth)/2;
                                tsemic1=rsemic1;
                                tsemic1.vertices=[[real(xt+dwidth),real(xt(end:-1:1)-dwidth(end:-1:1))]' ...
                                                  [imag(xt+dwidth),imag(xt(end:-1:1)-dwidth(end:-1:1))]' ...
                                                  [(dataz(n1)+dataz(n2))/2+(dataz(n2)-dataz(n1))/2*real(ssemic1)+0*z(n1,n2)*EPS+0*.5+100*abs(z(n1,n2))*imag(ssemic1)]'];
                                tsemic1.facevertexcdata=repmat(tempc,size(tsemic1.vertices,1),1);
                                tsemic1.facevertexalphadata=repmat(linetrans,size(tsemic1.vertices,1),1);
                                h=cumpatch(tsemic1,'edgecolor','none'); %max(1,data.plotconnoptions.LINEWIDTH*(1+0*(n1<=numel(seedz)&seedz(min(numel(seedz),n1))>0&n2<=numel(seedz)&seedz(min(numel(seedz),n2))>0)))));
                                %h=patch(tsemic1,'edgecolor','none','facecolor',tempc,'facealpha',linetrans); %max(1,data.plotconnoptions.LINEWIDTH*(1+0*(n1<=numel(seedz)&seedz(min(numel(seedz),n1))>0&n2<=numel(seedz)&seedz(min(numel(seedz),n2))>0)))));
%                                 h=patch([real(xt),fliplr(real(xt))],...
%                                     [imag(xt),fliplr(imag(xt))],...
%                                     (dataz(n1)+dataz(n2))/2+(dataz(n2)-dataz(n1))/2*real([semic1,fliplr(semic1)])+0*z(n1,n2)*EPS+0*.5+1000*abs(z(n1,n2))*[imag(semic1),fliplr(imag(semic1))],...
%                                     'r','edgecolor',tempc,'facecolor','none','edgealpha',linetrans,'linewidth',linewidth); %max(1,data.plotconnoptions.LINEWIDTH*(1+0*(n1<=numel(seedz)&seedz(min(numel(seedz),n1))>0&n2<=numel(seedz)&seedz(min(numel(seedz),n2))>0)))));
                                idxplotsadd2=find((data.list2(:,1)==n1&data.list2(:,2)==n2)|(data.list2(:,1)==n2&data.list2(:,2)==n1));
                                if ~isempty(idxplotsadd2), data.plotsadd2(idxplotsadd2)={h}; end
                                %idxplotsadd2=find((data.list2(:,1)==n1&data.list2(:,2)==0)|(data.list2(:,1)==n2&data.list2(:,2)==0));
                                %for nt=1:numel(idxplotsadd2),data.plotsadd2{idxplotsadd2(nt)}=cat(2,data.plotsadd2{idxplotsadd2(nt)},h); end
                                %if ~isempty(data.clusters), wcolor=data.clusters([n1,n2])/maxdataclusters; wcolor(~wcolor)=[]; if any(wcolor), set(h,'edgecolor',cmap(ceil(wcolor(ceil(numel(wcolor)*rand))*size(cmap,1)),:)); end; end
                                %if ~isempty(data.clusters), wcolor=data.clusters([n1,n2])>0; if any(wcolor), set(h,'edgecolor',wcolor'/sum(wcolor)*cmap(ceil(data.clusters([n1,n2])*size(cmap,1)/maxdataclusters),:)); end; end
                                %set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data);
                            end
                        end
                    end
                end
            end
            if (0&any(na1==data.source)||(n1<=size(z,1)&&(any(z(n1,:)>0)&&data.enablethr||n1<=numel(seedz)&&seedz(n1)>0&&data.mvpaenablethr))||any(z(:,n1)>0)&&data.enablethr),%((n1<=size(z,1)||~data.displayreduced)&&any(z(:,n1)>0)),
            %if any(na1==data.source)||(n1<=N&&(any(z(n1,:)>0)||seedz(n1)>0))||any(z(:,n1)>0), %||((n1<=N||~data.displayreduced)&&any(z(:,n1)>0)),
                %h=text(datax(n1),datay(n1),max(1,data.z(n1))*EPS+202,num2str(n1));
                %set(h,'fontsize',10,'color','w','horizontalalignment','center','interpreter','none','fontweight','bold','backgroundcolor','none');
                if data.view==0||(n1<=size(z,1)&&any(z(n1,:)>0))||any(z(:,n1)>0),%||data.z(n1)>0
                    idxtext=[idxtext;na1];
                end
                %%if any(n1==data.source), set(h,'color','k'); end
                %set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data);
            end
        end
        cumpatch('update');
%         conn_display_windowbuttonmotionfcn('init',ringsquares);
%         set(data.hfig,'windowbuttonmotionfcn',@conn_display_windowbuttonmotionfcn);
        if isfield(data,'displaylabels')&&data.displaylabels
            temp=data.names2reduced; for n1=1:numel(temp), if numel(temp{n1})>30, temp{n1}=temp{n1}(1:30); end; end
            tmvpaz=[seedz;0];
            h=text(1.02*datax(data.displaytheserois(idxtext)),1.02*datay(data.displaytheserois(idxtext)),...
                max(0,5*data.z(data.displaytheserois(idxtext)))*EPS+202,{temp{data.displaytheserois(idxtext)}});
                %(tmvpaz(min(numel(tmvpaz),data.displaytheserois(idxtext)))>0)+1002,{temp{data.displaytheserois(idxtext)}});
                %(seedz(data.displaytheserois(idxtext(data.displaytheserois(idxtext)<=size(z,1))))>0)+202,{temp{data.displaytheserois(idxtext)}});
            set(h,'tag','textstring','clipping','off');
            if data.view>0
                set(h,'fontsize',data.plotconnoptions.FONTSIZE,'color','k','horizontalalignment','center','interpreter','none','fontweight','normal','backgroundcolor','none');
            else
                fontsize=data.plotconnoptions.FONTSIZE;
                if isfield(data,'displaybrains')&&data.displaybrains, fontsize=max(4,fontsize-3); end
                set(h,'fontsize',fontsize,'color',.25+.25*get(data.hfig,'color'),'horizontalalignment','left','interpreter','none','fontweight','normal','backgroundcolor','none');
                if LABELONSIGNONLY, set(h,'visible','off'); end
                set(h(seedz(data.displaytheserois(idxtext(data.displaytheserois(idxtext)<=size(z,1))))>0),'color',1-get(data.hfig,'color'),'visible','on');%,'fontweight','bold');
                roundang=5; %45;
                for n1=1:numel(h),tpos=get(h(n1),'position');ang=angle(tpos*[1;1i;0])/pi*180+data.plotconnoptions.FONTANGLE;if abs(mod(ang,360)-180)<90, set(h(n1),'rotation',roundang*round(ang/roundang)+180,'position',tpos*1.10,'horizontalalignment','right'); else set(h(n1),'rotation',roundang*round(ang/roundang),'position',tpos*1.10); end; end
            end
            set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data.hfig,'interruptible','off');
        else
            data.displaylabels=0;
        end
        if ~data.view&&isfield(data,'displaybrains')&&data.displaybrains % brain displays
            if isempty(data.clusters), NPLOTS=data.plotconnoptions.NPLOTS;
            else NPLOTS=max(data.clusters); 
            end
            offset=OFFSET+data.plotconnoptions.DOFFSET*(data.displaylabels>0);
            xy=data.x+1i*data.y;
            mr=mean(data.plotconnoptions.rende.vertices,1);
            colors=[.3+.4*get(data.hfig,'color');1-get(data.hfig,'color')];
            for n1=1:NPLOTS,
                if isempty(data.clusters), idx=find(abs(angle(xy.*exp(-1i*2*pi/NPLOTS*n1)))<2*pi/NPLOTS/2);
                    %idx=find(max(1,min(NPLOTS,ceil((angle(xy)+pi)/2/pi*NPLOTS)))==n1);
                else idx=find(data.clusters==n1); 
                end
                idx1=find(markthese(idx)>0);
                if ~isempty(idx1)
                    mx=mean(xy(idx));
                    px=cos(angle(mx));
                    py=sin(angle(mx));
                    if isempty(data.clusters), a0=2*pi/NPLOTS*n1;
                    else a0=angle(mx);
                    end
                    if ~data.plotconnoptions.nprojection
                        cprojection=cellfun(@(x)sum(std(data.xyz2(idx,:)*x(1:2,:)',1,1).^2),data.plotconnoptions.Projections);
                        %cprojection(2)=nan;
                        [nill,nprojection]=max(cprojection);
                    else
                        nprojection=data.plotconnoptions.nprojection;
                    end
                    
                    p=data.plotconnoptions.Projections{nprojection}'*(1+offset)*data.plotconnoptions.BSCALE;
                    if nprojection==1&&mean(data.xyz2(idx,1)>0)>.5, p(:,1)=-p(:,1); end
                    rende=data.plotconnoptions.rende;
                    rende.vertices=[1.05*detrend(rende.vertices,'constant'),ones(size(rende.vertices,1),1)]*[p;(1+offset)*(1+.75*data.plotconnoptions.BSCALE)*200*px,(1+offset)*(1+.75*data.plotconnoptions.BSCALE)*200*py,0];
                    %h=patch(rende,'edgecolor','none','facecolor',.8-.6*get(data.hfig,'color'),'facealpha',data.plotconnoptions.BTRANS);
                    w=(-1+2*(mean(get(data.hfig,'color'))>.5))*rende.vertices(:,3); w=sqrt(max(0,0+1*(w-min(w(:)))/max(eps,max(w(:))-min(w(:)))));
                    h=patch(rende,'edgecolor','none','facevertexcdata',(1-w)*(1-get(data.hfig,'color'))+w*get(data.hfig,'color'),'facealpha',data.plotconnoptions.BTRANS,'facecolor','inter');
                    set(h,'tag','conn_displayroi_brain','buttondownfcn','conn_displayroi(''viewcycle'');','userdata',data.hfig);
                    hold on;
                    if data.displaybrains<2
                        plot((1+offset+.0*rem(n1,2))*200*[.98,ones(1,62),.98].*exp(1i*(a0+linspace(-0e-2+min(angle(xy(idx).*exp(-1i*a0))),0e-2+max(angle(xy(idx).*exp(-1i*a0))),64))),'k-','color',.1+.8*get(data.hfig,'color'),'linewidth',2);
                    end
                    %xy2=[datax(idx) datay(idx) dataz(idx)]; % roi positions in connections (ring/brain)
                    xy2=[data.xyz2(idx,:)-mr(ones(numel(idx),1),:),ones(numel(idx),1)]*[p;(1+offset)*(1+.75*data.plotconnoptions.BSCALE)*200*px,(1+offset)*(1+.75*data.plotconnoptions.BSCALE)*200*py,0]; % roi positions in brain 
                    for n2=idx1(:)' % rois in brains
                        zinc=100; %100; 
                        h=patch(xy2(n2,1)+data.plotconnoptions.RSCALE*rcircle(:,1)*(1+offset)*data.plotconnoptions.BSCALE*(2+0*markthese(idx(n2))),...
                            xy2(n2,2)+data.plotconnoptions.RSCALE*rcircle(:,2)*(1+offset)*data.plotconnoptions.BSCALE*(2+0*markthese(idx(n2))),...
                            xy2(n2,3)+zeros(size(rcircle,1),1)+zinc*markthese(idx(n2)),...
                            'k','facecolor',colors(markthese(idx(n2)),:),'edgecolor','none'); %1-get(data.hfig,'color'));
                        set(h,'tag','conn_displayroi_roi');
                        k=KK(idx(n2));
                        if isnan(k), set(h,'facecolor','none');
                        else set(h,'facecolor',cmap(round(1+(size(cmap,1)-1)*(1+k)/2),:));
                        end
                        set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',{data.hfig, idx(n2)},'interruptible','off');
                        %ttxt={['x,y,z = (',num2str(data.xyz2(idx(n2),1),'%1.0f'),',',num2str(data.xyz2(idx(n2),2),'%1.0f'),',',num2str(data.xyz2(idx(n2),3),'%1.0f'),') mm'],...
                        %    data.names2{idx(n2)}};
                        %set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',[{data.hfig} ttxt],'interruptible','off');
                        data.plotsadd3{idx(n2)}=[data.plotsadd3{idx(n2)},h];
                    end
                end
            end
        end
        
        %data.plotsadd2=data.plotsadd2(idxsort);
        hold off;
        set(gca,'ydir','normal');
        axis equal; axis off;
        if ~data.view&&data.displaylabels, 
            oldtlim=[nan nan nan nan];
            for nlim=1:10
                tlim=findobj(gca,'tag','textstring','visible','on');
                if ~isempty(tlim)
                    %tic; tlim=get(tlim,'extent'); toc
                    temp=get(tlim,'position');
                    if iscell(temp) temp=cell2mat(temp); end
                    [nill,temp]=sort(temp,1);
                    tlim=get(tlim(temp([1 end],:)),'extent');
                    if iscell(tlim) tlim=cell2mat(tlim(:)); end
                    tlim=[tlim(:,1:2);tlim(:,1:2)+tlim(:,3:4); [get(gca,'xlim')',get(gca,'ylim')']];
                    newtlim=[min(tlim(:,1))-0,max(tlim(:,1))+0,min(tlim(:,2))-0,max(tlim(:,2))+0];
                    if max(oldtlim-newtlim)<.01, break; end
                    set(gca,'xlim',newtlim(1:2),'ylim',newtlim(3:4));
                    oldtlim=newtlim;
                end
            end
        end
        %if ~data.view&&data.displaylabels&&data.displaybrains~=1, set(gca,'xlim',(1.5+.5*(data.displaylabels>0)+.5*data.displaybrains)*[-200,200]); end
        if data.display3d, data.display3d=0; datadisplay3d=1;else datadisplay3d=0; end
        set(hfig,'userdata',data);
        set(hcontrols(ishandle(hcontrols)),'enable','on');
        set(hfig,'pointer','arrow');

        if datadisplay3d
            c=mat2cell(cmap(round(1+(size(cmap,1)-1)*(1+K(idxtext))/2),:),ones(numel(idxtext),1),3);
            for n1=1:numel(data.source),idxc=find(idxtext==data.source(n1));c(idxc,:)=repmat({[.25,.25,.25]},[numel(idxc),1]); end
            % ring placeholder xyz/2
            conn_mesh_display('','',[],...
                struct('sph_names',{data.names2reduced(data.displaytheserois(idxtext))},'sph_xyz',[data.x(data.displaytheserois(idxtext)),data.y(data.displaytheserois(idxtext)),data.z(data.displaytheserois(idxtext))],...
                 'sph_r',3*ones(numel(idxtext),1),...
                 'sph_c',{c}),...%{repmat({[.9,.9,.9]},[1,numel(idxtext)])}), ...
                z(data.displaytheserois(idxtext(data.displaytheserois(idxtext)<=size(z,1))),data.displaytheserois(idxtext)).*sign(data.h(data.displaytheserois(idxtext(data.displaytheserois(idxtext)<=size(z,1))),data.displaytheserois(idxtext))), ...
                .2, [0,-.01,1],[],data.defaultfilepath);
        end
        
    case 'clusters',
        figure(hfig);set(hfig,'pointer','watch');drawnow;
        rcircle=1.3*[sin(linspace(0,2*pi,64)'),cos(linspace(0,2*pi,64))']*diag([5,5]);
        h=findobj('tag','conn_displayroi_plot');
        if ~isempty(h),delete(h); end
        h=axes('units','norm','position',[.03,.06,.45,.88]);
        lim=[1,1,1;data.ref.dim];refminmax=sort([lim((dec2bin(0:7)-'0'+1)+repmat([0,2,4],[8,1])),ones(8,1)]*data.ref.mat(1:3,:)'*data.proj(:,1:2));
        temp=reshape(data.bgimage,size(data.bgx)); %convn(convn(reshape(data.bgimage,size(data.bgx)),conn_hanning(5),'same'),conn_hanning(5)','same'); 
        temp(isnan(temp))=0;
        temp=round(1+(.7+.3*temp/max(temp(:)))*(size(get(hfig,'colormap'),1)-1));
        data.refaxes=image(refminmax(1,1):scale:refminmax(end,1),refminmax(1,2):scale:refminmax(end,2),temp);hold on;
        %data.refaxes=imagesc(refminmax(1,1):scale:refminmax(end,1),refminmax(1,2):scale:refminmax(end,2),convn(convn(reshape(data.bgimage,size(data.bgx)),conn_hanning(5),'same'),conn_hanning(5)','same'));hold on;
        h=gca;data.buttondown=struct('h1',h);set(h,'tag','conn_displayroi_plot');

        cmap=jet(max(1,max(data.clusters)));
        EPS=1;
        data.plotsadd2={};
        idxtext=[];
        for n1=1:N,
            hold on;
            if length(data.clusters)>=n1&&data.clusters(n1)>0,
                h=patch(data.x(n1)+rcircle(:,1)*max(.5,1+1e-3*data.z(n1)),data.y(n1)+rcircle(:,2)*max(.5,1+1e-3*data.z(n1)),max(1,data.z(n1))*EPS+.10+zeros(size(rcircle,1),1),'w');
                set(h,'edgecolor','none','facecolor',cmap(data.clusters(n1),:));
                hold on;
                set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data.hfig,'interruptible','off');
                idxtext=[idxtext;n1];
                %h=text(data.x(n1),data.y(n1),max(1,data.z(n1))*EPS+.10+2,num2str(n1));
                %set(h,'fontsize',9,'color','w','horizontalalignment','center','interpreter','none','fontweight','bold','backgroundcolor','none');
                %set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data);
            end
        end
        hold off;
        h=text(data.x(data.displaytheserois(idxtext)),data.y(data.displaytheserois(idxtext)),max(1,data.z(data.displaytheserois(idxtext)))*EPS+.10+2,{data.names2reduced{data.displaytheserois(idxtext)}});        
        set(h,'fontsize',8+CONN_gui.font_offset,'color','w','horizontalalignment','center','interpreter','none','fontweight','normal','backgroundcolor','none');
        %set(h,'buttondownfcn',@conn_displayroi_menubuttondownfcn,'userdata',data.hfig);
        set(gca,'ydir','normal');
        axis equal; axis off;
        set(hfig,'userdata',data);
        set(hfig,'pointer','arrow');
end
end

function h=cumpatch(option,varargin)
persistent patchobj patchopt patchvertices;
h=[];
if ischar(option)
    switch(option)
        case 'init',   patchobj=[];
        case 'update', 
            if ~isempty(patchobj)
                if 0
                    aLines=cat(3,patchobj.vertices);
                    mLines=(aLines(1:end/2,:,:)+aLines(end:-1:end/2+1,:,:))/2;
                    [Lines,LineWidths]=conn_menu_bundle(mLines,[],[],5,true);
                    for n1=1:numel(patchobj), patchobj(n1).vertices=[Lines(:,:,n1,end); flipud(Lines(:,:,n1,end))]+aLines(:,:,n1)-[mLines(:,:,n1);flipud(mLines(:,:,n1))]; end
                end
                temp=struct('vertices',cat(1,patchobj.vertices), 'faces',cat(1,patchobj.faces), 'facevertexcdata',cat(1,patchobj.facevertexcdata), 'facevertexalphadata',cat(1,patchobj.facevertexalphadata));
                h=patch(temp,patchopt{:},'facecolor','inter','facealpha','inter'); %,'alphadatamapping','direct');
            end
    end
else
    if isempty(patchobj)
        patchobj=option; 
        patchopt=varargin;
        patchvertices=size(option.vertices,1);
    else
        m=numel(patchobj);
        patchobj(m+1)=struct('vertices',option.vertices,'faces',patchvertices+option.faces,'facevertexcdata',option.facevertexcdata,'facevertexalphadata',option.facevertexalphadata);
        patchvertices=patchvertices+size(option.vertices,1);
    end
end
end

function conn_displayroi_menubuttondownfcn(varargin)
temp=get(gcbo,'userdata');
if iscell(temp)
    data=get(temp{1},'userdata');
    idx2=temp{2};
%     set(data.handles(21),'string',[temp{2},'      ',temp{3}]);
else
    data=get(temp,'userdata');
    idx2=[];
end
if isempty(idx2)
    xyz=get(data.buttondown.h1,'currentpoint');
    x=xyz(1,1);y=xyz(1,2);z=0;
    [nill,idx]=min(sqrt(abs(data.x(data.displaytheserois)-x).^2+abs(data.y(data.displaytheserois)-y).^2)+1e-10*abs(data.z(data.displaytheserois)-z).^2);
    idx2=data.displaytheserois(idx);
end
txt=data.names2{idx2};
if 0
    h=findobj('tag','conn_displayroi_menubuttondownfcn');if isempty(h), h=figure('units','pixels','position',[get(0,'pointerlocation')-[125,-200],250,40]);else, figure(h); end;
    set(h,'units','pixels','position',[get(0,'pointerlocation')-[125,-100],0,0]+[0,0,1,1].*get(h,'position'),'menubar','none','numbertitle','off','color','k','tag','conn_displayroi_menubuttondownfcn');
    clf(h);text(0,1,['x,y,z = (',num2str(data.xyz2(idx2,1),'%1.0f'),',',num2str(data.xyz2(idx2,2),'%1.0f'),',',num2str(data.xyz2(idx2,3),'%1.0f'),') mm'],'color','y','fontweight','bold','horizontalalignment','center','fontsize',9);
    text(0,0,['(',num2str(idx),') : ',txt],'color','y','fontweight','bold','horizontalalignment','center','fontsize',9,'interpreter','none');set(gca,'units','norm','position',[0,0,1,1],'xlim',[-1,1],'ylim',[-.5,1.5],'visible','off');
else
    txt={['x,y,z = (',num2str(data.xyz2(idx2,1),'%1.0f'),',',num2str(data.xyz2(idx2,2),'%1.0f'),',',num2str(data.xyz2(idx2,3),'%1.0f'),') mm'],...
        [' : ',txt]};
    set(data.handles(21),'string',[txt{1},'      ',txt{2}]);
    idx2a=find(data.list2(:,1)==idx2);
    idx2b=find(data.list2(:,2)==idx2);
    if ~isempty(idx2a)||~isempty(idx2b), set(data.handles(8),'value',[idx2a;idx2b]); end
    if ~isempty(idx2a), set(data.handles(8),'listboxtop',min(idx2a));
    elseif ~isempty(idx2b), set(data.handles(8),'listboxtop',min(idx2b));
    end
    conn_displayroi('list2');
end
%hc=get(0,'children');if length(hc)>0&&hc(1)~=h,hc=[h;hc(hc~=h)];set(0,'children',h); end
end

function conn_display_windowbuttonmotionfcn(option,varargin)
persistent x y dx dy h gtf gta busy;
if nargin>0&&ischar(option)&&strcmp(option,'init')
    x=varargin{1}.x;
    y=varargin{1}.y;
    dx=x([2:end 1],:)-x;
    dy=y([2:end 1],:)-y;
    h=varargin{1}.h;
    gta=varargin{1}.gca;
    gtf=varargin{1}.gcf;
    busy=false;
elseif ~isempty(x)
    if ~busy
        busy=true;
        hfig=gtf;
        set(hfig,'units','pixels');
        p1=get(0,'pointerlocation');
        p2=get(hfig,'position');
        p3=get(0,'screensize');
        p2(1:2)=p2(1:2)+p3(1:2)-1; % note: fix issue when connecting to external monitor/projector
        pos=(p1-p2(1:2));
        set(hfig,'currentpoint',pos);
        pos=get(gta,'currentpoint');
        pos=pos(1,1:2);
        idx=find(all(dx.*(pos(1)-x)+dy.*(pos(2)-y)>=0,1),1);

        set(h,'edgecolor','none');
        set(h(idx),'edgecolor',.5*[1 1 1]);
        busy=false;
    end
end
end


