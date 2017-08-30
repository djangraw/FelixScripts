function dataVar = MapLocalVar(dataBrick,roiRad)

% Created 11/1/16 by DJ.

% Set up
if ischar(dataBrick)
    dataBrick = BrikLoad(dataBrick);
end

% directionless sensitivity
% dataSize = size(dataBrick);
% Get "neighborhood"
SE = strel('sphere',roiRad);

dataVar = stdfilt(dataBrick,SE.Neighborhood).^2;