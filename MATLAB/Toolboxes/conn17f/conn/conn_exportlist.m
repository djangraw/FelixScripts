function conn_exportlist(cbo,filename,header)
% conn_exportlist
% exports uicontrol string

if nargin<1||isempty(cbo),cbo=gcbo; end
if nargin<2||isempty(filename)
    [filename,filepath]=uiputfile({'*.txt','*.txt (text file)'},'Save table as');
    if ~ischar(filename), return; end
    filename=fullfile(filepath,filename);
end
[filepath,filename,fileext]=fileparts(filename);

str=cellstr(get(cbo,'string'));
str=regexprep(str,'<[^<>]*>','');
fh=fopen(fullfile(filepath,[filename,fileext]),'wt');
if nargin>2, fprintf(fh,'%s\n',header); end
for n=1:numel(str),
    fprintf(fh,'%s\n',str{n});
end
fclose(fh);
end