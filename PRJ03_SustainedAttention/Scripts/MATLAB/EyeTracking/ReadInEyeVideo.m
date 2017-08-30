function video = ReadInEyeVideo(filename,nFrames)

% Created 12/30/15 by DJ.
% Updated 2/9/16 by DJ - added nFrames input

if ~exist('nFrames','var')    
    nFrames=[];
end

% set up video reader
v = VideoReader(filename);

% get (approximate) nFrames if not specified
if isempty(nFrames)
    nFrames = ceil(v.FrameRate*v.Duration);
    goToEnd = true;
else
    goToEnd = false;
end

%% read in video frames
% declare giant uint8 matrix (in a funky way to conserve memory)
zero = uint8(0);
video(v.Height,v.Width,nFrames) = zero;

one_pct = ceil(nFrames/100);
iFrame = 0;
fprintf('===Loading %d frames from %s...===\n',nFrames,filename);
while hasFrame(v) && (goToEnd || iFrame<nFrames)
    if mod(iFrame,one_pct)==0
        fprintf('%d%% done...\n',round(iFrame/nFrames*100));
    end
    iFrame = iFrame+1;
    frame = readFrame(v);
    video(:,:,iFrame) = frame(:,:,1); % convert RGB to gray
end
nFrames = iFrame;
video = flipud(video(:,:,1:nFrames)); % original movie is upside down.
fprintf('Done!\n');
