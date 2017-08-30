function atlasRGB = MapColorsOntoAtlas(atlas,colors)

% atlasRGB = MapColorsOntoAtlas(atlas,colors)
%
% An RGB version of MapValuesOntoAtlas.
%
% Created 3/24/16 by DJ.

atlasRGB = nan([size(atlas), 3]);
for i=1:3
    atlasRGB(:,:,:,i) = MapValuesOntoAtlas(atlas,colors(:,i));
end
