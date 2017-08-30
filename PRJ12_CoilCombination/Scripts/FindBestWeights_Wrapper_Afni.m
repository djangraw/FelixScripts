function FindBestWeights_Wrapper_Afni(dataDir,evenOrOdd,useParfor)

% FindBestWeights_Wrapper_Afni(evenOrOdd,pathToData)
%
% INPUTS:
% -dataDir is the folder where the .nii files sit (0
% -evenOrOdd is a string either 'even' or 'odd' uses the even or odd
% (1-based counting) samples to determine the weights.
% -useParFor is a binary value or string ('true' or 'false') indicating
% whether you'd like to use parallel computing [default: true]
%
% OUTPUTS:
%
% To Compile:
%
% Created 2/21/17 by DJ.


%% Declare defaults and parse inputs
if ~exist('dataDir','var') || isempty(dataDir)
    dataDir = '/data/jangrawdc/MATLAB/RenzoCoilWeights/uncombined_data';
end
if ~exist('evenOrOdd','var') || isempty(evenOrOdd)
    evenOrOdd = 'even';
end
if ~exist('useParfor','var') || isempty(useParfor)
    useParfor = 'true';
end
if ischar(useParfor)
    useParfor = eval(useParfor); % convert from string to binary value
end

% Display inputs to user
fprintf('Data directory: %s\n',dataDir);
fprintf('Using %s time points.\n',evenOrOdd);
if useParfor
    fprintf('Using parallel computing.\n');
else
    fprintf('Not using parallel computing.\n');
end

% addpath('/data/jangrawdc/MATLAB/afni_matlab/matlab')

%% Load data
fprintf('===Loading Coil Data...\n');
tic;

% Set up and load coil-by-coil data
% nCoils = 32;
niiFiles = dir(sprintf('%s/*.nii',dataDir));
nCoils = numel(niiFiles);
fprintf('%d nii files detected.\n',nCoils);

% Initialize
fprintf('Loading coil %d/%d...\n',1,nCoils);    
[data0,inputInfo] = BrikLoad(sprintf('%s/%d.nii',dataDir,0));
allData = nan([size(data0),nCoils]);
allData(:,:,:,:,1) = data0;
for i=2:nCoils
    % Load data
    fprintf('Loading coil %d/%d...\n',i,nCoils);
    [allData(:,:,:,:,i), inputInfo] = BrikLoad(sprintf('%s/%d.nii',dataDir,i-1));
end
% Permute and finish
allData = permute(allData,[1 2 3 5 4]); % make time last dimension
fprintf('===Done! Took %.1f seconds.\n',toc);

%% Extract odd/even samples
fprintf('===Extracting %s Samples...\n',evenOrOdd);
tic;
switch evenOrOdd
    case 'odd'
        data = allData(:,:,:,:,1:2:end); % select only odd time points
    case 'even'
        data = allData(:,:,:,:,2:2:end); % select even odd time points
    otherwise
        error('evenOrOdd value %s not recognized!',evenOrOdd);
end
fprintf('===Done! Took %.1f seconds.\n',toc);

%% Solve minimization problem for each voxel

% weights = nan(size(data,1),size(data,2),size(data,3),size(data,4));
weights_cell = cell(1,size(data,1)); % designed for parfor construct
winit = ones(nCoils,1)/nCoils; % start optimization with equal weights
fprintf('===Calculating weights...\n');
tic;
if useParfor
    % start parpool
    try
        fprintf('Starting parpool...\n');
        parpool();
%         myCluster = parcluster('local');
%         nWorkers = myCluster.NumWorkers;
%         fprintf('Starting parpool with %d workers...\n',nWorkers);
%         myPool = parpool(nWorkers); 
    catch
        warning('Parpool failed.\n');
        myPool = [];
    end
    % Find weights
    parfor i=1:size(data,1)
        fprintf('slice %d/%d...\n',i,size(data,1));
        weights_cell{i} = nan(1,size(data,2),size(data,3),size(data,4));
        for j=1:size(data,2)
            for k=1:size(data,3)
                C = squeeze(data(i,j,k,:,:));
                if ~all(C==0)
                    wts = FindBestWeights(C,winit,false);
                    weights_cell{i}(1,j,k,:) = permute(wts,[4 3 2 1]);
                end
            end
        end
    end
    % shut down parpool
    delete(myPool);
else
    % Get weights in loop without using parfor
    for i=1:size(data,1)
        fprintf('slice %d/%d...\n',i,size(data,1));
        weights_cell{i} = nan(1,size(data,2),size(data,3),size(data,4));
        for j=1:size(data,2)
            for k=1:size(data,3)
                C = squeeze(data(i,j,k,:,:));
                if ~all(C==0)
                    wts = FindBestWeights(C,winit,false);
                    weights_cell{i}(1,j,k,:) = permute(wts,[4 3 2 1]);
                end
            end
        end
    end
end
% Reconstitute and finish
weights = cat(1,weights_cell{:});
tProc = toc;
fprintf('===Done! Took %.1f seconds.\n',tProc);
    
%% Save result
% Declare filemame
% weightOutFile = sprintf('%s_CoilWeights.mat',dataDir);
% fprintf('===Saving weights as %s...\n',weightOutFile);
% tic;
% % Save
% save(weightOutFile,'weights');
% % finish
% fprintf('===Done! Took %.1f seconds.\n',toc);

% Set up
outPrefix = sprintf('%s_%s_CoilWeights.nii',dataDir,evenOrOdd);
fprintf('===Writing voxelwise weights as %s...\n',outPrefix);
tic;
[outPath,outName,outExt] = fileparts(outPrefix);
outputInfo = inputInfo;
outputInfo.RootName = sprintf('%s/%s',outPath,outName);
Opts = struct('Prefix',outPrefix,'OverWrite','y');
% Write AFNI brick
WriteBrik(weights,outputInfo,Opts);
% Finish
fprintf('===Done! Took %.1f seconds.\n',toc);

%% Save out results as AFNI brick
% Save reconstructed data
% Set up
outPrefix = sprintf('%s_comb_%s.nii',dataDir,evenOrOdd);
fprintf('===Writing reweighted data as %s...\n',outPrefix);
tic;
[outPath,outName,outExt] = fileparts(outPrefix);
outputInfo = inputInfo;
outputInfo.RootName = sprintf('%s/%s',outPath,outName);
Opts = struct('Prefix',outPrefix,'OverWrite','y');
% Write AFNI brick
WriteBrik(reconNew,outputInfo,Opts);
% Finish
fprintf('===Done! Took %.1f seconds.\n',toc);