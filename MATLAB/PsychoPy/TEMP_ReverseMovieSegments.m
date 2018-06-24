% TEMP_ReverseMovieSegments.m
%
% Read in a movie, flip each second (but keep them in order, then play the 
% result and write it to file.
% 
% Created 2/8/15 by DJ.

olddir = cd;
cd /Users/jangrawdc/Documents/Python/Learning/VideoLectures/
movObj = VideoReader('AncientGreekHistory02-TheDarkAges.mov');

vidWidth = movObj.Width;
vidHeight = movObj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
%%
k = 1;
while k<150 %hasFrame(movObj)
    mov(k).cdata = readFrame(movObj);
    k = k+1;
end

%% make each second play backwards
fs = movObj.FrameRate;
t = (1:length(mov))/fs;

for iSec = 1:ceil(t(end))
    iInSec = find(t>iSec-1 & t<iSec);
    mov(iInSec) = mov(fliplr(iInSec));
end

%% play
hf = figure;
set(hf,'position',[150 150 vidWidth vidHeight]);

movie(hf,mov,1,movObj.FrameRate);

%% write easy

movie2avi(mov,'TEST.avi','fps',fs);

%% write hard

writerObj = VideoWriter('TEST2.avi');
open(writerObj);

for k = 1:length(mov)
   surf(sin(2*pi*k/20)*Z,Z)
   frame = getframe;
   writeVideo(writerObj,frame);
end

close(writerObj);