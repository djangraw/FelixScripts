function [filenamesout,filestructsout]=conn_dir(PATHNAME,varargin)
% CONN_DIR RECURSIVE DIR
% e.g. filenames=CONN_DIR('*.m');
%      filenames=CONN_DIR('c:/*.nii');
%

DORECURSIVE=true;
OUTPUTCELL=false;
if ~isempty(varargin)&&any(strcmp(varargin,'-R')), DORECURSIVE=false; varargin=varargin(~strcmp(varargin,'-R')); end
if ~isempty(varargin)&&any(strcmp(varargin,'-cell')), OUTPUTCELL=true; varargin=varargin(~strcmp(varargin,'-cell')); end
if ~isempty(varargin), FILTER2=varargin{1}; else FILTER2=''; end

[PATHNAME,NAME,EXT]=fileparts(PATHNAME);
if isempty(PATHNAME),PATHNAME=pwd; end
FILTER=[NAME,EXT];
FILENAMES={};
FILESTRUCTS=[];
DODISP=~nargout;
conn_dir_int(PATHNAME,FILTER,FILTER2,DORECURSIVE);
if nargout,
    if OUTPUTCELL, filenamesout=FILENAMES;
    else filenamesout=char(FILENAMES);
    end
    filestructsout=FILESTRUCTS;
end

    function conn_dir_int(pathname,filter,filter2,dorecursive)
        filterrest=filter;
        [filternow,filterrest]=strtok(filterrest,';');
        while ~isempty(filternow),
            filename=fullfile(pathname,fliplr(deblank(fliplr(deblank(filternow)))));
            dir0=dir(filename);
            [nill,idx]=sort({dir0.name});
            for n1=1:length(dir0),
                if ~dir0(idx(n1)).isdir&&(isempty(filter2)||~isempty(regexp(dir0(idx(n1)).name,filter2))),
                    %if ~dir0(idx(n1)).isdir,
                    txt=fullfile(pathname,dir0(idx(n1)).name);
                    if size(FILENAMES,1)<1e6, % Change this value to increase the maximum number of FILENAMES displayed
                        FILENAMES=[FILENAMES {txt}];
                        FILESTRUCTS=[FILESTRUCTS dir0(idx(n1))];
                    else return; end
                    if DODISP,disp(txt);end
                end
            end
            [filternow,filterrest]=strtok(filterrest,';');
        end
        if dorecursive,
            dir0=dir(pathname);
            [names,idx]=sortrows(strvcat(dir0(:).name));
            for n1=1:length(dir0),
                if dir0(idx(n1)).isdir && ~strcmp(dir0(idx(n1)).name,'.') && ~strcmp(dir0(idx(n1)).name,'..'),
                    conn_dir_int(fullfile(pathname,dir0(idx(n1)).name),filter,filter2,dorecursive);
                end
            end
        end
    end
end

