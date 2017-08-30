function PlayMovie(mov,frameRate, hf, addVisuals)

% Created 4/27/15 by DJ.

if ~exist('hf','var') || isempty(hf)
    hf = figure;
end
if ~exist('addVisuals','var') || isempty(addVisuals)
    addVisuals = true;
end

% add visuals if requested
movWidth = size(mov(1).cdata,2);
movHeight = size(mov(1).cdata,1);
startPos = round([movHeight*0.9, movWidth*0.1]);
endPos = round([movHeight*0.9,movWidth*0.9]);
barSize = round([movWidth*0.02, movHeight*0.05]);
nFrames = numel(mov);
if addVisuals
    for i=1:nFrames        
        mov(i).cdata(startPos(1):startPos(1)+barSize(1), startPos(2):endPos(2)+barSize(2),:) = 0;
        mov(i).cdata(startPos(1):startPos(1)+barSize(1), startPos(2)+(endPos(2)-startPos(2))/2+(0:barSize(2)),1) = 255;
        pos = round(startPos + (endPos-startPos)*i/nFrames);        
        mov(i).cdata(pos(1):pos(1)+barSize(1), pos(2):(pos(2)+barSize(2)),:) = 255;
%         mov(i).cdata = insertText(mov(i).cdata,pos,i);
    end
end

% Size a figure based on the video's width and height. Then, play back the movie once at the video's frame rate.
fprintf('Playing movie...\n')
set(hf,'position',[150 150 movWidth movHeight]);
movie(hf,mov,1,frameRate);
set(hf,'ButtonDownFcn',{@ReplayMovie,hf,mov,frameRate});
fprintf('Done!\n')

end

function ReplayMovie(hObj,hOther,hf,mov,frameRate)
    movie(hf,mov,1,frameRate)
end