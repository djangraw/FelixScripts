function [out,V]=conn_file(filename,doconvert)
if nargin<2||isempty(doconvert), doconvert=true; end
filename=char(filename);
[V,str,icon,filename]=conn_getinfo(filename,doconvert);
out={fliplr(deblank(fliplr(deblank(filename)))),str,icon};

