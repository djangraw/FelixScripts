function GetRoiWhereami(atlas,atlasInfo,iRoi)

% Created 12/21/16 by DJ.

roiPos = GetAtlasRoiPositions(atlas);

[~,roiPos_xyz] = AFNI_Index2XYZcontinuous(roiPos(iRoi,:),atlasInfo);

for i=1:numel(iRoi)
    command = sprintf('whereami %f %f %f',roiPos_xyz(i,:));
    [status,cmdout] = unix(command);
    fprintf('===ROI %d (%f, %f, %f)===\n',iRoi(i),roiPos_xyz(i,:));
    fprintf(cmdout);
end
fprintf('===Done!===\n');