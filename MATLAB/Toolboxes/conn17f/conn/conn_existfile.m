function out=conn_existfile(filename)

out=false;
if iscell(filename)||size(filename,1)>1
    filename=cellfun(@strtrim,cellstr(filename),'uni',0);
    [filepath,filename,fileext,filenum]=cellfun(@spm_fileparts,filename,'uni',0);
    fullfilename=cellfun(@(a,b,c)fullfile(a,[b c]),filepath,filename,fileext,'uni',0);
    [ufullfilename,nill,idx]=unique(fullfilename);
    try
        out=cellfun(@spm_existfile,ufullfilename);
    catch
        out=cellfun(@(x)~isempty(dir(x)),ufullfilename);
    end
    out=out(idx);
else
    if isempty(deblank(filename)), out=false;
    else
        [filepath,filename,fileext,filenum]=spm_fileparts(deblank(filename));
        try
            out=spm_existfile(fullfile(filepath,[filename,fileext]));
        catch
            out=~isempty(dir(fullfile(filepath,[filename,fileext])));
        end
    end
end
