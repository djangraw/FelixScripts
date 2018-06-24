function [jp,pval,winjp,winpval] = computeJitterProbabilities_v1p2(X,v,labels,prior,forceOneWinner)

% [jp,pval] = computeJitterProbabilities_v1p2(X,v,labels,prior,forceOneWinner)
%
% INPUTS:
% X should be Dx(P+T)xN
% v should be DxP
% labels should be Nx1
% prior should be NxT
% forceOneWinner should be a 1x1 binary value
%
% OUTPUTS:
% jp is a matrix of size NxT
% pval is Nx1
% winjp is NxTxW (W=# windows)
% winpval is NxW
%
% Created 12/12/12 by BC.
% Updated 12/14/12 by DJ - added pval output.
% Updated 12/18/12 by DJ - v1p1, prior input, forceOneWinner input
% Updated 12/19/12 by DJ - v1p2 (soft EM), posterior for each window
% Updated 12/28/12 by DJ - fixed posterior normalization
% Updated 12/31/12 by DJ - fixed winpval for forceOneWinner, jp
% normalization given only 1 jitter option

makeplot = false;

[D,P] = size(v);
T = size(X,2) - P;
N = size(X,3);
if size(labels,1) > 1; labels = labels'; end;

% Find the columns of v that we are considering (those without NaN values)
keepCols = find(sum(isnan(v))==0);
W = numel(keepCols);
% Convert labels to +1/-1 and repmat
L = repmat(2*labels-1,numel(keepCols),1);
% Repeat filter v across trials
v = repmat(v(:,keepCols),1,N);
% Compute the base columns to keep in the data X
keepCols_x = repmat(keepCols,1,N) + reshape(repmat(0:(P+T):((P+T)*(N-1)),numel(keepCols),1),1,N*numel(keepCols));
X = reshape(X,size(X,1),(P+T)*N);
% [jp,jp0,jp1] = deal(zeros(T,N));

bigjp0 = zeros(W,N,T);
for t=1:T
    y = reshape(sum(v.*X(:,keepCols_x+t)),W,N);
    bigjp0(:,:,t) = 1./(1+exp(y)); % p(c=0 | x,v)
end

% Get window-by-window likelihoods given c=0, c=1, true labels
bigjp0 = permute(bigjp0,[3,2,1]);
bigjp1 = 1-bigjp0;
bigjp = bigjp0;
bigjp(:,labels==1,:) = bigjp1(:,labels==1,:);
% Multiply window-by-window likelihoods by prior
newjp0 = bsxfun(@times,bigjp0,prior');
newjp1 = bsxfun(@times,bigjp1,prior');
newjp = bsxfun(@times,bigjp,prior');

% Take product across windows, then multiply by prior
prodbigjp0 = prod(bigjp0,3);
prodbigjp1 = prod(1-bigjp0,3);
jp0 = prodbigjp0 ./ (prodbigjp0+prodbigjp1) .* prior';
jp1 = prodbigjp1 ./ (prodbigjp0+prodbigjp1) .* prior';
% jp0 = prod(bigjp0,3).*prior';
% jp1 = prod(1-bigjp0,3).*prior';
jp = jp0;
jp(:,labels==1) = jp1(:,labels==1);

%Get final results
if forceOneWinner
    pval = max(jp1,[],1)./(max(jp1,[],1)+max(jp0,[],1));    
    winpval = max(newjp1,[],1)./(max(newjp1,[],1)+max(newjp0,[],1));
    % Get posteriors
    [~,iMax] = max(jp,[],1);
    jp = full(sparse(iMax,1:length(iMax),1,size(jp,1),size(jp,2))); % all zeros except at max points
    winjp = nan(size(newjp));
    for i=1:W
        [~,iMax] = max(newjp(:,:,i),[],1);
        winjp(:,:,i) = full(sparse(iMax,1:length(iMax),1,size(newjp,1),size(newjp,2))); % all zeros except at max points
    end
else
    pval = sum(jp1,1)./(sum(jp1,1)+sum(jp0,1));
    winpval = sum(newjp1,1)./(sum(newjp1,1)+sum(newjp0,1));
    % Normalize posteriors
    jp = jp./repmat(sum(jp,1),T,1);
    winjp = newjp./repmat(sum(newjp,1),T,1);    
end
% Transpose to make size(__,2)=T
pval = pval';
jp = jp';
winpval = permute(winpval,[2,3,1]);
winjp = permute(winjp,[2,1,3]);


if makeplot
    figure(2);
    subplot(2,2,1); imagesc(jp0'); colorbar; 
    subplot(2,2,2); imagesc(jp1'); colorbar;
    subplot(2,1,2); plot([max(jp0,[],1);max(jp1,[],1);pval;labels]');
end
    



