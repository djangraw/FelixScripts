function fh=conn_slice_display(data,structural,defaultfilepath,actthr,titlestr)
% CONN_SLICE_DISPLAY slice display in CONN
%
% CONN_SLICE_DISPLAY(fileDATA) displays volume-level data in fileDATA (overlaid on default reference structural image)
% CONN_SLICE_DISPLAY(fileDATA.fileSTRUCT) displays volume-level data in fileDATA overlaid on structural image fileSTRUCT
% CONN_SLICE_DISPLAY('',fileSTRUCT) displays structural image fileSTRUCT
%
%  h=CONN_SLICE_DISPLAY(...) returns function handle implementing all GUI functionality
%

global CONN_x CONN_gui;
if nargin<2||isempty(structural), structural=''; end
if nargin<3||isempty(defaultfilepath), defaultfilepath=pwd; end
if nargin<4||isempty(actthr), actthr=0; end
if nargin<5||isempty(titlestr), titlestr=''; end
if isfield(CONN_gui,'slice_display_dovol'), DOVOL=CONN_gui.slice_display_dovol; 
else DOVOL=false;
end
if isfield(CONN_gui,'slice_display_skipbookmarkicons'), SKIPBI=CONN_gui.slice_display_skipbookmarkicons; 
else SKIPBI=false;
end
if isfield(CONN_gui,'slice_display_showroitype2asroitype1'), EXPACT=CONN_gui.slice_display_showroitype2asroitype1; 
else EXPACT=true;
end


fh=@(varargin)conn_slice_display_refresh([],[],varargin{:});
hmsg=conn_msgbox('Initializing. Please wait...');drawnow;
state.structural=structural;
state.refnames={};
state.actthr=actthr;
V=[];
doinit=true;
if ~isempty(data)&&ischar(data)&&~isempty(regexp(data,'\.mat$|\.jpg$')), data=load(conn_prepend('',data,'.mat'),'state'); data=data.state; end
if isstruct(data)&&isfield(data,'structural'), % struct from getstate
    state=data;
    if ~isdir(state.defaultfilepath), state.defaultfilepath=pwd; end
    doinit=false;
elseif isstruct(data)  % conn_slice_display( struct:T,p,stats,dof,mat ...
    state.isstat=true;
    state.isvol=true;
    state.T=data.T;
    state.p=data.p;
    state.stats=data.stats;
    state.dof=data.dof;
    state.mat=data.mat;
    if isfield(data,'clusters'), state.clusters=data.clusters;
    else data.clusters=[];
    end
    state.supra=data.supra.*sign(state.T);
    state.size=size(state.supra);
    state.info.structural='none';
    if isfield(data,'filename'), state.info.vol=data.filename;
    else state.info.vol='manually defined';
    end
    state.nslices=9;
    state.dslices=6;
elseif ~isempty(data) % conn_slice_display(datafile [,structural_file])
    state.isstat=false;
    state.isvol=true;
    V=spm_vol(data);
    %V=V(1);
    state.supra=spm_read_vols(V);
    state.mat=V(1).mat;
    state.size=size(state.supra);
    state.info.structural='none';
    state.info.vol=char(data);
    state.T=state.supra;
    state.nslices=9;
    state.dslices=6;
else                   % conn_slice_display([],structural_file)
    state.isstat=false;
    state.isvol=false;
    V=spm_vol(state.structural);
    state.info.structural=char(state.structural);
    %V=V(1);
    state.structural=spm_read_vols(V);
    state.mat=V(1).mat;
    state.size=size(state.structural);
    state.info.vol='none';
    state.T=state.structural;
    state.nslices=9;
    state.dslices=6;
    state.refnames={};
end
try % read .txt labels from ROI files
    if ~state.isstat&&~isempty(V)&&~any(rem(state.T(:),1))
        maxdata=max(state.T(:));
        trefnames=regexp(fileread(conn_prepend('',V(1).fname,'.txt')),'\n*','split');
        trefnames=trefnames(cellfun('length',trefnames)>0);
        if numel(trefnames)==maxdata, 
            state.refnames=trefnames; state.reftype=1;
        elseif numel(trefnames)==size(state.T,4), 
            state.refnames=trefnames; state.reftype=2;
            if EXPACT
                if ~isfield(state,'supra'), state.supra=state.T; end
                [nill,state.supra]=max(state.supra,[],4);
                state.supra(nill==0)=0;
                state.size=size(state.supra);
                if isequal(state.structural,state.T), state.structural=state.supra; end
                state.T=state.supra;
                state.reftype=1;
            end
        end
    end
end
state.handles.fh=fh;
if ~isfield(CONN_x,'folders')||~isfield(CONN_x.folders,'bookmarks')||isempty(CONN_x.folders.bookmarks), state.dobookmarks=false;
else state.dobookmarks=true;
end
if ~isfield(state,'cameraviews')
    state.cameraviews=[-1 0 .001; 0 -1 .001; 0 -.001 1];
    state.cameraviewnames={'sagittal','coronal','axial'};
    tc=abs(state.cameraviews*state.mat(1:3,1:3)*diag(1./sqrt(sum(state.mat(1:3,1:3).^2,1))));
    for tcn=1:3, [nill,tci(tcn)]=max(tc(tcn,:)); tc(:,tci)=-1; end
    state.cameraviews=state.cameraviews(tci,:);
    state.cameraviewnames=state.cameraviewnames(tci);
    [nill,state.cameraviewdirs]=sort(tci);
end

if doinit
    if isempty(state.structural),
        state.structural=fullfile(fileparts(which('conn')),'utils','surf','referenceT1_icbm.nii');
        if isfield(CONN_gui,'refs')&&isfield(CONN_gui.refs,'canonical')&&isfield(CONN_gui.refs.canonical,'filename')&&~isempty(CONN_gui.refs.canonical.filename)
            if ~isequal(CONN_gui.refs.canonical.filename,fullfile(fileparts(which('conn')),'utils','surf','referenceT1_trans.nii')), %handles conn defaults (high-res for slice display)
                state.structural=CONN_gui.refs.canonical.filename;
            end
        end
    end
    state.time=1;
    if numel(state.size)>3, state.endtime=state.size(4); else state.endtime=1; end
    if 0,%state.isstat
        state.view=[1 1 1 1 0];
        %if ~state.isstat, state.view(4)=1; end
        state.cameraview=[1 1 1];
    else
        state.view=[0 0 1 0 0];
        state.cameraview=state.cameraviews(3,:);%[0 -.001 1];
    end
    state.transparency=1;
    state.slice_transparency=1;
    state.background=.14*[1 1 1];%[.2,.6,.7];
    state.cmap=autumn(256); %[linspace(0,1,256)',zeros(256,2)];
    state.blackistransparent=true;
    state.contourtransparency=0;
    state.expandmultiview=true;
    state.colorbrightness=0;
    state.colorcontrast=1;
    state.defaultfilepath=defaultfilepath;
    state.bookmark_filename='';
    state.bookmark_descr='';
    [x,y,z]=ndgrid(1:state.size(1),1:state.size(2),1:state.size(3));
    xyz=state.mat*[x(:) y(:) z(:) ones(numel(x),1)]';
    state.xyz_x=reshape(xyz(1,:),state.size(1:3));
    state.xyz_y=reshape(xyz(2,:),state.size(1:3));
    state.xyz_z=reshape(xyz(3,:),state.size(1:3));
    state.xyz_range=[min(state.xyz_x(:)) max(state.xyz_x(:)); min(state.xyz_y(:)) max(state.xyz_y(:)); min(state.xyz_z(:)) max(state.xyz_z(:))];
    state.resamplestructural=false;
    if ischar(state.structural)
        V=spm_vol(state.structural);
        state.info.structural=state.structural;
        fact=abs(det(state.mat)/det(V(1).mat));
        while fact>1.1
            state.size(1:3)=2*state.size(1:3)-1;
            state.mat=state.mat*[.5 0 0 .5;0 .5 0 .5;0 0 .5 .5;0 0 0 1];
            try, state.supra=state.supra(round(1:.5:end),round(1:.5:end),round(1:.5:end),:); end
            try, state.T=state.T(round(1:.5:end),round(1:.5:end),round(1:.5:end),:); end
            try, state.p=state.p(round(1:.5:end),round(1:.5:end),round(1:.5:end),:); end
            fact=fact/8;
        end
        [x,y,z]=ndgrid(1:state.size(1),1:state.size(2),1:state.size(3));
        xyz=state.mat*[x(:) y(:) z(:) ones(numel(x),1)]';
        state.xyz_x=reshape(xyz(1,:),state.size(1:3));
        state.xyz_y=reshape(xyz(2,:),state.size(1:3));
        state.xyz_z=reshape(xyz(3,:),state.size(1:3));
        state.xyz_range=[min(state.xyz_x(:)) max(state.xyz_x(:)); min(state.xyz_y(:)) max(state.xyz_y(:)); min(state.xyz_z(:)) max(state.xyz_z(:))];
        state.resamplestructural=true;
        if numel(V)==1, 
            txyz=pinv(V(1).mat)*xyz;
            state.structural=reshape(spm_sample_vol(V,txyz(1,:),txyz(2,:),txyz(3,:),1),state.size(1),state.size(2),state.size(3));
        else
            state.structural=reshape(spm_get_data(V,pinv(V(1).mat)*xyz)',state.size(1),state.size(2),state.size(3),[]);
        end
        %V=V(1);
    end
    state.pointer_mm=[0 0 10];
    if any(state.pointer_mm'<state.xyz_range(:,1))||any(state.pointer_mm'>state.xyz_range(:,2))
        state.pointer_mm=mean(state.xyz_range,2)';
    end
    state.pointer_vox=round([state.pointer_mm 1]*pinv(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]+.001);
    if state.isvol, state.Vrange=[min([0,min(state.T(state.supra>state.actthr|state.supra<-state.actthr))]) max([0,max(state.T(state.supra>state.actthr|state.supra<-state.actthr))])]; end
    %if ~isempty(state.structural), state.structural(isnan(state.structural))=0; end
else
    [x,y,z]=ndgrid(1:state.size(1),1:state.size(2),1:state.size(3));
    xyz=state.mat*[x(:) y(:) z(:) ones(numel(x),1)]';
    state.xyz_x=reshape(xyz(1,:),state.size(1:3));
    state.xyz_y=reshape(xyz(2,:),state.size(1:3));
    state.xyz_z=reshape(xyz(3,:),state.size(1:3));
    state.xyz_range=[min(state.xyz_x(:)) max(state.xyz_x(:)); min(state.xyz_y(:)) max(state.xyz_y(:)); min(state.xyz_z(:)) max(state.xyz_z(:))];
    if state.isvol&&~isfield(state,'Vrange'), state.Vrange=[min([0,min(state.T(state.supra>state.actthr|state.supra<-state.actthr))]) max([0,max(state.T(state.supra>state.actthr|state.supra<-state.actthr))])]; end
    if ~isfield(state,'bookmark_filename'), state.bookmark_filename=''; end % backwards compatibility
    if ~isfield(state,'bookmark_descr'), state.bookmark_descr=''; end
    if ~isfield(state,'slice_transparency'), state.slice_transparency=1; end
end

if DOVOL&&state.isvol
    for n=1:size(state.supra,4)
        pVOL1{n}=conn_surf_volume({state.supra(:,:,:,n),cat(4,state.xyz_x,state.xyz_y,state.xyz_z)},0,0,[],1,0,0);
        pVOL2{n}=conn_surf_volume({state.supra(:,:,:,n),cat(4,state.xyz_x,state.xyz_y,state.xyz_z)},0,0,[],1,0,1);
    end
end
state.handles.hfig=figure('units','norm','position',[.1 .25 .8 .5],'name',['conn slice display ',titlestr],'numbertitle','off','menubar','none','color',state.background,'tag','conn_slice_display','interruptible','off','busyaction','cancel','renderer','opengl','colormap',state.cmap,'visible','off');
uicontrol('style','frame','units','norm','position',[.5 .65 .5 .35],'foregroundcolor',[.5 .5 .5]);
uicontrol('style','frame','units','norm','position',[.5 0 .5 .65],'foregroundcolor',[.5 .5 .5]);
uicontrol('style','text','units','norm','position',[.55 .55 .4 .05],'string','Reference point','horizontalalignment','center','fontweight','bold');
uicontrol('style','text','units','norm','position',[.55 .475 .10 .07],'string','Coordinates (mm):');
fontsize=get(0,'defaultuicontrolfontsize')+2;
for n=1:3,
    state.handles.pointer_mm(n)=uicontrol('style','edit','units','norm','position',[.7+.05*(n-1) .50 .05 .05],'string',num2str(state.pointer_mm(n)),'fontsize',fontsize,'callback',{@conn_slice_display_refresh,'pointer_mm'});
end
for n=1:3,
    state.handles.pointer_mm_delta(2*n-1)=uicontrol('style','pushbutton','units','norm','position',[.7+.025*(2*n-2) .470 .025 .03],'string','-','callback',{@conn_slice_display_refresh,'pointer_mm','-',n});
    state.handles.pointer_mm_delta(2*n-0)=uicontrol('style','pushbutton','units','norm','position',[.7+.025*(2*n-1) .470 .025 .03],'string','+','callback',{@conn_slice_display_refresh,'pointer_mm','+',n});
end
uicontrol('style','text','units','norm','position',[.55 .375 .10 .07],'string','Coordinates (voxels):');
for n=1:3,
    state.handles.pointer_vox(n)=uicontrol('style','edit','units','norm','position',[.7+.05*(n-1) .40 .05 .05],'string',num2str(state.pointer_vox(n)),'fontsize',fontsize,'callback',{@conn_slice_display_refresh,'pointer_vox'});
end
for n=1:3,
    state.handles.pointer_vox_delta(2*n-1)=uicontrol('style','pushbutton','units','norm','position',[.7+.025*(2*n-2) .37 .025 .03],'string','-','callback',{@conn_slice_display_refresh,'pointer_vox','-',n});
    state.handles.pointer_vox_delta(2*n-0)=uicontrol('style','pushbutton','units','norm','position',[.7+.025*(2*n-1) .37 .025 .03],'string','+','callback',{@conn_slice_display_refresh,'pointer_vox','+',n});
end
state.handles.view(1)=uicontrol('style','checkbox','units','norm','position',[.55 .90 .25 .05],'string',sprintf('View yz plane (%s)',state.cameraviewnames{1}),'value',state.view(1),'callback',{@conn_slice_display_refresh,'view'});
state.handles.view(2)=uicontrol('style','checkbox','units','norm','position',[.55 .85 .25 .05],'string',sprintf('View xz plane (%s)',state.cameraviewnames{2}),'value',state.view(2),'callback',{@conn_slice_display_refresh,'view'});
state.handles.view(3)=uicontrol('style','checkbox','units','norm','position',[.55 .80 .25 .05],'string',sprintf('View xy plane (%s)',state.cameraviewnames{3}),'value',state.view(3),'callback',{@conn_slice_display_refresh,'view'});
state.handles.view(4)=uicontrol('style','checkbox','units','norm','position',[.55 .70 .25 .05],'string','View axis','value',state.view(4),'callback',{@conn_slice_display_refresh,'view'});
% if state.isvol
%     if state.isstat, str='View activation volume'; else str='View volume'; end
%     state.handles.view(5)=uicontrol('style','checkbox','units','norm','position',[.55 .75 .25 .05],'string',str,'value',state.view(5),'callback',{@conn_slice_display_refresh,'view'},'visible','off');
% end
state.handles.multislice1=uicontrol('style','edit','units','norm','position',[.825 .875 .05 .075],'string',num2str(state.nslices),'callback',{@conn_slice_display_refresh,'multislice'},'tooltipstring','<HTML>Maximum number of slices shown in multi-slice display<br/> - Set to 1 for single-slice display</HTML>');
state.handles.multislice2=uicontrol('style','edit','units','norm','position',[.875 .875 .05 .075],'string',num2str(state.dslices),'callback',{@conn_slice_display_refresh,'multislice'},'tooltipstring','Distance between displayed slices (in voxels)');
state.handles.multislice0=uicontrol('style','checkbox','units','norm','position',[.825 .925 .15 .05],'string','Multi-slice display','horizontalalignment','center','fontweight','bold','callback',{@conn_slice_display_refresh,'multisliceset'});
if all(state.nslices==1), set(state.handles.multislice0,'value',0); else set(state.handles.multislice0,'value',1); end
state.handles.text1=uicontrol('style','edit','units','norm','position',[.55 .20 .4 .05],'string','','horizontalalignment','center');
if state.isstat
    uicontrol('style','text','units','norm','position',[.55 .25 .4 .05],'string','Statistics','horizontalalignment','center','fontweight','bold');
    state.handles.text2=uicontrol('style','edit','units','norm','position',[.55 .15 .4 .05],'string','','horizontalalignment','center');
else state.handles.text2=[];
end
state.handles.mode=uicontrol('style','togglebutton','units','norm','position',[0 0 .5 .05],'string','Click on image to select reference point','value',1,'callback',{@conn_slice_display_refresh,'togglepointer'},'tooltipstring','switch between click-to-rotate and click-to-select behavior');
state.handles.gui=uicontrol('style','togglebutton','units','norm','position',[.5 0 .5 .05],'string','Hide GUI','value',0,'callback',{@conn_slice_display_refresh,'togglegui'},'tooltipstring','shows/hides GUI elements');

axes_handle=axes('units','norm','position',[.05 .05 .4 .9]);
state.handles.patch=[patch(0,0,0,'w') patch(0,0,0,'w') patch(0,0,0,'w') patch(0,0,0,'w')];
%hold on; state.handles.patchcontour=[plot3(0,0,0,'k','linewidth',2) plot3(0,0,0,'k','linewidth',2) plot3(0,0,0,'k','linewidth',2)]; hold off;
if state.isvol
    if DOVOL
        for n=1:numel(pVOL1), state.handles.act1(n)=patch(pVOL1{n}); end
        for n=1:numel(pVOL1), state.handles.act2(n)=patch(pVOL2{n}); end
        set([state.handles.act1],'edgecolor','none','facecolor','r','facealpha',state.transparency,'visible','off');
        set([state.handles.act2],'edgecolor','none','facecolor','b','facealpha',state.transparency,'visible','off');
    else state.handles.act1=[]; state.handles.act2=[];
    end
    hold on; state.handles.patchcontour1=[plot3(0,0,0,'k-','linewidth',2) plot3(0,0,0,'k-','linewidth',2) plot3(0,0,0,'k-','linewidth',2)]; state.handles.patchcontour2=[plot3(0,0,0,'k-','linewidth',2) plot3(0,0,0,'k-','linewidth',2) plot3(0,0,0,'k-','linewidth',2)]; hold off;
else state.handles.act1=[]; state.handles.act2=[];state.handles.patchcontour1=[]; state.handles.patchcontour2=[];
end
set(state.handles.patch,'edgecolor','none');
hold on;
state.handles.line1=plot3(state.pointer_mm(1)+[0 0],state.pointer_mm(2)+[0 0],state.xyz_range(3,:),'b-');
state.handles.line2=plot3(state.pointer_mm(1)+[0 0],state.xyz_range(2,:),state.pointer_mm(3)+[0 0],'b-');
state.handles.line3=plot3(state.xyz_range(1,:),state.pointer_mm(2)+[0 0],state.pointer_mm(3)+[0 0],'b-');
hold off;
axis equal tight off;
state.handles.axes=gca;
state.handles.light=[light light];set(state.handles.light,'position',[1 1 1],'visible','off','color',.5*[1 1 1]);

if state.isvol, 
    axes('units','norm','position',[.453 .15 .015 .75]);
    temp=imagesc(max(0,min(1, ind2rgb(round((size(state.cmap,1)+1)/2+(size(state.cmap,1)-1)/2*linspace(-1,1,128)'),state.cmap))));
    set(gca,'ydir','normal','ytick',[],'xtick',[],'box','off','yaxislocation','left');
    temp2=text([1,1,1],[1-128*.05,64.5,128+128*.05],{' ',' ',' '},'horizontalalignment','center');
    state.handles.colorbar=[gca temp temp2(:)'];
    set(state.handles.colorbar,'visible','off');
else state.handles.colorbar=[];
end

state.handles.slider=uicontrol('style','slider','units','norm','position',[.47 .1 .025 .8],'callback',{@conn_slice_display_refresh,'pointer_mm','x'},'tooltipstring','Select reference slice');
if state.endtime>1, 
    state.handles.time=uicontrol('style','slider','units','norm','position',[.55 .05 .40 .05],'min',0,'max',1,'sliderstep',1/(state.endtime-1)*[1 2],'callback',{@conn_slice_display_refresh,'time'},'tooltipstring',sprintf('Volume/scan %d/%d',state.time,state.endtime)); 
    state.handles.timestr=uicontrol('style','text','units','norm','position',[.95 .05 .05 .05],'string',sprintf('%d/%d',state.time,state.endtime));
end
try, addlistener(state.handles.slider, 'ContinuousValueChange',@(varargin)conn_slice_display_refresh(state.handles.slider,[],'pointer_mm','x')); end
try, addlistener(state.handles.time, 'ContinuousValueChange',@(varargin)conn_slice_display_refresh(state.handles.time,[],'time')); end
hc=state.handles.hfig;
hc1=uimenu(hc,'Label','Effects');
uimenu(hc1,'Label','white background','callback',{@conn_slice_display_refresh,'background',[1 1 1]},'tag','background');
uimenu(hc1,'Label','black background','callback',{@conn_slice_display_refresh,'background',[0 0 0]},'tag','background');
uimenu(hc1,'Label','color background','callback',{@conn_slice_display_refresh,'background',[]},'tag','background','checked','on');
uimenu(hc1,'Label','multi-slice montage','separator','on','checked','on','callback',{@conn_slice_display_refresh,'expandmultiview','on'},'tag','expandmultiview');
uimenu(hc1,'Label','multi-slice stack','checked','off','callback',{@conn_slice_display_refresh,'expandmultiview','off'},'tag','expandmultiview');
uimenu(hc1,'Label','brighter','separator','on','callback',{@conn_slice_display_refresh,'brighter',.25});
uimenu(hc1,'Label','darker','callback',{@conn_slice_display_refresh,'brighter',-.25});
tvalues=[1 .9:-.1:.1 .05 0];
thdl=uimenu(hc1,'Label','slices on','separator','on','callback',{@conn_slice_display_refresh,'slice_transparency',1},'tag','slice_transparency');
hc2=uimenu(hc1,'Label','slices transparent');
for n1=1:numel(tvalues)-1, thdl=[thdl,uimenu(hc2,'Label',num2str(n1-1),'callback',{@conn_slice_display_refresh,'slice_transparency',tvalues(n1)},'tag','slice_transparency')]; end
thdl=[thdl,uimenu(hc1,'Label','slices off','callback',{@conn_slice_display_refresh,'slice_transparency',0},'tag','slice_transparency')];
[nill,idx]=min(abs(state.slice_transparency-[1 tvalues]));
set(thdl,'checked','off');set(thdl(max(1,min(numel(thdl),idx))),'checked','on');
if state.isvol
    tvalues=[1 .9:-.1:.1 .05 0];
    thdl=uimenu(hc1,'Label','activation surface on','separator','on','callback',{@conn_slice_display_refresh,'act_transparency',1},'tag','act_transparency');
    hc2=uimenu(hc1,'Label','activation surface transparent');
    for n1=1:numel(tvalues)-1, thdl=[thdl,uimenu(hc2,'Label',num2str(n1-1),'callback',{@conn_slice_display_refresh,'act_transparency',tvalues(n1)},'tag','act_transparency')]; end
    thdl=[thdl,uimenu(hc1,'Label','activation surface off','callback',{@conn_slice_display_refresh,'act_transparency',0},'tag','act_transparency')];
    [nill,idx]=min(abs(state.transparency-[1 tvalues]));
    set(thdl,'checked','off');set(thdl(max(1,min(numel(thdl),idx))),'checked','on');
%     hc2=uimenu(hc1,'Label','activation surface transparency','separator','on');
%     thdl=[];
%     for n1=0:.1:.9,thdl=[thdl,uimenu(hc2,'Label',num2str(1-n1),'callback',{@conn_slice_display_refresh,'act_transparency',n1},'tag','act_transparency')]; end
%     thdl=[thdl,uimenu(hc1,'Label','activation surface opaque','callback',{@conn_slice_display_refresh,'act_transparency',1},'tag','act_transparency')];
%     set(thdl,'checked','off');set(thdl(max(1,min(numel(thdl),1+round(state.transparency*10)))),'checked','on');
    hc2=uimenu(hc1,'Label','activation colormap','separator','on');
    for n1={'red','jet','hot','gray','cool','hsv','spring','summer','autumn','winter','random','brighter','darker','manual','color'}
        uimenu(hc2,'Label',n1{1},'callback',{@conn_slice_display_refresh,'colormap',n1{1}});
    end
    uimenu(hc1,'Label','colorbar on','callback',{@conn_slice_display_refresh,'colorbar','on'},'tag','colorbar');
    uimenu(hc1,'Label','colorbar off','callback',{@conn_slice_display_refresh,'colorbar','off'},'tag','colorbar','checked','on');
    uimenu(hc1,'Label','rescale colorbar','callback',{@conn_slice_display_refresh,'colorbar','rescale'});
    if DOVOL&& (any(cellfun('length',pVOL1))||any(cellfun('length',pVOL2)))
        uimenu(hc1,'Label','activation volume on','separator','on','callback',{@conn_slice_display_refresh,'vol_transparency',1},'tag','vol_transparency');
        uimenu(hc1,'Label','activation volume off','checked','on','callback',{@conn_slice_display_refresh,'vol_transparency',0},'tag','vol_transparency');
        hc2=uimenu(hc1,'Label','activation volume lighting');
        uimenu(hc2,'Label','normal','callback',{@conn_slice_display_refresh,'material','dull'},'tag','material');
        uimenu(hc2,'Label','emphasis','callback',{@conn_slice_display_refresh,'material',[.1 .75 .5 1 .5]},'tag','material');
        uimenu(hc2,'Label','sketch','callback',{@conn_slice_display_refresh,'material',[.1 1 1 .25 0]},'tag','material');
        uimenu(hc2,'Label','shiny','callback',{@conn_slice_display_refresh,'material',[.3 .6 .9 20 1]},'tag','material');
        uimenu(hc2,'Label','metal','callback',{@conn_slice_display_refresh,'material',[.3 .3 1 25 .5]},'tag','material');
        uimenu(hc2,'Label','flat','callback',{@conn_slice_display_refresh,'material',[]},'tag','material','checked','on');
        uimenu(hc2,'Label','bright','callback',{@conn_slice_display_refresh,'light',.8},'separator','on','tag','light');
        uimenu(hc2,'Label','medium','callback',{@conn_slice_display_refresh,'light',.5},'tag','light','checked','on');
        uimenu(hc2,'Label','dark','callback',{@conn_slice_display_refresh,'light',.2},'tag','light');
    end
    uimenu(hc1,'Label','activation contour on','separator','on','callback',{@conn_slice_display_refresh,'contour_transparency',1},'tag','contour_transparency');
    uimenu(hc1,'Label','activation contour off','checked','on','callback',{@conn_slice_display_refresh,'contour_transparency',0},'tag','contour_transparency');
end
hc2=uimenu(hc1,'Label','smoother display','separator','on','checked','on','callback',{@conn_slice_display_refresh,'black_transparency','on'},'tag','black_transparency');
hc2=uimenu(hc1,'Label','raw data display','callback',{@conn_slice_display_refresh,'black_transparency','off'},'tag','black_transparency');
hc2=uimenu(hc1,'Label','info','separator','on','callback',{@conn_slice_display_refresh,'info'});
hc1=uimenu(hc,'Label','Print');
uimenu(hc1,'Label','current view','callback',{@conn_slice_display_refresh,'print'});
if state.dobookmarks
    hc1=uimenu(hc,'Label','Bookmark');
    hc2=uimenu(hc1,'Label','Save','callback',{@conn_slice_display_refresh,'bookmark'});
    if ~isempty(state.bookmark_filename),
        hc2=uimenu(hc1,'Label','Save as copy','callback',{@conn_slice_display_refresh,'bookmarkcopy'});
    end
end
set(state.handles.hfig,'userdata',state);%'uicontextmenu',hc,
set(rotate3d,'ActionPostCallback',{@conn_slice_display_refresh,'position'});
set(rotate3d,'enable','on');
        
conn_slice_display_refresh([],[],'init');
if ishandle(hmsg), delete(hmsg); end
set(state.handles.hfig,'visible','on');
try, set(state.handles.hfig,'resizefcn',{@conn_slice_display_refresh,'init'}); end

    function out=conn_slice_display_refresh(hObject,eventdata,option,varargin)
        out=[];
        try
            if numel(hObject)==1&&ishandle(hObject)&&~isempty(get(hObject,'tag'))
                str=get(hObject,'tag');
                set(findobj(state.handles.hfig,'tag',str),'checked','off');
                set(hObject,'checked','on');
            elseif isempty(hObject)&&isempty(eventdata)&&ischar(option)
                h=findobj(state.handles.hfig,'type','uimenu');
                s1=get(h,'callback');
                idx1=find(cellfun('length',s1)>1);
                idx2=find(cellfun(@iscell,s1(idx1)));
                idx3=find(cellfun(@(x)strcmp(x{2},option)&isequal(x(3:end),varargin),s1(idx1(idx2))));
                if numel(idx3)==1
                    h2=findobj(state.handles.hfig,'type','uimenu','tag',get(h(idx1(idx2(idx3))),'tag'));
                    set(h2,'checked','off');
                    set(h(idx1(idx2(idx3))),'checked','on');
                end
            end
        end
        redrawnow=false;
        redrawnowcolorbar=false;
        switch(option)
            case 'none', return;
            case 'close', close(state.handles.hfig); return;
            case 'init',
                redrawnow=true;
            case 'getstate'
                out=state;
                out=rmfield(out,{'handles','xyz_x','xyz_y','xyz_z'});
            case {'bookmark','bookmarkcopy'},
                tfilename=[];
                if numel(varargin)>0&&~isempty(varargin{1}), tfilename=varargin{1}; 
                elseif ~isempty(state.bookmark_filename)&&strcmp(option,'bookmark'), tfilename=state.bookmark_filename;
                end
                if numel(varargin)>1&&~isempty(varargin{2}), descr=cellstr(varargin{2}); 
                else descr=state.bookmark_descr;
                end
                fcn=regexprep(mfilename,'^conn_','');
                conn_args={fcn,conn_slice_display_refresh([],[],'getstate')};
                [fullfilename,tfilename,descr]=conn_bookmark('save',...
                    tfilename,...
                    descr,...
                    conn_args);
                if isempty(fullfilename), return; end
                if ~SKIPBI, conn_slice_display_refresh([],[],'print',conn_prepend('',fullfilename,'.jpg'),'-nogui','-r50','-nopersistent'); end
                state.bookmark_filename=tfilename;
                state.bookmark_descr=descr;
                   %conn_args={fcn,conn_slice_display_refresh([],[],'getstate')}; % re-save to include bookmark info?
                   %save(conn_prepend('',fullfilename,'.mat'),'conn_args');
                if 0, conn_msgbox(sprintf('Bookmark %s saved',fullfilename),'',2);
                else out=fullfilename;
                end
                return;
            case 'info',
                voxelsize=round(1e3*sqrt(sum(state.mat(1:3,1:3).^2,1)))/1e3;
                conn_msgbox([{'Volume:'},cellstr(state.info.structural),{' ','Activation surface/contour:'},cellstr(state.info.vol),{' ','Voxel size used for display (mm):'},{mat2str(voxelsize)}],'Slice display info');
                return;
            case 'togglepointer'
                if get(state.handles.mode,'value')==1, set(state.handles.mode,'string','Click on image to select reference point');
                else set(state.handles.mode,'string','Click on image to rotate');
                end
                redrawnow=true;
            case 'togglegui',
                if numel(varargin)>0, onoff=varargin{1}; 
                else onoff=get(state.handles.gui,'value')==1;
                end
                if onoff, 
                    set(state.handles.gui,'string','Show GUI');
                    h=findobj(state.handles.hfig,'type','uicontrol');
                    set(h(~strcmp(get(h,'style'),'togglebutton')),'visible','off');
                    set(state.handles.axes,'units','norm','position',[.05 .05 .90 .9]);
                    set(state.handles.slider,'units','norm','position',[.97 .1 .025 .8]);
                    if ~isempty(state.handles.colorbar), set(state.handles.colorbar(1),'unit','norm','position',[.95 .15 .015 .75]); end
                else
                    set(state.handles.gui,'string','Hide GUI');
                    h=findobj(state.handles.hfig,'type','uicontrol');
                    set(h(~strcmp(get(h,'style'),'togglebutton')),'visible','on');
                    set(state.handles.axes,'units','norm','position',[.05 .05 .40 .9]);
                    set(state.handles.slider,'units','norm','position',[.47 .1 .025 .8]);
                    if ~isempty(state.handles.colorbar), set(state.handles.colorbar(1),'unit','norm','position',[.453 .15 .015 .75]); end
                end
                redrawnow=true;
            case 'pointer_mm',
                value=[str2num(get(state.handles.pointer_mm(1),'string')) str2num(get(state.handles.pointer_mm(2),'string')) str2num(get(state.handles.pointer_mm(3),'string'))];
                if numel(value)==3
                    if nargin>4,
                        if strcmp(varargin{1},'+'), d=1; else d=-1; end
                        npointer=varargin{2};
                    elseif nargin>3,
                        v=get(state.handles.slider,'value');
                        npointer=state.cameraviewdirs(find(state.view(1:3),1));
                        d=round(state.xyz_range(npointer,1)+v*(state.xyz_range(npointer,2)-state.xyz_range(npointer,1)))-value(npointer);
                    else
                        npointer=1; d=0;
                    end
                    value(npointer)=value(npointer)+d;
                    state.pointer_mm=value;
                    state.pointer_vox=round([state.pointer_mm 1]*pinv(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]+.001);
                end
                for n=1:3, set(state.handles.pointer_mm(n),'string',num2str(state.pointer_mm(n)));end
                for n=1:3, set(state.handles.pointer_vox(n),'string',num2str(state.pointer_vox(n)));end
                redrawnow=true;
            case 'pointer_vox'
                value=[str2num(get(state.handles.pointer_vox(1),'string')) str2num(get(state.handles.pointer_vox(2),'string')) str2num(get(state.handles.pointer_vox(3),'string'))];
                if numel(value)==3
                    if nargin>4,
                        if strcmp(varargin{1},'+'), d=1; else d=-1; end
                        npointer=varargin{2};
                    elseif nargin>3,
                        v=get(state.handles.slider,'value');
                        npointer=state.cameraviewdirs(find(state.view(1:3),1));
                        d=round(1+v*(state.size(npointer)-1))-value(npointer);
                    else
                        npointer=1; d=0;
                    end
                    value(npointer)=value(npointer)+d;
                    state.pointer_vox=value;
                    state.pointer_mm=round([state.pointer_vox 1]*(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]);
                end
                for n=1:3, set(state.handles.pointer_mm(n),'string',num2str(state.pointer_mm(n)));end
                for n=1:3, set(state.handles.pointer_vox(n),'string',num2str(state.pointer_vox(n)));end
                redrawnow=true;
            case 'time'
                value=get(state.handles.time,'value');
                state.time=round(1+(state.endtime-1)*max(0,min(1,value)));
                set(state.handles.time,'tooltipstring',sprintf('Volume/scan %d/%d',state.time,state.endtime));
                set(state.handles.timestr,'string',sprintf('%d/%d',state.time,state.endtime));
                redrawnow=true;
            case 'buttondown',
                p=get(gca,'cameraposition'); 
                pos=get(state.handles.axes,'currentpoint');
                pos=pos(1,1:3);
                mp=-inf;mpos=[];
                for nview=1:3,
                    if state.view(nview)
                        if 0,
                            txyz=get(state.handles.patch(nview),'vertices');
                            txyz=conn_bsxfun(@minus,txyz,pos);
                            ftxyz=(txyz/p)*p;
                            [mind,idx]=min(sum(abs(txyz-ftxyz).^2,2));
                            tpos=txyz(idx,:)+pos;
                            tp=-mind;
                            if tp>mp&&tp>-4, mpos=tpos; mp=tp; end
                        else
                            k=(state.pointer_mm(nview)-pos(nview))/p(nview);
                            tpos=pos+p*k;
                            tp=p*tpos';
                            if all(tpos>=state.xyz_range(:,1)')&&all(tpos<=state.xyz_range(:,2)')&&tp>mp, mpos=tpos; mp=tp; end
                        end
                    end
                end
                if ~isempty(mpos)
                    state.pointer_mm=round(mpos);
                    state.pointer_vox=round([state.pointer_mm 1]*pinv(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]+.001);
                end
%                 nview=find(state.view(1:3));
%                 if numel(nview)==1
%                     pos=get(state.handles.axes,'currentpoint');
%                     switch nview
%                         case 1, state.pointer_mm([2 3])=round(pos(1,[2 3]));
%                         case 2, state.pointer_mm([1 3])=round(pos(1,[1 3]));
%                         case 3, state.pointer_mm([1 2])=round(pos(1,[1 2]));
%                     end
%                     state.pointer_vox=round([state.pointer_mm 1]*pinv(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]+.001);
%                     %state.pointer_mm=round([state.pointer_vox 1]*(state.mat)'*[1 0 0;0 1 0;0 0 1;0 0 0]);
%                 end
                for n=1:3, set(state.handles.pointer_mm(n),'string',num2str(state.pointer_mm(n)));end
                for n=1:3, set(state.handles.pointer_vox(n),'string',num2str(state.pointer_vox(n)));end
                redrawnow=true;
            case 'view',
                oldview=state.view;
                for nview=1:length(state.handles.view), state.view(nview)=get(state.handles.view(nview),'value'); end
                if any(oldview(1:3)~=state.view(1:3))
                    nview=find(state.view(1:3));
                    if (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,1), state.cameraview=state.cameraviews(1,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                    elseif (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,2), state.cameraview=state.cameraviews(2,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                    elseif (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,3), state.cameraview=state.cameraviews(3,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                    %elseif nnz(abs(view*[1 0 0;0 1 0;0 0 1;0 0 0])>.01)==3, state.cameraview=[1 1 1]; set(state.handles.mode,'value',0,'string','Click on image to rotate');
                    else state.cameraview=[1 1 1]; set(state.handles.mode,'value',0,'string','Click on image to rotate');
                    end
                end
                redrawnow=true;
            case 'multisliceset',
                if get(state.handles.multislice0,'value')==1, 
                    set([state.handles.multislice1 state.handles.multislice2],'visible','on');
                    state.nslices=9;
                    set(state.handles.multislice1,'string',num2str(state.nslices));
                else
                    set([state.handles.multislice1 state.handles.multislice2],'visible','off');
                    state.nslices=1;
                    set(state.handles.multislice1,'string',num2str(state.nslices));
                end
                nview=find(state.view(1:3));
                if (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,1), state.cameraview=state.cameraviews(1,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                elseif (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,2), state.cameraview=state.cameraviews(2,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                elseif (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,3), state.cameraview=state.cameraviews(3,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                else state.cameraview=[1 1 1]; set(state.handles.mode,'value',0,'string','Click on image to rotate');
                end
                redrawnow=true;
            case 'multislice'
                val=str2num(get(state.handles.multislice1,'string'));
                if ~isempty(val), state.nslices=min(1e3,max(1,round(val))); end
                set(state.handles.multislice1,'string',num2str(state.nslices));
                val=str2num(get(state.handles.multislice2,'string'));
                if ~isempty(val), state.dslices=max(1,round(val)); end
                set(state.handles.multislice2,'string',num2str(state.dslices));
                redrawnow=true;
            case 'colorbar',
                if strcmp(varargin{1},'rescale')
                    answ=inputdlg({'Enter new colorbar limits:'},'Rescale colorbar',1,{mat2str(state.Vrange([1 end]),6)});
                    if ~isempty(answ)&&numel(str2num(answ{1}))==2
                        state.Vrange([1 end])=str2num(answ{1});
                        redrawnow=true;
                    end
                    redrawnow=true;
                else
                    set(state.handles.colorbar(2:end),'visible',varargin{1});
                end
                redrawnowcolorbar=true;
            case 'material'
                str=varargin{1};
                if isempty(str), set(state.handles.light,'visible','off');
                else
                    set(state.handles.light,'visible','on');
                    material(str);
                end
            case 'light'
                scale=varargin{1};
                set(state.handles.light,'color',scale*[1 1 1]);
            case 'colormap'
                cmap=varargin{1};
                if ischar(cmap)
                    switch(cmap)
                        case 'red', cmap=[linspace(0,1,256)',zeros(256,2)];
                        case 'hot', cmap=hot(256);
                        case 'jet', cmap=jet(256);
                        case 'gray', cmap=gray(256);
                        case 'cool',cmap=cool(256);
                        case 'hsv',cmap=hsv(256);
                        case 'spring',cmap=spring(256);
                        case 'summer',cmap=summer(256);
                        case 'autumn',cmap=autumn(256);
                        case 'winter',cmap=winter(256);
                        case 'random',cmap=rand(256,3);
                        case 'brighter',cmap=min(1,1/sqrt(.95)*get(state.handles.hfig,'colormap').^(1/2)); 
                        case 'darker',cmap=.95*get(state.handles.hfig,'colormap').^2; 
                        case 'manual',answer=inputdlg({'colormap (256x3)'},'',1,{mat2str(state.cmap)});if ~isempty(answer), answer=str2num(answer{1}); end;if ~any(size(answer,1)==[256]), return; end;cmap=max(0,min(1,answer));
                        case 'color',cmap=uisetcolor([],'Select color'); if isempty(cmap)||isequal(cmap,0), return; end; 
                        otherwise, disp('unknown value');
                    end
                end
                if size(cmap,2)<3, cmap=cmap(:,min(size(cmap,2),1:3)); end
                if size(cmap,1)==1, cmap=repmat(cmap,2,1); end
                state.cmap=cmap;
                set(state.handles.hfig,'colormap',cmap);
                redrawnow=true;
                redrawnowcolorbar=true;
            case 'background'
                if numel(varargin)>0&&~isempty(varargin{1}), color=varargin{1};
                else color=uisetcolor(state.background,'Select color'); if isempty(color)||isequal(color,0), return; end; 
                end
                state.background=color;
                set(state.handles.hfig,'color',color);
                redrawnowcolorbar=true;
            case 'slice_transparency'
                scale=varargin{1};
                state.slice_transparency=max(eps,scale);
                redrawnow=true;
            case 'act_transparency'
                scale=varargin{1};
                state.transparency=max(eps,scale);
                set([state.handles.act1 state.handles.act2],'facealpha',state.transparency);
                redrawnow=true;
            case 'black_transparency'
                str=varargin{1};
                if strcmp(str,'on'), state.blackistransparent=true; 
                else state.blackistransparent=false; 
                end
                redrawnow=true;
            case 'vol_transparency'
                scale=varargin{1};
                state.view(5)=max(0,min(1,round(scale)));
                %set(state.handles.view(5),'value',state.view(5));
                redrawnow=true;
            case 'contour_transparency'
                scale=varargin{1};
                state.contourtransparency=scale;
                redrawnow=true;
            case 'brighter'
                scale=varargin{1};
                state.colorbrightness=state.colorbrightness+scale;
                redrawnow=true;
            case 'contrast'
                scale=varargin{1};
                state.colorcontrast=state.colorcontrast+scale;
                redrawnow=true;
            case 'expandmultiview',
                str=varargin{1};
                if strcmp(str,'on'), state.expandmultiview=true; 
                else state.expandmultiview=false; 
                end
                nview=find(state.view(1:3));
                if (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,1), state.cameraview=state.cameraviews(1,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                elseif (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,2), state.cameraview=state.cameraviews(2,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                elseif (all(state.nslices==1)||state.expandmultiview)&&isequal(nview,3), state.cameraview=state.cameraviews(3,:); set(state.handles.mode,'value',1,'string','Click on image to select reference point');
                else state.cameraview=[1 1 1]; set(state.handles.mode,'value',0,'string','Click on image to rotate');
                end
                redrawnow=true;
            case 'position'
                p=get(state.handles.axes,'cameraposition'); 
                set(findobj(gcbf,'type','light'),'position',p);
                state.cameraview=[];
            case 'print'
                set([state.handles.gui state.handles.mode state.handles.text1 state.handles.text2],'visible','off');
                value=get(state.handles.gui,'value');
                set(state.handles.gui,'value',1);
                if numel(varargin)>0, conn_print(state.handles.hfig,varargin{:});
                else conn_print(state.handles.hfig,fullfile(state.defaultfilepath,'print01.jpg'));
                end
                set([state.handles.gui state.handles.mode],'visible','on');
                set(state.handles.gui,'value',value);
        end
        
        if redrawnow
            %tslices=state.dslices*((1:state.nslices)-1);
            kslices=1;
            minmax=[];
            cmap0=get(state.handles.hfig,'colormap');
            ccolor=get(state.handles.hfig,'color');
            dcamera=get(state.handles.axes,'cameraposition')-get(state.handles.axes,'cameratarget'); dcamera=dcamera(:)/max(eps,norm(dcamera));
            cmap=@(alpha,rgb)interp1(linspace(0,1,size(cmap0,1)),cmap0(:,rgb),max(0,min(1,alpha)));
            for nview=1:3
                if state.view(nview)
                    tslices=state.dslices(min(numel(state.dslices),nview))*((1:state.nslices(min(numel(state.nslices),nview)))-round((state.nslices(min(numel(state.nslices),nview))+1)/2));
                    switch nview
                        case 1,
                            tslices(state.pointer_vox(1)+tslices<1|state.pointer_vox(1)+tslices>state.size(1))=[];
                            x=permute(state.xyz_x(max(1,min(state.size(1),state.pointer_vox(1)+kslices*tslices)),:,:),[2 3 1]);
                            y=permute(state.xyz_y(max(1,min(state.size(1),state.pointer_vox(1)+tslices)),:,:),[2 3 1]);
                            z=permute(state.xyz_z(max(1,min(state.size(1),state.pointer_vox(1)+tslices)),:,:),[2 3 1]);
                            z1=permute(state.structural(max(1,min(state.size(1),state.pointer_vox(1)+tslices)),:,:,min(size(state.structural,4),state.time)),[2 3 1]);
                            if state.isvol, z2=permute(state.supra(max(1,min(state.size(1),state.pointer_vox(1)+tslices)),:,:,min(size(state.supra,4),state.time)),[2 3 1]); end
                        case 2,
                            tslices(state.pointer_vox(2)+tslices<1|state.pointer_vox(2)+tslices>state.size(2))=[];
                            x=permute(state.xyz_x(:,max(1,min(state.size(2),state.pointer_vox(2)+tslices)),:),[1 3 2]);
                            y=permute(state.xyz_y(:,max(1,min(state.size(2),state.pointer_vox(2)+kslices*tslices)),:),[1 3 2]);
                            z=permute(state.xyz_z(:,max(1,min(state.size(2),state.pointer_vox(2)+tslices)),:),[1 3 2]);
                            z1=permute(state.structural(:,max(1,min(state.size(2),state.pointer_vox(2)+tslices)),:,min(size(state.structural,4),state.time)),[1 3 2]);
                            if state.isvol, z2=permute(state.supra(:,max(1,min(state.size(2),state.pointer_vox(2)+tslices)),:,min(size(state.supra,4),state.time)),[1 3 2]); end
                        case 3,
                            tslices(state.pointer_vox(3)+tslices<1|state.pointer_vox(3)+tslices>state.size(3))=[];
                            x=permute(state.xyz_x(:,:,max(1,min(state.size(3),state.pointer_vox(3)+tslices))),[1 2 3]);
                            y=permute(state.xyz_y(:,:,max(1,min(state.size(3),state.pointer_vox(3)+tslices))),[1 2 3]);
                            z=permute(state.xyz_z(:,:,max(1,min(state.size(3),state.pointer_vox(3)+kslices*tslices))),[1 2 3]);
                            z1=permute(state.structural(:,:,max(1,min(state.size(3),state.pointer_vox(3)+tslices)),min(size(state.structural,4),state.time)),[1 2 3]);
                            if state.isvol, z2=permute(state.supra(:,:,max(1,min(state.size(3),state.pointer_vox(3)+tslices)),min(size(state.supra,4),state.time)),[1 2 3]); end
                    end
                    if state.isvol, 
                        z0=convn(convn(z2>state.actthr|z2<-state.actthr,conn_hanning(7)/4,'same'),conn_hanning(7)'/4,'same');
                        %if state.isstat, z0=convn(convn(z2>state.actthr|z2<-state.actthr,conn_hanning(7)/4,'same'),conn_hanning(7)'/4,'same');
                        %else z0=convn(convn((z2>state.actthr|z2<-state.actthr),conn_hanning(7)/4,'same'),conn_hanning(7)'/4,'same')&~convn(z2,[-1;0;1],'same')&~convn(z2,[-1 0 1],'same');
                        %end
                        [f1,f2,x0,x1,x2,f3]=conn_slice_display_surf2patch(x,y,z,state.expandmultiview,state.blackistransparent,state.handles.axes,nview,find(tslices==0),[1 1 2 2 2 1],z1,z2,~isnan(z1),{(z2>state.actthr).*z2,state.actthr},{-z2.*(z2<-state.actthr),state.actthr},z0); 
                    else
                        [f1,x0]=conn_slice_display_surf2patch(x,y,z,state.expandmultiview,state.blackistransparent,state.handles.axes,nview,find(tslices==0),[1 2],z1,~isnan(z1));
                    end
                    if isempty(minmax), minmax=[min(f1.vertices,[],1);max(f1.vertices,[],1)];
                    else minmax=[min(minmax(1,:),min(f1.vertices,[],1));max(minmax(2,:),max(f1.vertices,[],1))];
                    end
                    c1=f1.facevertexcdata;
                    %h=conn_hanning(5);h=h/sum(h); c1=convn(convn(c1,h,'same'),h','same');
                    c0=c1/max(abs(c1));
                    c1=(c1-min(c1))/max(eps,max(c1)-min(c1));
                    if 0, 
                        disp([size(c1) nnz(c1)]); % placeholder for transparency threshold/masking
                        c1(c1<.25)=nan;
                    end
                    c=repmat(c1,[1 3]);
                    c=max(0,min(1,state.colorbrightness+c.^state.colorcontrast));
                    if state.isvol, 
                        %c0=c;
                        s2=f2.facevertexcdata;
                        maxs2=max(1e-4,max(abs(s2)));
                        mask1=s2>state.actthr;
                        mask2=s2<-state.actthr;
                        c2a=max(0,min(1,(s2-max(0,state.Vrange(1)))/max(eps,state.Vrange(2)-max(0,state.Vrange(1)))));
                        c2b=max(0,min(1,(-s2+min(0,state.Vrange(2)))/max(eps,min(0,state.Vrange(2))-state.Vrange(1))));
                        %c2=.1+.9*abs(s2)/maxs2;
                        if state.blackistransparent, fb=f3.facevertexcdata.^4;
                        else fb=ones(size(f3.facevertexcdata)); 
                        end
                        alphamix=1-state.transparency*fb;
                        %fb=zeros(size(s2));
                        %fb(mask1)=max(0,(s2(mask1)-state.actthr)/max(eps,max(s2)-state.actthr)).^.5;
                        %fb(mask2)=max(0,(-s2(mask2)-state.actthr)/max(eps,max(-s2)-state.actthr)).^.5;
                        %alphamix=max(0,1-2*state.transparency)+2*min(state.transparency,(1-state.transparency))*(1-fb); 
                        %%alphamix=max(0,1-state.transparency);
                        c(mask1,1)=alphamix(mask1).*max(0,c(mask1,1))+(1-alphamix(mask1)).*cmap(c2a(mask1,1),1);
                        c(mask1,2)=alphamix(mask1).*max(0,c(mask1,2))+(1-alphamix(mask1)).*cmap(c2a(mask1,1),2);
                        c(mask1,3)=alphamix(mask1).*max(0,c(mask1,3))+(1-alphamix(mask1)).*cmap(c2a(mask1,1),3);
                        c(mask2,3)=alphamix(mask2).*max(0,c(mask2,3))+(1-alphamix(mask2)).*cmap(c2b(mask2),1);
                        c(mask2,1)=alphamix(mask2).*max(0,c(mask2,1))+(1-alphamix(mask2)).*cmap(c2b(mask2),2);
                        c(mask2,2)=alphamix(mask2).*max(0,c(mask2,2))+(1-alphamix(mask2)).*cmap(c2b(mask2),3);
                        %c=conn_bsxfun(@times,abs(s2)<=state.actthr,c0)+conn_bsxfun(@times,abs(s2)>state.actthr,c);
                        if state.contourtransparency
                            set(state.handles.patchcontour1(nview),'xdata',x1(1,:),'ydata',x1(2,:),'zdata',x1(3,:),'color',cmap0(1,:),'visible','on');
                            set(state.handles.patchcontour2(nview),'xdata',x2(1,:),'ydata',x2(2,:),'zdata',x2(3,:),'color',cmap0(1,[2 3 1]),'visible','on');
                        else set([state.handles.patchcontour1(nview),state.handles.patchcontour2(nview)],'visible','off'); 
                        end
                    else fb=1;
                    end
                    %c(~all(c>0,2),:)=nan;
                    set(state.handles.patch(nview),'faces',f1.faces,'vertices',f1.vertices,'facevertexcdata',c,'facecolor','flat','edgecolor','none','FaceLighting', 'gouraud','visible','on');
                    if state.blackistransparent, fa=min(1,max(0,10*c0)).^2;
                    else fa=double(~isnan(c0));
                    end
                    if 1, set(state.handles.patch(nview),'facevertexalpha',state.slice_transparency*fa,'facealpha','flat','AlphaDataMapping','none'); 
                    else set(state.handles.patch(nview),'facevertexalpha',[],'facealpha',state.slice_transparency); 
                    end
                    %set(state.handles.patchcontour(nview),'xdata',x0(1,:),'ydata',x0(2,:),'zdata',x0(3,:),'color',ccolor,'visible','on');
                else
                    set([state.handles.patch(nview)],'visible','off');
                    %set([state.handles.patchcontour(nview)],'visible','off');
                    if state.isvol, set([state.handles.patchcontour1(nview),state.handles.patchcontour2(nview)],'visible','off'); end
                end
            end
            set([state.handles.act1 state.handles.act2],'visible','off');
            if state.view(4), set([state.handles.line1 state.handles.line2 state.handles.line3],'visible','on');
            else set([state.handles.line1 state.handles.line2 state.handles.line3],'visible','off');
            end
            if numel(state.view)>4&&state.view(5), 
                if ~isempty(state.handles.act1), set(state.handles.act1(min(state.time,numel(state.handles.act1))),'visible','on'); end
                if ~isempty(state.handles.act2), set(state.handles.act2(min(state.time,numel(state.handles.act2))),'visible','on'); end
            end
            
            if isempty(state.cameraview), state.cameraview=get(gca,'cameraposition'); state.cameraview=state.cameraview(:)'; 
            else view(state.handles.axes,state.cameraview); 
            end
            set(findobj(state.handles.hfig,'type','light'),'position',state.cameraview);
            set([state.handles.line1 state.handles.line2 state.handles.line3],'xdata',[],'ydata',[],'zdata',[]);
            try, set(state.handles.line1,'xdata',state.xyz_x(state.pointer_vox(1),state.pointer_vox(2),:),'ydata',state.xyz_y(state.pointer_vox(1),state.pointer_vox(2),:),'zdata',state.xyz_z(state.pointer_vox(1),state.pointer_vox(2),:)); end
            try, set(state.handles.line2,'xdata',state.xyz_x(state.pointer_vox(1),:,state.pointer_vox(3)),'ydata',state.xyz_y(state.pointer_vox(1),:,state.pointer_vox(3)),'zdata',state.xyz_z(state.pointer_vox(1),:,state.pointer_vox(3))); end
            try, set(state.handles.line3,'xdata',state.xyz_x(:,state.pointer_vox(2),state.pointer_vox(3)),'ydata',state.xyz_y(:,state.pointer_vox(2),state.pointer_vox(3)),'zdata',state.xyz_z(:,state.pointer_vox(2),state.pointer_vox(3))); end
            if state.isstat, 
                set([state.handles.text1 state.handles.text2],'string','','visible','off');
                try, 
                    if get(state.handles.gui,'value')~=1
                        if isequal(state.stats,'T'), set(state.handles.text1,'string',sprintf('Voxel-level: (%d,%d,%d)  %s(%s) = %.2f  p = %.6f (two-sided p = %.6f)',round(state.pointer_mm(1)),round(state.pointer_mm(2)),round(state.pointer_mm(3)), state.stats,mat2str(state.dof(end)),state.T(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3),min(state.time,size(state.T,4))),state.p(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3),min(state.time,size(state.p,4))),2*min(state.p(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3),min(state.time,size(state.p,4))),1-state.p(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3),min(state.time,size(state.p,4))))),'visible','on');
                        else set(state.handles.text1,'string',sprintf('Voxel-level: (%d,%d,%d)  %s(%s) = %.2f  p = %.6f',round(state.pointer_mm(1)),round(state.pointer_mm(2)),round(state.pointer_mm(3)), state.stats,mat2str(state.dof),state.T(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3),min(state.time,size(state.T,4))),state.p(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3),min(state.time,size(state.p,4)))),'visible','on');
                        end
                    end
                end
                if ~isempty(state.clusters)&&get(state.handles.gui,'value')~=1
                    supra=state.supra(:,:,:,min(state.time,size(state.supra,4)))~=0;
                    d=inf(state.size(1:3));
                    d(supra)=(state.xyz_x(supra)-state.pointer_mm(1)).^2+(state.xyz_y(supra)-state.pointer_mm(2)).^2+(state.xyz_z(supra)-state.pointer_mm(3)).^2;
                    [mind,idxd]=min(d(:));
                    for n=1:numel(state.clusters.idx)
                        if any(d(state.clusters.idx{n})==mind),
                            set(state.handles.text2,'string',sprintf('Closest-cluster: %s',state.clusters.stats{n}),'visible','on');
                            break;
                        end
                    end
                end
            else
                set([state.handles.text1],'string','','visible','off');
                if get(state.handles.gui,'value')~=1, 
                    try, 
                        val=state.T(state.pointer_vox(1),state.pointer_vox(2),state.pointer_vox(3),min(state.time,size(state.T,4)));
                        lname='';
                        if ~isempty(state.refnames), 
                            if state.reftype==1&&round(val)>0, lname=state.refnames{round(val)};
                            elseif state.reftype==2, lname=state.refnames{state.time};
                            end
                        end
                        set(state.handles.text1,'string',sprintf('Value: (%d,%d,%d)  = %s %s',round(state.pointer_mm(1)),round(state.pointer_mm(2)),round(state.pointer_mm(3)), mat2str(1e-6*round(1e6*val)), lname),'visible','on'); 
                    end
                end
            end
            if get(state.handles.mode,'value')==1,
                set(rotate3d,'enable','off');
                set(state.handles.patch,'buttondownfcn',{@conn_slice_display_refresh,'buttondown'});
                set([state.handles.line1 state.handles.line2 state.handles.line3 state.handles.act1 state.handles.act2],'buttondownfcn',{@conn_slice_display_refresh,'buttondown'});
            else
                set(rotate3d,'enable','on');
                set(state.handles.patch,'buttondownfcn',[]);
                set([state.handles.line1 state.handles.line2 state.handles.line3 state.handles.act1 state.handles.act2],'buttondownfcn',[]);
            end
            if sum(state.view(1:3))==1&&all(state.nslices==1), 
                npointer=state.cameraviewdirs(find(state.view(1:3),1));
                d=(state.pointer_mm(npointer)-state.xyz_range(npointer,1))/(state.xyz_range(npointer,2)-state.xyz_range(npointer,1));
                set(state.handles.slider,'value',d,'sliderstep',[1/max(1,state.xyz_range(npointer,2)-state.xyz_range(npointer,1)), 10/max(1,state.xyz_range(npointer,2)-state.xyz_range(npointer,1))]);
                if strcmp(get(state.handles.pointer_mm(1),'visible'),'on'), set(state.handles.slider,'visible','on'); else set(state.handles.slider,'visible','off'); end
            else set(state.handles.slider,'visible','off');
            end
            if ~isempty(minmax), set(state.handles.axes,'xlim',minmax(:,1)'+[-.9 .9],'ylim',minmax(:,2)'+[-.9 .9],'zlim',minmax(:,3)'+[-.9 .9]); end
        end
        if ~isempty(state.handles.colorbar)&&redrawnowcolorbar
            if state.Vrange(1)>=0,
                set(state.handles.colorbar(2),'cdata',max(0,min(1, ind2rgb(round(linspace(1,size(state.cmap,1),128)'),state.cmap))));
            elseif state.Vrange(2)<=0,
                set(state.handles.colorbar(2),'cdata',max(0,min(1, ind2rgb(round(linspace(size(state.cmap,1),1,128)'),state.cmap(:,[2 3 1])))));
            else
                set(state.handles.colorbar(2),'cdata',cat(1,max(0,min(1, ind2rgb(round(linspace(size(state.cmap,1),1,64)'),state.cmap(:,[2 3 1])))),max(0,min(1, ind2rgb(round(linspace(1,size(state.cmap,1),64)'),state.cmap)))));
            end
            set(state.handles.colorbar(3),'string',num2str(state.Vrange(1),'%.2f'),'color',1-round(mean(state.background))*[1 1 1]);
            set(state.handles.colorbar(4),'string','');
            set(state.handles.colorbar(5),'string',num2str(state.Vrange(2),'%.2f'),'color',1-round(mean(state.background))*[1 1 1]);
        end
    end
end

function varargout=conn_slice_display_surf2patch(x,y,z,expand,smoothc,axesh,nview,refslice,opts,varargin)
if isempty(refslice), refslice=1; end
minl=[0,8]; % remove contours with length (pixels) below minl
x1=[1.5*x(:,1,refslice)-.5*x(:,2,refslice) .5*x(:,1:end-1,refslice)+.5*x(:,2:end,refslice) 1.5*x(:,end,refslice)-.5*x(:,end-1,refslice)];
x1=[1.5*x1(1,:)-.5*x1(2,:);.5*x1(1:end-1,:)+.5*x1(2:end,:);1.5*x1(end,:)-.5*x1(end-1,:)];
y1=[1.5*y(:,1,refslice)-.5*y(:,2,refslice) .5*y(:,1:end-1,refslice)+.5*y(:,2:end,refslice) 1.5*y(:,end,refslice)-.5*y(:,end-1,refslice)];
y1=[1.5*y1(1,:)-.5*y1(2,:);.5*y1(1:end-1,:)+.5*y1(2:end,:);1.5*y1(end,:)-.5*y1(end-1,:)];
z1=[1.5*z(:,1,refslice)-.5*z(:,2,refslice) .5*z(:,1:end-1,refslice)+.5*z(:,2:end,refslice) 1.5*z(:,end,refslice)-.5*z(:,end-1,refslice)];
z1=[1.5*z1(1,:)-.5*z1(2,:);.5*z1(1:end-1,:)+.5*z1(2:end,:);1.5*z1(end,:)-.5*z1(end-1,:)];
vertices=[x1(:) y1(:) z1(:)];
a=reshape(1:numel(x1),size(x1));
faces=reshape(cat(3, a(1:end-1,1:end-1), a(2:end,1:end-1),a(2:end,2:end),a(1:end-1,2:end)),[],4);

[d1,d2,d3]=deal(zeros(1,3));
x0={x,y,z};
for n=1:3,
    d1(n)=(size(x0{n},1)+1)*mean(mean(diff(x0{n}(:,:,1),1,1),1),2);
    d2(n)=(size(x0{n},2)+1)*mean(mean(diff(x0{n}(:,:,1),1,2),1),2);
    d3(n)=mean(mean(x0{n}(:,:,min(size(x0{n},3),2))-x0{n}(:,:,1),1),2);
end
switch(nview) % d1: left-to-right in plot; d2: top-to-bottom in plot
    case 1, d1=-abs(d1);d2=-abs(d2);
    case 2, d1=abs(d1); d2=-abs(d2); 
    case 3, d1=abs(d1); d2=-abs(d2); 
end
d=[norm(d1) norm(d2) norm(d3) zeros(1,min(2,numel(varargin)))];

units=get(axesh,'units');
set(axesh,'units','points');
emphx=get(axesh,'position');
set(axesh,'units',units);
emphx=emphx(4)/emphx(3);
[n1,n2]=ndgrid(1:size(x,3),1:size(x,3)); n1=n1(:); n2=n2(:);
[nill,idx]=max(min(d(2)./n1(:), emphx*d(1)./n2(:))-1e10*(n1(:).*n2(:)<size(x,3)));
n1=n1(idx); n2=n2(idx);
[i1,i2]=ind2sub([n1 n2],1:size(x,3));
if ~expand, i1(:)=1; i2(:)=1; end

done=false;
for n=find(opts==1),
    if ~done
        done=true;
        varargout{n}=struct('vertices',zeros(size(vertices,1)*numel(i1),3),'faces',zeros(size(faces,1)*numel(i1),4),'facevertexcdata',zeros(size(faces,1)*numel(i1),1));
        for m=1:numel(i1)
            %newvertices=vertices+repmat(d1*(i1(m)-ceil(n1/2))+d2*(i2(m)-ceil(n2/2))+d3*(m-1),size(vertices,1),1);
            newvertices=vertices+repmat(d1*(i1(m)-i1(refslice))+d2*(i2(m)-i2(refslice))+d3*(m-refslice),size(vertices,1),1);
            newfaces=(m-1)*size(vertices,1)+faces;
            newc=reshape(varargin{n}(:,:,m),[],1);
            varargout{n}.faces((m-1)*size(faces,1)+(1:size(faces,1)),:)=newfaces;
            varargout{n}.vertices((m-1)*size(vertices,1)+(1:size(vertices,1)),:)=newvertices;
            varargout{n}.facevertexcdata((m-1)*size(faces,1)+(1:size(faces,1)),:)=newc;
        end
    else
        varargout{n}=varargout{1};
        for m=1:numel(i1)
            newc=reshape(varargin{n}(:,:,m),[],1);
            varargout{n}.facevertexcdata((m-1)*size(faces,1)+(1:size(faces,1)),:)=newc;
        end
    end
end
if any(opts==2)
    if size(x,1)==1, x=cat(1,x,x); y=cat(1,y,y); z=cat(1,z,z); end
    if size(x,2)==1, x=cat(2,x,x); y=cat(2,y,y); z=cat(2,z,z); end
    if size(x,3)==1, x=cat(3,x,x); y=cat(3,y,y); z=cat(3,z,z); end
    for n=find(opts==2)
        c1=zeros(3,0); 
        %tmin=min(varargin{n}(:));tmax=max(varargin{n}(:));
        if 1,%~isnan(tmin)&&~isnan(tmax)&&tmin~=tmax
            if iscell(varargin{n}), data=varargin{n}{1}; thr=varargin{n}{2};
            else data=varargin{n}; thr=.5;
            end
            for m=1:size(data,3)
                ct=contourc(double(data(:,:,m)),thr*[1 1]); %tmin+(tmax-tmin)*[.10 .10]); %[.5 .5]);
                if ~isempty(ct), c1=[c1 [ct;m+zeros(1,size(ct,2))]]; end
            end
        end
        x1=zeros(3,0);
        try, x1=cat(1,interpn(x,c1(2,:),c1(1,:),refslice+0*c1(3,:)),interpn(y,c1(2,:),c1(1,:),refslice+0*c1(3,:)),interpn(z,c1(2,:),c1(1,:),refslice+0*c1(3,:))); end
        if ~isempty(x1), 
            m=c1(3,:);
            x1=x1+(d1'*(i1(m)-i1(refslice))+d2'*(i2(m)-i2(refslice))+d3'*(m-refslice));
            h=conn_hanning(5)'/3;
            ci=1;while ci<size(c1,2), cj=ci+c1(2,ci)+1; if cj-ci<=minl(1+(smoothc~=0)), x1(:,ci:cj-1)=nan; else x1(:,ci)=nan; if smoothc, x1(:,ci+1:cj-2)=convn(x1(:,ci+1+mod(0:cj-ci-3+4,cj-ci-2)),h,'valid'); x1(:,cj-1)=x1(:,ci+1); end; end; ci=cj; end; 
        end
        varargout{n}=x1;
    end
end
end

function c=spring(m)
r = (0:m-1)'/max(m-1,1); 
c = [ones(m,1) r 1-r];
end
function c=summer(m)
r = (0:m-1)'/max(m-1,1); 
c = [r .5+r/2 .4*ones(m,1)];
end
function c=winter(m)
r = (0:m-1)'/max(m-1,1); 
c = [zeros(m,1) r .5+(1-r)/2];
end
function c=autumn(m)
r = (0:m-1)'/max(m-1,1);
c = [ones(m,1) r zeros(m,1)];
end




    