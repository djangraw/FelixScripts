function [Gx,Gy,Gz] = MapLocalGradient(dataBrick)

% Created 11/1/16 by DJ.

% Set up
if ischar(dataBrick)
    dataBrick = BrikLoad(dataBrick);
end

[Gx,Gy,Gz] = imgradientxyz(dataBrick);