function newGifRgb = InterpolateGif(gifData,map,tGif,newTgif)

% Created 4/25/17 by DJ.

% Declare constants
sizeGif = [size(gifData,1),size(gifData,2)];
nFrames = size(gifData,4);

% Convert to RGB
gifRgb = nan([sizeGif,3,nFrames]);
for i=1:nFrames    
    gifRgb(:,:,:,i) = ind2rgb(gifData(:,:,:,i),map);
end

% Interpolate
nNewFrames = length(newTgif);
gifRgbVec = reshape(gifRgb,[sizeGif(1)*sizeGif(2)*3,nFrames]);
newGifRgbVec = interp1(tGif,gifRgbVec',newTgif,'linear')';
newGifRgb = reshape(newGifRgbVec,[sizeGif(1),sizeGif(2),3,nNewFrames]);
