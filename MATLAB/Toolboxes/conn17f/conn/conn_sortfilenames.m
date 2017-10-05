function [files,idx]=conn_sortfilenames(files)
% sorts strings with numbers

ischarfilename=ischar(files);
if ischarfilename, files=cellstr(files); end

n=max(cellfun('length',files));
tfiles=regexprep(files,'\d+',['${[repmat(''0'',1,max(0,',num2str(n),'-numel($0))) $0]}']);
[nill,idx]=sort(tfiles);
files=files(idx);
if ischarfilename, files=char(files); end
