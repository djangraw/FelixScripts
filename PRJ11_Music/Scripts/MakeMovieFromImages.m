function MakeMovieFromImages(imageNames,movieName,frameRate)

% MakeMovieFromImages(imageNames,movieName,frameRate)
%
% Created 5/18/17 by DJ.

if ~strcmp(movieName(end-3:end),'.avi')
    movieName = [movieName '.avi'];
end

if ischar(imageNames) && any(imageNames=='*')
    dirOut = dir(imageNames);
    imageNames = {dirOut.name};
    if isfield(dirOut,'folder')
        imageFolders = {dirOut.folder};
    else
        imageFolders = repmat({''},size(imageNames));
    end
else
    imageFolders = repmat({''},size(imageNames));
end

% Set up video
tic;
fprintf('Setting up...\n');
outputVideo = VideoWriter(movieName);
outputVideo.FrameRate = frameRate;
open(outputVideo)

% Loop through the image sequence, load each image, and then write it to the video.
fprintf('Writing %d frames...\n',length(imageNames));
for ii = 1:length(imageNames)
   img = imread(fullfile(imageFolders{ii},imageNames{ii}));
   writeVideo(outputVideo,img)
end

% Finalize the video file.
fprintf('Finalizing video...\n');
close(outputVideo)
fprintf('Done! Took %.3g seconds\n',toc);
