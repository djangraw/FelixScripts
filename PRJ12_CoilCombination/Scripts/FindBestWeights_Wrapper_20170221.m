function FindBestWeights_Wrapper_20170221(dataDir,oddevenall,usepar)

% FindBestWeights_Wrapper_20170221(dataDir,oddevenall,usepar)
%
% INPUTS:
% -dataDir is a string indicating the folder where the 32-channel data is
% stored. Files inside should be named 0.nii - 31.nii
% -oddevenall is a string indicating whether the odd samples, even samples,
% or all samples should be used when optimizing. [default: 'even']
% (NOTE: this uses MATLAB's one-based numbering, so 'even' means the second,
% fourth, etc. samples, saved as 1.nii, 3.nii, etc.)
% -usepar is a binary value indicating whether we should use parallel
% processing. It will also accept strings 'true','false','0','1'. 
% [default: true]
%
% OUTPUTS:
% -file <dataDir>_CoilWeights_<oddevenall>.nii contains an mxnxpx32 matrix called 'weights', 
% where (mxnxp) is the size of each file in dataDir and 32 is the number of
% coils. 'weights' contains the optimized weights for each voxel and coil.
% -file <dataDir>_comb_<oddevenall>.nii is an (mxnxp) data brick containing the
% data combined across coils using the optimized weights.
%
% Created 11/18/16 by DJ from FindBestWeights_TestScript (as edited by LH).
% Updated 2/21/17 by DJ - save weights as .nii file

% Add these lines to /home/$USER/.matlab/R2016b/mccpath before compiling
% -I /data/SFIM/RENZO/160805_SN_ANDREA_ubcomb/to_compile
% -I /data/SFIM/RENZO/160805_SN_ANDREA_ubcomb/to_compile/NIfTI_20140122

% Declare defaults
if ~exist('dataDir','var') || isempty(dataDir)
    dataDir = './left';
end
if ~exist('oddevenboth','var') || isempty(oddevenall)
    oddevenall = 'even';
end
if ~exist('usepar','var') || isempty(usepar)
    usepar = true;
end
if ischar(usepar)
    eval(sprintf('usepar = %s;', usepar));
end
% Remove last / if it's present
if dataDir(end)=='/'
    dataDir(end) = '';
end
% extract path and name
[dataPath,dataName,~] = fileparts(dataDir);

% Declare constants
nCoils = 32;
% niiFiles = dir(sprintf('%s/*.nii',dataDir));
% nCoils = numel(niiFiles);
% fprintf('%d nii files detected.\n',nCoils);

% Initialize dataset size
dataStruct = load_untouch_nii(sprintf('%s/%d.nii',dataDir,0));  
dataImg = dataStruct.img;  
allData = nan([size(dataImg),nCoils]);
% Load all datasets
fprintf('===Loading coil data...\n');
tic;
for i=1:nCoils
    % Load data
    fprintf('Loading coil %d/%d...\n',i,nCoils);
    dataStruct = load_untouch_nii(sprintf('%s/%d.nii',dataDir,i-1));
    [allData(:,:,:,:,i)] = dataStruct.img;
end
% switch last 2 dimensions so time is last
allData = permute(allData,[1 2 3 5 4]); % make time last dimension
% Extract relevant time points
fprintf('===Extracting %s samples...\n',oddevenall);
switch oddevenall
    case 'odd'
        data = allData(:,:,:,:,1:2:end); % select only odd time points (BOLD contrast)
    case 'even'
        data = allData(:,:,:,:,2:2:end); % select only even time points (BEST for VASO)
    otherwise %'all'
        data = allData;
end
tLoad = toc;
fprintf('===Done! Took %.1f seconds.\n',tLoad);

%% Solve minimization problem for each voxel

% Set up
winit = ones(nCoils,1)/nCoils; % start optimization with equal weights
tic; % start timer

% Try setting up a parallel computing pool
if usepar
    try
        pool = parpool(); % use default settings
    catch
        usepar = false;
        fprintf('Could not start parallel pool. Running in series...\n');
    end
end

% Calculate weights
fprintf('===Calculating weights...\n');
if usepar
    foo = nan(1,size(data,2),size(data,3),size(data,4)); % weights placeholder
    weights_cell = repmat({foo},1,size(data,1)); % designed for parfor construct
    % For each voxel
    parfor i=1:size(data,1)
        fprintf('slice %d/%d...\n',i,size(data,1));
        for j=1:size(data,2)
            for k=1:size(data,3)
                C = squeeze(data(i,j,k,:,:));
                if ~all(C==0)
                    % Calculate best weights for this voxel
                    wts = FindBestWeights(C,winit,false);
%                     weights(i,j,k,:) = permute(wts,[4 3 2 1]);
                    weights_cell{i}(1,j,k,:) = permute(wts,[4 3 2 1]);
                end
            end
        end
    end
    delete(pool);
    % Reconsitute from cell vector
    weights = cat(1,weights_cell{:});

else
    weights = nan(size(data,1),size(data,2),size(data,3),size(data,4));
    % For each voxel
    for i=1:size(data,1)
        fprintf('slice %d/%d...\n',i,size(data,1));
        for j=1:size(data,2)
            for k=1:size(data,3)
                C = squeeze(data(i,j,k,:,:));
                if ~all(C==0)
                    % Calculate best weights for this voxel
                    wts = FindBestWeights(C,winit,false);
                    weights(i,j,k,:) = permute(wts,[4 3 2 1]);
                end
            end
        end
    end
end
tProc = toc;
fprintf('===Done! Took %.1f seconds.\n',tProc);
    
%% Save weights
% Save with NIFTI toolbox
weightOutFilename = sprintf('%s/%s_CoilWeights_%s.nii',dataPath,dataName,oddevenall);
fprintf('===Writing voxelwise weights as %s...\n',weightOutFilename);
tic
Ima = make_nii(weights);
save_nii(Ima, weightOutFilename);
tWriteWts = toc;
fprintf('===Done! Took %.1f seconds.\n',tWriteWts);


%% Write reweighted data
% Reconstruct images
reconNew = squeeze(sum(repmat(weights,1,1,1,1,size(allData,5)).*allData,4));
% reconNew = squeeze(sum(repmat(1/nCoils,size(allData)).*allData,4));

% Save with NIFTI toolbox
reconOutFilename = sprintf('%s/%s_comb_%s.nii',dataPath,dataName,oddevenall);
fprintf('===Writing reweighted data as %s...\n',reconOutFilename);
tic
Ima = make_nii(reconNew);
save_nii(Ima, reconOutFilename);
tWrite = toc;
fprintf('===Done! Took %.1f seconds.\n',tWrite);
