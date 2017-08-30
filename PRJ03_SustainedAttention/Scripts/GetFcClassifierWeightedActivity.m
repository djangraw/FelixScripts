function [D,C,B,Z,Vx,Y,AzLoo] = GetFcClassifierWeightedActivity(X,fracFcVarToKeep,iFcEventSample,truth,fcWinLength)

% [D,C,B,Z,Vx,Y,AzLoo] = GetFcClassifierWeightedActivity(X,fracFcVarToKeep,iFcEventSample,truth,fcWinLength)
%
%
% Created 4/5/16 by DJ. 
% Updated 4/7/16 by DJ - debugged and finished!
% Updated 4/21/16 by DJ - added fcWinLength input, Z/Vx outputs

%%
fprintf('Setting Up...\n')
% declare LR params
params.regularize=1;
params.lambda=1e-6;
params.lambdasearch=true;
params.eigvalratio=1e-4;
% params.vinit=zeros(size(feats,1)+1,1);
params.show=0;
params.LOO=true; % false; %
params.demean=false;
params.LTO=false;%true;
% declare other params
if ~exist('fcWinLength','var') || isempty(fcWinLength)
    fcWinLength = 10;
end
% Declare processing options
normX = false; % true; % NOT CRUCIAL.
doSvdOnX = true; % false; % CRUCIAL!
demeanFc = false; % NOT CRUCIAL.
doSvdOnF = true; % CRUCIAL!
normP = false; % NOT CRUCIAL.
normQ = false; % true; % NOT CRUCIAL.


%% Get rotated timecourse matrix Z

% normalize timecourse of activity
if normX
    fprintf('Normalizing timecourses...\n')
    X_norm = nan(size(X));
    for i=1:size(X,1)
        X_norm(i,:) = (X(i,:)-nanmean(X(i,:)))/nanstd(X(i,:));
    end
else
    X_norm = X;
end

% Run PCA on tcs to get magnitude timecourse Z
if doSvdOnX
    fprintf('Running SVD on timecourses...\n')
    isNotCensoredSample = ~any(isnan(X_norm));
    [Ux,Sx,Vx] = svd(X_norm(:,isNotCensoredSample)');
    Z = Vx'*X_norm; % multiply each weight vec by each FC vec
else
    Vx = eye(size(X_norm,1));
    Z = X_norm;
end

%% Get FC matrix F

fprintf('Getting FC matrix...\n')
% Get 3d FC matrix
FC = GetFcMatrices(Z,'sw',fcWinLength);

% get upper triangular matrix to convert mat <-> vec
nROIs = size(FC,1);
uppertri = triu(ones(nROIs),1); % above the diagonal

% Turn each time point's matrix into a vector of the unique indices.
% (assume the elements above the diagonal contain all the information)
nT = size(FC,3);
nFC = sum(uppertri(:)); % number of unique elements 
F = nan(nFC,nT);
for i=1:nT
    thisFC = FC(:,:,i); % save out for easy indexing
    F(:,i) = thisFC(uppertri==1); % assume a symmetric matrix
end

%% Get dimensionality-reduced matrix P

% get FC feats
if doSvdOnF
    fprintf('Running SVD on FC...\n')
    % perform SVD
    [Uf,Sf,Vf,FcPcTc] = PlotFcPca(FC,0,demeanFc);
    cumsumS = cumsum(diag(Sf).^2)/sum(diag(Sf).^2);
    nPcsToKeep = find(cumsumS<=fracFcVarToKeep,1,'last');
    P = FcPcTc(1:nPcsToKeep,:);    
else
    P = F;
end

%% Get Normalized matrix Pnorm

if normP
    fprintf('Normalizing FC components...\n')
    P_norm = zeros(size(P));
    for i=1:size(P,1)
        P_norm(i,:) = (P(i,:)-nanmean(P(i,:)))/nanstd(P(i,:));
    end
else
    P_norm = P;
end

%% Get classifier weights W
fprintf('Sampling feature matrix...\n')
% Sample Pnorm at event times to get Q
nEvents = numel(iFcEventSample);
Q = nan(size(P_norm,1),nEvents);
Q(:,~isnan(iFcEventSample)) = P_norm(:,iFcEventSample(~isnan(iFcEventSample)));

% Set vinit
nFeats = size(P_norm,1);
params.vinit = zeros(nFeats+1,1);

% crop trials
isOkTrial = all(~isnan(Q),1);
Q_cropped = Q(:,isOkTrial);
truth_cropped = truth(isOkTrial);

% NORMALIZE
if normQ
    fprintf('Normalizing cropped FC components...\n')
    Q_norm = zeros(size(Q_cropped));
    for i=1:size(Q_cropped,1)
        Q_norm(i,:) = (Q_cropped(i,:)-nanmean(Q_cropped(i,:)))/nanstd(P(i,:));
    end
else
    Q_norm = Q_cropped;
end



% Run LR classification
fprintf('Running LR classifier...\n')
Q_permuted = permute(Q_norm,[1 3 2]);
[Az, AzLoo, stats, AzLto] = RunSingleLR(Q_permuted, truth_cropped, params);
W = stats.wts(1:end-1);
% normalize so RMS weights = 1
W_norm = W/sqrt(mean(W.^2));

fprintf('Az = %.3g, AzLoo = %.3g\n',Az,AzLoo);
% Get classifier output Y
Y = W_norm'*P_norm;

%% Get FC-based weight matrix W_hat
fprintf('Getting FC-based weight matrix...\n')
% Get normalization matrix D 
if normP
    sigma = nanstd(P,[],2);
    D = diag(sigma.^(-1));
else
    D = eye(size(P,1));
end
% Get weight matrix
if doSvdOnF
    W_hat = Vf(:,1:nPcsToKeep)*D*W_norm;
else
    W_hat = D*W_norm;
end

%% Get FC weighting matrix A and Mag weighting matrix B
fprintf('Getting ROI PC-based weighting...\n')
A = repmat(W_hat,1,size(F,2)).*F;
A = abs(A);
[jROIs,kROIs] = find(uppertri);
B = zeros(nROIs,nT);
for i=1:length(jROIs)
    B(jROIs(i),:) = B(jROIs(i),:) + A(i,:);
    B(kROIs(i),:) = B(kROIs(i),:) + A(i,:);
end

%% Apply weighting matrix B to component matrix Z
fprintf('Applying weighting to component timecourses...\n')
% Resize B to match size of Z
nPads = size(Z,2)-size(B,2);
B_padded = zeros(size(Z));
B_padded(:,(1:nT)+floor(nPads/2)) = B;
% Apply to Z
C = B_padded.*Z;

%% Rotate back into original space
fprintf('Rotating matrix back into ROI space...\n');
if doSvdOnX
    D = Vx*C; % in SVD, Vx'^(-1) = Vx
else
    D = C;
end

fprintf('Done!\n')


% %% Get weighting matrix C
% fprintf('Rotating matrix back into ROI space...\n');
% if doSvdOnX
%     C_cropped = Vx*B; % in SVD, Vx'^(-1) = Vx
% else
%     C_cropped = B;
% end
% % Resize C to match size of X
% nPads = size(X,2)-size(C_cropped,2);
% C = zeros(size(X));
% C(:,(1:nT)+floor(nPads/2)) = C_cropped;
% 
% %% Get output matrix D
% fprintf('Applying weighting to original data...\n')
% D = C.*X_norm;
% 
% fprintf('Done!\n')