function compTc = GetComponentTimecourses(nii_filename,compWeights)

% compTc = Get100RunsTimecoursesOfComponents(nii_filename,compWeights)
%
% Created 12/21/17 by DJ.

% Load data
if ischar(nii_filename)
    dataBrick = load_nii(nii_filename);
    dataBrick = dataBrick.img;
elseif isstruct(nii_filename)
    dataBrick = nii_filename.img;
else
    dataBrick = nii_filename;
end

% Scale data brick
meanDataBrick = mean(dataBrick,4);
nT = size(dataBrick,4);
dataBrick_scaled = (dataBrick-repmat(meanDataBrick,1,1,1,nT))./(repmat(meanDataBrick,1,1,1,nT)+eps)*100; % in pct units

% Apply weights
nComps = size(compWeights,4);
compTc = nan(nComps,nT);
for i=1:nComps
%     compWeightScale = sqrt(sum(sum(sum(compWeights(:,:,:,i).^2)))); % RMS
    compWeightScale = 1;
    for j=1:nT        
        compTc(i,j) = sum(sum(sum(compWeights(:,:,:,i).*dataBrick_scaled(:,:,:,j))))/compWeightScale;
    end
end