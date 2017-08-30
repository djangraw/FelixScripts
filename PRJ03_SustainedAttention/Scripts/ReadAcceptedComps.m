function okComps = ReadAcceptedComps(subject,run)

% okComps = ReadAcceptedComps(subject,run)
%
% TED folders must be in current folder.
%
% Created 10/6/16 by DJ.

fid = fopen(sprintf('TED.SBJ%02d.r%02d/comp_table.txt',subject,run));
str = '#';
while str(1)=='#'
    str = fgetl(fid);
    if strncmp(str,'#ACC',4)
        iEnd = find(str=='#',1,'last');
        accComps = str2num(str(5:iEnd-1)) + 1;
    elseif strncmp(str,'#IGN',4)
        iEnd = find(str=='#',1,'last');
        ignComps = str2num(str(5:iEnd-1)) + 1;
    end
end
okComps = sort([accComps, ignComps]);
fclose(fid);