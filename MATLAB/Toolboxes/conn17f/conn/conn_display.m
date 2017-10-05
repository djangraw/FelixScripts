function hfigure=conn_display(SPMfilename,varargin)
% CONN_DISPLAY
% Displays second-level results
% conn_display(SPMfilename);
%

% 03/09 alfnie@gmail.com
%
global CONN_x CONN_gui;

hfigure=[];
fulld=true;
if nargin<1 || isempty(SPMfilename),
    [filename,filepath]=uigetfile('SPM.mat');
    if ~ischar(filename), return; end
    SPMfilename=fullfile(filepath,filename);
elseif ishandle(SPMfilename) % conn_display(hfig,opts)
    conn_vproject(SPMfilename,[],varargin{:});
    return;
else
    [filepath,filename,fileext]=fileparts(SPMfilename);
    if isempty(filepath), filepath=pwd;end
    SPMfilename=fullfile(filepath,[filename,fileext]);
end
ncon=1;
THR={.001,1,.05,3};
side=1;
parametric=[];
if numel(varargin)>=1&&~isempty(varargin{1}), ncon=varargin{1}; end
if numel(varargin)>=2&&~isempty(varargin{2}), THR=varargin{2}; end
if numel(varargin)>=3&&~isempty(varargin{3}), side=varargin{3}; end
if numel(varargin)>=4&&~isempty(varargin{4}), parametric=varargin{4}; end

forceusespmresults=false;
try, 
    if nargin>2&&any(strcmp(varargin,'forceusespmresults')), forceusespmresults=true; end
end
[filepath,filename,fileext]=fileparts(SPMfilename);
cwd=pwd;

if ~isempty(filepath), cd(filepath); end
hm=conn_msgbox('Loading... please wait',''); 
if fulld, load([filename,fileext],'SPM'); end
if isfield(SPM.xX,'isSurface')&&SPM.xX.isSurface
    close(hm);
    conn_surf_results(fullfile(filepath,[filename,fileext]));
else
    voxeltovoxel=0;
    vol=SPM.xY.VY(1);
    % if isfield(CONN_x,'Setup')&&isfield(CONN_x.Setup,'steps')&&numel(CONN_x.Setup.steps)>2, voxeltovoxel=CONN_x.Setup.steps([3]);
    % else voxeltovoxel=0;
    % end
    [x,y,z]=ndgrid(1:vol.dim(1),1:vol.dim(2),1:vol.dim(3));
    xyz=vol.mat*[x(:),y(:),z(:),ones(numel(x),1)]';
    if isfield(CONN_x,'Setup')&&isfield(CONN_x.Setup,'analysismask')&&CONN_x.Setup.analysismask==1&&isfield(CONN_x.Setup,'explicitmask')&&~isempty(dir(CONN_x.Setup.explicitmask{1})), 
        filename=CONN_x.Setup.explicitmask{1};
        strfile=spm_vol(filename);
        a=mean(reshape(spm_get_data(strfile,pinv(strfile.mat)*xyz),vol.dim(1),vol.dim(2),vol.dim(3),[]),4);
    elseif ~isempty(dir(fullfile(fileparts(which(mfilename)),'utils','surf','mask.volume.brainmask.nii'))), 
        filename=fullfile(fileparts(which(mfilename)),'utils','surf','mask.volume.brainmask.nii');
        strfile=spm_vol(filename);
        a=reshape(spm_get_data(strfile,pinv(strfile.mat)*xyz),vol.dim(1:3));
    else a=ones(vol.dim(1:3));
    end
    ab0=(a>0).*a;
%     if isfield(CONN_gui,'refs')&&isfield(CONN_gui.refs,'canonical')&&isfield(CONN_gui.refs.canonical,'filename')&&~isempty(CONN_gui.refs.canonical.filename)
%         strfile=spm_vol(CONN_gui.refs.canonical.filename);
%     else
%         strfile=spm_vol(fullfile(fileparts(which('spm')),'canonical','avg305T1.nii'));
%     end
%     b=reshape(spm_get_data(strfile,pinv(strfile.mat)*xyz),vol.dim(1:3));
%     ab0=(a>0).*(a.*b);
    isparam=~isempty(SPM)&&isfield(SPM,'xVol');
    isnonparam=~isempty(SPM)&&(forceusespmresults||(isfield(SPM,'xX_multivariate')&&isfield(SPM.xX_multivariate,'F')));
    [param,nonparam]=deal(struct('p',[],'logp',[],'F',[],'stats',[],'backg',[]));
    for doparam=find([isparam isnonparam])
        if doparam==1 % SPM-based analyses, for parametric stats
            if isfield(SPM,'xCon')&&length(SPM.xCon)>1,
                if nargin<2||isempty(ncon), ncon=spm_conman(SPM); end
            else ncon=1;
            end
            statsname=SPM.xCon(ncon).STAT;
            tvol=SPM.xCon(ncon).Vspm;
            if length(tvol.dim)>3,tvol.dim=tvol.dim(1:3); end;
            if ~isfield(tvol,'dt'), tvol.dt=[spm_type('float32') spm_platform('bigend')]; end
            T=spm_read_vols(tvol);
            df=[SPM.xCon(ncon).eidf,SPM.xX.erdf];
            R=SPM.xVol.R;
            S=SPM.xVol.S;
            stat_thresh_fwhm=1;
            try, v2r=1/prod(SPM.xVol.FWHM(1:3)); catch, v2r=[]; end
            %             dof=regexp(a(1).descrip,'SPM{T_\[([\d\.])*\]','tokens');
        else % non SPM-based analyses, for nonparametric stats
            if ~forceusespmresults
                T=reshape(SPM.xX_multivariate.F,vol.dim);
                statsname=SPM.xX_multivariate.statsname;
                df=SPM.xX_multivariate.dof;
                %ncon=1;
            else
                T=spm_read_vols(tvol);
                SPM.xX_multivariate.X=SPM.xX.X;
                SPM.xX_multivariate.C=SPM.xCon(ncon).c';
                SPM.xX_multivariate.M=1;
                SPM.xX_multivariate.statsname=statsname;
                SPM.xX_multivariate.dof=df;
                SPM.xX_multivariate.F=permute(T,[4,5,1,2,3]);
                SPM.xX_multivariate.h=permute(spm_read_vols(SPM.xCon(ncon).Vcon),[4,5,1,2,3]);
                SPM.xX_multivariate.derivedfromspm=true;
                save(SPMfilename,'SPM');
            end
            R=[];S=[];v2r=[];stat_thresh_fwhm=[];
        end
        p=nan+zeros(size(T));idxvalid=find(~isnan(T));
        if ~isempty(idxvalid)
            switch(statsname),
                case 'T', p(idxvalid)=1-spm_Tcdf(T(idxvalid),df(end));
                case 'F', p(idxvalid)=1-spm_Fcdf(T(idxvalid),df(1),df(2));
                case 'X', p(idxvalid)=1-spm_Xcdf(T(idxvalid),df);
            end
        end
        x=find(any(any(ab0,2),3)|any(any(T,2),3)); x=max(1,min(size(T,1), [x(1)-1 x(end)+1]));%crop
        y=find(any(any(ab0,1),3)|any(any(T,1),3)); y=max(1,min(size(T,2), [y(1)-1 y(end)+1]));
        z=find(any(any(ab0,1),2)|any(any(T,1),2)); z=max(1,min(size(T,3), [z(1)-1 z(end)+1]));
        p=p(x(1):x(end),y(1):y(end),z(1):z(end));
        ab=ab0(x(1):x(end),y(1):y(end),z(1):z(end));
        ab(:,:,[1,end],1)=0;ab(:,[1,end],:,1)=0;ab([1,end],:,:,1)=0;
        T=T(x(1):x(end),y(1):y(end),z(1):z(end));
        logp=-log(max(eps,p));%logp=p;logp(logp==0)=nan; logp=-log(logp);
        logp(isnan(T))=nan;
        stats={vol.mat*(eye(4)+[zeros(4,3),[x(1)-1;y(1)-1;z(1)-1;0]]),R,df,S,v2r,statsname,stat_thresh_fwhm};
        if doparam==1, param=struct('p',p,'logp',logp,'F',T,'stats',{stats},'backg',ab);
        else nonparam=struct('p',p,'logp',logp,'F',T,'stats',{stats},'backg',ab);
        end
    end
    h0=get(0,'screensize');
    hfigure=figure('menubar','none','numbertitle','off','color','w','units','pixels','position',[2,h0(4)-.8*h0(4)-48,.75*h0(3)-2,.8*h0(4)]);
    close(hm);
    conn_vproject(param,nonparam,[],[],THR,side,parametric,[],[],[],.50,[],SPMfilename,voxeltovoxel);
end

cd(cwd);
