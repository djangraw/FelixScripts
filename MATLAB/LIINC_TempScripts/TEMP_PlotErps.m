% TEMP_PlotErps.m
% Created 2/27/15 by DJ.
Mats = load('sf-13-TargDis-v3pt6-Matrices');
X = Mats.X;
Y = Mats.Y;

if ~exist('chanlocs','var')
    EEG = pop_loadset('sf-13-all-40Hz-fs100-interp-noeog.set');
    chanlocs = EEG.chanlocs;
    clear EEG;
end

%%
D = size(Y,2);
p = size(X,2);
betas_erp = zeros(D,p);
for i=1:p
    betas_erp(:,i) = mean(Y(full(X(:,i))~=0,:),1);
end
T = 101;
M = p/T;
RF_erp = reshape(betas_erp,D,T,M);

%%
tRF = 0:10:1000;
tMaps = 50:100:1000;
sm = GetScalpMaps(RF_erp,tRF,tMaps,100);
figure(201);
PlotScalpMaps(sm,chanlocs,[],tMaps,Mats.events);

%% subtract and get residuals
t_betas = repmat(tRF,1,M);
betas_new = betas_erp(:,t_betas<500);
X_new = X(:,t_betas<500);
Y_recon = X_new*betas_new';
Y_resid = Y-Y_recon;
MSE = mean(Y_resid(iCz,:).^2);
MSY = mean(Y(iCz,:).^2);
fprintf('MSE = %g, MSY=%g\n',MSE,MSY);