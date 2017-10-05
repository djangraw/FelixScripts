function data=conn_randomise(X,Y,c1,c2,Pthr,Pthr_type,Pthr_side,niters,filename,overwrite,datatype,analysismask,groupingsamples)
% X: [n,m] (# of samples x # of effects) design matrix
% Y: [n,v,r1,r2] (# of samples x # of variables x # of seed ROIs x # of target ROIs) data matrix
% Y: [n,v,r...]     (# of samples x # of variables x # of voxels) data matrix
% C1: [a,m] left-hand contrast matrix
% C2: [b,v] right-hand contrast matrix
%
% Y(:,:,k)=X*B+e
% C1*B*C2'=0

% Pthr: [1]
% Pthr_type: 1 (p-unc) 2 (p-fdr rows) 3 (p-fdr all) 4 (T/F/X stat)
% Pthr_side: 1 (one-sided positive), 2 (one-sided negative), 3 (two-sided)

if nargin<5||isempty(Pthr), Pthr=[.05 .01 .005 .001 .0005 .0001]; end
if nargin<6||isempty(Pthr_type), Pthr_type=ones(size(Pthr)); end
if nargin<7||isempty(Pthr_side), Pthr_side=ones(size(Pthr)); end
if nargin<8||isempty(niters), niters=1000; end
if nargin<9||(ischar(filename)&&isempty(filename)), filename='temporal_conn_randomise.mat'; end
if nargin<10||isempty(overwrite), overwrite=false; end
if nargin<11||isempty(datatype), datatype='matrix'; end % 'matrix'|'surface'|volumecoords
if nargin<12, analysismask=[]; end
if nargin<13, groupingsamples=[]; end
maxT=10;
maxTmax=maxT*100;
[Nn,Nv,Nr1,Nr2,Nr3]=size(Y);
Nr=Nr1*Nr2*Nr3; 

% baseline results
model=struct('X',X,'c1',c1,'c2',c2,'dims',size(Y));
results=[]; % [results.h,results.F,results.p,results.dof,results.statsname]=conn_glm(X,Y,c1,c2);

% remove orthogonal contrasts
nc=null(c1);
xnc=X*nc;
iX=pinv(X'*X);
ix=pinv(xnc'*xnc);
r=zeros(Nn,size(c2,1),Nr);
for nr=1:Nr
    r(:,:,nr)=Y(:,:,nr)*c2'-X*(iX*(X'*Y(:,:,nr)*c2'));        % full-model residual
    %r(:,:,nr)=Y(:,:,nr)*c2'-xnc*(ix*(xnc'*Y(:,:,nr)*c2'));        % partial-model residual
end
x=X*c1'-xnc*(ix*(xnc'*X*c1'));        % removes from X
univariate=size(c1,1)==1&size(c2,1)==1;
if univariate&&numel(Pthr)==1, Pthr=repmat(Pthr,[1 3]); Pthr_type=repmat(Pthr_type,[1 3]); Pthr_side=1:3; end

% initialize
newPthr=Pthr;
newPthr_type=Pthr_type;
newPthr_side=Pthr_side;
if ~overwrite&&isstruct(filename)
    Hist_Cluster_size=filename.Hist_Cluster_size;
    Hist_Cluster_mass=filename.Hist_Cluster_mass;
    Dist_Cluster_sizemax=filename.Dist_Cluster_sizemax;
    Dist_Cluster_massmax=filename.Dist_Cluster_massmax;
    Hist_Seed_size=filename.Hist_Seed_size;
    Hist_Seed_mass=filename.Hist_Seed_mass;
    Dist_Seed_sizemax=filename.Dist_Seed_sizemax;
    Dist_Seed_massmax=filename.Dist_Seed_massmax;
    Pthr=filename.Pthr;
    Pthr_type=filename.Pthr_type;
    Pthr_side=filename.Pthr_side;
    if isfield(filename,'datatype'), datatype=filename.datatype; end
elseif ~overwrite&&ischar(filename)&&~isempty(dir(filename))
    load(filename);
else
    Hist_Cluster_size={};
    Hist_Cluster_mass={};
    Dist_Cluster_sizemax={};
    Dist_Cluster_massmax={};
    Hist_Seed_size={};
    Hist_Seed_mass={};
    Dist_Seed_sizemax={};
    Dist_Seed_massmax={};
    Pthr=[];
    Pthr_type=[];
    Pthr_side=[];
end
idx=find(~ismember([newPthr(:),newPthr_type(:),newPthr_side(:)],[Pthr(:),Pthr_type(:),Pthr_side(:)],'rows'));
nthr=numel(idx);
if ~nthr,     
    data=struct('Pthr',Pthr,'Pthr_type',Pthr_type,'Pthr_side',Pthr_side,'maxT',maxT,'Hist_Cluster_size',{Hist_Cluster_size},'Hist_Cluster_mass',{Hist_Cluster_mass},'Dist_Cluster_sizemax',{Dist_Cluster_sizemax},'Dist_Cluster_massmax',{Dist_Cluster_massmax},'Hist_Seed_size',{Hist_Seed_size},'Hist_Seed_mass',{Hist_Seed_mass},'Dist_Seed_sizemax',{Dist_Seed_sizemax},'Dist_Seed_massmax',{Dist_Seed_massmax});
    return;
end
thridx=numel(Pthr)+(1:nthr);
Hist_Cluster_size=[Hist_Cluster_size,repmat({sparse(1+Nr,1)},1,nthr)];
Hist_Cluster_mass=[Hist_Cluster_mass,repmat({sparse(1+maxTmax*Nr,1)},1,nthr)];
Dist_Cluster_sizemax=[Dist_Cluster_sizemax,repmat({zeros(niters,1)},1,nthr)];
Dist_Cluster_massmax=[Dist_Cluster_massmax,repmat({zeros(niters,1)},1,nthr)];
Hist_Seed_size=[Hist_Seed_size,repmat({sparse(1+Nr,1)},1,nthr)];
Hist_Seed_mass=[Hist_Seed_mass,repmat({sparse(1+maxTmax*Nr,1)},1,nthr)];
Dist_Seed_sizemax=[Dist_Seed_sizemax,repmat({zeros(niters,1)},1,nthr)];
Dist_Seed_massmax=[Dist_Seed_massmax,repmat({zeros(niters,1)},1,nthr)];
Pthr=[Pthr,newPthr(idx(:)')];
Pthr_type=[Pthr_type,newPthr_type(idx(:)')];
Pthr_side=[Pthr_side,newPthr_side(idx(:)')];
Nx=rank(X);
Nc0=rank(x);
Ns=rank(c2);
dof=size(Y,1)-Nx;
if size(c1,1)==1&size(c2,1)==1,
    Xthr(thridx)=spm_invTcdf(max(0,min(1,1-Pthr(thridx))),dof);
    Xthrb(thridx)=spm_invTcdf(max(0,min(1,Pthr(thridx))),dof);
    Xthrc(thridx)=spm_invTcdf(max(0,min(1,1-Pthr(thridx)/2)),dof);
    statsdof=dof;
    statsname='T';
elseif size(c1,1)==1
    Xthr(thridx)=spm_invFcdf(max(0,min(1,1-Pthr(thridx))),Ns,dof-Ns+1);
    statsdof=[Ns,dof-Ns+1];
    statsname='F';
elseif size(c2,1)==1||Ns==1
    Xthr(thridx)=spm_invFcdf(max(0,min(1,1-Pthr(thridx))),Nc0,dof);
    statsdof=[Nc0,dof];
    statsname='F';
else
    Xthr(thridx)=spm_invXcdf(max(0,min(1,1-Pthr(thridx))),Ns*Nc0);
    statsdof=Ns*Nc0;
    statsname='X';
end
tmask=thridx(Pthr_type(thridx)==4); Xthr(tmask)=Pthr(tmask);
if univariate
    ix=pinv(x'*x);
    Cyy=reshape(sum(abs(r).^2,1),[1,Nr]);
    k_dof=sqrt(dof*x'*x);
    r=r(:,:);
else
    conn_glm_steps(1,x,r);
end
if 1,%any(Pthr_type(thridx)>1)
    switch(statsname)
        case 'T',
            spmXcdf=linspace(spm_invTcdf(1e-10,statsdof),spm_invTcdf(1-1e-10,statsdof),1e4);
            spmXcdf=cat(1,spmXcdf, spm_Tcdf(spmXcdf,statsdof));
        case 'F',
            spmXcdf=linspace(spm_invFcdf(1e-10,statsdof(1),statsdof(2)),spm_invFcdf(1-1e-10,statsdof(1),statsdof(2)),1e4);
            spmXcdf=cat(1,spmXcdf, spm_Fcdf(spmXcdf,statsdof(1),statsdof(2)));
        case 'X',
            spmXcdf=linspace(spm_invXcdf(1e-10,statsdof),spm_invXcdf(1-1e-10,statsdof),1e4);
            spmXcdf=cat(1,spmXcdf, spm_Xcdf(spmXcdf,statsdof));
    end
end
isdisplay=~all(get(0,'screensize')==1);
if isdisplay, ht=conn_waitbar(0,'Updating non-parametric statistics. Please wait'); 
else disp('Updating non-parametric statistics. Please wait'); 
end

% run simulations: randomise residual model
try, warning('off','MATLAB:RandStream:ActivatingLegacyGenerators'); warning('off','MATLAB:RandStream:ReadingInactiveLegacyGeneratorState'); warning('off','MATLAB:nearlySingularMatrix'); warning('off','MATLAB:singularMatrix'); end
try, randstate=rand('state'); end
rand('seed',0);
doperminsteadofrand=false;%~any(all(bsxfun(@eq,x(1,:),x),1));
for niter=1:niters
    xnew=x;
    if doperminsteadofrand % permutation of residuals
        shiftsign=randperm(size(r,1))';
        xnew=x(shiftsign,:);
    else % randomisation of residuals
        if isempty(groupingsamples), shiftsign=rand(size(r,1),1)<.5;
        else shiftsign=full((groupingsamples*rand(size(groupingsamples,2),1))<.5);
        end
        xnew(shiftsign,:)=-xnew(shiftsign,:);
    end
    if univariate % speed-up for univariate tests (T stats)
        Cxy=xnew'*r;
        b=ix*Cxy;
        e2=Cyy-b.*Cxy;
        f=b./max(eps,sqrt(abs(e2)))*k_dof;
        f=f(:);
    else % general but much slower cases (F&Wilks lambda stats)
        [h,f]=conn_glm_steps(2,xnew,r,analysismask);
        f=f(:);
    end
    if 1,%any(Pthr_type(thridx)>1),
        p=nan(size(f));
        p(~isnan(f))=1-max(0,min(1,interp1(spmXcdf(1,:),spmXcdf(2,:),f(~isnan(f)),'linear','extrap')));
        pb=1-p;
        pc=2*min(p,1-p);
        if univariate
            if any(Pthr_type(thridx)==2&Pthr_side(thridx)==1), p2=reshape(conn_fdr(reshape(p,[Nr1,Nr2]),2),size(p)); end
            if any(Pthr_type(thridx)==2&Pthr_side(thridx)==2), pb2=reshape(conn_fdr(reshape(pb,[Nr1,Nr2]),2),size(p)); end
            if any(Pthr_type(thridx)==2&Pthr_side(thridx)==3), pc2=reshape(conn_fdr(reshape(pc,[Nr1,Nr2]),2),size(p)); end
            if any(Pthr_type(thridx)==3&Pthr_side(thridx)==1), p3=conn_fdr(p(:)); end
            if any(Pthr_type(thridx)==3&Pthr_side(thridx)==2), pb3=conn_fdr(pb(:)); end
            if any(Pthr_type(thridx)==3&Pthr_side(thridx)==3), pc3=conn_fdr(pc(:)); end
        else
            if any(Pthr_type(thridx)==2), p2=reshape(conn_fdr(reshape(p,[Nr1,Nr2]),2),size(p)); end
            if any(Pthr_type(thridx)==3), p3=conn_fdr(p(:)); end
        end
    end
    for i=thridx % all new threshold values
        if univariate
            if Pthr_type(i)==1
                if Pthr_side(i)==1,     show=f(:)>=Xthr(i); %ithres=Xthr(i);
                elseif Pthr_side(i)==2, show=f(:)<=Xthrb(i); %ithres=abs(Xthrb(i));
                elseif Pthr_side(i)==3, show=abs(f(:))>=Xthrc(i); %ithres=Xthrc(i);
                else error('incorrect option Pthr_side');
                end
            elseif Pthr_type(i)==2
                if Pthr_side(i)==1,     show=p2(:)<=Pthr(i); %ithres=Xthr(i);
                elseif Pthr_side(i)==2, show=pb2(:)<=Pthr(i); %ithres=abs(Xthrb(i));
                elseif Pthr_side(i)==3, show=pc2(:)<=Pthr(i); %ithres=Xthrc(i);
                else error('incorrect option Pthr_side');
                end
            elseif Pthr_type(i)==3
                if Pthr_side(i)==1,     show=p3(:)<=Pthr(i); %ithres=Xthr(i);
                elseif Pthr_side(i)==2, show=pb3(:)<=Pthr(i); %ithres=abs(Xthrb(i));
                elseif Pthr_side(i)==3, show=pc3(:)<=Pthr(i); %ithres=Xthrc(i);
                else error('incorrect option Pthr_side');
                end
            elseif Pthr_type(i)==4
                if Pthr_side(i)==1,     show=f(:)>=Xthr(i); %ithres=Xthr(i);
                elseif Pthr_side(i)==2, show=f(:)<=-Xthr(i); %ithres=Xthr(i);
                elseif Pthr_side(i)==3, show=abs(f(:))>=Xthr(i); %ithres=Xthr(i);
                else error('incorrect option Pthr_side');
                end
            else error('incorrect option Pthr_type');
            end
        elseif Pthr_type(i)==1, show=p(:)<=Pthr(i); %ithres=Xthr(i);
        elseif Pthr_type(i)==2, show=p2(:)<=Pthr(i);%ithres=Xthr(i);
        elseif Pthr_type(i)==3, show=p3(:)<=Pthr(i);%ithres=Xthr(i);
        elseif Pthr_type(i)==4, show=f(:)>=Xthr(i); %ithres=Xthr(i);
        else error('incorrect option Pthr_type');
        end
        
        % cluster-size & cluster-mass for each cluster
        [nclL,CLUSTER_labels]=conn_clusters(reshape(show,[Nr1,Nr2,Nr3]),datatype);
        mask=CLUSTER_labels>0;
        V=double(show); V(show)=abs(f(show));
        if nnz(mask), mclL=accumarray(CLUSTER_labels(mask),V(mask),[max([0,max(CLUSTER_labels(mask))]),1]);
        else mclL=0;
        end
        %mclL=accumarray(CLUSTER_labels(mask),V(mask)-ithres,[max([0,max(CLUSTER_labels(mask))]),1]);
        
        % maximum cluster-size & histogram of cluster-size
        if isempty(nclL), nclL=0; end
        Dist_Cluster_sizemax{i}(niter)=max(nclL); % maximum cluster-size
        Hist_Cluster_size{i}=Hist_Cluster_size{i}+sparse(1+nclL,1,1/numel(nclL),Nr+1,1);   % histogram of cluster size (note: Hist_(1) corresponds to cluster size=0)
        
        % maximum cluster-mass & histogram of cluster-mass
        if isempty(mclL), mclL=0; end
        Dist_Cluster_massmax{i}(niter)=max(mclL);  % maximum cluster-mass
        Hist_Cluster_mass{i}=Hist_Cluster_mass{i}+sparse(1+round(min(maxTmax*Nr,maxT*mclL)),1,1/numel(mclL),maxTmax*Nr+1,1);   % histogram of cluster mass (note: Hist_(1) corresponds to cluster mass=0)

        if ischar(datatype)&&strcmp(datatype,'matrix') % additional stats for ROI-to-ROI analyses
            % maximum seed-size & histogram of seed-size
            nsdL=sum(reshape(show,[Nr1,Nr2]),2);
            Dist_Seed_sizemax{i}(niter)=max(nsdL); % maximum seed-size
            Hist_Seed_size{i}=Hist_Seed_size{i}+sparse(1+nsdL,1,1/numel(nsdL),Nr+1,1);   % histogram of seed size (note: Hist_(1) corresponds to seed size=0)
            
            % maximum seed-mass & histogram of cluster-mass
            msdL=sum(reshape(V,[Nr1,Nr2]),2);
            Dist_Seed_massmax{i}(niter)=max(msdL);  % maximum seed-mass
            Hist_Seed_mass{i}=Hist_Seed_mass{i}+sparse(1+round(min(maxTmax*Nr,maxT*msdL)),1,1/numel(msdL),maxTmax*Nr+1,1);   % histogram of seed mass (note: Hist_(1) corresponds to seed mass=0)
        end
    end
    
    if ~rem(niter,1),
        if isdisplay, conn_waitbar(niter/niters,ht); 
        else fprintf('.'); 
        end
    end
end
for i=thridx 
    Hist_Cluster_mass{i}=Hist_Cluster_mass{i}/max(eps,sum(Hist_Cluster_mass{i}));
    Hist_Cluster_size{i}=Hist_Cluster_size{i}/max(eps,sum(Hist_Cluster_size{i}));
    if strcmp(datatype,'matrix')
        Hist_Seed_mass{i}=Hist_Seed_mass{i}/max(eps,sum(Hist_Seed_mass{i}));
        Hist_Seed_size{i}=Hist_Seed_size{i}/max(eps,sum(Hist_Seed_size{i}));
    end
end
if isdisplay, conn_waitbar('close',ht);
else fprintf('\n');
end
if ~nargout
    save(filename,'model','results','Pthr','Pthr_type','Pthr_side','maxT','Hist_Cluster_size','Hist_Cluster_mass','Dist_Cluster_sizemax','Dist_Cluster_massmax','Hist_Seed_size','Hist_Seed_mass','Dist_Seed_sizemax','Dist_Seed_massmax');
else
    data=struct('model',model,'results',results,'Pthr',Pthr,'Pthr_type',Pthr_type,'Pthr_side',Pthr_side,'maxT',maxT,'Hist_Cluster_size',{Hist_Cluster_size},'Hist_Cluster_mass',{Hist_Cluster_mass},'Dist_Cluster_sizemax',{Dist_Cluster_sizemax},'Dist_Cluster_massmax',{Dist_Cluster_massmax},'Hist_Seed_size',{Hist_Seed_size},'Hist_Seed_mass',{Hist_Seed_mass},'Dist_Seed_sizemax',{Dist_Seed_sizemax},'Dist_Seed_massmax',{Dist_Seed_massmax});
end
try, rand('state',randstate); end
try, warning('on','MATLAB:RandStream:ActivatingLegacyGenerators'); warning('on','MATLAB:RandStream:ReadingInactiveLegacyGeneratorState'); warning('on','MATLAB:nearlySingularMatrix'); warning('on','MATLAB:singularMatrix'); end
end

function [h,F,p,dof,statsname,BB,EE,opt]=conn_glm_steps(steps,X,Y,mask)%,C,M,opt)
% CONN_GLM General Linear Model estimation and hypothesis testing.
%
%   [h,F,p,dof]=CONN_GLM(X,Y,C,M) estimates a linear model of the form Y = X*B + E
%   where Y is an observed matrix of response or output variables (rows are observations, columns are output variables)
%         X is an observed design or regressor matrix (rows are observations, columns are predictor variables)
%         B is a matrix of unknown regression parameters (rows are predictor variables, columns are output variables)
%         E is an matrix of unobserved multivariate normally distributed disturbances with zero mean and unknown covariance.
%   and tests a general null hypothesis of the form h = C*B*M' = 0
%   where C is matrix or vector of "predictor" contrasts (rows are contrasts, columns are predictor variables, defaults to C=eye(size(X,2)) )
% 		  M is matrix or vector of "outcome" contrasts (rows are contrasts, columns are output variables, defaults to M=eye(size(Y,2)) )
%
%   CONN_GLM returns the following information:
%		  h:   a matrix of estimated contrast effect sizes (h = C*B*M')
%		  F:   the test statistic(s) (T,F,or Chi2 value, depending on whether h is a scalar, a vector, or a matrix. See below)
%		  p:   p-value of the test(s)
%		  dof: degrees of freedom
%
%   Additional information:
%   By default CONN_GLM will use a T, F, or a Chi2 statistic for hypothesis testing depending on the size of h=C*B*M'. The default options are:
%                  when size(h)=[1,1]      -> T statistic (note: one-sided t-test)
%	                      			          Examples of use: one-sided two-sample t-test, linear regression
%                  when size(h)=[1,Ns]     -> F statistic (note: equivalent to two-sided t-test when Ns=1)
%   							  	 		  Examples of use: Hotelling's two sample t-square test, two-sided t-test, multivariate regression
%                  when size(h)=[Nc,1]     -> F statistic (note: equivalent to two-sided t-test when Nc=1)
%					  			     		  Examples of use: ANOVA, ANCOVA, linear regression omnibus test
%                  when size(h)=[Nc,Ns]    -> Wilks' Lambda statistic, Bartlett's Chi2 approximation
%								     		  Examples of use: MANOVA, MANCOVA, multivariate regression omnibus test, likelihood ratio test
%   The default option can be changed using the syntax CONN_GLM(X,Y,C,M,opt) where opt is one of the following character strings:
%               CONN_GLM(X,Y,C,M,'collapse_none') will perform a separate univariate-test on each of the elements of the matrix h=C*B*M'
%  			    CONN_GLM(X,Y,C,M,'collapse_outcomes') will perform a separate multivariate-test on each of the rows of the matrix h (collapsing across multiple outcome variables or outcome contrasts).
% 			    CONN_GLM(X,Y,C,M,'collapse_predictors') will perform a separate multivariate-test on each of the columns of the matrix h (collapsing across multiple predictor variables or predictor contrasts).
% 			    CONN_GLM(X,Y,C,M,'collapse_all') will perform a single multivariate test on the matrix h.
%
% Example of use:
%   % MANOVA (three groups, two outcome variables)
%   % Data preparation
%    N1=10;N2=20;N3=30;
%    Y1=randn(N1,2)+repmat([0,0],[N1,1]); % data for group 1 (N1 samples, population mean = [0,0])
%    Y2=randn(N2,2)+repmat([0,1],[N2,1]); % data for group 2 (N2 samples, population mean = [0,1])
%    Y3=randn(N3,2)+repmat([1,0],[N3,1]); % data for group 2 (N3 samples, population mean = [1,0])
%    Y=cat(1,Y1,Y2,Y3);
%    X=[ones(N1,1),zeros(N1,2); zeros(N2,1),ones(N2,1),zeros(N2,1); zeros(N3,2),ones(N3,1)];
%   % Sample data analyses
%    [h,F,p,dof]=conn_glm(X,Y,[1,-1,0;0,1,-1]); disp(['Multivariate omnibus test of non-equality of means across the three groups:']);disp([' Chi2(',num2str(dof),') = ',num2str(F),'   p = ',num2str(p)]);
%    [h,F,p,dof]=conn_glm(X,Y,[1,-1,0]); disp(['Multivariate test of non-equality of means between groups 1 and 2:']);disp([' F(',num2str(dof(1)),',',num2str(dof(2)),') = ',num2str(F),'   p = ',num2str(p)]);
%    [h,F,p,dof]=conn_glm(X,Y,[-1,1,0],eye(2),'collapse_none'); disp(['Univariate one-sided test of non-equality of means between groups 1 and 2 on each outcome variable:']);disp([' T(',num2str(dof),') = ',num2str(F(:)'),'   p = ',num2str(p(:)')]);
%

% alfnie@gmail.edu
% 04/03

persistent Nx Ns Na dofe Nc0 iX r ir kF1; 
if nargin<4, mask=[]; end
opt=[];
if ~isempty(opt),switch(lower(opt)),case {'collapse_none','aa'},opt='AA';case {'collapse_outcomes','ab'},opt='AB';case {'collapse_predictors','ba'},opt='BA';case {'collapse_all','bb'},opt='BB';otherwise,error(['Unknown option ',opt]); end; end
if any(steps==1)
    [N1,Nx]=size(X);
    [N2,Ns,Na]=size(Y);
    if N1~=N2, error('wrong dimensions'); end
    %if nargin<4 || isempty(C), C=eye(Nx); end
    %if nargin<5 || isempty(M), M=speye(Ns,Ns); else, Ns=rank(M); end
    
    Nx=rank(X);
    dofe=N1-Nx;
    Nc0=Nx;%rank(X*C');

    iX=pinv(X'*X);
    r=iX;%C*iX*C';
    ir=pinv(r);
    kF1=1./max(eps,r)*(dofe-Ns+1)/Ns;
end

if any(steps==2)
    %if nargin<4 || isempty(C), C=eye(Nx); end
    %if nargin<5 || isempty(M), M=speye(Ns,Ns); end
    opt=[char(65+(Nx>1)),char(65+(Ns>1))]; 
    %if nargin<6 || isempty(opt), opt=[char(65+(size(C,1)>1)),char(65+(size(M,1)>1))]; else, opt=upper(opt); end
    if Na>1, Na_h=[]; nas=find(~any(any(isnan(Y)|isinf(Y),1),2)); else nas=1; end
    if ~isempty(mask), nas(~mask(nas))=[]; end
    univariate=(strcmp(opt,'AA')|strcmp(opt,'BA'));%&size(M,1)==Ns&size(M,2)==Ns&all(all(M==eye(Ns)));
    switch(opt),
        case 'AA',                          % h: [1,1]  T-test
            dof=              dofe;
            statsname=        'T';
        case 'AB',                          % h: [1,Ns] F-test
            dof=              [Ns,dofe-Ns+1];
            statsname=        'F';
        case 'BA',                          % h: [Nc,1] F-test
            dof=              [Nc0,dofe];
            statsname=        'F';
        case 'BB',                          % h: [Nc,Ns] Wilk's Lambda-test (Ns,dof,Nc0)
            if Ns==1 % rank-defficient EE case
                dof=              [Nc0,dofe];
                statsname=        'F';
            else
                dof=              [Ns*Nc0];
                statsname=        'X';
            end
    end
    Ball=reshape(iX*(X'*Y(:,:)),[size(iX,1),Ns,Na]);
    Eall=reshape(Y(:,:)-X*Ball(:,:),[size(Y,1),Ns,Na]);
    Ball(abs(Ball)<1e-10)=0;
    for na=nas(:)'
        h=Ball(:,:,na);
        E=Eall(:,:,na);
        %B=iX*(X'*Y(:,:,na));
        %E=Y(:,:,na)-X*B;
        if univariate, EE=sum(abs(E).^2,1); % univariate case within matrix
        else, EE=E'*E; end          	% within matrix
        %else, if size(E,2)<size(E,1), EE=full(M*(E'*E)*M'); else, EE=E*M'; EE=full(EE'*EE); end; end          	% within matrix
        %h=B;%full(C*B*M');
        %h(abs(h)<1e-10)=0;
        
        switch(opt),
            case 'AA',                          % h: [1,1]  T-test
                k=                sqrt(diag(r)*diag(EE).');
                F=			      real(h./max(eps,k))*sqrt(dofe);
                if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Tcdf(F(idxvalid),dofe); end; end
            case 'AB',                          % h: [1,Ns] F-test
                F=			      (h*inv(EE)*h.')*kF1;
                %F=			      real(sum((h*pinv(EE)).*conj(h),2)./max(eps,diag(r)))*(dofe-Ns+1)/Ns;
                if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Fcdf(F(idxvalid),Ns,dofe-Ns+1); end; end
            case 'BA',                          % h: [Nc,1] F-test
                BB=h'*ir*h;                    % between matrix
                F=                (BB./max(eps,EE))*dofe/Nc0;
                %F=                real(diag(BB)./max(eps,diag(EE)))*dofe/Nc0;
                if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Fcdf(F(idxvalid),Nc0,dofe); end; end
            case 'BB',                          % h: [Nc,Ns] Wilk's Lambda-test (Ns,dof,Nc0)
                BB=h'*ir*h;                    % between matrix
                if Ns==1 % rank-defficient EE case
                    F=                (BB./max(eps,EE))*dofe/Nc0;
                    %F=                real(diag(BB)./max(eps,diag(EE)))*dofe/Nc0; F=F(1);
                    if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Fcdf(F(idxvalid),Nc0,dofe); end; end
                else
                    F=                -(dofe-1/2*(Ns-Nc0+1))*real(log(real(det(EE)./max(eps,det(EE+BB)))));
                    if nargout>2, p=nan+zeros(size(F));idxvalid=find(~isnan(F));if ~isempty(idxvalid), p(idxvalid)=1-spm_Xcdf(F(idxvalid),Ns*Nc0); end; end
                end
        end
        if Na>1
            if isempty(Na_h), Na_h=nan(size(h,1),size(h,2),Na);Na_F=nan(size(F,1),size(F,2),Na);Na_p=nan(size(F,1),size(F,2),Na); end
            Na_h(:,:,na)=h;
            Na_F(:,:,na)=F;
            if nargout>2, Na_p(:,:,na)=p; end
        end
    end
    if Na>1
        h=Na_h;
        F=Na_F;
        if nargout>2, p=Na_p; end
    end
end
end

