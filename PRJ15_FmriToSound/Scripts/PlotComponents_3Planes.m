function PlotComponents_3Planes(betas,mask,varex)

% PlotComponents_3Planes(betas,mask)
% 
% Created 12/21/17 by DJ.

if ~exist('mask','var') || isempty(mask)
    mask = any(comps~=0,4);
end

% Plot components
figure(562); clf;
nComps = size(betas,4);
nRows = ceil(sqrt(nComps));
nCols = ceil(nComps/nRows);
mask_scaled = (mask>0)/2; % scaled mask
for i=1:nComps
    subplot(nRows,nCols,i);
    betas_temp = betas(:,:,:,i);
    % scale so that 99.9th percentile weight will saturate color
    betas_temp = betas_temp/GetValueAtPercentile(betas_temp(:),99.9)*0.5; 
    % combine mask and betas
    betasOnMask = cat(4,mask_scaled,mask_scaled+betas_temp,mask_scaled);
    % Plot results
    Plot3Planes(betasOnMask);    
    axis([0 3 0 1]);
    title(sprintf('component %d: variance %.3g',i,varex(i)));
end
colormap gray
