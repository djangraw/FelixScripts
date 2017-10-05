function conn_surf_results(filename,varargin)

global CONN_gui;
if ~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end

%% main function
if nargin<1||(isempty(filename)&&~ischar(filename)), 
    answ=conn_questdlg('Surface statistics from:','select file type','SPM.mat','spmT_ file','SPM.mat');
    if strcmp(answ,'SPM.mat')
        disp('Select SPM.mat file');
        [filename,path_name]=uigetfile('SPM.mat*','Select SPM.mat file');
        filename=fullfile(path_name,filename);
    elseif strcmp(answ,'spmT_ file')
        disp('Select contrast file(s) (spmT). Select a single file containing surface-vertex statistics for both hemispheres; or two files each containing left&right hemisphere statistics, respectively');
        filename=spm_select(inf,'image','Select contrast file(s) (spmT)',[],[],'spmT_.*');
    end
end
if any(strcmp(varargin(1:2:end-1),'style')), STYLE=varargin{2*find(strcmp(varargin(1:2:end),'style'),1)};
else STYLE='conn';
end

pathname=fileparts(which(mfilename));
filenames={'white','pial','inflated'};
hems={'lh.','rh.'};
PATCHES={};
for n1=1:numel(filenames)
    for n2=1:numel(hems)
        PATCHES{n1,n2}=conn_surf_readsurf(fullfile(pathname,'utils','surf',[hems{n2},filenames{n1},'.surf'])); 
    end
end
ADJ=spm_mesh_adjacency(PATCHES{1});
temp=sparse(1:size(ADJ,1),1:size(ADJ,2),1./(sum(ADJ,2)+1))*(ADJ+sparse(1:size(ADJ,1),1:size(ADJ,2),1));
for n2=1:numel(hems)
    x1=(PATCHES{1,n2}.vertices*(1-2)+PATCHES{2,n2}.vertices*2);
    x1=conn_bsxfun(@minus,x1,mean(x1,1));
    for n3=1:5, PATCHES{1,n2}.vertices=temp*PATCHES{1,n2}.vertices;end
    for n3=1:5, PATCHES{2,n2}.vertices=temp*PATCHES{2,n2}.vertices;end
    PATCHES{n1+1,n2}=PATCHES{2,n2};
	PATCHES{n1+1,n2}.vertices=(PATCHES{1,n2}.vertices+PATCHES{3,n2}.vertices)/2;
end
PATCHES=PATCHES([4,3,2],:);

CURV={};
for n2=1:numel(hems)
    CURV{n2}=conn_freesurfer_read_curv(fullfile(pathname,'utils','surf',[hems{n2},'curv.paint']));
end

[file_path,file_name,file_ext,file_num]=spm_fileparts(deblank(filename(1,:)));
if isempty(file_path), file_path=pwd; end
if ismember([file_name,file_ext],{'SPM.mat','spm.mat'})
    spmfilename=filename;
    disp(['reading analysis info from ',filename]);
    load(filename,'SPM');
    if isfield(SPM,'xX_multivariate')
        ncon=1;
        a=reshape(SPM.xX_multivariate.F,SPM.xY.VY(1).dim);
        statsname=SPM.xX_multivariate.statsname;
        dof=SPM.xX_multivariate.dof;
    else
        if isfield(SPM,'xCon')&&length(SPM.xCon)>1,
            ncon=spm_conman(SPM);
        else ncon=1;
        end
        [file_path2,file_name2,file_ext2,file_num2]=spm_fileparts(SPM.xCon(ncon).Vspm.fname);
        a=spm_vol(fullfile(file_path,[file_name2,file_ext2,file_num2]));
        statsname=SPM.xCon(ncon).STAT;
    end
elseif ismember(file_ext,{'.img','.nii'})        
    spmfilename=[];
    disp(['reading T-statistics from ',filename]);
    a=spm_vol(filename);
    SPM=[];
    ncon=sscanf(file_name,'spmT_%d');
    statsname='T';
else
    error(['unknown file extension ',file_ext]);
end
if ~isempty(dir(fullfile(file_path,'mask.img')))
    disp(['reading analysis mask from ',fullfile(file_path,'mask.img')]);
    MASK=spm_read_vols(spm_vol(fullfile(file_path,'mask.img'))); MASK=reshape(MASK(:)>0,[],2);
else MASK=[];
end
if ~isempty(dir(conn_surf_results_simfilename('all'))), 
    temp=dir(conn_surf_results_simfilename('all'));
    [nill,idx]=max([temp.datenum]);
    SIM=load(fullfile(file_path,temp(idx).name));
else SIM=[];
end

if isstruct(a)
    try
        dof=regexp(a(1).descrip,'SPM{T_\[([\d\.])*\]','tokens');dof=str2double(dof{1});
    catch
        disp('warning: no dof information found. Using inf degrees of freedom');
        dof=inf;
    end
    T=spm_read_vols(a);
else
    T=a;
end
T=reshape(T,[],2);
if size(T,1)~=size(PATCHES{1,1}.vertices,1),
    error(sprintf('Incorrect dimensions. Contrast file is expected to contain one value for each surface vertex (two %d-vertices files, or one %d-vertices file). The selected contrast files contain %d datapoints in total',size(PATCHES{1,1}.vertices,1),2*size(PATCHES{1,1}.vertices,1),numel(T)));
end

HEM=1;
POSITION=[-1,0,0];
SPH=1;
if ~isempty(SIM), THR=SIM.Pthr(end); THR_TYPE=SIM.Pthr_type(end);
else THR=.001; THR_TYPE=1;
end
SIDE=1; % one-sided (positive)
THRCL=100;
THRCL_TYPE=1;
COLOR_BRAIN=[.7,.65,.6; .6,.55,.5];
COLOR_BRAIN_GYRUSSCALING=100;
COLOR_BRAIN_TRANS=1;
COLOR_ACT='hot';
COLOR_ACT_SCALED=1;
COLOR_ACT_TRANS=1;
COLOR_BACKGROUND=[1 1 1];%[.02 .04 .15];
LIGHT_TYPE='on';
LIGHT_POSITION=[0,0,0];
SHOWSURFACE_OPTION=1;
DISPLAY_STATS=true;%false;
DOPRINT='none';
PRINT_OPTIONS={'-djpeg90','-r300'};
CROSSHAIR={[-20,20,nan,0,0,nan,0,0,nan],[0,0,nan,-20,20,nan,0,0,nan],[0,0,nan,0,0,nan,-20,20,nan]};

hfig=figure('numbertitle','off','menubar','none','units','norm','position',[.025 .2 .95 .65]);%,'closerequestfcn',@conn_surf_results_closerequestfcn);
if ~isempty(filename), set(hfig,'name',['Surface display: ',filename]); else set(hfig,'name','Surface display'); end

for iargin=1:2:nargin-1
    switch(varargin{iargin})
        case 'vox-thr', 
            if iscell(varargin{iargin+1}), THR=varargin{iargin+1}{1}; THR_TYPE=interp1([1 3 4],varargin{iargin+1}{2}); 
            else                           THR=varargin{iargin+1};
            end
            if ~isempty(dir(conn_surf_results_simfilename)), SIM=load(conn_surf_results_simfilename); else SIM=[]; end %THRCL_TYPE=min(1,THRCL_TYPE); end
        case 'clu-thr', 
            if iscell(varargin{iargin+1}), THRCL=varargin{iargin+1}{1}; THRCL_TYPE=varargin{iargin+1}{2}; 
            else                           THRCL=varargin{iargin+1};
            end
        case 'switch',
            SIDE=varargin{iargin+1};
    end
end
if any(strcmp(varargin(1:2:end-1),'vox-thr')), 
    if ~isempty(dir(conn_surf_results_simfilename)), SIM=load(conn_surf_results_simfilename); 
    elseif THRCL_TYPE==1||~conn_surf_results_randomise('nogui'), SIM=[]; THRCL_TYPE=min(1,THRCL_TYPE); 
    end
end
conn_surf_results_update;
if any(strcmp(varargin(1:2:end-1),'export_mask')), conn_surf_results_doexport(varargin{2*find(strcmp(varargin(1:2:end),'export_mask'),1)}); end

    %% main display function
    function conn_surf_results_update(varargin)
        hem=ceil(HEM/2);
        
        V=T;%(:,hem);
        if SIDE==2, V=-V; end
        
        if ~isnan(THR), 
            switch(THR_TYPE)
                case 1, % p-uncorrected
                    switch(statsname)
                        case 'T'
                            if SIDE==3, V=V.*(abs(V)>=spm_invTcdf(1-THR/2,dof));
                            else        V=V.*(V>=spm_invTcdf(1-THR,dof));
                            end
                        case 'F'
                            V=V.*(V>=spm_invFcdf(1-THR,dof));
                        case 'X'
                            V=V.*(V>=spm_invXcdf(1-THR,dof));
                    end
                case {2,3}, % p-FDR
                    switch(statsname)
                        case 'T'
                            p=1-conn_tcdf(V,dof);
                            if SIDE==3, p=2*min(p,1-p); end
                        case 'F'
                            p=1-spm_Fcdf(V,dof);
                        case 'X'
                            p=1-spm_Xcdf(V,dof);
                    end
                    mask=V~=0;
                    p(~mask)=nan;
                    p(:)=conn_fdr(p(:));
                    V=V.*(p<THR);
                case 4, % T-stat
                    switch(statsname)
                        case 'T'
                            if SIDE==3, V=V.*(abs(V)>=THR);
                            else        V=V.*(V>=THR);
                            end
                        case 'F'
                            V=V.*(V>=THR);
                        case 'X'
                            V=V.*(V>=THR);
                    end
            end
        end
        dotwosided=any(V(:)<0);
        show=~isnan(V)&V~=0;
        if ~isempty(MASK), show=show&MASK; end
        V(~show)=0;

        V=V(:,hem);
        show=show(:,hem);
        
        %show1=show;
        [nclL,CLUSTER_labels]=conn_clusters(show,ADJ);
        mask=CLUSTER_labels>0;
        mclL=accumarray(CLUSTER_labels(mask),abs(V(mask)),[max([1,max(CLUSTER_labels(mask))]),1]);
        validCluster=true(size(mclL));

        if ~isempty(SIM)&&any(SIM.Pthr==THR&SIM.Pthr_type==THR_TYPE&SIM.Pthr_side==SIDE)
            iPERM=find(SIM.Pthr==THR&SIM.Pthr_type==THR_TYPE&SIM.Pthr_side==SIDE,1);
            if nnz(SIM.Hist_Cluster_size{iPERM})<2, PERMp_cluster_size_unc=double(1+nclL<=find(SIM.Hist_Cluster_size{iPERM})); 
            else PERMp_cluster_size_unc=max(0,min(1,interp1(find(SIM.Hist_Cluster_size{iPERM}),flipud(cumsum(flipud(nonzeros(SIM.Hist_Cluster_size{iPERM})))),1+nclL,'linear','extrap')));
            end
            PERMp_cluster_size_FDR=conn_fdr(PERMp_cluster_size_unc);
            PERMp_cluster_size_FWE=mean(conn_bsxfun(@ge,SIM.Dist_Cluster_sizemax{iPERM}',nclL),2);
            
            if nnz(SIM.Hist_Cluster_mass{iPERM})<2, PERMp_cluster_mass_unc=double(1+round(SIM.maxT*mclL)<=find(SIM.Hist_Cluster_mass{iPERM})); 
            else PERMp_cluster_mass_unc=max(0,min(1,interp1(find(SIM.Hist_Cluster_mass{iPERM}),flipud(cumsum(flipud(nonzeros(SIM.Hist_Cluster_mass{iPERM})))),1+round(SIM.maxT*mclL),'linear','extrap')));
            end
            PERMp_cluster_mass_FDR=conn_fdr(PERMp_cluster_mass_unc);
            PERMp_cluster_mass_FWE=mean(conn_bsxfun(@ge,SIM.Dist_Cluster_massmax{iPERM}',mclL),2);
        else
            iPERM=[];
        end
        
        if ~isnan(THRCL), 
            if THRCL_TYPE>1, THRCL=max(0,min(1,THRCL)); end
            switch(THRCL_TYPE)
                case 1, % k cluster
                    validCluster=mclL>=THRCL; 
                case 2, % cluster p-unc
                    validCluster=PERMp_cluster_mass_unc<THRCL;
                case 3, % cluster p-FWE
                    validCluster=PERMp_cluster_mass_FWE<THRCL;
            end
            mask=show;%&labelsSet>0;
            mask(mask)=validCluster(CLUSTER_labels(mask));
            V=V.*mask;
            show=show&mask;
        end
        
        if ~COLOR_ACT_SCALED, W=sign(V); else W=V; end
        if dotwosided
            W(show)=W(show)/max(eps,max(abs(W(show))));
        elseif any(W(show)),
            W(show)=max(eps,W(show)-min(W(show)))/max(eps,max(W(show))-min(W(show)));
        end
        showfact=show.*(.25+.75*abs(tanh(10*abs(W)/max(eps,max(abs(W(:)))))));

        if ischar(COLOR_ACT), color_act=str2num(COLOR_ACT); else color_act=COLOR_ACT; end
        if min(size(color_act))==1
            cmap=(1-linspace(1,0,128)'.^2)*color_act;
        else
            cmap=color_act;
        end

        if ischar(COLOR_BRAIN), 
            curv=[];
            rgb=[];
            if ~isempty(strfind(COLOR_BRAIN,'curv'))
                curv=.5+.5*tanh(COLOR_BRAIN_GYRUSSCALING*CURV{hem});
                curv=[1-curv,curv]*[.7,.65,.6; .6,.55,.5];
                color_brain=feval(inline(COLOR_BRAIN,'curv'),curv);
            else
                color_brain=str2num(COLOR_BRAIN);
            end
        else color_brain=COLOR_BRAIN; 
        end
        if isequal(size(color_brain(:)),[3,1])
            cdat1=ones(size(CURV{hem}))*color_brain(:)';
        elseif isequal(size(color_brain),[2,3])
            c=.5+.5*tanh(COLOR_BRAIN_GYRUSSCALING*CURV{hem});
            cdat1=[1-c,c]*color_brain;
        elseif isequal(size(color_brain),[size(CURV{hem},1),3])
            cdat1=color_brain;
        else
            disp('unrecognized brain surface color option');
            cdat1=ones(size(CURV{hem}))*[1 1 1]*.75;
        end
        
        if dotwosided,  cdat2=max(0,min(1, permute(ind2rgb(max(1,min(2*size(cmap,1), round(size(cmap,1)+.5+size(cmap,1)*W))),[flipud(fliplr(cmap));cmap]),[1,3,2]) ));
        else            cdat2=max(0,min(1, permute(ind2rgb(max(1,min(size(cmap,1), round(size(cmap,1)*W))),cmap),[1,3,2]) ));
        end
        cdat=repmat((1-COLOR_ACT_TRANS*showfact),[1,3]).*cdat1 + repmat((COLOR_ACT_TRANS*showfact),[1,3]).*cdat2;
        if ~isempty(MASK), cdat(~MASK(:,hem),:)=.6; end
        
        %figure(hfig);
        clf(hfig);
        if strncmp(DOPRINT,'none_earlyreturn_saveas',numel('none_earlyreturn_saveas')), conn_surf_results_export(DOPRINT(numel('none_earlyreturn_saveas')+1:end)); return; end
        if DISPLAY_STATS, conn_surf_results_displaystats; end
        set(hfig,'color',COLOR_BACKGROUND);
        hpatch=patch(PATCHES{SPH,hem},'facevertexcdata',cdat,'facecolor','interp','edgecolor','none','alphadatamapping','none','facealpha',COLOR_BRAIN_TRANS,'FaceLighting', 'gouraud','SpecularStrength' ,0.1, 'AmbientStrength', 0.3,'DiffuseStrength', 0.8, 'SpecularExponent',10);
        axis equal; 
        view(POSITION);
        axis off tight;
        if DISPLAY_STATS, set(gca,'units','norm','position',[.05,.1,.5,.85]); else set(gca,'units','norm','position',[.05,.1,.85,.85]); end
        lighting gouraud;
        if ~strcmp(LIGHT_TYPE,'off')
            hlight=light;
            set(hlight,'position',POSITION+LIGHT_POSITION);
            if strcmp(LIGHT_TYPE,'on'), mprop={.3 .8 0 10 1};
            elseif strcmp(LIGHT_TYPE,'emphasis'), mprop={.1 .75 .5 1 .5};
            elseif strcmp(LIGHT_TYPE,'sketch'), mprop={.1 1 1 .25 0};
            elseif strcmp(LIGHT_TYPE,'shiny'), mprop={.3 .6 .9 20 1};
            elseif strcmp(LIGHT_TYPE,'dull'), mprop={.3 .8 0 10 1};
            elseif strcmp(LIGHT_TYPE,'metal'), mprop={.3 .3 1 25 .5};
            else mprop={'default','default','default','default','default'};
            %else mprop=num2cell(str2num(LIGHT_TYPE));
            end
            if numel(mprop)<5, mprop=[mprop,repmat({'default'},1,5-numel(mprop))]; end
            set(hpatch,'AmbientStrength', mprop{1},'DiffuseStrength',mprop{2},'SpecularStrength' ,mprop{3},  'SpecularExponent',mprop{4}, 'SpecularColorReflectance',mprop{5});
            %if strcmp(LIGHT_TYPE,'emphasis'),material([.1 .75 .5 1 .5]);end
        end
        if strcmp(DOPRINT,'print'), conn_surf_results_print; 
        elseif strcmp(DOPRINT,'none_earlyreturn'), return; 
        end

        uicontrol('style','frame','units','norm','position',[.60,.86,.39,.13],'foregroundcolor','w');
        if isequal(statsname,'T'), uicontrol('style','popupmenu','units','norm','position',[.87,.93,.11,.05],'string',{'one-sided (positive)','one-sided (negative)','two-sided'},'value',SIDE,'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_posneg,'tooltipstring','Select contrast directionality'); end
        uicontrol('style','popupmenu','units','norm','position',[.61,.93,.16,.05],'string',{'vertex-level p-unc < ','vertex-level p-FDR < ','vertex-level T > '},'value',interp1([1,2,2,3],THR_TYPE),'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_vertexptype,'tooltipstring','Select vertex-level threshold type');
        uicontrol('style','edit','units','norm','position',[.78,.93,.08,.05],'string',num2str(THR),'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_vertexp,'tooltipstring','Select vertex-level threshold value');
        if (isempty(SIM)||isempty(iPERM))&&isempty(SPM), uicontrol('style','popupmenu','units','norm','position',[.61,.87,.16,.05],'string',{'cluster mass > '},'value',THRCL_TYPE,'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_clusterptype,'tooltipstring','Select cluster-level threshold type');
        elseif isempty(SIM)||isempty(iPERM), uicontrol('style','popupmenu','units','norm','position',[.61,.87,.16,.05],'string',{'cluster mass > ','Compute cluster-level stats'},'value',THRCL_TYPE,'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_clusterptype,'tooltipstring','Select cluster-level threshold type');
        else, uicontrol('style','popupmenu','units','norm','position',[.61,.87,.16,.05],'string',{'cluster-level mass > ','cluster-level p-unc < ','cluster-level p-FWE < '},'value',THRCL_TYPE,'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_clusterptype,'tooltipstring','Select cluster-level threshold type');
        end
        uicontrol('style','edit','units','norm','position',[.78,.87,.08,.05],'string',num2str(THRCL),'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_clusterp,'tooltipstring','Select cluster/ROI threshold value');
        
        uicontrol('style','popupmenu','units','norm','position',[.01,.005,.20,.04],'string',{'semi-inflated surface','inflated surface'},'value',SPH,'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_sph,'tooltipstring','Select brain surface for display');
        uicontrol('style','popupmenu','units','norm','position',[.22,.005,.20,.04],'string',{'Left lateral view','Left medial view','Right lateral view','Right medial view'},'value',HEM,'fontsize',8+CONN_gui.font_offset,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_hem,'tooltipstring','Select view');
%         uicontrol('style','popupmenu','units','norm','position',[.9,0,.1,.05],'string',{'1. surface curvature','2. ROI colors','3. ROI contours','1 + 3','2 + 3','1 + 2 + 3','flat surface','advanced display options'},'value',SHOWSURFACE_OPTION,'backgroundcolor',max(.5,COLOR_BACKGROUND),'callback',@conn_surf_results_options,'tooltipstring','Select brain surface display options');
%         uicontrol('style','pushbutton','units','norm','position',[0,.95,.1,.05],'string','Print','callback',@conn_surf_results_doprint,'tooltipstring','Print high-resolution images to file');
        uicontrol('style','pushbutton','units','norm','position',[.01,.94,.1,.05],'string','Surface display','fontsize',8+CONN_gui.font_offset,'callback',@conn_surf_results_surfacedisplay,'tooltipstring','Display results on 3d brain');
        uicontrol('style','pushbutton','units','norm','position',[.01,.89,.1,.05],'string','Export mask','fontsize',8+CONN_gui.font_offset,'callback',@conn_surf_results_doexport,'tooltipstring','Export mask of suprathreshold voxels to file');
        if ~isempty(spmfilename), uicontrol('style','pushbutton','units','norm','position',[.01,.84,.1,.05],'string','Import values','fontsize',8+CONN_gui.font_offset,'callback',@conn_surf_results_doimport,'tooltipstring','Import average cluster connectivity values for each subject into CONN toolbox as second-level covariates'); end

        set(rotate3d,'ActionPostCallback',@conn_surf_results_rotate);
        ht=uicontrol('style','togglebutton','units','norm','position',[.98,.02,.02,.80],'string','<<','value',DISPLAY_STATS,'fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','callback',@conn_surf_results_showstats,'tooltipstring','Display cluster-level stats');
        if DISPLAY_STATS, 
            set(gca,'units','norm','position',[.05,.10,.5,.85]); 
            set(ht,'position',[.58,.02,.02,.80],'string','>>','tooltipstring','Hide cluster statistics');
            if isempty(SIM)||isempty(iPERM), uicontrol('style','pushbutton','units','norm','position',[.6,.02,.38,.05],'string','Compute cluster-level statistics','fontsize',8+CONN_gui.font_offset,'callback',@conn_surf_results_computeclusterstats,'tooltipstring','Compute cluster-level statistics using randomisation/permutation tests'); end
        else
            set(gca,'units','norm','position',[.05,.10,.85,.85]);
        end
        hold on;
        hcrosshair=plot3(CROSSHAIR{:},'g--','color',.75*[1 1 1],'linewidth',2);
        hold off;
        set(hcrosshair,'tag','conn_surf_results_crosshair','visible','off');
        set(rotate3d,'enable','on'); 

        function txt=conn_surf_results_displaystats
            if ~isempty(SIM)&&any(SIM.Pthr==THR&SIM.Pthr_type==THR_TYPE&SIM.Pthr_side==SIDE)
                iPERM=find(SIM.Pthr==THR&SIM.Pthr_type==THR_TYPE&SIM.Pthr_side==SIDE,1);
                if nnz(SIM.Hist_Cluster_size{iPERM})<2, PERMp_cluster_size_unc=double(1+nclL<=find(SIM.Hist_Cluster_size{iPERM}));
                else PERMp_cluster_size_unc=max(0,min(1,interp1(find(SIM.Hist_Cluster_size{iPERM}),flipud(cumsum(flipud(nonzeros(SIM.Hist_Cluster_size{iPERM})))),1+nclL,'linear','extrap')));
                end
                PERMp_cluster_size_FDR=conn_fdr(PERMp_cluster_size_unc);
                PERMp_cluster_size_FWE=mean(conn_bsxfun(@ge,SIM.Dist_Cluster_sizemax{iPERM}',nclL),2);
                
                if nnz(SIM.Hist_Cluster_mass{iPERM})<2, PERMp_cluster_mass_unc=double(1+round(SIM.maxT*mclL)<=find(SIM.Hist_Cluster_mass{iPERM}));
                else PERMp_cluster_mass_unc=max(0,min(1,interp1(find(SIM.Hist_Cluster_mass{iPERM}),flipud(cumsum(flipud(nonzeros(SIM.Hist_Cluster_mass{iPERM})))),1+round(SIM.maxT*mclL),'linear','extrap')));
                end
                PERMp_cluster_mass_FDR=conn_fdr(PERMp_cluster_mass_unc);
                PERMp_cluster_mass_FWE=mean(conn_bsxfun(@ge,SIM.Dist_Cluster_massmax{iPERM}',mclL),2);
            else
                iPERM=[];
            end

            txt={};
            coords={};
            txt{end+1}=' ';
            coords{end+1}=nan;
            txt{end+1}=sprintf('%16s %8s %8s %8s','Cluster','mass','p-unc','p-FWE');
            coords{end+1}=nan;
            i0=unique(CLUSTER_labels(show));
            if ~isempty(SIM)&~isempty(iPERM), [nill,idx]=sort(PERMp_cluster_mass_unc(i0));else [nill,idx]=sort(mclL(i0),'descend'); end;i0=i0(idx); 
            for i=i0(:)'
                idx0=find(CLUSTER_labels==i&show);
                [nill,idx]=max(abs(V(idx0)));
                xyz=round(mean(PATCHES{3,hem}.vertices(idx0(idx),:),1));
                xyzstr=sprintf('%+2d %+2d %+2d',xyz(1),xyz(2),xyz(3));
                if ~isempty(SIM)&&~isempty(iPERM), txt{end+1}=sprintf('%16s %8d %.6f %.6f',xyzstr,round(mclL(i)),PERMp_cluster_mass_unc(i),PERMp_cluster_mass_FWE(i));
                else txt{end+1}=sprintf('%16s %8d',xyzstr,round(mclL(i)));
                end
                coords{end+1}=round(mean(PATCHES{SPH,hem}.vertices(idx0(idx),:),1));
            end
            if ~nargout
                if isempty(SIM)||isempty(iPERM), h=uicontrol('units','norm','position',[.6,.07,.39,.75],'style','listbox','backgroundcolor','w','string',txt,'max',2,'horizontalalignment','center','fontname','monospaced','fontsize',8+CONN_gui.font_offset,'callback',@(varargin)conn_surf_results_displaystats_select(coords));
                else h=uicontrol('units','norm','position',[.6,.02,.39,.80],'style','listbox','backgroundcolor','w','string',txt,'max',2,'horizontalalignment','center','fontname','monospaced','fontsize',8+CONN_gui.font_offset,'callback',@(varargin)conn_surf_results_displaystats_select(coords));
                end
                hc=uicontextmenu;
                uimenu(hc,'Label','export to .txt file','callback',@(varargin)conn_surf_results_displaystats_export(txt));
                set(h,'uicontextmenu',hc);
            end
        end
        
        function conn_surf_results_export(tfilename,varargin)
            if nargin<1||isempty(tfilename)
                [tfilename,tpathname] = uiputfile('*.img', 'Export to mask file',fullfile(file_path,[hems{ceil(HEM/2)},'mask.img']));
                if isequal(tfilename,0), return; end
                tfilename=fullfile(tpathname,tfilename);
            else
                thems={'.lh','.rh'};
                [tpathname,tfilename,tfileext]=fileparts(tfilename);
                tfilename=fullfile(tpathname,[tfilename,thems{ceil(HEM/2)},tfileext]);
            end
            dim=conn_surf_dims(8);
            newvol=struct('fname',tfilename,...
                'mat',eye(4),...
                'dim',dim,...
                'pinfo',[1;0;0],...
                'dt',[spm_type('float32'),spm_platform('bigend')],...
                'descrip','surface data');
            newvol=spm_write_vol(newvol,reshape(V,dim));
            %disp(['Created file ',newvol.fname]);

            [tpathname,tfilename,tfileext]=fileparts(tfilename);
            tV=zeros(size(V));
            i0=unique(CLUSTER_labels(show));
            if ~isempty(SIM)&&~isempty(iPERM), [nill,idx]=sort(PERMp_cluster_mass_unc(i0));else [nill,idx]=sort(mclL(i0),'descend'); end;i0=i0(idx); 
            xyzstr={};
            for n1=1:numel(i0)
                i=i0(n1);
                idx0=find(CLUSTER_labels==i&show);
                tV(idx0)=n1;
                [nill,idx]=max(abs(V(idx0)));
                xyz=round(mean(PATCHES{3,hem}.vertices(idx0(idx),:),1));
                xyzstr{n1}=sprintf('%+2d %+2d %+2d',xyz(1),xyz(2),xyz(3));
            end
            newvol=struct('fname',fullfile(tpathname,[tfilename,'.ROIs.img']),...
                'mat',eye(4),...
                'dim',dim,...
                'pinfo',[1;0;0],...
                'dt',[spm_type('uint16'),spm_platform('bigend')],...
                'descrip','surface data');
            newvol=spm_write_vol(newvol,reshape(tV,dim));
            %disp(['Created file ',newvol.fname]);
            fh=fopen(fullfile(tpathname,[tfilename,'.ROIs.txt']),'wt');
            for n1=1:numel(xyzstr),
                fprintf(fh,'%s\n',xyzstr{n1});
            end
            fclose(fh);
            fh=fopen(fullfile(tpathname,[tfilename,'.rgb']),'wb');
            fwrite(fh,round(cdat(:)*255),'uint8');
            fclose(fh);
            %disp(['Created file ',fullfile(tpathname,[tfilename,'.rgb'])]);
            txt=conn_surf_results_displaystats;
            fh=fopen(fullfile(tpathname,[tfilename,'.stats']),'wt');
            for i=1:numel(txt)
                fprintf(fh,'%s\n',txt{i});
            end
            fclose(fh);
            %disp(['Created file ',fullfile(tpathname,[tfilename,'.stats'])]);
        end
    end




    %% auxiliary functions
    function conn_surf_results_posneg(varargin)
        SIDE=get(gcbo,'value');
        conn_surf_results_update;
    end

    function conn_surf_results_vertexptype(varargin)
        THR_TYPE=interp1([1 3 4],get(gcbo,'value'));
        if ~isempty(dir(conn_surf_results_simfilename)), SIM=load(conn_surf_results_simfilename); else SIM=[]; THRCL_TYPE=min(1,THRCL_TYPE); end
        conn_surf_results_update;
    end
    function conn_surf_results_vertexp(varargin)
        THR=str2num(get(gcbo,'string'));
        if ~isempty(dir(conn_surf_results_simfilename)), SIM=load(conn_surf_results_simfilename); else SIM=[]; THRCL_TYPE=min(1,THRCL_TYPE); end
        conn_surf_results_update;
    end
    function conn_surf_results_computeclusterstats(varargin)
        if isempty(SIM)&&~conn_surf_results_randomise, return; end
        DISPLAY_STATS=true;
        if isempty(SIM), THRCL_TYPE=min(1,THRCL_TYPE); end
        conn_surf_results_update;
    end        
    function conn_surf_results_clusterptype(varargin)
        v=get(gcbo,'value');
        switch(v)
            case 2, % compute cluster/ROI statistics
                if isempty(SIM)&&~conn_surf_results_randomise, return; end
                DISPLAY_STATS=true;
            case 4, % compute cluster/ROI statistics
                if ~conn_surf_results_randomise, return; end
                DISPLAY_STATS=true;
        end
        THRCL_TYPE=v;
        if isempty(SIM), THRCL_TYPE=min(1,THRCL_TYPE); 
        end
        conn_surf_results_update;
    end
    function conn_surf_results_clusterp(varargin)
        THRCL=str2num(get(gcbo,'string'));
        conn_surf_results_update;
    end
    function conn_surf_results_showstats(varargin)
        DISPLAY_STATS=get(gcbo,'value');
        conn_surf_results_update;
    end
    function conn_surf_results_sph(varargin)
        SPH=get(gcbo,'value');
        conn_surf_results_update;
    end
    function conn_surf_results_hem(varargin)
        HEM=get(gcbo,'value');
        switch(HEM)
            case 1,POSITION=[-1,0,0];
            case 2,POSITION=[1,0,0];
            case 3,POSITION=[1,0,0];
            case 4,POSITION=[-1,0,0];
        end
        conn_surf_results_update;
    end
    function conn_surf_results_options(varargin)
        opt=get(gcbo,'value');
        SHOWSURFACE_OPTION=opt;
        misc_options={[.7,.65,.6; .6,.55,.5],'.75+.5*(roi_sig-.75)','.75-.5*repmat(isborder_sig,1,3)','curv.*repmat(1-isborder_sig,1,3)','(.75+.5*(roi_sig-.75)).*(1-repmat(isborder_sig,1,3))','.2*roi_sig+.8*curv.*repmat(1-isborder_sig,1,3)',[.7,.65,.6]};
        switch(opt)
            case {1,2,3,4,5,6,7},
                COLOR_BRAIN=misc_options{opt};
                conn_surf_results_update;
            case 8,
                if ischar(COLOR_BRAIN), color_brain=COLOR_BRAIN; else color_brain=mat2str(COLOR_BRAIN); end
                if ischar(COLOR_ACT), color_act=COLOR_ACT; else color_act=mat2str(COLOR_ACT); end
                answ=inputdlg({'Brain surface color ([rgb]; [gyri_rgb;sulci_rgb] ; roi) ','Gyrus/Sulcus squashing factor (0-inf)','Brain surface transparency level', 'Activation scaling (1:color-gradient; 0:single-color)','Activation color ([rgb] ; colormap)','Activation transparency level (0-1)','Background color ([rgb])','lighting (off/on/emphasis)','Light-source position offset ([xyz])'},...
                    'display options',1,...
                    {color_brain,num2str(COLOR_BRAIN_GYRUSSCALING),num2str(COLOR_BRAIN_TRANS),num2str(COLOR_ACT_SCALED),color_act,num2str(COLOR_ACT_TRANS),mat2str(COLOR_BACKGROUND),LIGHT_TYPE,mat2str(LIGHT_POSITION)});
                if ~isempty(answ)
                    COLOR_BRAIN=answ{1};
                    COLOR_BRAIN_GYRUSSCALING=str2num(answ{2});
                    COLOR_BRAIN_TRANS=str2num(answ{3});
                    COLOR_ACT_SCALED=str2num(answ{4});
                    COLOR_ACT=answ{5};
                    COLOR_ACT_TRANS=str2num(answ{6});
                    COLOR_BACKGROUND=str2num(answ{7});
                    LIGHT_TYPE=answ{8};
                    LIGHT_POSITION=str2num(answ{9});
                    conn_surf_results_update;
                end
        end
    end
    function conn_surf_results_rotate(varargin)
        if ~strcmp(LIGHT_TYPE,'off')
            p=get(gca,'cameraposition');
            POSITION=p./max(eps,sqrt(sum(p.^2)));
            conn_surf_results_update;
        end
    end

    function conn_surf_results_doimport(varargin)
        conn_surf_results_doexport(fullfile(file_path,'results.img'));
        tfilename=fullfile(file_path,'results.ROIs.img');
        htfig=conn_msgbox('Loading connectivity values. Please wait','');
        cwd=pwd;
        cd(file_path);
        [y,tname]=conn_rex(spmfilename,tfilename,'level','clusters');
        if ishandle(htfig), delete(htfig); end
        tname=regexprep(tname,'^results\.ROIs\.','cluster ');
        temp=load(spmfilename,'SPM');
        if isfield(temp.SPM.xX,'SelectedSubjects')&&~rem(size(y,1),nnz(temp.SPM.xX.SelectedSubjects))
            ty=zeros(size(y,1)/nnz(temp.SPM.xX.SelectedSubjects)*numel(temp.SPM.xX.SelectedSubjects),size(y,2));
            ty(repmat(logical(temp.SPM.xX.SelectedSubjects),size(y,1)/nnz(temp.SPM.xX.SelectedSubjects),1),:)=y;
            y=ty;
        end
        clear temp;
        cd(cwd);
        conn_importl2covariate(tname,num2cell(y,1));
    end
                
    function conn_surf_results_doexport(varargin)
        if nargin&&ischar(varargin{1})
            tfilename=varargin{1};
        else
            [tfilename,tpathname] = uiputfile('*.img', 'Export to mask file',fullfile(file_path,'ResultsMask.img'));
            if isequal(tfilename,0), return; end
            tfilename=fullfile(tpathname,tfilename);
        end
        allpos={[-1,0,0],[1,0,0],[1,0,0],[-1,0,0]};
        thishem=HEM;
        thispos=POSITION;
        for i=[1,3]
            DOPRINT=['none_earlyreturn_saveas', tfilename];
            HEM=i;
            POSITION=allpos{i};
            conn_surf_results_update;
            drawnow;
        end
        [tpathname,tfilename2,tfileext]=fileparts(tfilename);
        a=spm_vol(char({fullfile(tpathname,[tfilename2,'.lh',tfileext]),fullfile(tpathname,[tfilename2,'.rh',tfileext])}));
        b=spm_read_vols(a);
        dim=a(1).dim.*[1 1 2];
        newvol=struct('fname',tfilename,...
            'mat',eye(4),...
            'dim',dim,...
            'pinfo',[1;0;0],...
            'dt',[spm_type('float32'),spm_platform('bigend')],...
            'descrip','surface mask');
        newvol=spm_write_vol(newvol,reshape(b,dim));
        disp(['Created file ',newvol.fname]);
        a=spm_vol(char({fullfile(tpathname,[tfilename2,'.lh','.ROIs.img']),fullfile(tpathname,[tfilename2,'.rh','.ROIs.img'])}));
        b=spm_read_vols(a);
        b(:,:,:,2)=(max(max(max(b(:,:,:,1))))+b(:,:,:,2)).*(b(:,:,:,2)>0);
        dim=a(1).dim.*[1 1 2];
        newvol=struct('fname',fullfile(tpathname,[tfilename2,'.ROIs.img']),...
            'mat',eye(4),...
            'dim',dim,...
            'pinfo',[1;0;0],...
            'dt',[spm_type('uint16'),spm_platform('bigend')],...
            'descrip','surface mask');
        newvol=spm_write_vol(newvol,reshape(b,dim));
        disp(['Created file ',newvol.fname]);
        txt={};
        for tfiletxt={fullfile(tpathname,[tfilename2,'.lh','.ROIs.txt']),fullfile(tpathname,[tfilename2,'.rh','.ROIs.txt'])}
            fh=fopen(tfiletxt{1},'rt');
            while 1
                tline=fgetl(fh);
                if ~ischar(tline), break; end
                txt{end+1}=tline;
            end
            fclose(fh);
        end
        fh=fopen(fullfile(tpathname,[tfilename2,'.ROIs.txt']),'wt');
        for n1=1:numel(txt)
            fprintf(fh,'%s\n',txt{n1});
        end
        fclose(fh);
        HEM=thishem;
        POSITION=thispos;
        DOPRINT='none';
        conn_surf_results_update;
    end
    
    function conn_surf_results_surfacedisplay(varargin)
        conn_surf_results_doexport(fullfile(file_path,'results.img'));
        conn_mesh_display(fullfile(file_path,'results.img'),'');
    end

    function conn_surf_results_doprint(varargin)
        DOPRINT='print';
        conn_surf_results_update;
    end

    function conn_surf_results_print(varargin)
        backname=get(hfig,'name');
        set(hfig,'inverthardcopy','off','name','conn_surf_results: Print preview');
        units=get(hfig,{'units','paperunits'});
        set(hfig,'units','points');
        set(hfig,'paperunits','points','paperpositionmode','manual','paperposition',get(hfig,'position'));
        set(hfig,{'units','paperunits'},units);
        answ=inputdlg({'Output file','Print options (see ''help print'')','View ( single | mosaic )'},...
            'print options',1,...
            {fullfile(file_path,'print01.jpg'),strtrim(sprintf('%s ',PRINT_OPTIONS{:})),'mosaic'});
        if ~isempty(answ)
            ok=false;
            try
                printtype=answ{3};
                tfilename=answ{1};
                if isempty(tfilename)
                    [tfilename,tpathname] = uiputfile('*.jpg', 'Save image as:');
                    if isequal(tfilename,0), error; end
                    tfilename=fullfile(tpathname,tfilename);
                end
                PRINT_OPTIONS=regexp(strtrim(answ{2}),'\s+','split');
                switch(printtype)
                    case 'mosaic'
                        a={};
                        hw=waitbar(0,'Printing. Please wait...','createcancelbtn','set(gcbf,''userdata'',1);');
                        set(hw,'handlevisibility','off','hittest','off','color','w');
                        allpos={[-1,0,0],[1,0,0],[1,0,0],[-1,0,0]};
                        for i=1:numel(allpos)
                            DOPRINT='none_earlyreturn';
                            HEM=i;
                            POSITION=allpos{i};
                            conn_surf_results_update;
                            drawnow;
                            print(hfig,PRINT_OPTIONS{:},tfilename);
                            b=imread(tfilename);
                            if isa(b,'uint8'), b=double(b)/255; end
                            if max(b(:))>1, b=double(b)/double(max(b(:))); end
                            a{i}=double(b);
                            set(hw,'handlevisibility','on');
                            waitbar(i/numel(allpos),hw);
                            set(hw,'handlevisibility','off');
                            if isequal(get(hw,'userdata'),1), a={}; break; end
                        end
                        if ~isempty(a)
                            a=[a{1},a{3};a{2},a{4}];
                            imwrite(a,tfilename);
                        end
                        delete(hw);
                        ok=true;
                    otherwise
                        drawnow;
                        print(hfig,PRINT_OPTIONS{:},tfilename);
                        ok=true;
                end
            catch
                disp('Error: Failed to print file');
            end
            if ok
                try
                    a=imread(tfilename);
                    hf=figure('name',['printed file ',tfilename],'numbertitle','off','color','w');
                    imagesc(a); title(tfilename,'interpreter','none'); axis equal tight; set(gca,'box','on','xtick',[],'ytick',[]); set(hf,'handlevisibility','off','hittest','off');
                catch
                    disp(['Saved file: ',tfilename]);
                end
            end
        end
        DOPRINT='none';
        drawnow;
        set(hfig,'name',backname);
    end
                
    function ok=conn_surf_results_randomise(varargin)
        if isempty(SPM), disp('randomization analyses only available when selecting SPM.mat file'); ok=false; return; end
        fh=figure('units','norm','position',[.4,.4,.3,.2],'menubar','none','numbertitle','off','name','cluster statistics','color','w');
        h1=uicontrol('units','norm','position',[.1,.8,.4,.15],'style','text','string','# of simulations: ','backgroundcolor',get(fh,'color'));
        h2=uicontrol('units','norm','position',[.5,.8,.4,.15],'style','edit','string',num2str(max(1000,round(1/THR))),'tooltipstring','Number of data permutations/randomisations that will be evaluated in order to compute cluster-level statistics');
        h3=uicontrol('units','norm','position',[.1,.5,.8,.25],'style','popupmenu','string',{'Run simulations now','Run simulations later'},'callback',@conn_surf_results_randomise_nowlater);
        h4=uicontrol('units','norm','position',[.1,.3,.4,.15],'style','text','string','filename: ','backgroundcolor',get(fh,'color'),'visible','off');
        h5=uicontrol('units','norm','position',[.5,.3,.4,.15],'style','edit','string','./script_clusterstatistics.m','visible','off','tooltipString','This option will create a script that you may run at a later time in order to compute the cluster-level statistics. Here you must define a filename (two files will be created, a #filename#.m and a #filename#.mat file)');
        h6=uicontrol('units','norm','position',[.3,.05,.3,.15],'style','pushbutton','string','OK','callback','uiresume(gcbf)');
        h7=uicontrol('units','norm','position',[.65,.05,.3,.15],'style','pushbutton','string','Cancel','callback','close(gcbf)');
        if ~(nargin>0&&ischar(varargin{1})&&strcmp(varargin{1},'nogui')), uiwait(fh); end
        if ishandle(fh), 
            v2=str2num(get(h2,'string'));
            v3=get(h3,'value');
            v5=get(h5,'string');
            close(fh);
            niters=v2;
            [i,j]=find(ADJ);
            CLUSTERS=sparse([i;size(ADJ,1)+i],[j;size(ADJ,1)+j],1,2*size(ADJ,1),2*size(ADJ,2));
            analysismask=MASK(:);
            simfilename=conn_surf_results_simfilename;
            if isfield(SPM,'xX_multivariate')
                X=SPM.xX_multivariate.X;
                c=SPM.xX_multivariate.C;
                m=SPM.xX_multivariate.M;
            else
                X=SPM.xX.X;
                c=SPM.xCon(ncon).c';
                m=1;
            end
            if v3==1, % now
                ht=conn_msgbox('Preparing data. Please wait...','conn_surf_results');
                try
                    a=spm_vol(char(SPM.xY.Y));
                catch
                    a=SPM.xY.VY;
                end
                y=spm_read_vols(a);
                y=permute(reshape(y,[SPM.xY.VY(1).dim(1:3),size(SPM.xY.VY)]),[4,5,1,2,3]);
                if ishandle(ht), delete(ht); end
                try
                    conn_randomise(X,y(:,:,:),c,m,THR,THR_TYPE,SIDE,niters,simfilename,[],CLUSTERS,analysismask);
                    SIM=load(simfilename);
                    ok=true;
                catch
                    ok=false;
                end
            else % later
                [file2_path,file2_name,file2_ext]=fileparts(v5);
                Y=char(SPM.xY.Y);
                if ~isempty(dir(fullfile(file2_path,[file2_name,'.m'])))
                    answ=conn_questdlg(sprintf('Overwrite %s file?',fullfile(file2_path,[file2_name,'.m'])),'warning','Yes','No','Yes');
                    if strcmp(answ,'No'), ok=false; return; end
                end
                save(fullfile(file2_path,[file2_name,'.mat']),'X','Y','c','m','THR','THR_TYPE','SIDE','niters','CLUSTERS','simfilename','analysismask');%,'repeatedsubjects',',dolaterality');
                fprintf('Created file %s\n',fullfile(file2_path,[file2_name,'.mat']));
                fh=fopen(fullfile(file2_path,[file2_name,'.m']),'wt');
                fprintf(fh,'load %s;\n',fullfile(file2_path,[file2_name,'.mat']));
                fprintf(fh,'a=spm_vol(Y);\n');
                fprintf(fh,'y=spm_read_vols(a);\n');
                fprintf(fh,'y=permute(reshape(y,[SPM.xY.VY(1).dim(1:3),size(SPM.xY.VY)]),[4,5,1,2,3]);\n');
                fprintf(fh,'conn_randomise(X,y(:,:,:),c,m,THR,THR_TYPE,SIDE,niters,simfilename,[],CLUSTERS,analysismask);\n');
                fclose(fh);
                fprintf('Created file %s\n',fullfile(file2_path,[file2_name,'.m']));
                ok=false;
            end
        else
            ok=false; 
        end
        
        function conn_surf_results_randomise_nowlater(varargin)
            v3=get(h3,'value');
            if v3==1, set([h4,h5],'visible','off'); else set([h4,h5],'visible','on'); end
        end
    end

    function conn_surf_results_displaystats_export(str)
        [tfilename,folder]=uiputfile('*.txt','Select output file');
        if ~isequal(tfilename,0)
            fh=fopen(fullfile(folder,tfilename),'wt');
            for n=1:numel(str)
                fprintf(fh,'%s\n',str{n});
            end
            fclose(fh);
        end
    end

    function conn_surf_results_displaystats_select(coords)
        hcrosshair=findobj(gcbf,'tag','conn_surf_results_crosshair');
        nselect=get(gcbo,'value');
        xdata=[];
        for n=1:numel(nselect),
            xdata=[xdata,conn_bsxfun(@plus,cell2mat(CROSSHAIR'),coords{nselect(n)}')];
        end
        set(hcrosshair(end),'visible','on',{'xdata','ydata','zdata'},num2cell(xdata,2)');
    end

    function simfilename=conn_surf_results_simfilename(varargin)
        if nargin==1&&isequal(varargin{1},'all')
            simfilename=fullfile(file_path,sprintf('spmT_%04d.p*.cluster.mat',ncon));
        elseif nargin==3
            simfilename=arrayfun(@(a,b,c)fullfile(file_path,sprintf('spmT_%04d.p%d.%.8f.%d.cluster.mat',ncon,a,b,c)),varargin{1},varargin{2},varargin{3},'uni',0);
        else
            simfilename=fullfile(file_path,sprintf('spmT_%04d.p%d.%.8f.%d.cluster.mat',ncon,THR_TYPE,THR,SIDE));
        end
    end

    function conn_surf_results_closerequestfcn(varargin)
        answ=conn_questdlg('Do you want to:','conn_surf_results','Exit','Continue','Exit');
        if isempty(answ), answ='Continue'; end
        switch(answ)
            case 'Exit',
                delete(gcbf);
            case 'Continue',
                conn_surf_results_update;
        end
    end
end

