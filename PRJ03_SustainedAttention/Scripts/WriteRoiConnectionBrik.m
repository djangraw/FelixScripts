function WriteRoiConnectionBrik(atlas,atlasInfo,fcNetwork,iROI,outFilename)

% WriteRoiConnectionBrik(atlas,atlasInfo,fcNetwork,iROI,outFilename)
%
% INPUTS:
% -atlas is a 3D matrix of atlas values, where each ROI has a different
% integer value.
% -atlasInfo is a struct from loading the atlas.
% -fcNetwork is an nROIs x nROIs symmetric or upper triangular matrix.
% -iROI is a scalar or vector of the atlas ROIs
% -outFilename is a string indicating the path & filename where you want to
% write the file.
%
% Created 2/2/17 by DJ.

% default filename
if ~exist('outFilename','var') || isempty(outFilename)
    if numel(iROI)==1
        outFilename = sprintf('Distraction-Roi%03d-NetworkCxns.BRIK',iROI);
    else
        outFilename = sprintf('Distraction-Roi%03dto%03d-NetworkCxns.BRIK',min(iROI),max(iRoi));
    end
end

% make it symmetric
if ~issymmetric(fcNetwork)
    fcNetwork = UnvectorizeFc(VectorizeFc(fcNetwork),0,true);
end
% get sum across ROIs of interest
fcSum = sum(fcNetwork(:,iROI),2);

% write brick
atlasMap = MapValuesOntoAtlas(atlas,fcSum);
WriteBrik(atlasMap,atlasInfo,struct('Prefix',outFilename,'Overwrite','y'));