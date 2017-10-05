function [nlabels,labels]=conn_clusters(mask,A)
% labels connected components (bwlabel for volume/surface/matrix/arbitrary connectivity)
%

persistent surfparams;
if nargin<2, datatype='matrix';
elseif isempty(A), datatype='get_matrix';
elseif ischar(A), datatype=A; A=[];
else datatype='explicit';
end
   
switch(datatype)
    case 'matrix' % uses default node-connectivity for ROI-to-ROI analyses
        [Nr1,Nr2]=size(mask);
        [i,j]=find(mask);
        M=sparse(i(i~=j),j(i~=j),1,max(Nr1,Nr2),max(Nr1,Nr2)); % handles non-square matrices
        M=M|M';
        valid=find(any(M,1));
        M=M(valid,valid)|speye(numel(valid));
        [p,q,r,s]=dmperm(M);
        n=diff(r);
        i=find(n>1);
        Nlabels=zeros(size(M,1),1); % node labels
        %Nnlabels=zeros(numel(i),1); % node count
        for i1=1:numel(i)
            Nlabels(p(r(i(i1)):r(i(i1)+1)-1))=i1;
            %Nnlabels(i1)=n(i(i1));
        end
        labels=zeros(Nr1,Nr2);
        rmask=mask(valid(valid<=Nr1),valid);
        rmask(1:size(rmask,1)+1:size(rmask,1)*size(rmask,1))=0;
        labels(valid(valid<=Nr1),valid)=conn_bsxfun(@times,Nlabels(valid<=Nr1),rmask); % edge labels
        nlabels=accumarray(Nlabels(valid<=Nr1),sum(rmask,2)); % edge count
    
    case 'get_matrix',  % returns default node-connectivity structure for ROI-to-ROI analyses
        [Nr1,Nr2]=size(mask);
        A=cat(1,repmat(sparse(1:Nr1*Nr1,repmat(1:Nr1,Nr1,1),1),1,Nr2),sparse(Nr1*(Nr2-Nr1),Nr1*Nr2));
        A=A|A'|sparse(1:size(A,1),1:size(A,1),1);
        nlabels=double(A);

    case 'none'
        idx=find(mask);
        labels=zeros(size(mask));
        labels(idx)=1:numel(idx);
        nlabels=ones(numel(idx),1);
        
    otherwise, % for surface, volume, or other arbitrary node-connectivity definitions
        if isempty(A) % if no info assume surface
            if strcmp(datatype,'volume')
                [tx,ty,tz]=ndgrid(1:size(mask,1),1:size(mask,2),1:size(mask,3));
                A=struct('xyz',[tx(:) ty(:) tz(:)]');
            else
                if isempty(surfparams)
                    surfparams=load(fullfile(fileparts(which(mfilename)),'utils','surf','surf_top.mat'),'A');
                end
                A=surfparams.A;
            end
        end
        if (isstruct(A)&&isfield(A,'xyz'))||size(A,1)==3, % volume-case (entering xyz voxel coordinates)
            labels=zeros(size(mask));
            if isstruct(A), l=spm_clusters(A.xyz(:,mask));
            else l=spm_clusters(A(:,mask));
            end
            nlabels=accumarray(l(:),1);
            labels(mask)=l;
            return;
        end
        if (isstruct(A)&&isfield(A,'faces'))||size(A,2)==3, A=spm_mesh_adjacency(A); end % surface-case (entering triangular faces info)
        [n,n2]=size(mask);
        mask=mask>0;
        labels=zeros(size(mask));
        nlabels=zeros(n*n2,1);
        for nlabel=1:n*n2
            if ~nnz(mask), break; end
            [i,j]=find(mask,1);
            
            d=sparse(i,j,1,n,n2);
            e=sparse(i,j,1,n,n2);
            c=mask;c(i,j)=false;
            while 1
                d=c&(A*d);
                if ~nnz(d), break; end
                c(d)=false;
                e=e|d;
            end
            j=find(e);
            labels(j)=nlabel;
            mask(j)=false;
            nlabels(nlabel)=numel(j);
        end
        nlabels=nlabels(1:nlabel-1);
end
end

