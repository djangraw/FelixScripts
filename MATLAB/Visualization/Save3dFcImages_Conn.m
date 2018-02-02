function Save3dFcImages_Conn(h,viewTypes)

% Save3dFcImages_Conn(atlasFile,FC,viewtypes)
%
% NOTE: call conn before running this function (to set path/display params)
% To Make conn plot:
% h = PlotAtlasFcIn3d_Conn(atlasFile,FC,sphereSize,roiColors);
%
% INPUTS:
% -h is a handle to a plotting function created with conn_mesh_display.
%
% Created 5/8/17 by DJ.

% Declare defaults
if ~exist('viewTypes','var') || isempty(viewTypes)
    viewTypes = {'left','top'};
end

% prep for image
feval(h,'background',[1 1 1]); % white background
drawnow;
for iView = 1:numel(viewTypes)
    % switch view
    switch viewTypes{iView}
        case 'left'
            feval(h,'view',[-1 0 0],[],0); % left
        case 'top'
            feval(h,'view',[0,-.01,1],[],0); % superior
        case 'back'
            feval(h,'view',[0,-1,0],[],0); % posterior
    end
    % Save result to image
    feval(h,'print',1); % save image with current view
end
end