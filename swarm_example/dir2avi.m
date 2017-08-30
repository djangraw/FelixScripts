function dir2avi(framepath,ofile,frametype,size_percent,framerate)
% dir2avi(framepath,ofile,frametype,size_percent,framerate)
%
% This function makes an avi object, finds all of the image files in a
% directory, and adds them as frames to the avi.  It will use the order
% specified by the ascii order of the file names.  If not variables are
% passed, it will just look in the current working directory and save an avi
% there.
%
% Written by godlovedc@helix.nih.gov 2015-11-13
%
% OPTIONAL INPUT:
%     framepath    = where to look for the images to convert to video frames
%                    (defualts to working directory)
%     ofile        = name (and perhaps directory) to save .avi file (defaults
%                    to movie.avi and will add a number to the name if the
%                    file already exists to avoid overwriting)
%     frametype    = what is the image format to convert to frames (.tiff,
%                    .jpg, etc. default is .png)
%     size_percent = used to resize movie frames if desired (default 100%)
%     framerate    = in frames per second (fps default is 30)
%
% see also VideoWriter, imread, imwrite, imresize, and im2frame

% set default vars if the users hasn't provided input
if nargin < 5; framerate    = 30;      end
if nargin < 4; size_percent = 100;     end
if nargin < 3; frametype    = '.png';  end
if nargin < 2; ofile        = 'movie'; end
if nargin < 1; framepath    = pwd;     end

% make sure to include the following for compiling
if ischar(framerate),    eval(sprintf('framerate = %s;',framerate)),      end
if ischar(size_percent), eval(sprintf('size_percent= %s;',size_percent)), end

% check to see if the movie name exists and don't overwrite it
orig    = ofile;
is_file = 2;
append_num  = 1;
while exist([ofile '.avi'],'file') == is_file;
    
    ofile  = [orig num2str(append_num)];
    append_num = append_num + 1;
    
end


write_vid = VideoWriter([ofile '.avi']);
write_vid.Quality = 100;
write_vid.FrameRate = framerate;
open(write_vid)

frame_list = dir(fullfile(framepath,['*' frametype]));

for ii = 1:length(frame_list)
    
    frame = frame_list(ii).name;
    frame = imread(fullfile(framepath,frame)); 
    [rows, cols, ~] = size(frame);
    frame = imresize(frame,round([rows cols]*(size_percent/100)));
    frame = im2frame(frame);
    writeVideo(write_vid,frame)
    
end

close(write_vid)
