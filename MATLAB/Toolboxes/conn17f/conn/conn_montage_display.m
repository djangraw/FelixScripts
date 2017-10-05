function fh=conn_montage_display(x,xlabels,style, xcovariate, xcovariate_name)

% CONN_MONTAGE_DISPLAY displays 3d data as montage
% conn_montage_display(x [,labels]);
%   displays a montage of each matrix x(:,:,:,i), labeled by labels{i}
%   size(x,3)==3 : for rgb values
%   size(x,3)==1 : for colormap scaling
%

global CONN_x CONN_gui;

if isstruct(x)
    state=x;
else
    state.x=x;
    if nargin>1, state.xlabels=xlabels;
    else state.xlabels={};
    end
    cmap2=repmat(1-linspace(1,0,128)'.^2,[1,3]).*hot(128)+repmat(linspace(1,0,128)'.^2,[1,3])*.1;
    cmap2=cmap2([1,21,35:end],:);
    state.colormap_default=cmap2;
    cmap2=[flipud(cmap2(:,[2,3,1]));cmap2];
    state.colormap=cmap2;
    %state.colormap_default=[flipud(fliplr(hot))*diag([.5 .5 1]);gray];
    %state.cmap=state.colormap_default;
    state.bookmark_filename='';
    state.bookmark_descr='';
end
if nargin<3||isempty(style), style='montage'; end
if nargin<4||isempty(xcovariate), xcovariate=[]; end
if nargin<5||isempty(xcovariate_name), xcovariate_name={}; end
if isfield(CONN_gui,'slice_display_skipbookmarkicons'), SKIPBI=CONN_gui.slice_display_skipbookmarkicons;
else SKIPBI=false;
end
fh=@(varargin)conn_montage_display_refresh([],[],varargin{:});
state.handles.fh=fh;
if ~isfield(CONN_x,'folders')||~isfield(CONN_x.folders,'bookmarks')||isempty(CONN_x.folders.bookmarks), state.dobookmarks=false;
else state.dobookmarks=true;
end
state.loop=0;
if ~isfield(state,'style'), state.style=style; end
if ~isfield(state,'slide'), state.slide=1; end
if ~isfield(state,'xcov'), 
    state.xcov=xcovariate; 
    state.xcov_name=xcovariate_name;
    %if ~isempty(xcovariate), state.xcov=state.xcov./repmat(max(eps,max(abs(state.xcov),[],1)),size(state.xcov,1),1); end
end
if ~isfield(state,'x_orig')
    state.x_orig=state.x;
end
if ~isfield(state,'xnonzero'),%||~isfield(state,'xnonzeroorder'),
    state.xnonzero=repmat(any(any(state.x~=0,4),3),[1,1,size(state.x,3),size(state.x,4)]);
%     idx=find(any(any(state.x~=0,4),3));
%     if numel(idx)<=2e3
%         clX=reshape(detrend(reshape(state.x(state.xnonzero),[],size(state.x,4))','constant')',numel(idx),[]);
%         clk1=sum(clX.^2,2);
%         clk2=clX*clX';
%         clZ=conn_bsxfun(@plus,clk1,clk1')-2*clk2;
%         clI=tril(true(size(clX,1)),-1);
%         clL=conn_statslinkage(clZ(clI>0)', 'co');
%         [nill,nill,idx]=conn_statsdendrogram(clL,0);
%         state.xnonzeroorder=idx;
%     else
%         state.xnonzeroorder=1:numel(idx);
%     end
end

%x=x./(max(max(max(abs(x),[],1),[],2),[],3));
if any(strcmp(state.style,{'movie','moviereplay','timeseries'})), pos=[.35 .35 .5 .5];
else pos=[.4 .15 .6 .8];
end
state.handles.hfig=figure('units','norm','position',pos,'color','k','menubar','none','name','montage display','numbertitle','off','colormap',state.colormap);
hc=state.handles.hfig;
hc1=uimenu(hc,'Label','Effects');
if size(state.x,3)==1,
    hc2=uimenu(hc1,'Label','colormap');
    for n1={'normal','gray','red','jet','hot','cool','hsv','spring','summer','autumn','winter','brighter','darker','color'}
        uimenu(hc2,'Label',n1{1},'callback',{@conn_montage_display_refresh,'colormap',n1{1}});
    end
end
hc2=uimenu(hc1,'Label','colorscale');
uimenu(hc2,'Label','direct','callback',{@conn_montage_display_refresh,'colorscale','direct'});
uimenu(hc2,'Label','equalized','callback',{@conn_montage_display_refresh,'colorscale','equalize'});
hc2=uimenu(hc1,'Label','style');
if ~strcmp(style,'timeseries')
    uimenu(hc2,'Label','montage','callback',{@conn_montage_display_refresh,'style','montage'});
    uimenu(hc2,'Label','movie','callback',{@conn_montage_display_refresh,'style','movie'});
end
if size(state.x,3)==1,
    uimenu(hc2,'Label','timeseries','callback',{@conn_montage_display_refresh,'style','timeseries'});
end
hc1=uimenu(hc,'Label','Print');
uimenu(hc1,'Label','current view','callback',{@conn_montage_display_refresh,'print',1});
uimenu(hc1,'Label','as video','callback',{@conn_montage_display_refresh,'printvideo'});
if state.dobookmarks
    hc1=uimenu(hc,'Label','Bookmark');
    hc2=uimenu(hc1,'Label','Save','callback',{@conn_montage_display_refresh,'bookmark'});
    if ~isempty(state.bookmark_filename),
        hc2=uimenu(hc1,'Label','Save as copy','callback',{@conn_montage_display_refresh,'bookmarkcopy'});
    end
end
drawnow;
state.handles.hax=axes('units','norm','position',[0 0 1 1],'parent',state.handles.hfig);
[state.y,state.nX]=conn_menu_montage(state.handles.hax,state.x(:,:,:,end));
state.datalim=max(abs(state.x(:)));
state.y(isnan(state.y))=0;
if size(state.y,3)==1, state.handles.him=image((size(state.colormap,1)+1)/2+(size(state.colormap,1)-1)/2*state.y/state.datalim,'parent',state.handles.hax);
else state.handles.him=imagesc(state.y,'parent',state.handles.hax);
end
axis(state.handles.hax,'equal','off');
clim=get(state.handles.hax,'clim');
if clim(1)/max(abs(clim))<-1e-2, clim=max(abs(clim))*[-1 1]; set(state.handles.hax,'clim',clim); set(state.handles.hfig,'colormap',state.colormap); end
set(state.handles.hfig,'resizefcn',{@conn_montage_display_refresh,'refresh'});
if ~isempty(state.xlabels),
    state.handles.hlabel=uicontrol('style','text','horizontalalignment','left','visible','off','parent',state.handles.hfig);
    set(state.handles.hfig,'units','pixels','windowbuttonmotionfcn',@conn_menu_montage_figuremousemove);
    %drawnow;
end
state.handles.slider=uicontrol('style','slider','units','norm','position',[.2 0 .6 .05],'foregroundcolor','w','backgroundcolor','k','parent',state.handles.hfig,'callback',{@conn_montage_display_refresh,'slider'});
try, addlistener(state.handles.slider, 'ContinuousValueChange',@(varargin)conn_montage_display_refresh([],[],'slider')); end
set(state.handles.slider,'min',1,'max',size(state.x,4),'sliderstep',min(.5,[1,10]/max(1,size(state.x,4)-1)),'value',1);
state.handles.startstop=uicontrol('style','togglebutton','units','norm','position',[.05 0 .1 .05],'string','Play','parent',state.handles.hfig,'callback',{@conn_montage_display_refresh,'startstop'});
state.handles.singleloop=uicontrol('style','checkbox','units','norm','position',[.85 0 .15 .05],'string','loop','parent',state.handles.hfig,'backgroundcolor','k','foregroundcolor',.85*[1 1 1],'value',0);
state.handles.movietitle=uicontrol('style','text','units','norm','position',[0 .95 1 .05],'string','','parent',state.handles.hfig,'horizontalalignment','left','foregroundcolor',.85*[1 1 1],'backgroundcolor','k');
if ~isempty(state.xcov)
    state.handles.haxcov=axes('units','norm','position',[.2 .075 .6 .20],'parent',state.handles.hfig);
    maxxcov=max(eps,max(abs(state.xcov),[],1));
    maxxcov=maxxcov.*(max(maxxcov.^.25)./(maxxcov.^.25));
    xcov=repmat(size(state.xcov,2)-1:-1:0, size(state.xcov,1),1) + .65*state.xcov./repmat(max(eps,maxxcov),size(state.xcov,1),1);
    state.handles.himcov=plot(xcov,'parent',state.handles.haxcov,'color',.75*[1 1 1]);%state.handles.himcov=image((size(state.colormap,1)+1)/2+(size(state.colormap,1)-1)/2*state.xcov','parent',state.handles.haxcov);
    hold(state.handles.haxcov,'on'); state.handles.refcov=plot([1 1],[min(xcov(:)) max(xcov(:))],'b','parent',state.handles.haxcov); hold(state.handles.haxcov,'off');%hold(state.handles.haxcov,'on'); state.handles.refcov=plot([1 1],[.5,size(state.xcov,2)+.5],'b','parent',state.handles.haxcov); hold(state.handles.haxcov,'off');
    axis(state.handles.haxcov,'tight','off');
    if ~isempty(state.xcov_name),
        if numel(state.xcov_name)==1, 
            ht=text(-size(state.xcov,1)*.05,size(state.xcov,2)/2,state.xcov_name,'parent',state.handles.haxcov); 
            set(ht,'rotation',90,'color',.75*[1 1 1],'horizontalalignment','center','fontsize',10,'interpreter','none');
        else
            ht=text(1.02*size(state.xcov,1)+zeros(1,numel(state.xcov_name)),.25+size(state.xcov,2)-(1:numel(state.xcov_name)),state.xcov_name,'parent',state.handles.haxcov);
            set(ht,'color',.75*[1 1 1],'horizontalalignment','left','fontsize',10,'interpreter','none');
        end
    end
else [state.handles.haxcov,state.handles.himcov,state.handles.refcov]=deal([]);
end

fh('refresh');
if strcmp(state.style,'moviereplay')
    %drawnow;
    set(state.handles.startstop,'value',1);
    fh('startstop');
end
    
    function out=conn_montage_display_refresh(hObject,eventdata,option,varargin)
        out=[];
        if nargin<3||isempty(option), option='refresh'; end
        switch(option)
            case 'refresh',
            case 'slider',
            case 'close', state.loop=0; close(state.handles.hfig); return;
            case 'printvideo',
                state.style='movie';
                defs_videowriteframerate=20; % fps
                if isempty(which('VideoWriter')), uiwait(errordlg('Sorry. VideoWriter functionality only supported on newer Matlab versions')); return; end
                videoformats={'*.avi','Motion JPEG AVI (*.avi)';'*.mj2','Motion JPEG 2000 (*.mj2)';'*.mp4;*.m4v','MPEG-4 (*.mp4;*.m4v)';'*.avi','Uncompressed AVI (*.avi)'; '*.avi','Indexed AVI (*.avi)'; '*.avi','Grayscale AVI (*.avi)'};
                [filename, pathname,filterindex]=uiputfile(videoformats,'Save video as','conn_video01.avi');
                if isequal(filename,0), return; end
                objvideo = VideoWriter(fullfile(pathname,filename),regexprep(videoformats{filterindex,2},'\s*\(.*$',''));
                set(objvideo,'FrameRate',defs_videowriteframerate);
                open(objvideo);
                ss=1;
                set(state.handles.startstop,'string','Stop','value',1);
                for n=1:size(state.x,4),
                    state.slide=n;
                    try, 
                        set(state.handles.slider,'value',state.slide);
                        conn_montage_display_refresh([],[],'refresh');
                        set([state.handles.slider state.handles.startstop state.handles.singleloop],'visible','off');
                        ss=get(state.handles.startstop,'value');
                        currFrame=getframe(state.handles.hfig);
                        writeVideo(objvideo,currFrame);
                        drawnow;
                    catch, ss=0; break; 
                    end
                    if ~ss, break; end
                end
                close(objvideo);
                try, set([state.handles.slider state.handles.startstop state.handles.singleloop],'visible','on'); end
                if ~ss, return; end
                objvideo=[];
                objvideoname=get(objvideo,'Filename');
                try, set(state.handles.startstop,'string','Play','value',0); end
                conn_msgbox(sprintf('File %s created',fullfile(pathname,filename)),'');
                %try, if ispc, winopen(objvideoname); else system(sprintf('open %s',objvideoname)); end; end
                return;
            case 'print',
                conn_print(state.handles.hfig,varargin{:});
                return;
            case 'colorscale',
                opt=varargin{1};
                switch(opt)
                    case 'equalize'
                        if ~isfield(state,'x_equalized')
                            temp=state.x_orig;
                            temp(isnan(temp))=0;
                            [ut,nill,idx]=unique(abs(temp));
                            nidx=cumsum(accumarray(idx(:),1));
                            nidx=nidx-nidx(1);
                            temp=reshape(sign(temp(:)).*nidx(idx(:)),size(temp));
                            temp=temp/max(abs(temp(:)));
                            state.x_equalized=temp;
                        end
                        state.x=state.x_equalized;
                    case 'direct'
                        state.x=state.x_orig;
                end
                state.datalim=max(abs(state.x(:)));
            case {'start','stop','startstop'}
                if strcmp(option,'start'), state.loop=1; set(state.handles.startstop,'value',state.loop); state.style='moviereplay'; 
                elseif strcmp(option,'stop'), state.loop=0; set(state.handles.startstop,'value',state.loop);
                else state.loop=get(state.handles.startstop,'value');
                end
                if state.loop, % stop
                    set(state.handles.startstop,'string','Stop','value',1);
                    while 1,
                        state.slide=round(max(1,min(size(state.x,4), get(state.handles.slider,'value'))));
                        state.slide=1+mod(state.slide,size(state.x,4));
                        set(state.handles.slider,'value',state.slide);
                        conn_montage_display_refresh([],[],'refresh');
                        drawnow;
                        try, state.loop=state.loop & get(state.handles.startstop,'value'); infloop=get(state.handles.singleloop,'value');
                        catch, return;
                        end
                        if ~state.loop || (~infloop && state.slide==1), break; end % force single loop
                    end
                    state.loop=0;
                    try, set(state.handles.startstop,'string','Play','value',0); end
                else
                    set(state.handles.startstop,'string','Play','value',0);
                end
                return;
            case 'colormap'
                cmap=varargin{1};
                if ischar(cmap)
                    switch(cmap)
                        case 'normal', cmap=state.colormap_default;
                        case 'gray', cmap=gray(96);
                        case 'red', cmap=[linspace(0,1,96)',zeros(96,2)];
                        case 'hot', cmap=hot(96);
                        case 'jet', cmap=jet(2*96); 
                        case 'cool',cmap=cool(96);
                        case 'hsv',cmap=hsv(2*96); 
                        case 'spring',cmap=spring(96);
                        case 'summer',cmap=summer(96);
                        case 'autumn',cmap=autumn(96);
                        case 'winter',cmap=winter(96);
                        case 'brighter',cmap=min(1,1/sqrt(.95)*get(state.handles.hfig,'colormap').^(1/2)); cmap=cmap(round(size(cmap,1)/2)+1:end,:);
                        case 'darker',cmap=.95*get(state.handles.hfig,'colormap').^2; cmap=cmap(round(size(cmap,1)/2)+1:end,:);
                        case 'color',cmap=uisetcolor([],'Select color'); if isempty(cmap)||isequal(cmap,0), return; end;
                        otherwise, disp('unknown value');
                    end
                end
                if ~isempty(cmap)
                    if size(cmap,2)<3, cmap=cmap(:,min(size(cmap,2),1:3)); end
                    if size(cmap,1)==1, cmap=linspace(0,1,96)'*cmap; end
                    if size(cmap,1)~=2*96, cmap=[flipud(cmap(:,[2,3,1]));cmap]; end
                    state.colormap=cmap;
                    set(state.handles.hfig,'colormap',cmap);
                end
            case 'style',
                state.loop=0; 
                state.style=varargin{1};
            case 'getstate',
                out=state;
                out=rmfield(out,'handles');
                return;
            case {'bookmark','bookmarkcopy'},
                tfilename=[];
                if numel(varargin)>0&&~isempty(varargin{1}), tfilename=varargin{1};
                elseif ~isempty(state.bookmark_filename)&&strcmp(option,'bookmark'), tfilename=state.bookmark_filename;
                end
                if numel(varargin)>1&&~isempty(varargin{2}), descr=cellstr(varargin{2});
                else descr=state.bookmark_descr;
                end
                fcn=regexprep(mfilename,'^conn_','');
                conn_args={fcn,conn_montage_display_refresh([],[],'getstate')};
                [fullfilename,tfilename,descr]=conn_bookmark('save',...
                    tfilename,...
                    descr,...
                    conn_args);
                if isempty(fullfilename), return; end
                if ~SKIPBI, conn_print(state.handles.hfig,conn_prepend('',fullfilename,'.jpg'),'-nogui','-r50','-nopersistent'); end
                state.bookmark_filename=tfilename;
                state.bookmark_descr=descr;
                conn_args={fcn,conn_montage_display_refresh([],[],'getstate')}; % re-save to include bookmark info
                save(conn_prepend('',fullfilename,'.mat'),'conn_args');
                if 0, conn_msgbox(sprintf('Bookmark %s saved',fullfilename),'',2);
                else out=fullfilename;
                end
                return;
        end
        switch(state.style)
            case 'montage'
                set(state.handles.hax,'position',[0 0 1 1]);
                [state.y,state.nX]=conn_menu_montage(state.handles.hax,state.x);
                set([state.handles.slider state.handles.startstop state.handles.singleloop state.handles.movietitle state.handles.haxcov state.handles.himcov(:)' state.handles.refcov],'visible','off');
                axis(state.handles.hax,'equal');
                datalim=state.datalim;
            case {'movie','moviereplay'}
                if ~isempty(state.xcov), set([state.handles.himcov(:)' state.handles.refcov],'visible','on'); set(state.handles.hax,'position',[.05 .3 .90 .65]);
                else set(state.handles.hax,'position',[.05 .05 .90 .90]);
                end
                state.slide=round(max(1,min(size(state.x,4), get(state.handles.slider,'value'))));
                [state.y,state.nX]=conn_menu_montage(state.handles.hax,state.x(:,:,:,state.slide));
                set([state.handles.slider state.handles.startstop state.handles.singleloop state.handles.movietitle],'visible','on');
                axis(state.handles.hax,'equal');
                datalim=state.datalim;
            case {'timeseries'}
                if ~isempty(state.xcov), set([state.handles.himcov(:)' state.handles.refcov],'visible','on'); set(state.handles.hax,'position',[.2 .3 .6 .55]);
                else set(state.handles.hax,'position',[.2 .05 .6 .80]);
                end
                state.slide=1;%round(max(1,min(size(state.x,4), get(state.handles.slider,'value'))));
                temp=detrend(reshape(state.x(state.xnonzero),[],size(state.x,4))','constant');
                %temp=temp(:,state.xnonzeroorder);
                [state.y,state.nX]=conn_menu_montage(state.handles.hax,temp');
                set([state.handles.slider state.handles.startstop state.handles.singleloop state.handles.refcov],'visible','off');
                axis(state.handles.hax,'normal');
                state.y=.5+.5*state.y/max(abs(state.y(:)));
                datalim=1;
        end
        state.y(isnan(state.y))=0;
        if size(state.y,3)==1, set(state.handles.him,'cdata',(size(state.colormap,1)+1)/2+(size(state.colormap,1)-1)/2*state.y/datalim);
        else set(state.handles.him,'cdata',state.y);
        end
        set(state.handles.hax,'xlim',[.5 size(state.y,2)+.5],'ylim',[.5 size(state.y,1)+.5],'clim',clim); 
        if any(strcmp(state.style,{'timeseries'})),
            if state.slide==numel(state.xlabels), 
                set(state.handles.movietitle,'string',state.xlabels{state.slide},'visible','on');
            else set(state.handles.movietitle,'visible','off');
            end
        end
        if any(strcmp(state.style,{'movie','moviereplay'})),
            if state.slide<=numel(state.xlabels), 
                set(state.handles.movietitle,'string',state.xlabels{state.slide});
            end
            if ~isempty(state.xcov)
                set(state.handles.refcov,'xdata',state.slide+[0 0]);
            end
        end
    end

    function conn_menu_montage_figuremousemove(varargin)
        if ~strcmp(state.style,'montage'), 
            set(state.handles.hlabel,'visible','off');
            return; 
        end
        p1=get(0,'pointerlocation');
        p2=get(state.handles.hfig,'position');
        p3=get(0,'screensize');
        p4=p2(1:2)+p3(1:2)-1; % note: fix issue when connecting to external monitor/projector
        pos0=(p1-p4);
        set(state.handles.hfig,'currentpoint',pos0);
        pos=(get(state.handles.hax,'currentpoint')); pos=pos(1,1:3);
        set(state.handles.hax,'units','pixels');posax=get(state.handles.hax,'position');set(state.handles.hax,'units','norm');
        if strcmp(state.style,'montage'), txyz=conn_menu_montage('coords2xyz',state.nX,pos(1:2)'); txyz=round(txyz(3));
        else txyz=state.slide;
        end
        if txyz>=1&&txyz<=numel(state.xlabels)&&pos(1)>=1&&pos(1)<=state.nX(3)*state.nX(1)&&pos(2)>=1&&pos(2)<=state.nX(4)*state.nX(2)
            tlabel=state.xlabels{txyz};
            set(state.handles.hlabel,'units','pixels','position',[pos0+[10 -10] 20 20],'visible','on','string',tlabel);
            hext=get(state.handles.hlabel,'extent');
            nlines=ceil(hext(3)/(p2(3)/2));
            ntlabel=numel(tlabel);
            newpos=[pos0+[-0*min(p2(3)/2,hext(3))/2 +20] min(p2(3)/2,hext(3)) nlines*hext(4)];
            newpos(1)=max(posax(1),newpos(1)-max(0,newpos(1)+newpos(3)-posax(1)-posax(3)));
            newpos(2)=max(posax(2),newpos(2)-max(0,newpos(2)+newpos(4)-posax(2)-posax(4)));
            %newpos(1)=max(0,newpos(1)-max(0,newpos(1)+newpos(3)-posax(3)));
            %newpos(2)=max(0,newpos(2)-max(0,newpos(2)+newpos(4)-posax(4)));
            set(state.handles.hlabel,'position',newpos,'string',reshape([tlabel,repmat(' ',1,nlines*ceil(ntlabel/nlines)-ntlabel)]',[],nlines)');
        else
            set(state.handles.hlabel,'visible','off');
        end
    end

end



