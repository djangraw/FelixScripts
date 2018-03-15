function h = PrintAfniConnResults(subjContrast,fcContrast,iRoi,thresh,viewTypes,roiName,contrastName,connProject,analysisName)

% Makes and saves a jpg of a Conn "3D ball" FC plot. 
%
% h = PrintAfniConnResults(subjContrast,fcContrast,iRoi,thresh,viewTypes,roiName,contrastName,connProject,analysisName)
%
% Created 2/1/18 by DJ.
% Updated 2/2/18 by DJ - added subjContrast.
% Updated 3/14/18 by DJ - added more inputs.

% Parse inputs
if ~exist('subjContrast','var') || isempty(subjContrast)
    subjContrast = 'AllSubjects';
end
if ~exist('fcContrast','var') || isempty(fcContrast)
    fcContrast='str.uns';
end
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi=151;
end
if ~exist('thresh','var') || isempty(thresh)
    thresh=0.05;
end
if ~exist('viewTypes','var') || isempty(viewTypes)
    viewTypes = {'left'};
end
if ~exist('roiName','var') || isempty(roiName)
    roiName = '';
end
if ~exist('contrastName','var') || isempty(contrastName)
    contrastName = fcContrast;
end
if ~exist('connProject','var') || isempty(connProject)
    connProject = 'conn_project_SRTT_d3';
end
if ~exist('analysisName','var') || isempty(analysisName)
    analysisName = 'ANALYSIS_01';
end

%% Load
info=GetSrttConstants();
% load(sprintf('%s/AfniConn/conn_project_SRTT_d3/results/secondlevel/ANALYSIS_01/AllSubjects/%s/ROI.mat',info.PRJDIR,contrastType));
load(sprintf('%s/AfniConn/%s/results/secondlevel/%s/%s/%s/ROI.mat',info.PRJDIR,connProject,analysisName,subjContrast,fcContrast));
%% Plot
% iRoi = 151;
% thresh = 0.05;

p = cat(1,ROI(iRoi).p(1:268));
isPos = p<0.5;
p(~isPos) = 1-p(~isPos);
p_fdr=reshape(conn_fdr(p(:)),size(p)); % analysis-level correction
isSig = (p_fdr<thresh).*isPos - (p_fdr<thresh).*(~isPos);
% one-sided
% p_fdr=reshape(conn_fdr(p(:)),size(p)); % analysis-level correction
% isSig = (p_fdr<(thresh/2)) - (p_fdr>(1-thresh/2));

%% plot
% convert to matrix
foo = zeros(268);
foo(iRoi,:) = isSig;
foo(:,iRoi) = isSig;
if ~any(foo(:)~=0)
    fprintf('roi %d; no edges survive!\n',iRoi);
    return;
end
% Plot with conn
h = PlotShenFcIn3d_Conn(foo);
% Change background and figure size
feval(h,'background',[1 1 1]); % white background
set(gcf,'Units','points','Position',[0  360  330  280]);
if ~isempty(roiName)
    title(sprintf('%s contrast, ROI %d (%s), q<%g',contrastName,iRoi,roiName,thresh));
else
    title(sprintf('%s contrast, ROI %d, q<%g',contrastName,iRoi,thresh));
end
for iView = 1:numel(viewTypes)
    switch viewTypes{iView}
        case 'left'
            feval(h,'view',[-1 0 0],[],0); % left
        case 'top'
            feval(h,'view',[0,-.01,1],[],0); % superior
        case 'back'
            feval(h,'view',[0,-1,0],[],0); % posterior
    end
    drawnow;
    % print
    if ~isempty(roiName)
        filename = sprintf('%s/Results/AfniConn_%s_%s_%s_p%g_%s.jpg',...
            info.PRJDIR,subjContrast,contrastName,roiName,thresh,viewTypes{iView});
    else
        filename = sprintf('%s/Results/AfniConn_%s_%s_roi%03d_p%g_%s.jpg',...
            info.PRJDIR,subjContrast,contrastName,iRoi,thresh,viewTypes{iView});
    end
    conn_print(filename,'-djpeg90','-opengl','-nogui');
end
% close result
close(gcf);
% Save3dFcImages_Conn(h); % left and top