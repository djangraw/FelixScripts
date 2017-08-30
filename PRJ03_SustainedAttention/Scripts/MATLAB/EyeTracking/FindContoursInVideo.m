function [pos0, pos1, video_interp] = FindContoursInVideo(video,RoiPos)

% -video is a 3D matrix of eye images.
% -RoiPos is [xmin ymin width height]
%
% Created 12/30/15 by DJ. (UNFINISHED!)

%% turn into NaNs
xmin = RoiPos(1);
ymin = RoiPos(2);
w = RoiPos(3);
h = RoiPos(4);

video = video0;
leftLine = [repmat(xmin,h+1,1), ymin+(0:h)'];
rightLine = [repmat(xmin+w,h+1,1), ymin+(0:h)'];
topLine = [xmin+(0:w)', repmat(ymin,w+1,1)];
bottomLine = [xmin+(0:w)', repmat(ymin+h,w+1,1)];

video(leftLine(:,1),leftLine(:,2),:) = 0;
video(rightLine(:,1),rightLine(:,2),:) = 0;
video(topLine(:,1),topLine(:,2),:) = 0;
video(bottomLine(:,1),bottomLine(:,2),:) = 0;

%% Interpolate extreme values
one_pct = ceil(nFrames/100);
nFrames = size(video,3);
[Y,X] = meshgrid(1:size(video,2),1:size(video,1));
isInRoi = X>=xmin & X<=xmin+w & Y>=ymin & Y<=ymin+h;
for i=1:nFrames
    if mod(i,one_pct)==0
        fprintf('%d%% done...\n',round(i/nFrames*100));
    end
    frame = video(:,:,i);
    medianFrame = medfilt2(frame, [3 3]);
    isExtreme = frame<=5 | frame>=250;
    frame(isExtreme & isInRoi) = medianFrame(isExtreme & isInRoi);
    video(:,:,i) = frame;
end
fprintf('Done!\n');
