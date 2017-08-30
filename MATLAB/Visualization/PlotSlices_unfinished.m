function PlotSlices(brick_anat, brick_overlay, info_anat, info_overlay, dim, x_slices)

% Created 4/17/15 by DJ.
% DOESN'T WORK YET.

% manipulate anat brick as need be
[overlaydim,isFlipped] = deal(zeros(1,3));
for iDim=1:3
    overlaydim(iDim) = find(ismember(info_overlay.Orientation,info_anat.Orientation(iDim,:),'rows') | ismember(info_overlay.Orientation,fliplr(info_anat.Orientation(iDim,:)),'rows'));
    isFlipped(iDim) = (info_overlay.Orientation(overlaydim(iDim),1)==info_anat.Orientation(iDim,2));
end
brick_anat = permute(brick_anat,overlaydim);
info_anat.ORIGIN(overlaydim) = info_anat.ORIGIN;
info_anat.DELTA(overlaydim) = info_anat.DELTA;
info_anat.Orientation(overlaydim,:) = info_anat.Orientation;
% info_anat.DELTA = abs(info_anat.DELTA) .* (-2*isFlipped+1);
% info_anat.DELTA = abs(info_anat.DELTA) .* [1 -1 1];
% info_anat.ORIGIN = info_anat.ORIGIN .* (-2*isFlipped+1);

% get positions
xAnat = (1:size(brick_anat,1))*info_anat.DELTA(1) + info_anat.ORIGIN(1);
yAnat = (1:size(brick_anat,2))*info_anat.DELTA(2) + info_anat.ORIGIN(2);
zAnat = (1:size(brick_anat,3))*info_anat.DELTA(3) + info_anat.ORIGIN(3);
xOver = (1:size(brick_overlay,1))*info_overlay.DELTA(1) + info_overlay.ORIGIN(1);
yOver = (1:size(brick_overlay,2))*info_overlay.DELTA(2) + info_overlay.ORIGIN(2);
zOver = (1:size(brick_overlay,3))*info_overlay.DELTA(3) + info_overlay.ORIGIN(3);

if isFlipped(1), xAnat = fliplr(xAnat); end
if isFlipped(2), yAnat = fliplr(yAnat); end
if isFlipped(2), zAnat = fliplr(zAnat); end


x_dim_anat = (1:size(brick_anat,dim))*info_anat.DELTA(dim) + info_anat.ORIGIN(dim);
x_dim_overlay = (1:size(brick_overlay,dim))*info_overlay.DELTA(dim) + info_overlay.ORIGIN(dim);
iSlice_overlay = interp1(x_dim_overlay,1:size(brick_overlay,dim),x_slices,'nearest','extrap');
iSlice_anat = interp1(x_dim_anat,1:size(brick_anat,dim),x_slices,'nearest','extrap');


weight_anat =1;% 0.5;
weight_overlay = 0.5;%1-weight_anat;
% set up plots
nRows = ceil(sqrt(numel(x_slices)));
nCols = ceil(numel(x_slices)/nRows);
clf;
for i=1:numel(x_slices)
    hAxis = subplot(nRows,nCols,i);
    hold on;
    switch dim
        case 1 % sagittal
            foo_anat = permute(squeeze(brick_anat(iSlice_anat(i),:,:)),[2 1]);
            foo_over = permute(squeeze(brick_overlay(iSlice_overlay(i),:,:)),[2 1]);
            xPlot_anat = zAnat;
            yPlot_anat = yAnat;
            xPlot_over = zOver;
            yPlot_over = yOver;            
        case 2 % coronal
            foo_anat = permute(squeeze(brick_anat(:,iSlice_anat(i),:)),[2 1]);
            foo_over = permute(squeeze(brick_overlay(:,iSlice_overlay(i),:)),[2 1]);
            xPlot_anat = zAnat;
            yPlot_anat = xAnat;
            xPlot_over = zOver;
            yPlot_over = xOver;
        case 3 % axial
            foo_anat = permute(squeeze(brick_anat(:,:,iSlice_anat(i))),[2 1]);
            foo_over = permute(squeeze(brick_overlay(:,:,iSlice_overlay(i))),[2 1]);
            xPlot_anat = yAnat;
            yPlot_anat = xAnat;
            xPlot_over = yOver;
            yPlot_over = xOver;
    end
    anat = foo_anat/max(brick_anat(:))*weight_anat;
    overlay_2d = foo_over>0;%/max(abs(brick_overlay(:)));%*weight_overlay;
    overlay_rgb = cat(3,overlay_2d.*(overlay_2d>0), zeros(size(overlay_2d)), -overlay_2d.*(overlay_2d<0));
    hAnat = imagesc(xPlot_anat,yPlot_anat,cat(3,anat,anat,anat));
    hOver = imagesc(xPlot_over,yPlot_over,overlay_rgb); 
%     hAnat = imshow(cat(3,anat,anat,anat),'XData',xPlot_anat,'YData',yPlot_anat);
%     hOver = imshow(overlay_rgb,'XData',xPlot_over,'YData',yPlot_over);
    set(hOver,'alphaData',weight_overlay);
    title(sprintf('x = %.2f',x_slices(i)));
end
