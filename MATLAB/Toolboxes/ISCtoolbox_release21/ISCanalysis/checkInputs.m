function [flag,directories,Params,memMaps] = checkInputs(parentDir,atlasPath)

directories = [];
Params = [];
memMaps = [];

flag = true;
if ~ischar(parentDir)
    disp('Directory names must be strings!!')
    flag = false;
    return
end

if length(parentDir) < 3
    disp('Directory names must contain more than 2 characters!!')
    flag = false;
    return
end

if nargin == 1
   %[dn,fn] = fileparts(parentDir);
   dn = parentDir;
   try
       load([dn 'Tag.mat' ])
       load([dn '' Tag])
       atlasPath = Params.PublicParams.atlasPath;
   catch
      disp('Cannot find Params-struct in the specified location!')
      flag = false;
      return
   end
end

flag = true;
if ~ischar(atlasPath)
    disp('Directory names must be strings!!')
    flag = false;
    return
end

if length(atlasPath) < 3
    disp('Directory names must contain more than 2 characters!!')
    flag = false;
    return
end



disp(['Checking brain atlas directory: ' atlasPath])

if ~strcmp(atlasPath(end),'/') && ~strcmp(atlasPath(end),'\')
    disp('Atlas directory name must end with slash!!')
    flag = false;
    return
end

if exist([atlasPath],'dir') ~= 7
    disp('Atlas directory not found!!')
    flag = false;
    return
end


disp(['Checking project directory: ' parentDir])

if ~strcmp(parentDir(end),'/') && ~strcmp(parentDir(end),'\')
    disp('Parent directory name must end with slash!!')
    flag = false;
    return
end

if exist(parentDir,'dir') ~= 7
    disp('Parent directory does not exist!!')
    flag = false;
    return
end

disp('Searching Params-struct from parent directory.....')
s = what(parentDir);
fl = false;
for k = 1:length(s.mat)
    q = whos('-file',[parentDir s.mat{k}]);
    for h = 1:length(q)
        if strcmp(q(h).name,'Params');
            load([parentDir s.mat{k}],q(h).name)
            if isfield(Params,'PublicParams')
                if isfield(Params.PublicParams,'dataDescription')
                    if strcmp([Params.PublicParams.dataDescription '.mat'],s.mat{k});
                        disp(['  Found ' s.mat{k}])
                        fl = true;
                        break
                    end
                end
            end
        end
    end
    if fl
        break
    end
    
end
if ~fl
    disp('mat-file containing parameter-struct not found in parent directory!!')
    flag = false;
end
disp('Searching memMap.m from parent directory.....')
fl = false;
for k = 1:length(s.mat)
    if strcmp(s.mat{k},'memMaps.mat')
        load([parentDir s.mat{k}])
        fl = true;
    end
end
if ~fl
    disp('memMaps.mat not found in parent directory!!')
    flag = false;
    return
end
disp('  Found memMaps.mat')

directories = {['results' parentDir(end)],['fMRIfiltered' parentDir(end)],...
    ['fMRIpreprocessed' parentDir(end)],['stats' parentDir(end)],...
    ['PF' parentDir(end)],['phase' parentDir(end)],['PFsession' parentDir(end)]};

if exist([parentDir directories{1}],'dir') ~= 7
    mkdir([parentDir directories{1}])
end
if exist([parentDir directories{2}],'dir') ~= 7
    mkdir([parentDir directories{2}])
end
if exist([parentDir directories{3}],'dir') ~= 7
    mkdir([parentDir directories{3}])
end
if exist([parentDir directories{4}],'dir') ~= 7
    mkdir([parentDir directories{4}])
end
if exist([parentDir directories{5}],'dir') ~= 7
    mkdir([parentDir directories{5}])
end
if exist([parentDir directories{6}],'dir') ~= 7
    mkdir([parentDir directories{6}])
end

