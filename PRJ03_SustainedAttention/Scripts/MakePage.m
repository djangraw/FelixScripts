function [I,words,pos,truepos] = MakePage(longstring)

% Created 3/24/15 by DJ.
cla; hold on;
set(gca,'FontName','Courier New'); % be sure to choose fixed width font
pagedim = [500 500];
axis([0, pagedim(1), 0, pagedim(2)]);
set(gca,'xdir','normal','ydir','reverse');


words = strsplit(longstring);
char_width = 4.2;
char_height = 16.4474;
char_per_line = 20;
fontsize = 50;

iChar = 1;
iLine = 1;
pos = nan(numel(words),4);
truepos = pos;
for i=1:numel(words)
    xy = [iChar*char_width, iLine*char_height];
    pos(i,:) = [xy, length(words{i})*char_width, char_height];
    h = text(pos(i,1),pos(i,2),words{i},'FontName','FixedWidth','FontSize',fontsize,...
        'VerticalAlignment','cap','HorizontalAlignment','left',...
        'Margin',eps,'EdgeColor','b');
    truepos(i,:) = get(h,'Extent');
    % update position
    if (iChar+length(words{i}))>=char_per_line
        iLine = iLine+1;
        iChar = 1;
    else
        iChar = iChar+length(words{i})+1; % add 1 for space
    end
end
plot(pos(:,1),pos(:,2),'r.');
plot(pos(:,1)+pos(:,3),pos(:,2)+pos(:,4),'g.');

I = getframe(gcf);

