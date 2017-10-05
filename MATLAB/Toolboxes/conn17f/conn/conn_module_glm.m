function SPM = conn_module_glm(X,filenames,C1,C2,swd,effectnames,contrastnames,secondlevelanalyses)
% CONN_MODULE_GLM second-level model estimation
%
% conn_module_glm(X,Y,c1,c2,folder) 
%   X     : design matrix (Nsubjects x Neffects)
%   Y     : data files (cell array Nsubjects x Nmeasures)
%   c1    : contrast between-subjects (Nc1 x Neffects) (default eye(size(X,2)))
%   c2    : contrast between-measures (Nc2 x Nmeasures) (default eye(size(Y,2)))
%   folder: folder where analysis are stored (default current folder)
%
% eg: conn_module_glm( ...
%    [1; 1; 1; 1] ,...
%    {'subject1.img'; 'subject2.img'; 'subject3.img'; 'subject4.img'} );
%     performs a one-sample t-test and stores the analysis results in the current folder
%
% eg: conn_module_glm( ...
%    [1 0; 1 0; 0 1; 0 1; 0 1],...
%    {'subject1_group1.img'; 'subject2_group1.img'; 'subject1_group2.img'; 'subject2_group2.img'; 'subject3_group2.img'},...
%    [1 -1]);
%     performs a two-sample t-test and stores the analysis results in the current folder
%
% eg: conn_module_glm( ...
%    [1; 1; 1; 1],...
%    {'subject1_time1.img', subject1_time2.img'; 'subject2_time1.img', subject2_time2.img'; 'subject3_time1.img', subject3_time2.img'; 'subject4_time1.img', subject4_time2.img'},...
%    1,...
%    [1 -1]);
%     performs a paired t-test and stores the analysis results in the current folder
%

[Ns,Nx]=size(X);
if ischar(filenames), filenames=cellstr(filenames); end
if size(filenames,1)==1&&Ns>1, filenames=filenames'; end
[Ns2,Ny]=size(filenames);
if Ns~=Ns2, error('Incorrect dimensions (X and filenames should have the same number of rows)'); end
if nargin<3||isempty(C1), C1=eye(Nx); end
if nargin<4||isempty(C2), C2=eye(Ny); end
if nargin<5||isempty(swd), swd=pwd; end
if nargin<6||isempty(effectnames), effectnames=arrayfun(@(n)sprintf('contrast %d',n),1:Nx,'uni',0); end
if nargin<7||isempty(contrastnames), contrastnames=arrayfun(@(n)sprintf('contrast %d',n),1:Ny,'uni',0); end
if nargin<8||isempty(secondlevelanalyses), secondlevelanalyses=1; end % 1:all; 2:param only; 3:nonparam only
if size(C1,2)~=Nx, error('Incorrect dimensions (X and C1 should have the same number of columns)'); end
if size(C2,2)~=Ny, error('Incorrect dimensions (filenames and C2 should have the same number of columns)'); end

for nsub=1:Ns
    filename=filenames(nsub,:);
    for n1=1:numel(filename),if isempty(fileparts(filename{n1})), filename{n1}=fullfile(pwd,filename{n1}); end; end
    SPM.xY.VY(nsub,:)=spm_vol(char(filename))';
    if nsub==1
        SPM.altestsmooth=0;
        SPM.xX.name={};
        for n01=1:numel(contrastnames),for n00=1:Nx,SPM.xX.name{n00,n01}=[effectnames{n00},'_',contrastnames{n01}]; end; end
        SPM.xX.name=SPM.xX.name(:)';
    end
    for n1=1:numel(filename), SPM.xY.VY(nsub,n1).fname=filename{n1}; end
end
nrepeated=size(SPM.xY.VY,2);
SPM.xX_multivariate.X=X;
SPM.xX_multivariate.C=C1;
SPM.xX_multivariate.M=C2;
SPM.xX_multivariate.Xnames=effectnames;
SPM.xX_multivariate.Ynames=contrastnames;
SPM.xX.SelectedSubjects=logical(full(sparse(1:Ns,1,1,Ns,1)));
SPM.xX.isSurface=conn_surf_dimscheck(SPM.xY.VY(1).dim); %,isequal(SPM.xY.VY(1).dim,conn_surf_dims(8).*[1 1 2]);
SPM.xX.X=kron(eye(nrepeated),X);
SPM.xX.iH     = [];
SPM.xX.iC     = 1:size(SPM.xX.X,2);
SPM.xX.iB     = [];
SPM.xX.iG     = [];
SPM.xGX       = [];
if nrepeated>1
    xVi=struct('I',[repmat((1:size(SPM.xY.VY,1))',[nrepeated,1]),reshape(repmat(1:nrepeated,[size(SPM.xY.VY,1),1]),[],1)],'var',[0,1],'dep',[1,0]);
    SPM.xVi=spm_non_sphericity(xVi);
end

pwd0=pwd;
cd(swd);
issurface=isfield(SPM.xX,'isSurface')&&SPM.xX.isSurface;
save('SPM.mat','SPM');
spm_unlink('mask.img','mask.hdr','mask.nii');
files=cat(1,dir('spmT_*.cluster.mat'),dir('nonparametric_p*.mat'));
if ~isempty(files)
    files={files.name};
    spm_unlink(files{:});
end
if issurface||ismember(secondlevelanalyses,[1 3]) % nonparametric stats
    mask=ones(SPM.xY.VY(1).dim(1:3));
    [gridx,gridy]=ndgrid(1:SPM.xY.VY(1).dim(2),1:SPM.xY.VY(1).dim(3));
    xyz0=[gridx(:),gridy(:)]';
    donefirst=false;
    for n2=1:SPM.xY.VY(1).dim(1)
        xyz=[n2+zeros(1,size(xyz0,2)); xyz0; ones(1,size(xyz0,2))];
        y=spm_get_data(SPM.xY.VY(:)',xyz);
        maskthis=~any(isnan(y),1)&any(diff(y,1,1)~=0,1);
        mask(n2,:,:)=reshape(maskthis,[1 SPM.xY.VY(1).dim(2:3)]);
        if any(maskthis)
            y=reshape(y,size(SPM.xY.VY,1),size(SPM.xY.VY,2),SPM.xY.VY(1).dim(2),SPM.xY.VY(1).dim(3));
            if ~donefirst
                donefirst=true;
                [results_h,results_F,nill,SPM.xX_multivariate.dof,SPM.xX_multivariate.statsname]=conn_glm(SPM.xX_multivariate.X,y(:,:,maskthis),SPM.xX_multivariate.C,SPM.xX_multivariate.M);
                SPM.xX_multivariate.h=zeros([size(results_h,1),size(results_h,2),SPM.xY.VY(1).dim(1:3)]);
                SPM.xX_multivariate.F=zeros([size(results_F,1),size(results_F,2),SPM.xY.VY(1).dim(1:3)]);
            else
                [results_h,results_F]=conn_glm(SPM.xX_multivariate.X,y(:,:,maskthis),SPM.xX_multivariate.C,SPM.xX_multivariate.M);
            end
            SPM.xX_multivariate.h(:,:,n2,maskthis)=results_h;
            SPM.xX_multivariate.F(:,:,n2,maskthis)=results_F;
        end
    end
    if ~donefirst, error('Please check your data: There are no inmask voxels'); end
end
if issurface % surface-based analyses
    V=struct('mat',SPM.xY.VY(1).mat,'dim',SPM.xY.VY(1).dim,'fname','mask.img','pinfo',[1;0;0],'n',[1,1],'dt',[spm_type('uint8') spm_platform('bigend')]);
    spm_write_vol(V,double(mask));
    save('SPM.mat','SPM');
    fprintf('\nSecond-level results saved in folder %s\n',pwd);
    if ~nargout
        conn_surf_results('SPM.mat');
    end
elseif ismember(secondlevelanalyses,[1 2]) % volume-based parametric stats
    save('SPM.mat','SPM');
    spm('Defaults','fmri');
    spm_unlink('mask.img','mask.hdr','mask.nii');
    SPM=spm_spm(SPM);
    c=kron(C2,C1); 
    cname='connectivity result';
    if size(c,1)==1, Statname='T'; else Statname='F'; end
    if ~isfield(SPM.xX,'xKXs'), error('SPM analyses did not finish correctly'); end
    SPM.xCon = spm_FcUtil('Set',cname,Statname,'c',c',SPM.xX.xKXs);
    if isfield(SPM,'altestsmooth')&&SPM.altestsmooth, % modified smoothness estimation
        SPM=conn_est_smoothness(SPM);
        save('SPM.mat','SPM');
    end
    SPM=spm_contrasts(SPM,1:length(SPM.xCon));
    SPM.xY.VY=SPM.xY.VY(:);
    SPM.xsDes='';
    save('SPM.mat','SPM');
    fprintf('Second-level results saved in folder %s\n',pwd);
    if ~nargout,
        conn_display('SPM.mat',1);
    end
elseif ismember(secondlevelanalyses,[1 3]) % volume-based nonparametric stats
    V=struct('mat',SPM.xY.VY(1).mat,'dim',SPM.xY.VY(1).dim,'fname','mask.img','pinfo',[1;0;0],'n',[1,1],'dt',[spm_type('uint8') spm_platform('bigend')]);
    spm_write_vol(V,double(mask));
    save('SPM.mat','SPM');
    fprintf('Second-level results saved in folder %s\n',pwd);
    if ~nargout,
        conn_display('SPM.mat',1);
    end
end
cd(pwd0);


end

