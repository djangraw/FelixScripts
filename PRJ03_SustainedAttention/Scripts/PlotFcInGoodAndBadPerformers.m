function PlotFcInGoodAndBadPerformers(FCtop,FCbottom,atlas,atlasLabels,atlasColors,clim)

% PlotFcInGoodAndBadPerformers(FCtop,FCbottom,atlas,atlasLabels,atlasColors,clim)
% 
% Created 2/22/17 by DJ.

% Get clim
FCtop_grp = GroupFcByRegion(FCtop,atlasLabels,'mean',true);
FCbottom_grp = GroupFcByRegion(FCbottom,atlasLabels,'mean',true);
if ~exist('clim','var') || isempty(clim)    
    clim = [-1 1] * max(abs([FCtop_grp(:); FCbottom_grp(:)]));
end
clim_diff = [-1 1] * max(abs(FCtop_grp(:)-FCbottom_grp(:)));

% Visualize as matrices
clf;
subplot(1,3,1);
PlotFcMatrix(FCtop,clim,atlas,atlasLabels,true,atlasColors,'mean');
title('Top third of performers');
subplot(1,3,2);
PlotFcMatrix(FCbottom,clim,atlas,atlasLabels,true,atlasColors,'mean');
title('Bottom third of performers');
subplot(1,3,3);
PlotFcMatrix(FCtop-FCbottom,clim_diff,atlas,atlasLabels,true,atlasColors,'mean');
title('Top - Bottom third of performers');

% Visualize in 3D?