function reviewTables = GetAllDistractionReviewTables(subjects)

% reviewTables = GetAllDistractionReviewTables(subjects)
%
% AFNI outputs review files called out.ss_review.SBJXX.txt. This reads them
% in as a table so you can easily compare across subjects.
%
% Created 9/19/16 by DJ.

homedir='/data/jangrawdc/PRJ03_SustainedAttention';
reviewTables = table;
for i=1:numel(subjects)
    fprintf('===subject %d/%d...\n',i,numel(subjects))
    % Get to directory
    subjStr = sprintf('SBJ%02d',subjects(i));
    cd(sprintf('%s/Results/%s',homedir,subjStr));
    datadir = dir('AfniProc*');
    cd(datadir(1).name);
    % Run review script and capture output
    if ~exist(sprintf('out.ss_review.%s.txt',subjStr),'file')
        fprintf('===Running review script for %s...\n',subjStr)
        !./\@ss_review_basic
    end
    % Read in review output as table
    fid = fopen(sprintf('out.ss_review.%s.txt',subjStr));
    fseek(fid,0,'eof'); % find end of file
    eof = ftell(fid);
    fseek(fid,0,'bof'); % rewind to beginning

    subjTable = table;
    while ftell(fid) < eof
        str = fgetl(fid);
        if ~isempty(str) && ~strcmp(str(1),'+')
            [C,matches] = strsplit(str,{'\t',':'},'CollapseDelimiters',true);
            varname = C{1}(isstrprop(C{1},'alphanum'));
            if isempty(str2num(C{2}))
                subjTable.(varname) = strtrim(C{2});
            elseif length(str2num(C{2}))>1
                subjTable.(varname) = {str2num(C{2})};
            else
                subjTable.(varname) = str2num(C{2});
            end
        end
    end
    if i==1
        reviewTables = subjTable;
    else 
        reviewTables = cat(1,reviewTables,subjTable);
    end
end
