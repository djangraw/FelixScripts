function [mov, frameRate] = GetMovie(movieFilename,tStart,tEnd)

% Created 4/28/15 by DJ.

if ischar(movieFilename)
    fprintf('Loading movie...\n');
    movObj = VideoReader(movieFilename);
else
    movObj = movieFilename;
end

vidWidth = movObj.Width;
vidHeight = movObj.Height;
frameRate = movObj.FrameRate;

% edit times
if tStart<0
    fprintf('tStart was <0... changing to 0.\n');
    tStart = 0;
end
if tEnd>movObj.Duration
    fprintf('tEnd was > duration of movie... changing to %f.\n',movObj.Duration);
    tEnd = movObj.Duration;
end

% Create a movie structure array, mov.
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);

switch version('-release')
    case '2013a'
        iStart = round(tStart*movObj.FrameRate);
        nFrames = round((tEnd-tStart)*movObj.FrameRate);
        fprintf('Getting ~%d frames...\n',(tEnd-tStart)*movObj.FrameRate)
        for k=1:nFrames
            if mod(k,100)==0
                fprintf('%d\n',k);
            else
                fprintf('.');
            end
            mov(k).cdata = read(movObj,iStart+k-1);
        end
    otherwise
        % Read one frame at a time until the end of the video is reached.
        set(movObj,'CurrentTime',tStart);
        k = 1;
        fprintf('Getting ~%d frames...\n',(tEnd-tStart)*movObj.FrameRate)
        while movObj.CurrentTime<tEnd && hasFrame(movObj)
            if mod(k,100)==0
                fprintf('%d\n',k);
            else
                fprintf('.');
            end
            mov(k).cdata = readFrame(movObj);
            k = k+1;
        end
end
fprintf('\n')