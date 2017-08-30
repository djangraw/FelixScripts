function residuals = GetFitResiduals(filenames,echoTimes,fits,offsets)

% Created 8/17/15 by DJ.

% Load data
for i=1:numel(filenames)
    V(:,:,:,:,i) = BrikLoad(filenames{i});
end

% Get size constants
sizeV = size(V);
nVoxels = prod(sizeV(1:3));
nT = sizeV(4);
nE = sizeV(5);

% reshape and transform into log space to get fit
Vlog = reshape(log(abs(V)),nVoxels*nT,nE)';
% construct echo times matrix of equal size

% get least squares solution
fitMat = [reshape(offsets,1,numel(offsets)); reshape(fits,1,numel(fits))];
echoTimeReg = [ones(size(echoTimes)); -echoTimes]'; % include ones for offset

% get residuals (note that this is in log units).
residMat = echoTimeReg*fitMat - Vlog;

residuals = reshape(residMat',sizeV);