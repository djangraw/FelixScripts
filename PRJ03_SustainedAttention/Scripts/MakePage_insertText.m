function [I,words,pos] = MakePage_insertText(pagedim,text)

% Created 3/24/15 by DJ.

I = ones(pagedim);

words = strsplit(text);
char_width = 10;
char_height = 21;
char_per_line = 50;

iChar = 1;
iLine = 1;
pos = nan(numel(words),4);
for i=1:numel(words)
    xy = [iChar*char_width, iLine*char_height];
    pos(i,:) = [xy, length(words{i})*char_width, char_height];
    if iChar+length(words{i})>char_per_line
        iLine = iLine+1;
    end
    iChar = mod(iChar+length(words{i}),char_per_line);
end
I = insertText(I,pos(:,1:2),words);

cla; hold on;
imagesc(I);
set(gca,'xdir','normal','ydir','reverse');
plot(pos(:,1),pos(:,2),'r.');
plot(pos(:,1)+pos(:,3),pos(:,2)+pos(:,4),'r.');
axis([0, size(I,1), 0, size(I,2)]);
