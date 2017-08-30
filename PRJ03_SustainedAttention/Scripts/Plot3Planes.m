function [hImg,hCross,hLine] = Plot3Planes(dataBrick,slicecoords,rectpos)

% [hImg,hCross,hLine] = Plot3Planes(dataBrick,slicecoords,rectpos)
%
% INPUTS:
% -dataBrick is an nX x nY x nZ x nC matrix of data. If nC = 3, it's RGB,
% otherwise the mean across dimension 4 will be taken.
% -slicecoords is a 3-element vector of the x,y,z coordinate where you'd
% like to draw the slices and the crosshairs.
% -rectpos is a 4-element vector indicating the [x,y,w,h] of the rectangle
% in which you'd like to plot the data.
%
% OUTPUTS:
% -hImg is a 3-element vector of handles to images (the slices).
% -hCross is a 2x3 matrix of handles to the green crosshairs lines.
% -hLines is a 2-element vector of handles to the white lines between the
% images.
%
% Created 12/10/15 by DJ.
% Updated 12/11/16 by DJ - allow 1-color plots in addition to RGB.

% handle inputs
if size(dataBrick,4)~=3
    dataBrick = mean(dataBrick,4); %repmat(mean(dataBrick,4),[1 1 1 3]);
end
[nX,nY,nZ,nC] = size(dataBrick);

if ~exist('slicecoords','var') || isempty(slicecoords)
    foo = mean(dataBrick,4);
    [~,iMax] = max(foo(:));
    slicecoords = nan(1,3);
    [slicecoords(1),slicecoords(2),slicecoords(3)] = ind2sub([nX,nY,nZ],iMax);
end
if ~exist('rectpos','var') || isempty(rectpos)
    rectpos = [0 0 3 1];
end
    
% plot
hold on;
x = linspace(0,1,nX);
y = linspace(0,1,nY);
z = linspace(0,1,nZ);
hImg(1) = imagesc(scale(y,'x'),scale(z,'y'),permute(squeeze(dataBrick(slicecoords(1),:,:,:)),[2 1 3]));
hImg(2) = imagesc(scale(x+1,'x'),scale(z,'y'),permute(squeeze(dataBrick(:,slicecoords(2),:,:)),[2 1 3]));
hImg(3) = imagesc(scale(x+2,'x'),scale(y,'y'),permute(squeeze(dataBrick(:,:,slicecoords(3),:)),[2 1 3]));
% draw crosshairs
hCross(1,1) = plot(scale([1 1]*y(slicecoords(2)),'x'),scale([0 1],'y'),'g');
hCross(2,1) = plot(scale([0 1],'x'),scale([1 1]*z(slicecoords(3)),'y'),'g');
hCross(1,2) = plot(scale([1 1]+x(slicecoords(1)),'x'),scale([0 1],'y'),'g');
hCross(2,2) = plot(scale([1 2],'x'),scale([1 1]*z(slicecoords(3)),'y'),'g');
hCross(1,3) = plot(scale([2 2]+x(slicecoords(1)),'x'),scale([0 1],'y'),'g');
hCross(2,3) = plot(scale([2 3],'x'),scale([1 1]*y(slicecoords(2)),'y'),'g');

% draw separation lines
hLine(1) = plot(scale([1 1],'x'),scale([0 1],'y'),'w');
hLine(2) = plot(scale([2 2],'x'),scale([0 1],'y'),'w');

% Put coordinates inside specified rectangle
function newcoords = scale(coords,xory)

    switch xory
        case 'x'
            rstart = rectpos(1);
            rsize = rectpos(3)/3; % because there are 3 plots arranged horizontally 
        case 'y'
            rstart = rectpos(2);
            rsize = rectpos(4);
    end
    newcoords = rstart + coords*rsize;
end

end
