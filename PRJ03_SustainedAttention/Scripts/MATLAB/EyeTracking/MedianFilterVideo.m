function video = MedianFilterVideo(video)

% Created 12/30/15 by DJ.


% set up 
nFrames = size(video,3);
one_pct = ceil(nFrames/100);
% apply median filter, frame by frame
fprintf('===Applying Median Filter to %d frames...===\n',nFrames);
for i=1:nFrames
    if mod(i,one_pct)==0
        fprintf('%d%% done...\n',round(i/nFrames*100)); %status update
    end
    video(:,:,i) = medfilt2(video(:,:,i), [3 3]);        
end
fprintf('Done!\n')