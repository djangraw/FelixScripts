function [dataplot,infoplot,data1plot]=conn_vproject(param,nonparam,views,projection,thres,side,parametric,res,box,select,threshold,data1plot,spmfile,voxeltovoxel)
global CONN_gui;
if isempty(CONN_gui)||~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end
%CONN_VPROJECT Volume display
%
if numel(param)==1 && ishandle(param), % callbacks from UI objects
    init=0;
    GCF=gcf;
    if isstruct(nonparam), ARG=nonparam; end;
	OPTION=views; 
    if nargin>3, OPTION2=projection; else OPTION2=''; end
    if isempty(OPTION), return; end
    DATA=get(GCF,'userdata');
    a=DATA.a;
    b=DATA.b;
    c=DATA.c;
    d=DATA.d;
    SIM=DATA.SIM; 
    parametric=DATA.parametric;
    paramoptions=DATA.paramoptions;
    projection=DATA.projection;
    thres=DATA.thres;
    threshold=DATA.threshold;
    res=DATA.res;
    box=DATA.box;
    views=DATA.views;
    side=DATA.side;
    select=DATA.select;
    pointer=DATA.pointer;
    mat=DATA.mat;
    spmfile=DATA.spmfile;
    if isfield(DATA,'voxeltovoxel'), voxeltovoxel=DATA.voxeltovoxel; else voxeltovoxel=0; end
    data1plot=[];
    if isstruct(OPTION),
    else,
        switch(OPTION),
            case 'buttondown',
                xlim=get(DATA.axes,'xlim');ylim=get(DATA.axes,'ylim');xpos=get(DATA.axes,'currentpoint');
                if xpos(1,1)>=xlim(1)&&xpos(1,1)<=xlim(2)&&xpos(1,2)>=ylim(1)&&xpos(1,2)<=ylim(2),
                    DATA.buttondown=get(0,'pointerlocation');
                    DATA.selectiontype=get(GCF,'selectiontype');
                    set(GCF,'windowbuttonmotionfcn',{@conn_vproject,'buttonmotion'},'busyaction','queue','userdata',DATA);
                    res=DATA.res*3/2;
                    box=1;
                else, DATA.buttondown=[]; set(GCF,'userdata',DATA); return; end
            case 'buttonup',
                set(GCF,'windowbuttonmotionfcn',[],'busyaction','cancel');
                p1=DATA.buttondown;
                if ~isempty(p1),
                    p2=get(0,'pointerlocation')-p1;
                    if strcmp(DATA.selectiontype,'extend'),
                        ang=-.005*(p2(2)+p2(1));projection([1,2],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([1,2],:);
                    else,
                        %ang=.01*p2(2);projection([2,3],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([2,3],:);
                        ang=-.01*p2(1);projection([1,3],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([1,3],:);
                    end
                    DATA.projection=projection;
                    set(GCF,'windowbuttonmotionfcn',[],'userdata',DATA);
                else, return; end
            case 'buttonmotion',
                p1=DATA.buttondown;
                if isempty(p1), return; end
                p2=get(0,'pointerlocation')-p1;
                if strcmp(DATA.selectiontype,'extend'),
                    ang=-.005*(p2(2)+p2(1));projection([1,2],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([1,2],:);
                else,
                    %ang=.01*p2(2);projection([2,3],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([2,3],:);
                    ang=-.01*p2(1);projection([1,3],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([1,3],:);
                end
                res=DATA.res*3/2;
                box=1;
            case 'resolution',
                res=str2num(get(DATA.handles(2),'string'));
                if isempty(res), res=DATA.res; end
                set(DATA.handles(2),'string',num2str(res));
                DATA.res=res;
                set(GCF,'userdata',DATA);
                init=-1;
            case 'threshold',
                threshold=str2num(get(DATA.handles(4),'string'));
                if isempty(threshold), threshold=DATA.threshold; end
                set(DATA.handles(4),'string',num2str(threshold));
                DATA.threshold=threshold;
                set(GCF,'userdata',DATA);
                init=-1;
            case 'keypress',
                if exist('ARG','var')&&isfield(ARG,'Character')
                    switch(lower(ARG.Character)),
                        case 'y',
                            DATA.rotation=DATA.rotation+[10,0,0]*(2*(length(ARG.Modifier)>0)-1);
                        case 'x',
                            DATA.rotation=DATA.rotation+[0,10,0]*(2*(length(ARG.Modifier)>0)-1);
                        case 'z',
                            DATA.rotation=DATA.rotation+[0,0,10]*(2*(length(ARG.Modifier)>0)-1);
                        otherwise,
                            return;
                    end
                    ang=-.01*DATA.rotation(1);projection([1,3],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([1,3],:);
                    ang=.01*DATA.rotation(2);projection([2,3],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([2,3],:);
                    ang=-.01*DATA.rotation(3);projection([1,2],:)=[cos(ang),sin(ang);-sin(ang),cos(ang)]*projection([1,2],:);
                    DATA.rotation=[0,0,0];
                    DATA.projection=projection;
                    set(GCF,'windowbuttonmotionfcn',[],'userdata',DATA);
                else
                    return;
                end
            case 'selectroi'
                selectcluster=get(DATA.handles(8),'value');
                if selectcluster>length(DATA.clusters), select=[]; else, select=DATA.clusters{selectcluster}; end
                DATA.select=select; DATA.selectcluster=selectcluster; set(GCF,'userdata',DATA);
                init=-2;
            case 'vox-thr',
                if isempty(OPTION2), 
                    temp=str2num(get(DATA.handles(2),'string')); 
                    if ~isempty(temp), thres{1}=temp; else, set(DATA.handles(2),'string',num2str(thres{1})); end
                    thres{2}=get(DATA.handles(3),'value');
                else
                    if iscell(OPTION2), thres(1:numel(OPTION2))=OPTION2;
                    else thres{1}=OPTION2;
                    end
                    set(DATA.handles(2),'string',num2str(thres{1}));
                    set(DATA.handles(3),'value',thres{2});
                end
                if thres{2}<3&&(thres{1}<0|thres{1}>.25), thres{1}=max(0,min(.25,thres{1})); set(DATA.handles(2),'string',num2str(thres{1}));
                elseif thres{2}==3&&thres{1}<0, thres{1}=max(0,thres{1}); set(DATA.handles(2),'string',num2str(thres{1}));
                end
                DATA.selectcluster=[];
                if thres{2}<3, set(DATA.handles(1),'string','height threshold: p <'); 
                else set(DATA.handles(1),'string',['height threshold: ',DATA.mat{6},' >']); 
                end
                DATA.thres=thres;set(GCF,'userdata',DATA);
                init=-1;
            case 'clu-thr',
                if isempty(OPTION2), 
                    temp=str2num(get(DATA.handles(5),'string'));
                    if ~isempty(temp), thres{3}=temp; else, set(DATA.handles(5),'string',num2str(thres{3})); end
                    thres{4}=get(DATA.handles(6),'value');
                    thres4=thres{4}+(thres{4}>=6);
                    if DATA.parametric==1&&thres4>8, conn_msgbox('This threshold option is only available when using non-parametric statistics','',2); thres{4}=1;
                    elseif DATA.parametric==2&&ismember( thres4,[5 6 7]), conn_msgbox('This threshold option is only available when using parametric statistics','',2); thres{4}=1;
                    end
                    set(DATA.handles(6),'value',thres{4});
                else
                    if iscell(OPTION2), thres(2+(1:numel(OPTION2)))=OPTION2;
                    else thres{3}=OPTION2;
                    end
                    set(DATA.handles(5),'string',num2str(thres{3}));
                    set(DATA.handles(6),'value',thres{4});
                end
                DATA.selectcluster=[];
                if thres{4}==1||thres{4}==8, set(DATA.handles(4),'string','cluster threshold: k >'); 
                elseif DATA.parametric==1&&thres{4}>=5&&thres{4}<=6, set(DATA.handles(4),'string','peak threshold: p <'); 
                else set(DATA.handles(4),'string','cluster threshold: p <'); 
                end
                DATA.thres=thres;set(GCF,'userdata',DATA);
                init=-1;
            case 'export_mask',
                if isempty(OPTION2)
                    [filename,filepath]=uiputfile('*.img;*.nii','Save mask as',fileparts(spmfile));
                else
                    [filepath,filename_name,filename_ext]=fileparts(OPTION2);
                    filename=[filename_name,filename_ext];
                end
                if ischar(filename),
                    [nill,filename_name,filename_ext]=fileparts(filename);
                    if isempty(filename_ext), filename=[filename,'.img']; end
                    
                    V=struct('mat',mat{1},'dim',size(b(:,:,:,1)),'dt',[spm_type('float32') spm_platform('bigend')],'fname',fullfile(filepath,filename));
                    V=spm_write_vol(V,d.*double(b(:,:,:,end)>0));
                    fprintf('Suprathreshold file saved as %s\n',V.fname);
                    
                    V=struct('mat',mat{1},'dim',size(b(:,:,:,1)),'dt',[spm_type('float32') spm_platform('bigend')],'fname',fullfile(filepath,[filename_name,'.Mask.img']));
                    V=spm_write_vol(V,double(b(:,:,:,end)>0));
                    fprintf('Mask file saved as %s\n',V.fname);
                    
                    V=struct('mat',mat{1},'dim',size(b(:,:,:,1)),'pinfo',[1;0;0],'dt',[spm_type('uint32') spm_platform('bigend')],'fname',fullfile(filepath,[filename_name,'.ROIs.img']));
                    btemp=zeros(size(b(:,:,:,1)));
                    for nbtemp=1:numel(DATA.clusters), btemp(DATA.clusters{nbtemp})=nbtemp; end
                    V=spm_write_vol(V,btemp);
                    fprintf('ROI file saved as %s\n',V.fname);
                    fh=fopen(fullfile(filepath,[filename_name,'.ROIs.txt']),'wt');
                    for nbtemp=1:numel(DATA.clusters),
                        fprintf(fh,'%+d ',[DATA.xyzpeak{nbtemp},1]*DATA.mat{1}(1:3,:)');
                        fprintf(fh,'\n');
                    end
                    fclose(fh);

                    [peaks,peaks_idx,C]=conn_peaks({d,mat{1}});
                    peaks_suprathreshold=b(peaks_idx+size(b,1)*size(b,2)*size(b,3))>0;
                    %peaks_F=d(peaks_idx);
                    %peaks_p=exp(-b(peaks_idx(peaks_suprathreshold)));
                    %dof=mat{3};
                    save(fullfile(filepath,[filename_name,'.PEAKS.MAT']),'peaks','peaks_suprathreshold');%,'peaks_F','peaks_p','dof');
                    %fprintf('Peaks file saved as %s\n',fullfile(filepath,[filename_name,'.PEAKS.MAT']));
                    if ~isempty(C)
                        V=struct('mat',mat{1},'dim',size(C),'pinfo',[1;0;0],'dt',[spm_type('uint32') spm_platform('bigend')],'fname',fullfile(filepath,[filename_name,'.SEGs.img']));
                        V=spm_write_vol(V,C);
                        fprintf('Segmentation file saved as %s\n',V.fname);
                        fh=fopen(fullfile(filepath,[filename_name,'.SEGs.txt']),'wt');
                        for nbtemp=1:numel(peaks_idx),
                            fprintf(fh,'%+d ',peaks(nbtemp,:));
                            fprintf(fh,'\n');
                        end
                        fclose(fh);
                    end
                end
                return;
                
            case 'surface_view'
                filename=fullfile(fileparts(spmfile),'results.img');
                conn_vproject(gcf,[],'export_mask',filename);
                fh=conn_mesh_display(filename,'');
                %fh('zoomin');
                return;

            case 'volume_view'
                filename=fullfile(fileparts(spmfile),'results.img');
                conn_vproject(gcf,[],'export_mask',filename);
                fh=conn_mesh_display('',filename);
                return;

            case 'tvolume_view'
                filename=fullfile(fileparts(spmfile),'results.img');
                conn_vproject(gcf,[],'export_mask',filename);
                fh=conn_mesh_display('',filename,[],[],[],.5);
                fh('brain',4);
                fh('background',[1 1 1]);
                if 1
                    fh('brain_transparency',0);
                    fh('sub_transparency',0);
                    fh('mask_transparency',.5);
                    fh('material',[.1 1 1 .25 0]);
                else
                    fh('material',[.1 1 1 .25 0]);
                    fh('light',1);
                    fh('brain_color',.8*[1 1 1]);
                    fh('sub_color',.8*[1 1 1]);
                end
                return;
                
            case 'spm_view'
                [spmfile_path,spmfile_name]=fileparts(spmfile);
                cwd=pwd;cd(spmfile_path);
                load(spmfile,'SPM');
                spm defaults fmri;
                [hReg,xSPM,SPM] = spm_results_ui('setup',SPM);
                assignin('base','hReg',hReg);
                assignin('base','xSPM',xSPM);
                assignin('base','SPM',SPM);
                figure(spm_figure('GetWin','Interactive'));
                cd(cwd);
                return;
                
            case 'slice_view'
                [spmfile_path,spmfile_name]=fileparts(spmfile);
                conn_slice_display(struct('T',DATA.d,'p',DATA.c,'stats',DATA.mat{6},'dof',DATA.mat{3},'mat',DATA.mat{1},'supra',DATA.b(:,:,:,2),'clusters',struct('stats',{DATA.cluster_stats},'idx',{DATA.clusters}),'filename',spmfile),...
                    [],...
                    spmfile_path);
                return
                
            case 'cluster_view'
                filename=fullfile(fileparts(spmfile),'results.img');
                conn_vproject(gcf,[],'export_mask',filename);
                filename=fullfile(fileparts(spmfile),'results.ROIs.img');
                [tfilename,tspmfile,tviewrex]=conn_vproject_selectfiles(filename,spmfile,0);
                if isempty(tfilename), return; end
                [tspmfile_path,tspmfile_name]=fileparts(tspmfile);
                cwd=pwd;
                cd(tspmfile_path);
                if tviewrex
                    conn_rex(tspmfile,tfilename,'output_type','saverex','level','clusters','select_clusters',0,'s',[],'gui',1);
                else
                    htfig=conn_msgbox('Loading connectivity values. Please wait','');
                    conn_rex(tspmfile,tfilename,'output_type','saverex','level','clusters','select_clusters',0,'steps',{'extract','results'},'s',[],'gui',0);
                    if ishandle(htfig), delete(htfig); end
                end
                cd(cwd);
                return;
                
            case 'cluster_import',
                filename=fullfile(fileparts(spmfile),'results.img');
                conn_vproject(gcf,[],'export_mask',filename);
                filename=fullfile(fileparts(spmfile),'results.ROIs.img');
                [tfilename,tspmfile]=conn_vproject_selectfiles(filename,spmfile,[]);
                if isempty(tfilename), return; end
                [tspmfile_path,tspmfile_name]=fileparts(tspmfile);
                cwd=pwd;
                cd(tspmfile_path);
                htfig=conn_msgbox('Loading connectivity values. Please wait','');
                [y,name]=conn_rex(tspmfile,tfilename,'level','clusters');
                if ishandle(htfig), delete(htfig); end
                name=regexprep(name,'^results\.ROIs\.','cluster ');
                temp=load(tspmfile,'SPM');
                if isfield(temp.SPM.xX,'SelectedSubjects')&&~rem(size(y,1),nnz(temp.SPM.xX.SelectedSubjects))
                    ty=nan(size(y,1)/nnz(temp.SPM.xX.SelectedSubjects)*numel(temp.SPM.xX.SelectedSubjects),size(y,2));
                    ty(repmat(logical(temp.SPM.xX.SelectedSubjects),size(y,1)/nnz(temp.SPM.xX.SelectedSubjects),1),:)=y;
                    y=ty;
                end
                conn_importl2covariate(name,num2cell(y,1));
                cd(cwd);
                return;
                
            case 'bookmark',
                if ~isempty(OPTION2), 
                    if iscell(OPTION2), tfilename=OPTION2{1}; descr=OPTION2{2};
                    else tfilename=OPTION2; descr='';
                    end
                else
                    tfilename=[]; %fullfile(fileparts(spmfile),'results.bookmark.jpg');
                    descr='';
                end
                if isfield(CONN_gui,'slice_display_skipbookmarkicons'), SKIPBI=CONN_gui.slice_display_skipbookmarkicons;
                else SKIPBI=false;
                end
                conn_args={'display',spmfile,[],DATA.thres,DATA.side,DATA.parametric};
                opts={'forcecd'};
                [fullfilename,tfilename,descr]=conn_bookmark('save',...
                    tfilename,...
                    descr,...
                    conn_args,...
                    opts);
                if isempty(fullfilename), return; end
                if ~SKIPBI, conn_print(GCF,conn_prepend('',fullfilename,'.jpg'),'-nogui','-r50','-nopersistent'); end
                return;
            case 'connectome',
                optionDistancePeaks=12; % minimum distance between extracted peaks (mm)
                switch(DATA.side)
                    case 1, [peaks,peaks_idx]=conn_peaks({d,mat{1}},optionDistancePeaks);
                    case 2, [peaks,peaks_idx]=conn_peaks({-d,mat{1}},optionDistancePeaks);
                    case 3, [peaks,peaks_idx]=conn_peaks({abs(d),mat{1}},optionDistancePeaks);
                end
                if 0 % one peak per cluster
                    peaks_C=zeros(size(d));
                    for n1=1:numel(DATA.clusters), peaks_C(DATA.clusters{n1})=n1; end
                    withinClusterPeak=zeros(numel(DATA.clusters)+1,1);
                    withinClusterPeak(1+peaks_C(flipud(peaks_idx)))=flipud(peaks_idx);
                    otherwithinClusterPeak=find(peaks_C(peaks_idx)>0&~ismember(peaks_idx,withinClusterPeak(2:end)));
                    peaks_idx(otherwithinClusterPeak)=[];
                    peaks(otherwithinClusterPeak,:)=[];
                end
                peaks_suprathreshold=b(peaks_idx+size(b,1)*size(b,2)*size(b,3))>0;
                [spmfile_path,spmfile_name]=fileparts(spmfile);
                save(fullfile(spmfile_path,'PEAKS.mat'),'peaks','peaks_suprathreshold');
                conn_process('extract_connectome',peaks(peaks_suprathreshold,:),[peaks(peaks_suprathreshold,:);peaks(~peaks_suprathreshold,:)],-1);
                return
%                 ROI=conn_process('results_connectome',spmfile_path,-1);
%                 save(fullfile(spmfile_path,'ROI.mat'),'ROI');
%                 conn_displayroi('initfile','results_roi',0,fullfile(spmfile_path,'ROI.mat'));
                %conn_displayroi('initfile','results_connectome',0,spmfile_path,peaks_suprathreshold,fullfile(spmfile_path,'ROI.mat'));
                %conn_displayroi('init','results_connectome',0,spmfile_path,peaks_suprathreshold);
                
            case 'switch',
                if isempty(OPTION2), side=get(DATA.handles(11),'value');
                else side=OPTION2;
                end
                if DATA.mat{6}=='T'
                    set(DATA.handles(11),'value',side);
                    if side~=DATA.side,
                        switch(side),
                            case 1, b=c;
                            case 2, b=1-c;
                            case 3, b=2*min(c,1-c);
                        end
                        %b(b==0)=nan;
                        b=-log(max(eps,b));
                        b(isnan(c))=nan;
                        DATA.side=side;
                        init=-1;
                        DATA.selectcluster=[];
                    end
                end
            case 'computeparametric'
                if isempty(OPTION2), skipgui=false;
                else skipgui=OPTION2;
                end
                switch(DATA.thres{2}),
                    case 1, THR_TYPE=1; %'vox-unc',
                    case 2, THR_TYPE=3; %'fdr-all'
                    case 3, THR_TYPE=4;%'T/F/X stat',
                end
                THR=DATA.thres{1};
                SIDE=DATA.side;
                if conn_vproject_randomise(spmfile,THR_TYPE,THR,~skipgui);
                    SIM=load(conn_vproject_simfilename(spmfile,THR_TYPE,THR));
                end
                init=-1;
                DATA.selectcluster=[];
            case 'parametric',
                if nnz(paramoptions)>1
                    if isempty(OPTION2), parametric=get(DATA.handles(23),'value');
                    else parametric=OPTION2;
                    end
                    set(DATA.handles(23),'value',parametric);
                    if parametric~=DATA.parametric,
                        switch(parametric),
                            case 1,
                                a=DATA.param.backg;
                                b=DATA.param.logp;
                                c=DATA.param.p;
                                d=DATA.param.F;
                                mat=DATA.param.stats;
                                set(DATA.handles(7),'string',sprintf('%15s%13s%13s%13s%13s%13s%13s','Clusters (x,y,z)','size','size p-FWE','size p-FDR','size p-unc','peak p-FWE','peak p-unc'));
                            case 2,
                                a=DATA.nonparam.backg;
                                b=DATA.nonparam.logp;
                                c=DATA.nonparam.p;
                                d=DATA.nonparam.F;
                                mat=DATA.nonparam.stats;
                                set(DATA.handles(7),'string',sprintf('%15s%13s%13s%13s%13s%13s%13s%13s%13s','Clusters (x,y,z)','size','size p-FWE','size p-FDR','size p-unc','mass','mass p-FWE','mass p-FDR','mass p-unc'));
                        end
                        switch(DATA.side),
                            case 1, b=c;
                            case 2, b=1-c;
                            case 3, b=2*min(c,1-c);
                        end
                        b=-log(max(eps,b));
                        b(isnan(c))=nan;
                        DATA.a=a;DATA.b=b;DATA.c=c;DATA.d=d;DATA.mat=mat;DATA.parametric=parametric;
                        %                     %b(b==0)=nan;
                        %                     b=-log(max(eps,b));
                        init=-1;
                        DATA.selectcluster=[];
                    end
                end
            otherwise,
                return
        end
    end
else, %initialization
    init=1;
    if nargin<14 || isempty(voxeltovoxel), voxeltovoxel=0; end
    if nargin<13 || isempty(spmfile), spmfile=[]; end
    if nargin<12 || isempty(data1plot), data1plot=[]; end
    if nargin<11 || isempty(threshold), threshold=.5; end
    if nargin<10 || isempty(select), select=[]; end
    if nargin<9 || isempty(box), box=0; end
    if nargin<8 || isempty(res), res=1; end
    if nargin<7 || isempty(parametric), parametric=[]; end
    if nargin<6 || isempty(side), side=1; end
    if nargin<5 || isempty(thres), thres={.05,1,1,1}; end
    if nargin<4 || isempty(projection), projection=[-1,0,0;0,0,-1;0,-1,0]; end; 
    %if nargin<4 || isempty(projection), projection=[-0.3529,0.9347,-0.0429;0.0247,-0.0365,-0.9990;-0.9353,-0.3537,-0.0103]; end
    if nargin<3 || isempty(views), views='full'; end
%     if nargin<9 || isempty(threshold), if isempty(b), threshold=[nanmean(a(:))]; else, threshold=[nanmean(a(:)),2]; end; end
    pointer=[0 0 0];

    GCF=gcf;
    if ~strcmp(views,'none'), 
        clf; 
        paramoptions=[~isempty(param.F), ~isempty(nonparam.F)];
        if isempty(parametric)
            if paramoptions(1), parametric=1;
            elseif paramoptions(2), parametric=2;
            else error('no analyses found');
            end
        end
        if parametric==1
            a=param.backg;
            b=param.logp;
            c=param.p;
            d=param.F;
            mat=param.stats;
        else
            a=nonparam.backg;
            b=nonparam.logp;
            c=nonparam.p;
            d=nonparam.F;
            mat=nonparam.stats;
        end
        if mat{6}=='T'&&side~=1
            switch(side),
                case 1, b=c;
                case 2, b=1-c;
                case 3, b=2*min(c,1-c);
            end
            b=-log(max(eps,b));
            b(isnan(c))=nan;
        end
        DATA.a=a;
        DATA.b=b;
        DATA.c=c;
        DATA.d=d;
        DATA.projection=projection;
        DATA.thres=thres;
        DATA.threshold=threshold;
        DATA.res=res;
        DATA.box=box;
        DATA.views=views;
        DATA.rotation=[0,0,0];
        DATA.selectcluster=[];
        DATA.select=select;
        DATA.pointer=pointer;
        DATA.mat=mat;
        DATA.clusters={[]};
        DATA.side=side;
        DATA.spmfile=spmfile;
        DATA.voxeltovoxel=voxeltovoxel;
        DATA.SIM=[];
        DATA.param=param;
        DATA.nonparam=nonparam;
        DATA.parametric=parametric;
        DATA.paramoptions=paramoptions;
        DATA.peakFDR=0;
    end
end

if init>0, % initialize
    %map=[gray(64).^2;.5*repmat([1,1,0],[64,1])+.5*((gray(64).^2)*diag([1,1,0]));.5*repmat([1,0,0],[64,1])+.5*((gray(64).^2)*diag([1,0,0]))];
    %map=[.5+.5*(gray(64).^2);.5*repmat([1,1,0],[64,1])+.5*((gray(64).^.5)*diag([1,1,0]));.5*repmat([0,0,1],[64,1])+.5*((gray(64).^.5)*diag([0,0,1]))];map(1,:)=1;
    map=[.25+.75*(gray(64).^2)*diag([1,1,1]);0*repmat([1,1,1],[64,1])+1*((gray(64).^1)*diag([1,0,0]));.25*repmat([1,1,0],[64,1])+.75*((gray(64).^.5)*diag([1,1,0]))];map(1,:)=.25;
    switch(views),
        case 'full',
            clf;
            if isempty(b),
                DATA.handles=[uicontrol('style','text','units','norm','position',[.6,.95,.1,.05],'string','resolution','backgroundcolor','w','foregroundcolor','b'),...
                    uicontrol('style','edit','units','norm','position',[.7,.95,.1,.05],'string',num2str(DATA.res),'callback',{@conn_vproject,'resolution'},'backgroundcolor','w','foregroundcolor','k'),...
                    uicontrol('style','text','units','norm','position',[.8,.95,.1,.05],'string','threshold','backgroundcolor','w','foregroundcolor','b'),...
                    uicontrol('style','edit','units','norm','position',[.9,.95,.1,.05],'string',num2str(DATA.threshold),'callback',{@conn_vproject,'threshold'},'backgroundcolor','w','foregroundcolor','b')];
                DATA.axes=subplot(122); set(DATA.axes,'units','norm','position',[.55,.1,.4,.8],'visible','off');
                set(GCF,'name','results explorer','numbertitle','off','color','w','units','norm','position',[.1,.5,.8,.4],'interruptible','off','busyaction','cancel','colormap',map,'userdata',DATA); %,'windowbuttondownfcn',{@conn_vproject,'buttondown'},'windowbuttonupfcn',{@conn_vproject,'buttonup'},'windowbuttonmotionfcn',[],'keypressfcn',{@conn_vproject,'keypress'},
            else
                uicontrol('style','frame','units','norm','position',[.0,.87,1,.13],'backgroundcolor',.9*[1,1,1],'foregroundcolor','w');
                %uicontrol('style','frame','units','norm','position',[.0,.0,1,.16],'backgroundcolor',.9*[1,1,1],'foregroundcolor','w');
                DATA.handles=[...
                    uicontrol('style','text','units','norm','position',[.05,.92,.15,.04],'string','height threshold: p <','fontname','arial','fontsize',8+CONN_gui.font_offset,'fontweight','bold','foregroundcolor','k','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','edit','units','norm','position',[.20,.93,.10,.03],'string',num2str(thres{1}),'fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'vox-thr'},'tooltipstring','Height-threshold value: False-positive threshold value for each voxel','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','popupmenu','units','norm','position',[.325,.935,.25,.03],'string',{'p-uncorrected','p-FDR corrected','F/T/X stat'},'fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'vox-thr'},'value',thres{2},'tooltipstring','False-positive control type for individual voxels','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','text','units','norm','position',[.05,.88,.15,.04],'string','cluster threshold: p <','fontname','arial','fontsize',8+CONN_gui.font_offset,'fontweight','bold','foregroundcolor','k','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','edit','units','norm','position',[.20,.89,.10,.03],'string',num2str(thres{3}),'fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'clu-thr'},'tooltipstring','Extent threshold value: False-positive threshold value for individual clusters (based on cluster size)','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','popupmenu','units','norm','position',[.325,.895,.25,.03],'string',{'cluster-size','cluster-size p-FWE corrected','cluster-size p-FDR corrected','cluster-size p-uncorrected','peak-voxel p-FWE corrected','peak-voxel p-FDR corrected','peak-voxel p-uncorrected','cluster-mass','cluster-mass p-FWE corrected','cluster-mass p-FDR corrected','cluster-mass p-uncorrected'},'fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'clu-thr'},'value',thres{4},'tooltipstring','False-positive control type for individual clusters','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','text','units','norm','position',[.1,.40,.8,.025],'string',sprintf('%15s%13s%13s%13s%13s%13s%13s%15s','Clusters (x,y,z)','size','size p-FWE','size p-FDR','size p-unc','peak p-FWE','peak p-FDR','peak p-unc'),'fontname','arial','fontsize',8+CONN_gui.font_offset,'backgroundcolor','w','foregroundcolor','b','horizontalalignment','left','fontname','monospaced','fontsize',8+CONN_gui.font_offset),...
                    uicontrol('style','listbox','units','norm','position',[.1,.20,.8,.20],'string','','backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','fontname','monospaced','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'selectroi'}),...
                    uicontrol('style','pushbutton','units','norm','position',[.025,.03,.15,.12],'string','Surface display','fontname','arial','fontweight','bold','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'surface_view'},'tooltipstring','<HTML><b>Surface display</b><br/>Displays above results projected to cortical surface</HTML>'),...
                    uicontrol('style','text','units','norm','position',[.62,.80,.28,.04],'string','Voxels in selected-cluster','fontname','arial','fontsize',9+CONN_gui.font_offset,'backgroundcolor','w','foregroundcolor',.5*[1 1 1],'horizontalalignment','left','max',2,'value',[],'enable','off'),...
                    uicontrol('style','popupmenu','units','norm','position',[.605,.935,.2,.03],'string',{'positive contrast','negative contrast','two-sided'},'value',side,'fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'switch'},'tooltipstring','Analysis results directionality','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','listbox','units','norm','position',[.62,.45,.28,.35],'string','','fontname','arial','fontsize',9+CONN_gui.font_offset,'visible','off','backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','max',2,'value',[],'enable','off'),...
                    uicontrol('style','text','units','norm','position',[.855,.92,.1,.04],'string','','fontname','arial','fontsize',8+CONN_gui.font_offset,'horizontalalignment','right','foregroundcolor','k','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','text','units','norm','position',[.855,.88,.1,.04],'string','','fontname','arial','fontsize',8+CONN_gui.font_offset,'horizontalalignment','right','foregroundcolor','k','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','pushbutton','units','norm','position',[.825,.13,.15,.04],'string','Plot effects','fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'cluster_view'},'tooltipstring','Explores/displays average effect sizes within each significant cluster'),...
                    uicontrol('style','pushbutton','units','norm','position',[.825,.05,.15,.04],'string','Export mask','fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'export_mask'},'tooltipstring','Exports mask of supra-threshold voxels'),...
                    uicontrol('style','pushbutton','units','norm','position',[.185,.03,.15,.12],'string','Volume display','fontname','arial','fontweight','bold','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'volume_view'},'tooltipstring','<HTML><b>Volume display</b><br/>Displays above results on 3d brain</HTML>'),...
                    uicontrol('style','pushbutton','units','norm','position',[.825,.09,.15,.04],'string','Import values','fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'cluster_import'},'tooltipstring','Imports average connectivity values within each significant cluster and for each subject into CONN toolbox as second-level covariates'),...
                    uicontrol('style','pushbutton','units','norm','position',[.665,.03,.15,.12],'string','SPM display','fontname','arial','fontweight','bold','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'spm_view'},'tooltipstring','<HTML><b>SPM display</b><br/>Displays results in SPM</HTML>'),...
                    uicontrol('style','pushbutton','units','norm','position',[.345,.03,.15,.12],'string','Glass display','fontname','arial','fontweight','bold','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'tvolume_view'},'tooltipstring','<HTML><b>Glass display</b><br/>Displays above results on 3d glass-brain</HTML>'),...
                    uicontrol('style','pushbutton','units','norm','position',[.505,.03,.15,.12],'string','Slice display','fontname','arial','fontweight','bold','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'slice_view'},'tooltipstring','<HTML><b>Slice display</b><br/>Displays above results on individual slices</HTML>'),...
                    uicontrol('style','pushbutton','units','norm','position',[.825,.01,.15,.04],'string','Bookmark','fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'bookmark'},'tooltipstring','Bookmark this second-level results explorer view'),...
                    uicontrol('style','popupmenu','units','norm','position',[.605,.895,.2,.03],'string',{'parametric stats','non-parametric stats'},'value',parametric,'fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'parametric'},'tooltipstring','Statistics based on parametric (Random Field Theory) or non-parametric (permutation) analyses','backgroundcolor',.9*[1,1,1]),...
                    uicontrol('style','pushbutton','units','norm','position',[.68,.205,.20,.04],'string','Compute non-parametric statistics','visible','off','fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'computeparametric'},'tooltipstring','<HTML>Compute non-parametric statistics<br/> (permutation tests)</HTML>')];
                    %uicontrol('style','text','units','norm','position',[.2,.30,.1,.025],'string','k','backgroundcolor','k','foregroundcolor','y','horizontalalignment','left'),...
                    %uicontrol('style','text','units','norm','position',[.3,.30,.1,.025],'string','voxel p-unc','backgroundcolor','k','foregroundcolor','y','horizontalalignment','left'),...
                    %uicontrol('style','text','units','norm','position',[.4,.30,.1,.025],'string','voxel p-cor','backgroundcolor','k','foregroundcolor','y','horizontalalignment','left'),...
                    %uicontrol('style','listbox','units','norm','position',[.2,.05,.1,.25],'string','','backgroundcolor','k','foregroundcolor','w','horizontalalignment','left'),...
                    %uicontrol('style','listbox','units','norm','position',[.3,.05,.1,.25],'string','','backgroundcolor','k','foregroundcolor','w','horizontalalignment','left'),...
                    %uicontrol('style','listbox','units','norm','position',[.4,.05,.1,.25],'string','','backgroundcolor','k','foregroundcolor','w','horizontalalignment','left')];
                if DATA.mat{6}~='T', set(DATA.handles(11),'value',3,'enable','off'); end; 
                bp=[9 17 20 21 19]; for n1=1:numel(bp),set(DATA.handles(bp(n1)),'units','pixel'); pt=get(DATA.handles(bp(n1)),'position'); set(DATA.handles(bp(n1)),'units','norm'); temp=imread(fullfile(fileparts(which(mfilename)),sprintf('conn_vproject_icon%02d.jpg',n1))); temp=double(temp); temp=temp/255; temp=max(0,min(1,(temp).^.5)); ft=.45*max(size(temp,1)/ceil(pt(4)),size(temp,2)/ceil(pt(3))); str=get(DATA.handles(bp(n1)),'string'); set(DATA.handles(bp(n1)),'cdata',temp(round(1:ft:size(temp,1)),round(1:ft:size(temp,2)),:),'string',''); end; %uicontrol('units','pixel','position',pt.*[1 1 1 0]+[0 pt(4)-18-CONN_gui.font_offset 0 18+CONN_gui.font_offset],'style','text','string',str,'fontsize',9+CONN_gui.font_offset,'backgroundcolor','w','foregroundcolor','k'); end
                if ~isfield(DATA,'peakFDR')||~DATA.peakFDR, 
                    set(DATA.handles(6),'string',{'cluster-size','cluster-size p-FWE corrected','cluster-size p-FDR corrected','cluster-size p-uncorrected','peak-voxel p-FWE corrected','peak-voxel p-uncorrected','cluster-mass','cluster-mass p-FWE corrected','cluster-mass p-FDR corrected','cluster-mass p-uncorrected'}); 
                    set(DATA.handles(7),'string',sprintf('%15s%13s%13s%13s%13s%13s%13s','Clusters (x,y,z)','size','size p-FWE','size p-FDR','size p-unc','peak p-FWE','peak p-unc'));
                end
                if DATA.parametric==2
                    set(DATA.handles(7),'string',sprintf('%15s%13s%13s%13s%13s%13s%13s%13s%13s','Clusters (x,y,z)','size','size p-FWE','size p-FDR','size p-unc','mass','mass p-FWE','mass p-FDR','mass p-unc'));
                end
                if nnz(DATA.paramoptions)<2, 
                    if DATA.paramoptions(1), set(DATA.handles(23),'string',{'parametric stats'},'value',1,'enable','off');
                    elseif DATA.paramoptions(2),  set(DATA.handles(23),'string',{'non-parametric stats'},'value',1,'enable','off');
                    else set(DATA.handles(23),'visible','off');
                    end
                end
                hc1=uicontextmenu;
                uimenu(hc1,'Label','Export table','callback',@(varargin)conn_exportlist(DATA.handles(8),'',get(DATA.handles(7),'string')));
                set(DATA.handles(8),'uicontextmenu',hc1);
                hc1=uicontextmenu;
                uimenu(hc1,'Label','Export table','callback',@(varargin)conn_exportlist(DATA.handles(12)));
                set(DATA.handles(12),'uicontextmenu',hc1);
                %uicontrol('style','pushbutton','units','norm','position',[.775,.02,.1,.04],'string','Export table','fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',@(varargin)conn_exportlist(DATA.handles(12)),'tooltipstring','Exports table'),...
                %hc1=uicontextmenu;
                %uimenu(hc1,'Label','Export stats','callback',{@conn_vproject,'export_stats'});
                %set(DATA.handles(8),'uicontextmenu',hc1);
                if voxeltovoxel
                    DATA.handles(10)=uicontrol('style','pushbutton','units','norm','position',[.875,.845,.1,.04],'string','post-hoc peak analyses','fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'connectome'});
                end
                %if DATA.mat{6}~='T'||isempty(DATA.mat{2}), %enable Fcluster% 
                %    delete(DATA.handles(6)); DATA.handles(6)=uicontrol('style','popupmenu','units','norm','position',[.625,.895,.1,.03],'string',{'peak p-FDR corrected','extent k-value'},'fontname','arial','fontsize',8+CONN_gui.font_offset,'callback',{@conn_vproject,'clu-thr'},'value',min(2,thres{4}));
                %end
                %if isempty(DATA.mat{2}), set(DATA.handles(6),'visible','off','value',4); DATA.thres{4}=4; DATA.thres{3}=10; thres=DATA.thres; set(DATA.handles(5),'string',num2str(thres{3})); set(DATA.handles(4),'string','extent threshold: cluster k ='); end
                DATA.axes=subplot(222);set(DATA.axes,'units','norm','position',[.40,.45,.2,.38],'visible','off');%[.55,.35,.4,.6],'visible','off');
                h0=get(0,'screensize');
                set(GCF,'name',['results explorer ',DATA.spmfile],'numbertitle','off','color','w','units','pixels','position',[2,h0(4)-.8*h0(4)-48,.75*h0(3)-2,.8*h0(4)],'interruptible','off','busyaction','cancel','colormap',map,'userdata',DATA); %,'windowbuttondownfcn',{@conn_vproject,'buttondown'},'windowbuttonupfcn',{@conn_vproject,'buttonup'},'windowbuttonmotionfcn',[],'keypressfcn',{@conn_vproject,'keypress'},'colormap',map,'userdata',DATA); 
            end
        case '3d',
            clf;
            DATA.handles=[uicontrol('style','text','units','norm','position',[0,0,.1,.05],'string','resolution','backgroundcolor','k','foregroundcolor','w'),...
                uicontrol('style','edit','units','norm','position',[.1,0,.1,.05],'string',num2str(DATA.res),'callback',{@conn_vproject,'resolution'},'backgroundcolor','k','foregroundcolor','w'),...
                uicontrol('style','text','units','norm','position',[.2,0,.1,.05],'string','threshold','backgroundcolor','k','foregroundcolor','w'),...
                uicontrol('style','edit','units','norm','position',[.3,0,.1,.05],'string',num2str(DATA.threshold),'callback',{@conn_vproject,'threshold'},'backgroundcolor','k','foregroundcolor','w')];
            DATA.axes=gca;set(DATA.axes,'visible','off');
            set(GCF,'name','Volume display','numbertitle','off','color','w','interruptible','off','busyaction','cancel','colormap',map,'userdata',DATA);%,'windowbuttondownfcn',{@conn_vproject,'buttondown'},'windowbuttonupfcn',{@conn_vproject,'buttonup'},'windowbuttonmotionfcn',[],'keypressfcn',{@conn_vproject,'keypress'},'colormap',map,'userdata',DATA);
        case 'orth',
            clf;
            DATA.handles=[uicontrol('style','text','units','norm','position',[0,0,.1,.05],'string','resolution','backgroundcolor','k','foregroundcolor','w'),...
                uicontrol('style','edit','units','norm','position',[.1,0,.1,.05],'string',num2str(DATA.res),'callback',{@conn_vproject,'resolution'},'backgroundcolor','k','foregroundcolor','w'),...
                uicontrol('style','text','units','norm','position',[.2,0,.1,.05],'string','threshold','backgroundcolor','k','foregroundcolor','w'),...
                uicontrol('style','edit','units','norm','position',[.3,0,.1,.05],'string',num2str(DATA.threshold),'callback',{@conn_vproject,'threshold'},'backgroundcolor','k','foregroundcolor','w')];
            DATA.axes=gca;set(DATA.axes,'visible','off');
            %DATA.axes=gca;
            set(GCF,'color','w','windowbuttondownfcn',[],'windowbuttonupfcn',[],'windowbuttonmotionfcn',[],'keypressfcn',[],'colormap',map,'userdata',DATA);
        case 'none',
            if ~nargout, DATA.axes=gca;set(DATA.axes,'visible','off'); end
            %DATA.axes=gca;
            %set(GCF,'color','w','userdata',DATA);
    end
end

% display
if strcmp(views,'full'),
    if init~=0, % redraws orth views
        hcontrols=findobj(GCF,'enable','on');
        hcontrols=hcontrols(ishandle(hcontrols));
        set(hcontrols,'enable','off');
        set(GCF,'pointer','watch'); %drawnow
        if ~isempty(b),%length(threshold)>1,
            if isempty(DATA.clusters)||init~=-2, % compute/display stats
                bnew=b(:,:,:,1); %bnew(~a)=nan;%bnew(a<=threshold(1))=nan;
                [bnew,txt,xyzpeak,clusters,clusternames,ithres,cluster_stats,doneparam,DATA.SIM]=vproject_display(bnew,threshold,thres,mat,DATA.side,DATA.d,DATA.peakFDR,DATA.parametric,DATA.SIM,DATA.spmfile,init);
                b(:,:,:,2)=bnew; threshold(3)=0;%.5;
                %for n1=1:4, set(DATA.handles(8+n1),'string',strvcat(txt{n1})); end
                set(DATA.handles(8),'string',strvcat(txt,' '),'value',max(1,min(size(txt,1)+1,get(DATA.handles(8),'value'))));
                if DATA.parametric==2&&~doneparam, set(DATA.handles(24),'visible','on');
                else set(DATA.handles(24),'visible','off');
                end
                if DATA.parametric==2&&~doneparam, set(DATA.handles(24),'visible','on');
                else set(DATA.handles(24),'visible','off');
                end
                DATA.stdprojections=cell(1,4); 
                DATA.txt=txt;
                DATA.clusternames=clusternames;
                DATA.ithres=ithres;
                DATA.cluster_stats=cluster_stats;
            else
                clusters=DATA.clusters;
                xyzpeak=DATA.xyzpeak;
                clusternames=DATA.clusternames;
            end
            if isfield(DATA,'selectcluster'), selectcluster=DATA.selectcluster;else, selectcluster=get(DATA.handles(8),'value'); end
            if selectcluster<=length(clusters), select=clusters{selectcluster}; clusternames=clusternames{selectcluster}.txt; titleclusternames='Voxels in selected cluster:';
            elseif (isempty(selectcluster)||selectcluster==length(clusters)+1)&&~isempty(clusternames), select=[]; clusternames=clusternames{length(clusters)+1}.txt; titleclusternames='All suprathreshold voxels:';
            else, select=[]; clusternames=[]; titleclusternames=''; end
        end
        %M={[-1,0,0;0,0,-1;0,-1,0],[0,-1,0;0,0,-1;-1,0,0],[-1,0,0;0,1,0;0,0,1]};
        M={[1,0,0;0,0,-1;0,1,0],[0,-1,0;0,0,-1;1,0,0],[1,0,0;0,-1,0;0,0,-1]};
        if ~isfield(DATA,'stdprojections') || init==-1, DATA.stdprojections=cell(1,4); end
        tplot={};infoplot={};
        for n1=1:3, 
            [tplot{n1},nill,nill,nill,b2,tres,DATA.stdprojections{n1}]=vproject_view(a,b,c,M{n1},threshold,res,select,DATA.stdprojections{n1});
            infoplot{n1}=struct('boundingbox',b2,'res',tres,'size',[size(tplot{n1},1),size(tplot{n1},2)],'projection',projection);
            %[tplot{n1},infoplot{n1},DATA.stdprojections{n1}]=conn_vproject(a,b,c,d,'none',M{n1},thres,res,0,select,mat,threshold,DATA.stdprojections{n1}); 
        end
        %tplot=[tplot{1},tplot{2};tplot{3},ones(size(tplot{3},1),size(tplot{2},2))];
        tplot=cat(1,cat(2,tplot{1},tplot{2}),cat(2,tplot{3},tplot{1}(1)*ones([size(tplot{3},1),size(tplot{2},2),size(tplot{2},3)])));
        if ~isempty(b), h=subplot(3,4,1); set(h,'units','norm','position',[.1,.45,.4,.4]); else, h=subplot(3,4,1); set(h,'units','norm','position',[.05,.1,.4,.8]);end
        %pres=.5;image(1:pres:size(tplot,2),1:pres:size(tplot,1),round(max((ceil(tplot(1:pres:end,1:pres:end)/64)-1)*64+1,convn(convn(tplot(1:pres:end,1:pres:end),conn_hanning(7)/4,'same'),conn_hanning(7)'/4,'same'))));axis equal; axis off;
        pres=.25;
        conf=conn_hanning(2/pres+1);conf=conf/sum(conf); 
        temp=convn(convn(tplot(round(1:pres:end),round(1:pres:end),:),conf,'same'),conf','same');
        image(1:pres:size(tplot,2),1:pres:size(tplot,1),temp);axis equal; axis off;
        %image(round(convn(convn(tplot(round(1:.5:end),round(1:.5:end),:),conn_hanning(3)/2,'same'),conn_hanning(3)'/2,'same')));axis equal; axis off;
        %image(tplot);axis equal; axis off;
        data1plot=DATA.stdprojections{4};
        if ~isempty(clusternames),set(DATA.handles(12),'string',clusternames,'value',[],'visible','on'); set(DATA.handles(10),'string',titleclusternames); else, set(DATA.handles(12),'string','','value',1,'visible','off'); set(DATA.handles(10),'string',''); end
        if numel(DATA.mat{3})>1&&isequal(DATA.mat{6},'T'), set(DATA.handles(13),'string',[DATA.mat{6},'(',num2str(DATA.mat{3}(end)),')','_min = ',num2str(DATA.ithres(1),'%0.2f')]);
        elseif numel(DATA.mat{3})>1, set(DATA.handles(13),'string',[DATA.mat{6},'(',num2str(DATA.mat{3}(1)),',',num2str(DATA.mat{3}(2)),')','_min = ',num2str(DATA.ithres(1),'%0.2f')]);
        else set(DATA.handles(13),'string',[DATA.mat{6},'(',num2str(DATA.mat{3}),')','_min = ',num2str(DATA.ithres(1),'%0.2f')]);
        end
        set(DATA.handles(14),'string',['k_min =',num2str(DATA.ithres(2))]);
        if DATA.paramoptions(1), set(DATA.handles(19),'visible','on');
        else set(DATA.handles(19),'visible','off');
        end
        if ~isempty(b),
            DATA.b=b;DATA.threshold=threshold;DATA.xyzpeak=xyzpeak;DATA.infoplot=infoplot;DATA.select=select;DATA.clusters=clusters;
            %set(GCF,'userdata',DATA);
        end
        %views='none';
        set(hcontrols(ishandle(hcontrols)),'enable','on');
        set(GCF,'pointer','arrow');%,'userdata',DATA);
    end
    set(DATA.axes,'visible','off');
    %subplot(122);conn_vproject(a,'none',projection,threshold,res,box); 
    %if ~isempty(b), DATA.axes=subplot(222); else, DATA.axes=subplot(122); end
end
if strcmp(views,'orth'),
%     %M={[-1,0,0;0,0,-1;0,-1,0],[0,-1,0;0,0,-1;-1,0,0],[-1,0,0;0,1,0;0,0,1]};
%     M={[1,0,0;0,0,-1;0,1,0],[0,1,0;0,0,-1;1,0,0],[1,0,0;0,1,0;0,0,-1]};
%     set(GCF,'pointer','watch'); drawnow
%     for n1=1:3, 
%         subplot(2,2,n1);
%         conn_vproject(a,b,c,d,'none',M{n1},threshold,res,box); 
%     end;
%     set(GCF,'pointer','arrow');
else, % none/full
    if ~nargout, set(GCF,'pointer','watch'); drawnow; end
    % volume plot
	[dataplot,idx,mask,B,b2,res,data1plot]=vproject_view(a,b,c,projection,threshold,res,select,data1plot);
    %if size(dataplot,3)>1, dataplot=dataplot(:,:,1)+dataplot(:,:,2); end
    infoplot=struct('boundingbox',b2,'res',res,'size',[size(dataplot,1),size(dataplot,2)],'projection',projection);
    DATA.infoplot{4}=infoplot;DATA.stdprojections{4}=data1plot; set(GCF,'userdata',DATA);
    if 0,%~nargout,  % note: do not display interactive single-display
        axes(DATA.axes);
        %image(dataplot);axis equal;axis off;
        pres=.25;conf=conn_hanning(2/pres+1);conf=conf/sum(conf); image(1:pres:size(dataplot,2),1:pres:size(dataplot,1),convn(convn(dataplot(round(1:pres:end),round(1:pres:end),:),conf,'same'),conf','same'));axis equal; axis off;
        %pres=.5;image(1:pres:size(dataplot,2),1:pres:size(dataplot,1),round(max((ceil(dataplot(1:pres:end,1:pres:end)/64)-1)*64+1,convn(convn(dataplot(1:pres:end,1:pres:end),conn_hanning(5)/3,'same'),conn_hanning(5)'/3,'same'))));axis equal; axis off;
        DATA.axes=gca;
        % bounding box
        if box,
            B3=B'*pinv(projection);
            B3=[1+(B3(:,1)-b2(1,1))/res, 1+(B3(:,2)-b2(1,2))/res, 1+(B3(:,3)-b2(1,3))/res];
            border={[1,3,7,5,1],[2,6,4,8,2],[1,3,2,8,1],[7,5,4,6,7]};
            [minBt3]=max(B3(:,3));
            for n0=1:length(border),
                for n1=1:length(border{n0})-1,
                    color=(B3(border{n0}(n1),3)==minBt3|B3(border{n0}(n1+1),3)==minBt3);
                    Bt1=linspace(B3(border{n0}(n1),1),B3(border{n0}(n1+1),1),100);
                    Bt2=linspace(B3(border{n0}(n1),2),B3(border{n0}(n1+1),2),100);
                    Bt3=linspace(B3(border{n0}(n1),3),B3(border{n0}(n1+1),3),100);
                    if color,
                        Bt1(Bt3>idx(max(1,min(prod(size(mask)), round(Bt2)+size(idx,1)*round(Bt1-1)))) & ...
                            mask(max(1,min(prod(size(mask)), round(Bt2)+size(idx,1)*round(Bt1-1)))) )=nan;
                    end
                    hold on; h=plot(Bt1,Bt2,'-'); set(h,'color',.25*[0,0,1],'linewidth',4-3*color);hold off;
                end
            end
        end
    end
    if ~nargout, set(GCF,'pointer','arrow'); end
end
end

function [dataplot,idx,mask,B,b2,res,data1plot]=vproject_view(a,b,c,projection,threshold,res,select,data1plot)
%interpolate&project
if ~isempty(data1plot),
    mask=data1plot.mask;
    idx=data1plot.idx;
    trans=data1plot.trans;
    B=data1plot.B;
    b2=data1plot.b2;
else,
    if ~isempty(b), a=a+j*b(:,:,:,end); end
    [x1,y1,z1]=meshgrid((1:size(a,2))-(size(a,2)+1)/2,(1:size(a,1))-(size(a,1)+1)/2,(1:size(a,3))-(size(a,3)+1)/2);
    bb={[1,size(a,2)]-(size(a,2)+1)/2,[1,size(a,1)]-(size(a,2)+1)/2,[1,size(a,3)]-(size(a,3)+1)/2};
    B=[];for n1=1:8,B=[B,[bb{1}(1+rem(n1,2));bb{2}(1+rem(floor(n1/2),2));bb{3}(1+rem(floor(n1/4),2))]]; end
    B2=B'*pinv(projection);
    b2=[min(B2,[],1);max(B2,[],1)];
    %res=res*((prod(b2(2,:)-b2(1,:))./prod(size(a))).^(1/3));
    if 1,%faster&avoids memory problems
        nz2=b2(1,3):res:b2(2,3);
        [x2,y2]=meshgrid(b2(1,1):res:b2(2,1),b2(1,2):res:b2(2,2));
        N=numel(x2);
        d2=[x2(:),y2(:)]*projection(1:2,:);
        d2=d2-repmat([bb{2}(1),bb{1}(1),bb{3}(1)],[N,1]);
        d2=reshape(d2,[size(x2),3]);
        trans=zeros(size(x2));
        idx=zeros([size(x2),1+(length(threshold)>1)]);
        idx1=1:N;idx2=[];
        for n1=1:length(nz2),
            x3=round(d2(idx1)+nz2(n1)*projection(3,1));
            y3=round(d2(idx1+N)+nz2(n1)*projection(3,2));
            z3=round(d2(idx1+N*2)+nz2(n1)*projection(3,3));
            %a3=interp3(x1,y1,z1,a,x3,y3,z3,'nearest');
            %idxs=max(1,min(size(a,1), 1+round(y3-bb{2}(1)) )) + size(a,1)*max(0,min(size(a,2)-1, round(x3-bb{1}(1)) )) + size(a,1)*size(a,2)*max(0,min(size(a,3)-1, round(z3-bb{3}(1)) ));
            idxs=max(1,min(size(a,1), 1+y3 )) + size(a,1)*max(0,min(size(a,2)-1, x3 )) + size(a,1)*size(a,2)*max(0,min(size(a,3)-1, z3 ));
            a3=a(idxs);
            idx0=real(a3)>threshold(1)|imag(a3)>threshold(end);
            idx(idx1(idx0))=(length(nz2)+1-n1)/length(nz2);
            idx2=[idx2,idx1(idx0)];
            idx1=idx1(~idx0);
            if length(threshold)>1,
                x3=d2(idx2)+nz2(n1)*projection(3,1);
                y3=d2(idx2+N)+nz2(n1)*projection(3,2);
                z3=d2(idx2+N*2)+nz2(n1)*projection(3,3);
                %a3=interp3(x1,y1,z1,a,x3,y3,z3,'nearest');
                %idxt=max(1,min(size(a,1), 1+round(y3-bb{2}(1)) )) + size(a,1)*max(0,min(size(a,2)-1, round(x3-bb{1}(1)) )) + size(a,1)*size(a,2)*max(0,min(size(a,3)-1, round(z3-bb{3}(1)) ));
                idxt=max(1,min(size(a,1), 1+round(y3) )) + size(a,1)*max(0,min(size(a,2)-1, round(x3) )) + size(a,1)*size(a,2)*max(0,min(size(a,3)-1, round(z3) ));
                a3=a(idxt);
                if 0,
                    idx00=find(imag(a3)>threshold(end));
                    idx(N+idx2(idx00))=max(idx(N+idx2(idx00)),imag(a3(idx00))); %n1;
                    idxtrans=find(trans(idx2(idx00))==0);
                    trans(idx2(idx00(idxtrans)))=idxt(idx00(idxtrans));
                else,
                    idx00=find(imag(a3)>threshold(end));
                    idxtrans=find(~idx(N+idx2(idx00)));%idxtrans=find(imag(a3(idx00))>=idx(N+idx2(idx00)));
                    idx(N+idx2(idx00(idxtrans)))=(length(nz2)+1-n1)/length(nz2);%imag(a3(idx00(idxtrans)));
                    trans(idx2(idx00(idxtrans)))=idxt(idx00(idxtrans));
                end
                
                %idx2=idx2(~idx00);
            end
        end
        mask=(idx>0);
        %if any(any(mask(:,:,1)>0)), idx(~mask(:,:,1))=5*max(idx(mask(:,:,1)>0)); else, idx(~mask(:,:,1))=length(nz2); end
    else,
        [x2,y2,z2]=meshgrid(b2(1,1):res:b2(2,1),b2(1,2):res:b2(2,2),b2(1,3):res:b2(2,3));
        d=[x2(:),y2(:),z2(:)]*projection;
        x2=reshape(d(:,1),size(x2));
        y2=reshape(d(:,2),size(y2));
        z2=reshape(d(:,3),size(z2));
        %a2=interp3(x1,y1,z1,a,x2,y2,z2,'nearest');
        a2=a(max(1,min(size(a,1), 1+round(y2-bb{2}(1)) )) + size(a,1)*max(0,min(size(a,2)-1, round(x2-bb{1}(1)) )) + size(a,1)*size(a,2)*max(0,min(size(a,3)-1, round(z2-bb{3}(1)) )));
        [mask,idx]=max(a2>threshold,[],3);idx(~mask)=max(idx(mask>0));
    end
    data1plot.mask=mask;
    data1plot.idx=idx;
    data1plot.trans=trans;
    data1plot.B=B;
    data1plot.b2=b2;
end
conf1=conn_hanning(3)/2;conf1=conf1/sum(conf1);
conf2=conn_hanning(3)/2;conf2=conf2/sum(conf2);
if size(idx,3)==1, dataplot=-idx; dataplot=1+63*(dataplot-min(dataplot(:)))/(max(dataplot(:))-min(dataplot(:)));
else, 
    %dataplot1=-idx(:,:,1); dataplot1=1+63*(dataplot1-min(dataplot1(:)))/(max(dataplot1(:))-min(dataplot1(:)));
    %conjmask=mask(:,:,1)&mask(:,:,2);
    %dataplot2=-idx(:,:,2); dataplot2=1+63*(dataplot2-min(dataplot2(:)))/(max(dataplot2(:))-min(dataplot2(:)));
    %dataplot=dataplot1; dataplot(conjmask)=64+dataplot2(conjmask);
    if 1,
        dataplot1=idx(:,:,1);
        dataplot2=idx(:,:,2);
        %dataplot1=convn(convn(dataplot1,conf1,'same'),conf1','same');
        %dataplot2=convn(convn(dataplot2,conf2,'same'),conf2','same');
        k=.75;%.2;
        dataplotA=(dataplot2==0).*(k+(1-k)*dataplot1.^4) + (dataplot2>0).*(k+(1-k)*dataplot1.^4);
        dataplotA(dataplot1==0)=1;
        dataplotB=(dataplot2==0).*dataplotA + (dataplot2>0).*(dataplotA.*max(0,min(.8,.4+.4*tanh(5*(dataplot1-dataplot2)))));
        %dataplotB=(dataplot2==0).*dataplotA + (dataplot2>0).*(dataplotA.*max(0,min(.75,tanh(1.5*(1*dataplot1-dataplot2)))));
        %dataplotB=(dataplot2==0).*dataplotA + (dataplot2>0).*(.25*dataplotA.*(dataplot2<=.9*dataplot1));
        %dataplotB=(dataplot2==0).*dataplotA + (dataplot2>0).*(0*(dataplot2>.95*dataplot1) + .5*dataplotA.*(dataplot2<=.95*dataplot1));
        dataplot=cat(3,dataplotA,dataplotB,dataplotB);
    else,
        dataplot1=idx(:,:,1);
        dataplot1=0+1*(dataplot1-min(dataplot1(~isinf(dataplot1))))/(max(dataplot1(~isinf(dataplot1)))-min(dataplot1(~isinf(dataplot1))));
        dataplot2=idx(:,:,2); if any(dataplot2(:)>0),mindataplot=.95*min(dataplot2(dataplot2>0));else,mindataplot=0;end;
        %dataplot2=dataplot2>mindataplot;
        dataplot2=max(0,dataplot2-mindataplot);
        dataplot2=convn(convn(dataplot2,conf1,'same'),conf1','same');
        dataplot2=0+1*dataplot2/max(eps,max(dataplot2(:)));
        %dataplot1=max(prctile(dataplot1(dataplot1<max(dataplot1(:))),5),dataplot1);dataplot2=max(0,dataplot1-dataplot2);
        %dataplot1=.75+.25*(dataplot1).^2;dataplot2=max(0,dataplot1-dataplot2);
        dataplot1=convn(convn(max(0,min(1,dataplot1)),conf2,'same'),conf2','same');
        dataplot1=0+1*(dataplot1).^4;
        %dataplotA=max(0,min(1, dataplot1+.25*(dataplot2>0)));dataplotB=max(0,min(1, dataplot1-dataplot2+.0*(dataplot2>0)));
        dataplotA=max(0,min(1, dataplot1.*(dataplot2==0)+(.25+dataplot1).*(dataplot2>0)));
        dataplotB=max(0,min(1, dataplot1.*(dataplot2==0)+(.25+dataplot1).*(.5-.5*dataplot2).*(dataplot2>0)));
        dataplot=cat(3,dataplotA,dataplotB,dataplotB);
        %idxback=find(all(dataplot<.1,3)); dataplot(idxback)=1;dataplot(idxback+size(dataplot,1)*size(dataplot,2))=1;dataplot(idxback+2*size(dataplot,1)*size(dataplot,2))=1;
        %dataplot=cat(3,dataplot1,dataplot2,dataplot2);
    end
end
if ~isempty(select),
    [transa,transb,transc]=unique(trans(:));%trans=a(c);
    [nill,idxp]=intersect(transa(:),select(:));
    d=logical(zeros(size(transa)));d(idxp)=1;
    e=find(d(transc));
    %%dataplot(e)=dataplot(e)+64;
    dataplot3=zeros([size(dataplot,1),size(dataplot,2)]);dataplot3(e)=1;dataplot3=convn(convn(dataplot3,conf1,'same'),conf1,'same');e=find(dataplot3>0);
    n=size(dataplot,1)*size(dataplot,2);
    dataplot(e+1*n)=dataplot(e+1*n).*(1-dataplot3(e))+0*dataplot(e+0*n).*(dataplot3(e));
    dataplot(e+2*n)=dataplot(e+2*n).*(1-dataplot3(e))+0*dataplot(e+0*n).*(dataplot3(e));
    dataplot(e+0*n)=dataplot(e+0*n).*(1-dataplot3(e))+0*dataplot(e+0*n).*(dataplot3(e));
end
if size(idx,3)~=1,
    n=size(dataplot,1)*size(dataplot,2);
    idxtemp1=find(dataplot2>0);
    idxtemp2=find(c(trans(idxtemp1))>.5);
    idxtemp=idxtemp1(idxtemp2);
    temp3=dataplot(idxtemp+2*n); 
    dataplot(idxtemp+2*n)=dataplot(idxtemp+0*n); 
    dataplot(idxtemp+0*n)=temp3;
end
end

function [anew,txt,xyzpeak,clusters,clusternames,ithres,cluster_stats,doneall,SIM]=vproject_display(a,threshold,thres,mat,side,Z,peakfdr,parametric,SIM,spmfile,init)
global CONN_gui;
persistent refsrois;
if isempty(refsrois),
    if isfield(CONN_gui,'refs')&&isfield(CONN_gui.refs,'rois')&&isfield(CONN_gui.refs.rois,'filename')&&~isempty(CONN_gui.refs.rois.filename),
        refsrois=CONN_gui.refs.rois;
    else
        %filename=fullfile(fileparts(which('conn')),'utils','otherrois','Td.img');
        filename=fullfile(fileparts(which('conn')),'rois','atlas.nii');
        %filename=fullfile(fileparts(which('conn')),'utils','otherrois','BA.img');
        [filename_path,filename_name,filename_ext]=fileparts(filename);
        V=spm_vol(filename);
        refsrois=struct('filename',filename,'filenameshort',filename_name,'V',V,'data',spm_read_vols(V),'labels',{textread(fullfile(filename_path,[filename_name,'.txt']),'%s','delimiter','\n')});
    end
    [x,y,z]=ndgrid(1:size(a,1),1:size(a,2),1:size(a,3));xyz=[x(:),y(:),z(:)];
    refsrois.data=spm_get_data(refsrois.V,pinv(refsrois.V.mat)*mat{1}*[xyz,ones(size(xyz,1),1)]');
    maxrefsrois=max(refsrois.data(:)); refsrois.count=hist(refsrois.data(:),0:maxrefsrois);
    refsrois.labels={'not-labeled',refsrois.labels{:}};
end

if nargin<5, side=1; end
if nargin<4, mat={eye(4),numel(a)}; end
idx0=find(~isnan(a));
p=exp(-a(idx0));
p0=a;p0(idx0)=p;
P=a;P(idx0)=conn_fdr(p(:));
ithres=[nan,nan];
doneall=true;

switch(thres{2}),
    case 1,%'vox-unc',
        % voxels above height threshold
        idxvoxels=find(a>-log(thres{1}));
        anew=zeros(size(a));anew(idxvoxels)=a(idxvoxels)+log(thres{1});%1;
        if ~isempty(idxvoxels),
            [xt,yt,zt]=ind2sub(size(a),idxvoxels);C=spm_clusters([xt,yt,zt]');c=hist(C,1:max(C));
        end
        if mat{6}=='T'&&side<3, %T stat one-sided
            u=spm_invTcdf(1-thres{1},mat{3}(end));
            ithres(1)=u;
        elseif mat{6}=='T'&&side==3, %two-sided T stat
            u=spm_invFcdf(1-thres{1},1,mat{3}(end));
            ithres(1)=sqrt(u);
        elseif mat{6}=='F' %F stat
            u=spm_invFcdf(1-thres{1},mat{3}(1),mat{3}(2));
            ithres(1)=u;
        elseif mat{6}=='X' %X2 stat
            u=spm_invXcdf(1-thres{1},mat{3});
            ithres(1)=u;
        end
    case 2,%'vox-FDR',
        idxvoxels=find(P<thres{1})  ;
        anew=zeros(size(a));anew(idxvoxels)=-log(P(idxvoxels))+log(thres{1});%1;
        if ~isempty(idxvoxels),
            [xt,yt,zt]=ind2sub(size(a),idxvoxels);C=spm_clusters([xt,yt,zt]');c=hist(C,1:max(C)); % C: cluster per voxel; c: #voxels per clusters
        end
        if isempty(idxvoxels), u=1; ithres(1)=inf;
        else 
            if mat{6}=='T'&&side<3, %T stat
                u=spm_invTcdf(1-exp(-min(a(idxvoxels))),mat{3}(end)); ithres(1)=u;
            elseif mat{6}=='T'&&side==3, %two-sided T stat
                u=spm_invFcdf(1-exp(-min(a(idxvoxels))),1,mat{3}(end)); ithres(1)=sqrt(u);
            elseif mat{6}=='F' %F stat
                u=spm_invFcdf(1-exp(-min(a(idxvoxels))),mat{3}(1),mat{3}(2)); ithres(1)=u;
            elseif mat{6}=='X' %X2 stat
                u=spm_invXcdf(1-exp(-min(a(idxvoxels))),mat{3}); ithres(1)=u;
            end
        end
    case 3,%'T/F/X stat',
        % voxels above height threshold
        if mat{6}=='T'&&side==2, idxvoxels=find(Z<-thres{1});  %T stat negative-sided
        elseif mat{6}=='T'&&side==3, idxvoxels=find(abs(Z)>thres{1});  %T stat two-sided
        else idxvoxels=find(Z>thres{1}); 
        end
        anew=zeros(size(a));anew(idxvoxels)=a(idxvoxels)-min(a(idxvoxels))+.01;
        if ~isempty(idxvoxels),
            [xt,yt,zt]=ind2sub(size(a),idxvoxels);C=spm_clusters([xt,yt,zt]');c=hist(C,1:max(C));
        end
        u=thres{1};
        if mat{6}=='T'&&side<3, %T stat
            ithres(1)=thres{1};
        elseif mat{6}=='T'&&side==3, %two-sided T stat
            ithres(1)=abs(u);
        else %F/X stat
            ithres(1)=u;
        end
end
% if mat{6}=='T'&&side>2, %T stat two-sided
%     ithres(1)=spm_invTcdf(1-(1-spm_Tcdf(ithres(1),mat{3}(2)))/2,mat{3}(2));
% end

txt=[];xyzpeak={};clusters={};clusternames={};cluster_stats={};
if ~isempty(idxvoxels),
    xyz=[xt,yt,zt];
    idx1=find(c>0);
    idxn=[];idx2={};for n1=1:length(idx1),idx2{n1}=find(C==(idx1(n1))); idxn(n1)=length(idx2{n1}); end
    [nill,sidxn]=sort(idxn(:));sidxn=flipud(sidxn);
    xyzpeak=cell(1,length(idx1));
    clusters=cell(1,length(idx1));
    [k,cp,cP,kmass,cpmass,cPmass,minP,minp,maxZ,pPFWE]=deal(zeros(1,length(idx1)));
    if ~peakfdr, thres4=thres{4}+(thres{4}>=6);
    else thres4=thres{4};
    end
    %k=zeros(1,length(idx1));cp=k;cP=k;Ez=k;cPFDR=k; minP=k;minp=k;maxZ=k;pPFWE=k;
    if parametric==2 % non-parametric stats
        switch(thres{2}),
            case 1, THR_TYPE=1; %'vox-unc',
            case 2, THR_TYPE=3; %'fdr-all'
            case 3, THR_TYPE=4;%'T/F/X stat',
        end
        THR=thres{1};
        SIDE=side;
        if isempty(SIM)||~any(SIM.Pthr==THR&SIM.Pthr_type==THR_TYPE&SIM.Pthr_side==SIDE)
            if ~isempty(dir(conn_vproject_simfilename(spmfile,THR_TYPE,THR)))||((thres4~=1&&thres4~=8)&&conn_vproject_randomise(spmfile,THR_TYPE,THR,init~=1)),
                SIM=load(conn_vproject_simfilename(spmfile,THR_TYPE,THR));
            end
        end
        if ~isempty(SIM)&&any(SIM.Pthr==THR&SIM.Pthr_type==THR_TYPE&SIM.Pthr_side==SIDE), iPERM=find(SIM.Pthr==THR&SIM.Pthr_type==THR_TYPE&SIM.Pthr_side==SIDE,1);
        else iPERM=[];
        end
    end
    for n1=1:length(idx1),
        k(n1)=idxn(sidxn(n1));
        clusters{n1}=idxvoxels(idx2{sidxn(n1)});
        if side==1, [nill,idxminp]=max(Z(clusters{n1}));
        elseif side==2, [nill,idxminp]=max(-Z(clusters{n1}));
        else [nill,idxminp]=max(abs(Z(clusters{n1}))); 
        end
        minp(n1)=p0(clusters{n1}(idxminp));
        %[minp(n1),idxminp]=min(p0(clusters{n1}));
        minP(n1)=P(clusters{n1}(idxminp));
        maxZ(n1)=Z(clusters{n1}(idxminp));
        if side==2, maxZ(n1)=-maxZ(n1);
        elseif side==3, maxZ(n1)=abs(maxZ(n1)); 
        end
        kmass(n1)=sum(abs(Z(clusters{n1})));
        %kmass(n1)=sum(abs(Z(clusters{n1}))-ithres(1));
        %[minP(n1),idxminp]=min(P(clusters{n1}));
        %minp(n1)=exp(-max(a(clusters{n1})));
        xyzpeak{n1}=xyz(idx2{sidxn(n1)}(idxminp),:);
        if parametric==1 % parametric stats
            if ~isempty(mat{2}),
                if mat{6}=='T'&&side<3, %T stat
                    try
                        if isempty(mat{5}), [cP(n1),cp(n1)]=spm_P(1,k(n1)*mat{2}(end)/mat{4},u,mat{3},'T',mat{2},1,mat{4});
                        else, [cP(n1),cp(n1)]=spm_P(1,k(n1)*mat{5},u,mat{3},'T',mat{2},1,mat{4});
                            if isnan(cP(n1))&&~cp(n1),cP(n1)=0; end
                        end
                    catch
                        cP(n1)=nan; cp(n1)=nan;
                    end
                    try
                        pPFWE(n1)=spm_P(1,0,maxZ(n1),mat{3},'T',mat{2},1,mat{4});
                    catch
                        pPFWE(n1)=nan;
                    end
                elseif mat{6}=='T'|mat{6}=='F', % two-sided T-stat or F-stat
                    ok=false;
                    if isdeployed||str2num(regexprep(spm('ver'),'[^\d]',''))>8,
                        try
                            if isempty(mat{5}), [cP(n1),cp(n1)]=spm_P(1,k(n1)*mat{2}(end)/mat{4},u,mat{3},'F',mat{2},1,mat{4});
                            else, [cP(n1),cp(n1)]=spm_P(1,k(n1)*mat{5},u,mat{3},'F',mat{2},1,mat{4});
                                if isnan(cP(n1))&&~cp(n1),cP(n1)=0; end
                            end
                            ok=true;
                        end
                    end
                    if ~ok
                        try
                            if isempty(mat{5}), [nill,cP(n1),nill,cp(n1)] =stat_thres(mat{2},mat{4},mat{7},[mat{3};inf,inf], .05, u, k(n1)*mat{2}(end)/mat{4});
                            else, [nill,cP(n1),nill,cp(n1)] =stat_thres(mat{2},mat{4},mat{7},[mat{3};inf,inf], .05, u, k(n1)*mat{5});
                                if isnan(cP(n1))&&~cp(n1),cP(n1)=0; end
                            end
                        catch
                            cP(n1)=nan; cp(n1)=nan;
                        end
                    end
                    try
                        if mat{6}=='T'&&side==3, %two-sided T stat
                            pPFWE(n1)=spm_P(1,0,maxZ(n1).^2,mat{3},'F',mat{2},1,mat{4});
                        else
                            pPFWE(n1)=spm_P(1,0,maxZ(n1),mat{3},'F',mat{2},1,mat{4});
                        end
                    catch
                        pPFWE(n1)=nan;
                    end
                else
                    cP(n1)=nan; cp(n1)=nan; pPFWE(n1)=nan;
                end
            else 
                cP(n1)=nan;cp(n1)=nan; pPFWE(n1)=nan;
            end
            cpmass(n1)=nan; cPmass(n1)=nan; 
        else % non-parametric stats
            nclL=k(n1);
            mclL=kmass(n1);
            if ~isempty(iPERM)
                if nnz(SIM.Hist_Cluster_size{iPERM})<2, PERMp_cluster_size_unc=double(1+nclL<=find(SIM.Hist_Cluster_size{iPERM}));
                else PERMp_cluster_size_unc=max(0,min(1,interp1(find(SIM.Hist_Cluster_size{iPERM}),flipud(cumsum(flipud(nonzeros(SIM.Hist_Cluster_size{iPERM})))),1+nclL,'linear','extrap')));
                end
                %PERMp_cluster_size_FDR=conn_fdr(PERMp_cluster_size_unc);
                PERMp_cluster_size_FWE=mean(conn_bsxfun(@ge,SIM.Dist_Cluster_sizemax{iPERM}',nclL),2);
                if nnz(SIM.Hist_Cluster_mass{iPERM})<2, PERMp_cluster_mass_unc=double(1+round(SIM.maxT*mclL)<=find(SIM.Hist_Cluster_mass{iPERM}));
                else PERMp_cluster_mass_unc=max(0,min(1,interp1(find(SIM.Hist_Cluster_mass{iPERM}),flipud(cumsum(flipud(nonzeros(SIM.Hist_Cluster_mass{iPERM})))),1+round(SIM.maxT*mclL),'linear','extrap')));
                end
                %PERMp_cluster_mass_FDR=conn_fdr(PERMp_cluster_mass_unc);
                PERMp_cluster_mass_FWE=mean(conn_bsxfun(@ge,SIM.Dist_Cluster_massmax{iPERM}',mclL),2);
                cP(n1)=PERMp_cluster_size_FWE;
                cp(n1)=PERMp_cluster_size_unc;
                cPmass(n1)=PERMp_cluster_mass_FWE;
                cpmass(n1)=PERMp_cluster_mass_unc;
            else
                doneall=false;
                cP(n1)=nan;cp(n1)=nan; cPmass(n1)=nan;cpmass(n1)=nan;
            end
            pPFWE(n1)=nan;
        end
    end
    if peakfdr>0,
        try
            if peakfdr==1, % consider all peak voxels for peak-FDR correction
                if side==2, tZ=-Z(idxvoxels); else tZ=Z(idxvoxels); end
                mtZ=min(tZ);
                [maxN,maxZ,maxXYZ,maxA]=spm_max(1-mtZ+tZ,xyz'); 
                maxZ=maxZ+mtZ-1;
                [maxOK,maxI]=min(sum(abs(conn_bsxfun(@minus,permute(maxXYZ',[1,3,2]),permute(cell2mat(xyzpeak'),[3,1,2]))).^2,3),[],1);
            else % consider only onepeak voxel within each cluster for peak-FDR correction
                maxI=1:numel(maxZ);
            end
            Ez=nan(size(maxZ));
            if mat{6}=='T'&&side<3,
                [nill,nill,Eu] = spm_P_RF(1,0,u,mat{3},'T',mat{2},1);
                for n1=1:numel(maxZ)
                    [nill,nill,Ez(n1)] = spm_P_RF(1,0,maxZ(n1),mat{3},'T',mat{2},1);
                end
            elseif mat{6}=='T'&&side==3,
                [nill,nill,Eu] = spm_P_RF(1,0,u,mat{3},'F',mat{2},1);
                for n1=1:numel(maxZ)
                    [nill,nill,Ez(n1)] = spm_P_RF(1,0,maxZ(n1).^2,mat{3},'F',mat{2},1);
                end
            elseif mat{6}=='F',
                [nill,nill,Eu] = spm_P_RF(1,0,u,mat{3},'F',mat{2},1);
                for n1=1:numel(maxZ)
                    [nill,nill,Ez(n1)] = spm_P_RF(1,0,maxZ(n1),mat{3},'F',mat{2},1);
                end
            else Eu=Ez;
            end
            pPFDR=conn_fdr(Ez/Eu);
            pPFDR=pPFDR(maxI);
            maxZ=maxZ(maxI);
        catch
            pPFDR=nan(size(k));
        end
    end
    cPFDR=conn_fdr(cp); 
    cPFDRmass=conn_fdr(cpmass);
    for n1=1:length(idx1),
        %temp=['( ',sprintf('%+03.0f ',(mat{1}(1:3,:)*[xyzpeak{n1}';1])'),') '];
        temp=[sprintf('%+03.0f ',(mat{1}(1:3,:)*[xyzpeak{n1}';1])')];
        cluster_stats{end+1}=sprintf('%s  k = %d  p = %.6f',temp,k(n1),cp(n1));
        temp=[temp,repmat(' ',[1,max(0,15-length(temp))])];
        if peakfdr>0,
            txt=strvcat(txt,[...
                temp,...
                [sprintf('%13d',k(n1))],...
                [sprintf('%13f',cP(n1))],...
                [sprintf('%13f',cPFDR(n1))],...
                [sprintf('%13f',cp(n1))],...
                [sprintf('%13f',pPFWE(n1))],...
                [sprintf('%13f',pPFDR(n1))],...
                [sprintf('%13f',minp(n1))]]);
            %[sprintf('%15f',minP(n1))]]);
        elseif parametric==1
            txt=strvcat(txt,[...
                temp,...
                [sprintf('%13d',k(n1))],...
                [sprintf('%13f',cP(n1))],...
                [sprintf('%13f',cPFDR(n1))],...
                [sprintf('%13f',cp(n1))],...
                [sprintf('%13f',pPFWE(n1))],...
                [sprintf('%13f',minp(n1))]]);
        else
            txt=strvcat(txt,[...
                temp,...
                [sprintf('%13d',k(n1))],...
                [sprintf('%13f',cP(n1))],...
                [sprintf('%13f',cPFDR(n1))],...
                [sprintf('%13f',cp(n1))],...
                [sprintf('%13.2f',kmass(n1))],...
                [sprintf('%13f',cPmass(n1))],...
                [sprintf('%13f',cPFDRmass(n1))],...
                [sprintf('%13f',cpmass(n1))]]);
        end
    end
    switch(thres4),
        case 1,%'k-value',
            idxclu=find(k>=thres{3});
            idxrem=find(~(k>=thres{3}));
        case 2,%'clu-FWE',
            idxclu=find(cP<thres{3});
            idxrem=find(~(cP<thres{3}));
        case 3,%'clu-FDR',
            idxclu=find(cPFDR<thres{3});
            idxrem=find(~(cPFDR<thres{3}));
        case 4,%'clu-unc',
            idxclu=find(cp<thres{3});
            idxrem=find(~(cp<thres{3}));
        case 5,%'peak-FWE',
            idxclu=find(pPFWE<thres{3});
            idxrem=find(~(pPFWE<thres{3}));
        case 6,%'peak-FDR',
            idxclu=find(pPFDR<thres{3});
            idxrem=find(~(pPFDR<thres{3}));
        case 7,%'peak-unc',
            idxclu=find(minp<thres{3});
            idxrem=find(~(minp<thres{3}));
        case 8,%'mass-value',
            idxclu=find(kmass>=thres{3});
            idxrem=find(~(kmass>=thres{3}));
        case 9,%'mass clu-FWE',
            idxclu=find(cPmass<thres{3});
            idxrem=find(~(cPmass<thres{3}));
        case 10,%'mass clu-FDR',
            idxclu=find(cPFDRmass<thres{3});
            idxrem=find(~(cPFDRmass<thres{3}));
        case 11,%'mass clu-unc',
            idxclu=find(cpmass<thres{3});
            idxrem=find(~(cpmass<thres{3}));
    end
    if ~isempty(idxclu), ithres(2)=min(k(idxclu)); end
    for n1=1:length(idxrem), anew(clusters{idxrem(n1)})=0; end
    txt=txt(idxclu,:);
    if ~isempty(txt), txt=char(regexprep(cellstr(txt),'NaN','---')); end
    xyzpeak={xyzpeak{idxclu}};
    clusters={clusters{idxclu}};
    cluster_stats={cluster_stats{idxclu}};
    if ~isempty(idxclu),
        for n1=1:length(idxclu)+1,
            if n1<=length(idxclu),xyztemp=xyz(idx2{sidxn(idxclu(n1))},:);
            else, xyztemp=xyz(cat(2,idx2{sidxn(idxclu)}),:); end;
            v=spm_get_data(refsrois.V,pinv(refsrois.V.mat)*mat{1}*[xyztemp,ones(size(xyztemp,1),1)]');
            uv=unique(v);
            clusternames{n1}.uvb=zeros(1,length(uv));for n2=1:length(uv),clusternames{n1}.uvb(n2)=sum(v==uv(n2));end
            clusternames{n1}.uvc=refsrois.count(1+uv);
            clusternames{n1}.uvd={refsrois.labels{1+uv}};
            [nill,uvidx]=sort(-clusternames{n1}.uvb+1e10*(uv==0));
            clusternames{n1}.uvb=clusternames{n1}.uvb(uvidx);clusternames{n1}.uvc=clusternames{n1}.uvc(uvidx);clusternames{n1}.uvd={clusternames{n1}.uvd{uvidx}};
            clusternames{n1}.txt=cell(1,length(uv)); for n2=1:length(uv),clusternames{n1}.txt{n2}=[num2str(clusternames{n1}.uvb(n2)),' voxels covering ',num2str(clusternames{n1}.uvb(n2)/clusternames{n1}.uvc(n2)*100,'%0.0f'),'% of ',refsrois.filenameshort,'.',clusternames{n1}.uvd{n2}]; end
            clusternames{n1}.txt=strvcat(clusternames{n1}.txt{:});
        end
    end
%     clusternames={clusternames{idxclu,1},clusternames{idxclu(idxclulast),2}};
    %for n1=1:length(clusternames),disp(' ');disp(clusternames{n1}.txt);end
    if ~doneall&&(thres4~=1&&thres4~=8), txt=strvcat('Cluster threshold information unavailable. Please compute non-parametric statatistics',txt); end
end

%if params.plotlist, figure('color','w'); end
%h=[];xlim=[];ylim=[];
%disp(txt);

%     if params.permutation && ~isempty(params.L),
%         txt{end}=[txt{end},'  p=',num2str(mean(params.L(:,1)>=k),'%0.4f'),' (',num2str(length(unique(params.L(params.L(:,1)>=k,2)))/params.Ln,'%0.4f'),')'];
%     end
%     if params.plotlist,
%         %subplot(length(idx1),1,n1);
%         h(n1)=axes('units','norm','position',...
%             [.9,.5*(1-n1/max(length(idx1)+1,5)+.05/max(length(idx1)+1,5)),.09,.5*.9/max(length(idx1)+1,5)]);
%         mx1=mean(X1(:,idx(idx2{sidxn(n1)})),2);
%         mx2=mean(X2(:,idx(idx2{sidxn(n1)})),2);
%         plot(mx1,mx2,'.'); h0=ylabel(txt{end});set(h0,'fontsize',8+CONN_gui.font_offset,'rotation',0,'horizontalalignment','right')
%         params.output.clusters{n1}=[mx1,mx2];
%         xlim=cat(1,xlim,[min(mx1),max(mx1)]);ylim=cat(1,ylim,[min(mx2),max(mx2)]);
%     end
%   end
%if params.plotlist,
%    for n1=1:length(idx1),
%        set(h(n1),'xlim',[min(xlim(:,1))-.01,max(xlim(:,2))+.01],'ylim',[min(ylim(:,1))-.01,max(ylim(:,2))+.01]);
%        if n1~=length(idx1), set(h(n1),'xticklabel',[],'yticklabel',[],'fontsize',6); end
%    end
%end
end

function [peak_threshold, extent_threshold, peak_threshold_1, extent_threshold_1] = ...
   stat_thres(search_volume, num_voxels, fwhm, df, p_val_peak, ...
   cluster_threshold, p_val_extent, nconj, nvar, EC_file, expr)
%
% stat_thresh.m
% Modified version of STAT_THRESHOLD function by Keith Worsley. The original
% STAT_THRESHOLD function is part of the FMRISTAT packgage. The main use of the
% original version is to calculate peak and cluster thresholds, both corrected
% and uncorrected. Details on input and output arguments are found in the
% original STAT_THRESHOLD function available from Keith Worsley's web site
% at McGill University's Math & Stat department. 
%
% This stat_thresh.m function is a customized version to be called by a function
% spm_list_nS for non-stationarity correction of RFT-based cluster size test.
% The input and output of this function is therefore modified for producing cluster
% p-values (corrected) under non-stationarity. The modification includes:
%   -supressing the output from being displayed.
%   -the number of cluster p-values it can calculate has been increased to 500 clusters
%    (the default in the original version was 5).
%   -the p_val_extent is treated as extent, no matter how small it is.
%
% stat_thresh is called by spm_list_nS in the following format:
% [PEAK_P CLUSTER_P PEAK_P_1 CLUSTER_P_1] = 
%    stat_thresh(V_RESEL,NUM_VOX,1,[DF_ER;DF_RPV],ALPHA,CL_DEF_TH,CL_RESEL);
% PARAMETERS:
%    V_RESEL:      The seach volume in terms of resels. It is a 1x4 vector
%                  describing the topological characteristic of the search
%                  volume.
%    NUM_VOX:      The number of voxels in the search volume.
%    DF_ER:        Degrees of freedom of error
%    DF_RPV:       Degrees of freedom of RPV image estimation. Usually the same
%                  as the error df.
%    ALPHA:        The significance level of the peak (arbitrarily set to 0.05) 
%    CL_DEF_TH:    The cluster defining threshold. Can be entered in terms of
%                  a p-value (uncorrected) or a t-value.
%    CL_RESEL:     The cluster size in terms of resel
%
%    PEAK_P:       Peak p-value (FWE corrected). Not used for our purpose.
%    PEAK_P_1:     Peak p-value (uncorrected). Not used for our purpose.
%    CLUSTER_P:    Cluster p-value (FWE corrected)
%    CLUSTER_P_1:  Cluster p-value (uncorrected)
%    
%                           ----------------
%
% More etails on non-stationary cluster size test can be found in
%
% Worsley K J, Andermann M, Koulis T, MacDonald D and Evans A C
%   Detecting Changes in Nonisotropic Images
%   Human Brain Mapping 8: 98-101 (1999)
%
% Hayasaka S, Phan K L, Liberzon I, Worsley K J, and Nichols T E
%   Nonstationary cluster size inference with random-field and permutation methods
%   NeuroImage 22: 676-687 (2004)
%
%
%-----------------------------------------------------------------------------------
% Version 0.76b   Feb 19, 2007  by Satoru Hayasaka
%

%############################################################################
% COPYRIGHT:   Copyright 2003 K.J. Worsley 
%              Department of Mathematics and Statistics,
%              McConnell Brain Imaging Center, 
%              Montreal Neurological Institute,
%              McGill University, Montreal, Quebec, Canada. 
%              keith.worsley@mcgill.ca , www.math.mcgill.ca/keith
%
%              Permission to use, copy, modify, and distribute this
%              software and its documentation for any purpose and without
%              fee is hereby granted, provided that this copyright
%              notice appears in all copies. The author and McGill University
%              make no representations about the suitability of this
%              software for any purpose.  It is provided "as is" without
%              express or implied warranty.
%############################################################################

%############################################################################
% UPDATES:
%
%          Variable nvar is rounded so that it is recognized as an integer.
%          Feb 19, 2007 by Satoru Hayasaka
%############################################################################


% Defaults:
if nargin<1;  search_volume=[];  end
if nargin<2;  num_voxels=[];  end
if nargin<3;  fwhm=[];  end
if nargin<4;  df=[];  end
if nargin<5;  p_val_peak=[];  end
if nargin<6;  cluster_threshold=[];  end
if nargin<7;  p_val_extent=[];  end
if nargin<8;  nconj=[];  end
if nargin<9;  nvar=[];  end
if nargin<10;  EC_file=[];  end
if nargin<11;  expr=[];  end

if isempty(search_volume);  search_volume=1000000;  end
if isempty(num_voxels);  num_voxels=1000000;  end
if isempty(fwhm);  fwhm=0.0;  end
if isempty(df);  df=Inf;  end
if isempty(p_val_peak);  p_val_peak=0.05;  end
if isempty(cluster_threshold);  cluster_threshold=0.001;  end
if isempty(p_val_extent);  p_val_extent=0.05;  end
if isempty(nconj);  nconj=1;  end
if isempty(nvar);  nvar=1;  end

if size(fwhm,1)==1; fwhm(2,:)=fwhm; end
if size(fwhm,2)==1; scale=1; else scale=fwhm(1,2)/fwhm(1,1); fwhm=fwhm(:,1); end;
isscale=(scale>1); 

if length(num_voxels)==1; num_voxels(2,1)=1; end

if size(search_volume,2)==1
   radius=(search_volume/(4/3*pi)).^(1/3);
   search_volume=[ones(length(radius),1) 4*radius 2*pi*radius.^2 search_volume];
end
if size(search_volume,1)==1
   search_volume=[search_volume; [1 zeros(1,size(search_volume,2)-1)]];
end
lsv=size(search_volume,2);
fwhm_inv=all(fwhm>0)./(fwhm+any(fwhm<=0));
resels=search_volume.*repmat(fwhm_inv,1,lsv).^repmat(0:lsv-1,2,1);
invol=resels.*(4*log(2)).^(repmat(0:lsv-1,2,1)/2);
for k=1:2
   D(k,1)=max(find(invol(k,:)))-1;
end

% determines which method was used to estimate fwhm (see fmrilm or multistat): 
df_limit=4;

% max number of pvalues or thresholds to print:
% it can print out a ton of stuff! (the original default was 5)
nprint=500;

if length(df)==1; df=[df 0]; end
if size(df,1)==1; df=[df; Inf Inf]; end
if size(df,2)==1; df=[df [0; df(2,1)]]; end

% is_tstat=1 if it is a t statistic
is_tstat=(df(1,2)==0);
if is_tstat
   df1=1;
   df2=df(1,1);
else
   df1=df(1,1);
   df2=df(1,2);
end
if df2 >= 1000; df2=Inf; end
df0=df1+df2;

dfw1=df(2,1);
dfw2=df(2,2);
if dfw1 >= 1000; dfw1=Inf; end
if dfw2 >= 1000; dfw2=Inf; end

if length(nvar)==1; nvar(2,1)=df1; end
nvar = round(nvar); %-to make sure that nvar is integer!

if isscale & (D(2)>1 | nvar(1,1)>1 | df2<Inf)
   D
   nvar
   df2
   fprintf('Cannot do scale space.');
   return
end

Dlim=D+[scale>1; 0];
DD=Dlim+nvar-1;

% Values of the F statistic:
t=((1000:-1:1)'/100).^4;
% Find the upper tail probs cumulating the F density using Simpson's rule:
if df2==Inf
   u=df1*t;
   b=exp(-u/2-log(2*pi)/2+log(u)/4)*df1^(1/4)*4/100;
else  
   u=df1*t/df2;
   b=exp(-df0/2*log(1+u)+log(u)/4-betaln(1/2,(df0-1)/2))*(df1/df2)^(1/4)*4/100;
end
t=[t; 0];
b=[b; 0];
n=length(t);
sb=cumsum(b);
sb1=cumsum(b.*(-1).^(1:n)');
pt1=sb+sb1/3-b/3;
pt2=sb-sb1/3-b/3;
tau=zeros(n,DD(1)+1,DD(2)+1);
tau(1:2:n,1,1)=pt1(1:2:n);
tau(2:2:n,1,1)=pt2(2:2:n);
tau(n,1,1)=1;
tau(:,1,1)=min(tau(:,1,1),1);

% Find the EC densities:
u=df1*t;
 kk=(max(DD)-1+min(DD))/2;
 uu=conn_bsxfun(@power,u,0:.5:kk);
 [ii,jj]=ndgrid(0:kk,0:kk);
 gammalnii=gammalni(0:max(DD)+kk);
for d=1:max(DD)
   for e=0:min(min(DD),d)
      s1=0;
      cons=-((d+e)/2+1)*log(pi)+gammaln(d)+gammaln(e+1);
      for k=0:(d-1+e)/2
         %[i,j]=ndgrid(0:k,0:k);
         i=ii(1:k+1,1:k+1); j=jj(1:k+1,1:k+1);
         if df2==Inf
            q1=log(pi)/2-((d+e-1)/2+i+j)*log(2);
         else
            q1=(df0-1-d-e)*log(2)+gammaln((df0-d)/2+i)+gammaln((df0-e)/2+j) ...
               -gammalni(df0-d-e+i+j+k)-((d+e-1)/2-k)*log(df2);
         end
         %q2=cons-gammalni(i+1)-gammalni(j+1)-gammalni(k-i-j+1) ...
         %   -gammalni(d-k-i+j)-gammalni(e-k-j+i+1);
         q2=cons-gammalnii(1+max(0,i+1))-gammalnii(1+max(0,j+1))-gammalnii(1+max(0,k-i-j+1)) ...
            -gammalnii(1+max(0,d-k-i+j))-gammalnii(1+max(0,e-k-j+i+1));
         s2=sum(sum(exp(q1+q2)));
         if s2>0
            %s1=s1+(-1)^k*u.^((d+e-1)/2-k)*s2;
            s1=s1+(-1)^k*uu(:,1+2*((d+e-1)/2-k))*s2;
         end
      end
      if df2==Inf
         s1=s1.*exp(-u/2);
      else
         s1=s1.*exp(-(df0-2)/2*log(1+u/df2));
      end
      if DD(1)>=DD(2)
         tau(:,d+1,e+1)=s1;
         if d<=min(DD)
            tau(:,e+1,d+1)=s1;
         end
      else
         tau(:,e+1,d+1)=s1;      
         if d<=min(DD)
            tau(:,d+1,e+1)=s1;
         end
      end
   end
end

% For multivariate statistics, add a sphere to the search region:
a=zeros(2,max(nvar));
for k=1:2
   j=(nvar(k)-1):-2:0;
   a(k,j+1)=exp(j*log(2)+j/2*log(pi) ...
      +gammaln((nvar(k)+1)/2)-gammaln((nvar(k)+1-j)/2)-gammaln(j+1));
end
rho=zeros(n,Dlim(1)+1,Dlim(2)+1);
for k=1:nvar(1)
   for l=1:nvar(2)
      rho=rho+a(1,k)*a(2,l)*tau(:,(0:Dlim(1))+k,(0:Dlim(2))+l);
   end
end

if is_tstat
   t=[sqrt(t(1:(n-1))); -flipdim(sqrt(t),1)];
   rho=[rho(1:(n-1),:,:); flipdim(rho,1)]/2;
   for i=0:D(1)
      for j=0:D(2)
         rho(n-1+(1:n),i+1,j+1)=-(-1)^(i+j)*rho(n-1+(1:n),i+1,j+1);
      end
   end
   rho(n-1+(1:n),1,1)=rho(n-1+(1:n),1,1)+1;
   n=2*n-1;
end

% For scale space:
if scale>1
   kappa=D(1)/2;
   tau=zeros(n,D(1)+1);
   for d=0:D(1)
      s1=0;
      for k=0:d/2
         s1=s1+(-1)^k/(1-2*k)*exp(gammaln(d+1)-gammaln(k+1)-gammaln(d-2*k+1) ...
            +(1/2-k)*log(kappa)-k*log(4*pi))*rho(:,d+2-2*k,1);
      end
      if d==0
         cons=log(scale);
      else
         cons=(1-1/scale^d)/d;
      end
      tau(:,d+1)=rho(:,d+1,1)*(1+1/scale^d)/2+s1*cons;
   end
   rho(:,1:(D(1)+1),1)=tau;
end

if D(2)==0
   d=D(1);
   if nconj>1
      % Conjunctions:
      b=gamma(((0:d)+1)/2)/gamma(1/2);
      for i=1:d+1
         rho(:,i,1)=rho(:,i,1)/b(i);
      end
      m1=zeros(n,d+1,d+1);
      for i=1:d+1
         j=i:d+1;
         m1(:,i,j)=rho(:,j-i+1,1);
      end
      for k=2:nconj
         for i=1:d+1
            for j=1:d+1
               m2(:,i,j)=sum(rho(:,1:d+2-i,1).*m1(:,i:d+1,j),2);
            end
         end
         m1=m2;
      end
      for i=1:d+1
         rho(:,i,1)=m1(:,1,i)*b(i);
      end
   end
   
   if ~isempty(EC_file)
      if d<3
         rho(:,(d+2):4,1)=zeros(n,4-d-2+1);
      end
      fid=fopen(EC_file,'w');
      % first 3 are dimension sizes as 4-byte integers:
      fwrite(fid,[n max(d+2,5) 1],'int');
      % next 6 are bounding box as 4-byte floats: 
      fwrite(fid,[0 0 0; 1 1 1],'float');
      % rest are the data as 4-byte floats:
      if ~isempty(expr)
         eval(expr);
      end
      fwrite(fid,t,'float');
      fwrite(fid,rho,'float');
      fclose(fid);
   end
end

if all(fwhm>0)
   pval_rf=zeros(n,1);
   for i=1:D(1)+1
      for j=1:D(2)+1
         pval_rf=pval_rf+invol(1,i)*invol(2,j)*rho(:,i,j);
      end
   end
else
   pval_rf=Inf;
end

% Bonferroni 
pt=rho(:,1,1);
pval_bon=abs(prod(num_voxels))*pt;

% Minimum of the two:
pval=min(pval_rf,pval_bon);

tlim=1;
if p_val_peak(1) <= tlim
   peak_threshold=minterp1(pval,t,p_val_peak);
   if length(p_val_peak)<=nprint
      peak_threshold;
   end
else
   % p_val_peak is treated as a peak value:
   P_val_peak=interp1(t,pval,p_val_peak);
   peak_threshold=P_val_peak;
   if length(p_val_peak)<=nprint
      P_val_peak;
   end
end

if fwhm<=0 | any(num_voxels<0)
   peak_threshold_1=p_val_peak+NaN;
   extent_threshold=p_val_extent+NaN;
   extent_threshold_1=extent_threshold;
   return
end

% Cluster_threshold:
%###-Changed so that cluster_threshold is considered as cluster extent no matter what.
if cluster_threshold > eps
   tt=cluster_threshold;
else
   % cluster_threshold is treated as a probability:
   tt=minterp1(pt,t,cluster_threshold);
   Cluster_threshold=tt;
end

d=D(1);
rhoD=interp1(t,rho(:,d+1,1),tt);
p=interp1(t,pt,tt);

% Pre-selected peak:

pval=rho(:,d+1,1)./rhoD;
if p_val_peak(1) <= tlim 
   peak_threshold_1=minterp1(pval,t, p_val_peak);
   if length(p_val_peak)<=nprint
      peak_threshold_1;
   end
else
   % p_val_peak is treated as a peak value:
   P_val_peak_1=interp1(t,pval,p_val_peak);
   peak_threshold_1=P_val_peak_1;
   if length(p_val_peak)<=nprint
      P_val_peak_1;
   end
end

if  D(1)==0 | nconj>1 | nvar(1)>1 | D(2)>0 | scale>1
    extent_threshold=p_val_extent+NaN;
    extent_threshold_1=extent_threshold;
    if length(p_val_extent)<=nprint
       extent_threshold;
       extent_threshold_1;
    end
    return
end

% Expected number of clusters:

%###-Change tlim to a small number so that p_val_extent is considered as cluster extent
tlim = eps;

EL=invol(1,d+1)*rhoD;
cons=gamma(d/2+1)*(4*log(2))^(d/2)/fwhm(1)^d*rhoD/p;

if df2==Inf & dfw1==Inf
   if p_val_extent(1) <= tlim 
      pS=-log(1-p_val_extent)/EL;
      extent_threshold=(-log(pS)).^(d/2)/cons;
      pS=-log(1-p_val_extent);
      extent_threshold_1=(-log(pS)).^(d/2)/cons;
      if length(p_val_extent)<=nprint
         extent_threshold;
         extent_threshold_1;
      end
   else
      % p_val_extent is now treated as a spatial extent:
      pS=exp(-(p_val_extent*cons).^(2/d));
      P_val_extent=1-exp(-pS*EL);
      extent_threshold=P_val_extent;
      P_val_extent_1=1-exp(-pS);
      extent_threshold_1=P_val_extent_1;
      if length(p_val_extent)<=nprint
         P_val_extent;
         P_val_extent_1;
      end
   end
else
   % Find dbn of S by taking logs then using fft for convolution:
   ny=2^12;
   a=d/2;
   b2=a*10*max(sqrt(2/(min(df1+df2,dfw1))),1);
   if df2<Inf
      b1=a*log((1-(1-0.000001)^(2/(df2-d)))*df2/2);
   else
      b1=a*log(-log(1-0.000001));
   end
   dy=(b2-b1)/ny;
   b1=round(b1/dy)*dy;
   y=((1:ny)'-1)*dy+b1;
   numrv=1+(d+1)*(df2<Inf)+d*(dfw1<Inf)+(dfw2<Inf);
   f=zeros(ny,numrv);
   mu=zeros(1,numrv);
   if df2<Inf
      % Density of log(Beta(1,(df2-d)/2)^(d/2)):
      yy=exp(y./a)/df2*2;  
      yy=yy.*(yy<1);
      f(:,1)=(1-yy).^((df2-d)/2-1).*((df2-d)/2).*yy/a;
      mu(1)=exp(gammaln(a+1)+gammaln((df2-d+2)/2)-gammaln((df2+2)/2)+a*log(df2/2));
   else
      % Density of log(exp(1)^(d/2)):
      yy=exp(y./a);   
      f(:,1)=exp(-yy).*yy/a;
      mu(1)=exp(gammaln(a+1));
   end
   
   nuv=[];
   aav=[];
   if df2<Inf
      nuv=[df1+df2-d  df2+2-(1:d)];
      aav=[a repmat(-1/2,1,d)]; 
   end
   if dfw1<Inf
      if dfw1>df_limit
         nuv=[nuv dfw1-dfw1/dfw2-(0:(d-1))];
      else
         nuv=[nuv repmat(dfw1-dfw1/dfw2,1,d)];
      end
      aav=[aav repmat(1/2,1,d)];
   end   
   if dfw2<Inf
      nuv=[nuv dfw2];
      aav=[aav -a];
   end   
   
   for i=1:(numrv-1)
      nu=nuv(i);
      aa=aav(i);
      yy=y/aa+log(nu);
      % Density of log((chi^2_nu/nu)^aa):
      f(:,i+1)=exp(nu/2*yy-exp(yy)/2-(nu/2)*log(2)-gammaln(nu/2))/abs(aa);
      mu(i+1)=exp(gammaln(nu/2+aa)-gammaln(nu/2)-aa*log(nu/2));
   end
   % Check: plot(y,f); sum(f*dy,1) should be 1
      
   omega=2*pi*((1:ny)'-1)/ny/dy;
   shift=complex(cos(-b1*omega),sin(-b1*omega))*dy;
   prodfft=prod(fft(f),2).*shift.^(numrv-1);
   % Density of Y=log(B^(d/2)*U^(d/2)/sqrt(det(Q))):
   ff=real(ifft(prodfft));
   % Check: plot(y,ff); sum(ff*dy) should be 1
   mu0=prod(mu);
   % Check: plot(y,ff.*exp(y)); sum(ff.*exp(y)*dy.*(y<10)) should equal mu0   
   
   alpha=p/rhoD/mu0*fwhm(1)^d/(4*log(2))^(d/2);
   
   % Integrate the density to get the p-value for one cluster: 
   pS=cumsum(ff(ny:-1:1))*dy;
   pS=pS(ny:-1:1);
   % The number of clusters is Poisson with mean EL:
   pSmax=1-exp(-pS*EL);
   
   if p_val_extent(1) <= tlim 
      yval=minterp1(-pSmax,y,-p_val_extent);
      % Spatial extent is alpha*exp(Y) -dy/2 correction for mid-point rule:
      extent_threshold=alpha*exp(yval-dy/2);
      % For a single cluster:
      yval=minterp1(-pS,y,-p_val_extent);
      extent_threshold_1=alpha*exp(yval-dy/2);
      if length(p_val_extent)<=nprint
         extent_threshold;
         extent_threshold_1;
      end
   else
      % p_val_extent is now treated as a spatial extent:
      P_val_extent=interp1(y,pSmax,log(p_val_extent/alpha)+dy/2);
      extent_threshold=P_val_extent;
      % For a single cluster:
      P_val_extent_1=interp1(y,pS,log(p_val_extent/alpha)+dy/2);
      extent_threshold_1=P_val_extent_1;
      if length(p_val_extent)<=nprint
         P_val_extent;
         P_val_extent_1;
      end
   end
   
end
   
return
end

function x=gammalni(n)
i=find(n>=0);
x=Inf+n;
if ~isempty(i)
   x(i)=gammaln(n(i));
end
return
end

function iy=minterp1(x,y,ix)
% interpolates only the monotonically increasing values of x at ix
n=length(x);
mx=x(1);
my=y(1);
xx=x(1);
for i=2:n
   if x(i)>xx
      xx=x(i);
      mx=[mx xx];
      my=[my y(i)];
   end
end
iy=interp1(mx,my,ix);
return
end

function [filename_rois,filename_sources,viewrex]=conn_vproject_selectfiles(filename_rois,filename_sources,viewrex)
global CONN_gui;
if isempty(CONN_gui)||~isfield(CONN_gui,'font_offset'), CONN_gui.font_offset=0; end

filename_rois0=filename_rois;
filename_sources0=filename_sources;
thfig=dialog('units','norm','position',[.3,.4,.4,.25],'windowstyle','normal','name','REX interface','color','w','resize','on');
uicontrol(thfig,'style','text','units','norm','position',[.1,.75,.8,.20],'string',{'Extract average connectivity values','(effect sizes) from clusters of interest'},'backgroundcolor','w','fontsize',9+CONN_gui.font_offset,'fontweight','bold');
ht1=uicontrol(thfig,'style','popupmenu','units','norm','position',[.1,.55,.8,.15],'string',{'clusters of interest in current analysis','others clusters of interest (select mask/ROI file)'},'fontsize',8+CONN_gui.font_offset,'horizontalalignment','left','callback',@conn_vproject_selectfiles_callback1,'tooltipstring','Define the clusters of interest');
ht2=uicontrol(thfig,'style','popupmenu','units','norm','position',[.1,.40,.8,.15],'string',{'connectivity values in current analysis','other connectivity values (select second-level SPM.mat file)'},'fontsize',8+CONN_gui.font_offset,'horizontalalignment','left','callback',@conn_vproject_selectfiles_callback2,'tooltipstring','Define the connectivity values');
if ~isempty(viewrex), ht3=uicontrol(thfig,'style','checkbox','units','norm','position',[.1,.3,.8,.1],'string','enable REX gui','value',0,'fontsize',8+CONN_gui.font_offset,'horizontalalignment','left','backgroundcolor','w','tooltipstring','Displays REX gui interface for additional options'); end
uicontrol(thfig,'style','pushbutton','string','OK','units','norm','position',[.1,.01,.38,.2],'callback','uiresume','fontsize',8+CONN_gui.font_offset);
uicontrol(thfig,'style','pushbutton','string','Cancel','units','norm','position',[.51,.01,.38,.2],'callback','delete(gcbf)','fontsize',8+CONN_gui.font_offset);
uiwait(thfig);
ok=ishandle(thfig);
if ok, 
    if ~isempty(viewrex), viewrex=get(ht3,'value'); end
    delete(thfig);
else   filename_rois=[]; filename_sources=[]; 
end

    function conn_vproject_selectfiles_callback1(varargin)
        if get(ht1,'value')==1
            filename_rois=filename_rois0;
        else
            [tfilename,tpathname]=uigetfile('*.nii; *.img','Select mask/ROI file',filename_rois);
            if ischar(tfilename), filename_rois=fullfile(tpathname,tfilename);
            else
                filename_rois=filename_rois0;
                set(ht1,'value',1);
            end
        end
    end
    function conn_vproject_selectfiles_callback2(varargin)
        if get(ht2,'value')==1
            filename_sources=filename_sources0;
        else
            [tfilename,tpathname]=uigetfile('*.mat','Select SPM.mat file',filename_sources);
            if ischar(tfilename), filename_sources=fullfile(tpathname,tfilename);
            else
                filename_sources=filename_sources0;
                set(ht2,'value',1);
            end
        end
    end
end

function simfilename=conn_vproject_simfilename(spmfile,THR_TYPE,THR)
if nargin==2&&isequal(THR_TYPE,'all')
    simfilename=fullfile(fileparts(spmfile),'nonparametric_p*.mat');
else
    simfilename=char(arrayfun(@(a,b)fullfile(fileparts(spmfile),sprintf('nonparametric_p%d_%.8f.mat',a,b)),THR_TYPE,THR,'uni',0));
end
end

function ok=conn_vproject_randomise(spmfile,THR_TYPE,THR,dogui)
fh=figure('units','norm','position',[.4,.4,.3,.2],'menubar','none','numbertitle','off','name','non-parametric analyses','color','w');
h1=uicontrol('units','norm','position',[.1,.8,.4,.15],'style','text','string','# of simulations: ','backgroundcolor',get(fh,'color'));
h2=uicontrol('units','norm','position',[.5,.8,.4,.15],'style','edit','string',num2str(max(1000,round(1/THR))),'tooltipstring','<HTML>Number of data permutations/randomisations that will be evaluated in order to compute cluster-level statistics</HTML>');
h3=uicontrol('units','norm','position',[.1,.5,.8,.25],'style','popupmenu','string',{'Run simulations now','Run simulations later'},'callback',@conn_vproject_randomise_nowlater);
h4=uicontrol('units','norm','position',[.1,.3,.4,.15],'style','text','string','filename: ','backgroundcolor',get(fh,'color'),'visible','off');
h5=uicontrol('units','norm','position',[.5,.3,.4,.15],'style','edit','string','./script_clusterstatistics.m','visible','off','tooltipString','This option will create a script that you may run at a later time in order to compute the cluster-level statistics. Here you must define a filename (two files will be created, a #filename#.m and a #filename#.mat file)');
h6=uicontrol('units','norm','position',[.3,.05,.3,.15],'style','pushbutton','string','OK','callback','uiresume(gcbf)');
h7=uicontrol('units','norm','position',[.65,.05,.3,.15],'style','pushbutton','string','Cancel','callback','close(gcbf)');
if nargin<4||dogui, uiwait(fh); end
if ishandle(fh),
    v2=str2num(get(h2,'string'));
    v3=get(h3,'value');
    v5=get(h5,'string');
    close(fh);
    niters=v2;
    simfilename=conn_vproject_simfilename(spmfile,THR_TYPE,THR);
    maskfile=fullfile(fileparts(spmfile),'mask.nii');
    if ~conn_existfile(maskfile), maskfile=fullfile(fileparts(spmfile),'mask.img'); end
    if conn_existfile(maskfile), mask=spm_read_vols(spm_vol(maskfile)); 
    else mask=[]; 
    end
    SIDE=1:3;
    THR=THR+[0 0 0];
    THR_TYPE=THR_TYPE+[0 0 0];
    load(spmfile,'SPM');
    if isfield(SPM,'xX_multivariate')
        X=SPM.xX_multivariate.X;
        c=SPM.xX_multivariate.C;
        m=SPM.xX_multivariate.M;
    else
        disp('Warning: xX_multivariate design info not found. Assuming no covariance modeling design. First contrast only');
        ncon=1;
        X=SPM.xX.X;
        c=SPM.xCon(ncon).c';
        m=1;
    end
    if isfield(SPM,'repeatedsubjects'), groupingsamples=SPM.repeatedsubjects; else groupingsamples=[]; end
    if v3==1, % now
        ht=conn_msgbox('Preparing data. Please wait...','results explorer');
        try
            a=spm_vol(char(SPM.xY.Y));
        catch
            a=SPM.xY.VY;
        end
        y=[];
        if isempty(mask)
            y=spm_read_vols(a);
            mask=~any(isnan(y),4)&any(diff(y,1,4)~=0,4);
            y=reshape(y,size(y,1)*size(y,2)*size(y,3),size(y,4));
            y=y(mask,:);
        end
        [i,j,k]=ind2sub(size(mask),find(mask));
        xyz=[i(:) j(:) k(:)]';
        if isempty(y), y=spm_get_data(a,xyz)'; end
        y=permute(reshape(y,size(y,1),size(SPM.xX_multivariate.X,1),[]),[2,3,1]);
        if ishandle(ht), delete(ht); end
        try
            conn_randomise(X,y,c,m,THR,THR_TYPE,SIDE,niters,simfilename,[],xyz,[],groupingsamples);
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
        save(fullfile(file2_path,[file2_name,'.mat']),'X','Y','c','m','THR','THR_TYPE','SIDE','niters','simfilename','mask','groupingsamples');
        fprintf('Created file %s\n',fullfile(file2_path,[file2_name,'.mat']));
        fh=fopen(fullfile(file2_path,[file2_name,'.m']),'wt');
        fprintf(fh,'load %s;\n',fullfile(file2_path,[file2_name,'.mat']));
        fprintf(fh,'a=spm_vol(Y);\n');
        fprintf(fh,'y=[];\n');
        fprintf(fh,'if isempty(mask)\n');
        fprintf(fh,'    y=spm_read_vols(a);\n');
        fprintf(fh,'    mask=~any(isnan(y),4)&~all(y==0,4);\n');
        fprintf(fh,'    y=reshape(y,size(y,1)*size(y,2)*size(y,3),size(y,4));\n');
        fprintf(fh,'    y=y(mask,:);\n');
        fprintf(fh,'end\n');
        fprintf(fh,'[i,j,k]=ind2sub(size(mask),find(mask));\n');
        fprintf(fh,'xyz=[i(:) j(:) k(:)]'';\n');
        fprintf(fh,'if isempty(y), y=spm_get_data(a,xyz)''; end\n');
        fprintf(fh,'y=permute(reshape(y,size(y,1),size(SPM.xX_multivariate.X,1),[]),[2,3,1]);\n');
        fprintf(fh,'conn_randomise(X,y,c,m,THR,THR_TYPE,SIDE,niters,simfilename,[],xyz,[],groupingsamples);\n');
        fclose(fh);
        fprintf('Created file %s\n',fullfile(file2_path,[file2_name,'.m']));
        ok=false;
    end
else
    ok=false;
end

    function conn_vproject_randomise_nowlater(varargin)
        v3=get(h3,'value');
        if v3==1, set([h4,h5],'visible','off'); else set([h4,h5],'visible','on'); end
    end
end

