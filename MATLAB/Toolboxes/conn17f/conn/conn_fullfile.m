function filename=conn_fullfile(varargin)

if ~nargin, filename=''; 
elseif nargin==1, filename=varargin{1}; 
else filename=fullfile(varargin{:}); 
end
if isempty(filename), return; end
[filename_path,filename_name,filename_ext]=fileparts(filename);
if isempty(filename_path),
    filename_path=pwd;
else
    cwd=pwd;
    try
        cd(filename_path);
        filename_path=pwd;
        cd(cwd);
    end
end
filename=fullfile(filename_path,[filename_name,filename_ext]);
