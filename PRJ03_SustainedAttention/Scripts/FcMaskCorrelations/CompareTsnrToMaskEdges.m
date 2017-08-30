function CompareTsnrToMaskEdges(fcMask,atlas,tsnr)

% CompareTsnrToMaskEdges(fcMask,atlas,tsnr)
%
% Created 10/20/16 by DJ.

% Load tsnr
if iscell(tsnr)
    for i=1:numel(tsnr)
        if ischar(tsnr{i})
            tsnr{i} = BrikLoad(tsnr{i});
        end
    end
    tsnr = cat(4,tsnr{:});
elseif ischar(tsnr)
    tsnr = BrikLoad(tsnr);
end

% Load atlas
if iscell(atlas)
    for i=1:numel(atlas)
        if ischar(atlas{i})
            atlas{i} = BrikLoad(atlas{i});
        end
    end
    atlas = cat(4,atlas{:});
elseif ischar(atlas)
    atlas = BrikLoad(atlas);
end

% Get mean TSNR in each ROI
nRois = max(atlas(:));
meanTsnr = nan(1,nRois);
for i=1:nRois
    isInRoi = atlas==i;
    meanTsnr(i) = mean(tsnr(isInRoi));
end

% Get # mask edges for each ROI
fcMask = UnvectorizeFc(VectorizeFc(fcMask), 0); % make upper triangular
fcMask = fcMask + fcMask'; % make symmetric
nEdges = sum(fcMask,1);

% Correlate the two
cla;
plot(meanTsnr,nEdges,'.');
xlabel('mean TSNR in ROI')
ylabel('# edges in FC mask')
[r,p] = corr(meanTsnr',nEdges');
title(sprintf('r=%.3g, p=%.3g\n',r,p));