function [C0,P0,xyz] = conn_watershed(X,IDX,A)
% CONN_WATERSHED watershed segmentation
%
% C=spm_ss_watershed(X);
% C=spm_ss_watershed(X,idx);
%

% note: assumes continuous volume data (this implementation does not work well with discrete data). In practice this means having sufficiently-smoothed volume data
%

persistent surfparams;
if nargin<2||isempty(A), datatype='volume'; A=[];
elseif ischar(A), datatype=A; A=[];
else datatype='explicit';
end
sX=[size(X) 1 1 1];
if nargin<2||isempty(IDX), IDX=find(~isnan(X)); IDX=IDX(:); else IDX=IDX(:); end
xyz=[];

[a,idx]=sort(-X(IDX)); idx=IDX(idx);
if isequal(datatype,'surface')||(isequal(datatype,'explicit')&&~((isstruct(A)&&isfield(A,'xyz'))||size(A,1)==3)), % surface-case
    if isempty(A) 
        if isempty(surfparams)
            surfparams=load(fullfile(fileparts(which(mfilename)),'utils','surf','surf_top.mat'),'A');
        end
        A=surfparams.A;
    end
    if (isstruct(A)&&isfield(A,'faces'))||size(A,2)==3, A=spm_mesh_adjacency(A); end % surface-case (entering triangular faces info)
    if isstruct(A)&&isfield(A,'vertices'), xyz=A.vertices'; end
    A=A(idx,idx);
    esX=sX;
    eidx=idx;
elseif isequal(A,'volume')||(isstruct(A)&&isfield(A,'xyz'))||size(A,1)==3, % volume-case (entering xyz voxel coordinates)
    if isequal(A,'volume')
        [pidx{1:numel(sX)}]=ind2sub(sX,idx(:));
        pidx=num2cell(1+cat(2,pidx{:}),1);
        esX=sX+2;
        [ix,iy,iz]=ndgrid(1:sX(1),1:sX(2),1:sX(3));
        xyz=[ix(:) iy(:) iz(:)]';
    else
        if isstruct(A), xyz=A.xyz;
        else xyz=A;
        end
        pidx=num2cell(1+xyz(:,idx)',1);
        esX=max(xyz(:,idx),[],2)'+2;
    end
    eidx=sub2ind(esX,pidx{:});
    %neighbours (max-connected; i.e. 8-connected for 2d, 26-connected for 3d)
    [dd{1:numel(esX)}]=ndgrid(1:3);
    d=sub2ind(esX,dd{:});
    d=d-d((numel(d)+1)/2);d(~d)=[];
    A=[];
end

%zero-pad&sort
%if nargin<3||isempty(scale), scale=0; end
% [a,idx]=sort(-X(IDX)); idx=IDX(idx); 
% [pidx{1:numel(sX)}]=ind2sub(sX,idx(:));
% pidx=mat2cell(1+cat(2,pidx{:}),numel(pidx{1}),ones(1,numel(sX)));
% eidx=sub2ind(sX+2,pidx{:});
% sX=sX+2;
N=numel(eidx);


%assigns labels
C=zeros(esX);   % labeled regions
P=zeros(esX); % labeled peaks
m=0;
for n1=1:N,
    if isempty(A)
        c=C(eidx(n1)+d);
    else
        c=C(eidx(A(:,n1)>0));
    end
    c=c(c>0);
    if isempty(c),                          % no labeled neighb
        m=m+1;C(eidx(n1))=m;P(eidx(n1))=m;  %       new label
    elseif ~any(diff(c))                    % consistently labeled neighb
        C(eidx(n1))=c(1);                   %       same label
    end
end
idxborder=find(C(eidx)==0);
for n1=idxborder(:)',
    if isempty(A)
        c=C(eidx(n1)+d);
    else
        c=C(eidx(A(:,n1)>0));
    end
    c=c(c>0);
    if numel(c)>0
        u=sparse(c,1,1);
        [nill,uk]=max(u);
        C(eidx(n1))=uk;
        %uk=find(u==max(u));
        %C(eidx(n1))=uk(1+mod(n1,numel(uk)));%       mode
    end
end
C0=zeros(size(X));C0(idx)=C(eidx);
P0=zeros(size(X));P0(idx)=P(eidx);



