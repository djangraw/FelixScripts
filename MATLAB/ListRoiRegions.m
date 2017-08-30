function ListRoiRegions(atlas,atlasInfo,iRoi,whereamiAtlas)

% Created 12/21/16 by DJ.

% Declare defaults
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi = 1:max(atlas(:));
end
if ~exist('whereamiAtlas','var') || isempty(whereamiAtlas)
    whereamiAtlas = 'CA_ML_18_MNIA'; % cortical
%     whereamiAtlas = 'DD_DESAI_MPM'; % subcortical
end


roiPos = GetAtlasRoiPositions(atlas);

[~,roiPos_xyz] = AFNI_Index2XYZcontinuous(roiPos(iRoi,:),atlasInfo);

fprintf('===%s Atlas===\n',whereamiAtlas);
for i=1:numel(iRoi)
    command = sprintf('whereami %f %f %f -atlas %s -max_areas 1 > tmp.txt',roiPos_xyz(i,:),whereamiAtlas);
    [status,cmdout] = unix(command);
    % Read it in
    C = dataread('file','tmp.txt','%s','delimiter','\n');
    iPoint = find(strncmp('Focus point:',C,length('Focus point:')),1);
    foo = strsplit(C{iPoint},': ');
    fprintf('ROI %d: %s\n',iRoi(i),foo{2});
end
delete tmp.txt
fprintf('===Done!===\n');