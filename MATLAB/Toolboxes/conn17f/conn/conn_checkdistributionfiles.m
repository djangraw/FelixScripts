function [ok,files]=conn_checkdistributionfiles(filename)
if isdeployed, ok=true; files={}; return; end
if ~nargin||isempty(filename), 
    conn_checkdistributionfiles spm;
    conn_checkdistributionfiles conn;
    return
end
thispath=which(filename);
if isempty(thispath), 
    fprintf('Error: %s not found!\n',filename); 
    switch(filename)
        case 'spm',
            fprintf(['To install SPM follow these instructions:\n',...
                    '  SPM installation:\n',...
                    '    1) Download the SPM installation spm*.zip file from http://www.fil.ion.ucl.ac.uk/spm and uncompress the contents of this file in your desired target installation folder\n',...
                    '    2) Start Matlab, \n',...
                    '        Click on the "Set path" menu-item or button in the main Matlab command window (in older Matlab versions this item is in the ''File'' menu-list, in newer Matlab versions this button is the ''Home'' tab)\n',...
                    '        Click on "Add folder" (not "Add with subfolders") and select the target installation folder (make sure the selected folder is the one containing the file spm.m)\n',...
                    '        Click on "Save" (this will keep these changes for future Matlab sessions)\n']);
        case 'conn'
            fprintf(['To install CONN follow these instructions:\n',...
                    '  CONN installation:\n',...
                    '    1) Download the CONN installation conn*.zip file from http://www.nitrc.org/projects/conn and uncompress the contents of this file in your desired target installation folder\n',...
                    '    2) Start Matlab, \n',...
                    '        Click on the "Set path" menu-item or button in the main Matlab command window (in older Matlab versions this item is in the ''File'' menu-list, in newer Matlab versions this button is the ''Home'' tab)\n',...
                    '        Click on "Add folder" (not "Add with subfolders") and select the target installation folder (make sure the selected folder is the one containing the file conn.m)\n',...
                    '        Click on "Save" (this will keep these changes for future Matlab sessions)\n']);
    end
    ok=false;files={};return; 
end
thispath=fileparts(thispath);
fprintf('%s @ %s\n',filename,thispath);
names=dir(fullfile(thispath,'*.m'));
files={names.name};
okpath=cellfun(@(x)strcmpi(fileparts(which(x)),thispath)|strncmp(x,'.',1),files);
if ~nargout
    for n=find(~okpath(:)')
        foldername=fileparts(which(files{n}));
        if isempty(foldername), fprintf('Warning: %s overloaded by version in current folder (%s)\n',files{n},pwd);
        else fprintf('Warning: %s overloaded by version in folder %s\n',files{n},foldername);
        end
    end
end
files=files(~okpath);
ok=all(okpath);
