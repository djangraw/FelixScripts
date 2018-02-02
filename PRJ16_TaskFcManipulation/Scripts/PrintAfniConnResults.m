function h = PrintAfniConnResults(contrastType,iRoi,thresh,viewTypes,roiName)
% PrintAfniConnResults.m
%
% Created 2/1/18 by DJ.

% Parse inputs
if ~exist('contrastType','var') || isempty(contrastType)
    contrastType='str.uns';
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


%% Load
info=GetSrttConstants();
load(sprintf('%s/AfniConn/conn_project_SRTT_d3/results/secondlevel/ANALYSIS_01/AllSubjects/%s/ROI.mat',info.PRJDIR,contrastType));

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
% Plot with conn
h = PlotShenFcIn3d_Conn(foo);
% Change background and figure size
feval(h,'background',[1 1 1]); % white background
set(gcf,'Units','points','Position',[0  360  330  280]);
if ~isempty(roiName)
    title(sprintf('%s contrast, ROI %d (%s), q<%g',contrastType,iRoi,roiName,thresh));
else
    title(sprintf('%s contrast, ROI %d, q<%g',contrastType,iRoi,thresh));
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
    filename = sprintf('%s/Results/AfniConn_%s_roi%03d_p%g_%s.jpg',...
        info.PRJDIR,contrastType,iRoi,thresh,viewTypes{iView});
    conn_print(filename,'-djpeg90','-opengl','-nogui');
end
% close result
close(gcf);
% Save3dFcImages_Conn(h); % left and top