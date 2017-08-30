function FindBestWeights_Wrapper_20170531(dataDir,nCoils,oddevenall,lastSampleForWeightCalc,smoothingSigma,usepar)

% FindBestWeights_Wrapper_20170531(dataDir,nCoils,oddevenall,lastSampleForWeightCalc,smoothingSigma,usepar)
%
% INPUTS:
% -dataDir is a string indicating the absolute path to the folder where the
% nCoils-channel data is stored. Files inside should be named 0.nii -
% <nCoils-1>.nii  [default = './'] 
% -nCoils is a scalar indicating the number of coils (and therefore number
% of files) in your dataset. [default: 32]
% -oddevenall is a string indicating whether the odd samples, even samples,
% or all samples should be used when optimizing. [default: 'even']
% (NOTE: this uses MATLAB's one-based numbering, so 'even' means the second,
% fourth, etc. samples.)
% -lastSampleForWeightCalc is a scalar indicating the last sample that
% should be used to calculate the weights. If you are using odd samples
% only (for example), this will use TRs 1:3:lastIndForWeightCalc. 'all' is
% the same as nT, the number of samples in your datasets. [default: 'all']
% -smoothingSigma is a scalar or 3-element vector indicating the stddev of
% the smoothing kernel to be applied to the data before calculating the
% weights IN UNITS OF VOXELS. If smoothingSigma is a vector [a,b,c], an
% asymmetric kernel of stddev [a,b,c] in the (XxYxZ) dimensions will be
% used. The kernel size will be 2*ceil(smoothingStd)+1. This kernel will
% NOT be applied to the reweighted data. [default: 0 (no smoothing)]
% -usepar is a binary value indicating whether we should use parallel
% processing. It will also accept strings 'true','false','0','1'.
% [default: true]
%
% OUTPUTS:
% -file <dataDir>/mSTARC_CoilWeights.nii contains an mxnxpxnCoils
% matrix, where (mxnxp) is the size of each file in dataDir. The matrix
% contains the optimized weights for each voxel and coil. 
% -file <dataDir>/mSTARC_CombinedData.nii is an (mxnxp) data brick containing the
% data combined across coils using the optimized weights.
% -file <dataDir/mSTARC_command.txt is a text file containing the MATLAB
% command that could be used to reproduce the output files. Note that some
% values are as interpreted by this script, not precisely what was input.
%
% Created 11/18/16 by DJ from FindBestWeights_TestScript (as edited by LH).
% Updated 2/21/17 by DJ - save weights as .nii file
% Updated 5/31/17 by DJ - added multiple inputs, comments
% Updated 6/1/17 by DJ - debugging
% Updated 6/8/17 by DJ - fixed naming conventions, comments
% Updated 6/9/17 by DJ - added mSTARC_command.txt file output

% Running on Felix: Add these lines to /home/$USER/.matlab/R2016b/mccpath before compiling
% -I /data/SFIM/RENZO/PATH/to_compile
% -I /data/SFIM/RENZO/PATH/to_compile/NIfTI_20140122
% Or if running uncompiled in MATLAB, add dirs to path
% addpath('/data/SFIM/RENZO/coil_repository/NIfTI_20140122')
% addpath('/data/SFIM/RENZO/coil_repository/')

%% Set up
% Declare defaults
if ~exist('dataDir','var') || isempty(dataDir)
    dataDir = './';
end
if ~exist('nCoils','var') || isempty(nCoils)
    nCoils = 32;
end
if ~exist('oddevenall','var') || isempty(oddevenall)
    oddevenall = 'even';
end
if ~exist('lastSampleForWeightCalc','var') || isempty(lastSampleForWeightCalc)
    lastSampleForWeightCalc = 'all';
end
if ~exist('smoothingSigma','var') || isempty(smoothingSigma)
    smoothingSigma = 0;
end 
if ~exist('usepar','var') || isempty(usepar)
    usepar = true;
end
% Convert from strings to numbers/booleans
if ischar(nCoils)
    eval(sprintf('nCoils = %s;', nCoils));
end
if ischar(smoothingSigma)
    eval(sprintf('smoothingSigma = %s;', smoothingSigma));
end
if ischar(usepar)
    eval(sprintf('usepar = %s;', usepar));
end
if ischar(lastSampleForWeightCalc) && ~strcmp(lastSampleForWeightCalc,'all')
    eval(sprintf('nTrsForWeightCalc = %s;', lastSampleForWeightCalc));
end

% Change smoothing zeros to very small numbers (to avoid error)
smoothingSigma(smoothingSigma==0) = eps;
% Make into 3-element vector
if numel(smoothingSigma) == 1
    smoothingSigma = repmat(smoothingSigma,1,3);
end

% Remove last / if it's present
if dataDir(end)=='/'
    dataDir(end) = '';
end
% extract path and name
[dataPath,dataName,~] = fileparts(dataDir);

% Declare constants
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
if ischar(lastSampleForWeightCalc) && strcmp(lastSampleForWeightCalc,'all')
    % Convert 'all' to number
    lastSampleForWeightCalc = size(allData,5);
end
fprintf('===Extracting %s samples up to %d...\n',oddevenall,lastSampleForWeightCalc);
switch oddevenall
    case 'odd'
        data = allData(:,:,:,:,1:2:lastSampleForWeightCalc); % select only odd time points (BOLD contrast)
    case 'even'
        data = allData(:,:,:,:,2:2:lastSampleForWeightCalc); % select only even time points (BEST for VASO)
    otherwise %'all'
        data = allData(:,:,:,:,1:lastSampleForWeightCalc); % select all time points (BOTH contrasts);
end
tLoad = toc;
fprintf('===Done! Took %.1f seconds.\n',tLoad);

% check for dimensionality
nSamples = size(data,5);
fprintf('Using %d samples to estimate weights across %d coils...\n',nSamples,nCoils)
if nCoils>nSamples
    warning('nCoils>nSamples! Optimization will be underdetermined.');
end

%% Smooth data
if smoothingSigma<=0
    fprintf('===Skipping Smoothing...\n');
else   
    tic;
    % kernelSize = 2*ceil(2*smoothingSigma)+1; % for non-image-proc toolbox version
    fprintf('===Smoothing each coil & TR with %gx%gx%g voxel std dev Gaussian kernel...\n',smoothingSigma);
    % Smooth
    for i=1:size(data,4)
        for j=1:size(data,5)
            % data(:,:,:,i,j) = smooth3(data(:,:,:,i,j),'gaussian',kernelSize,smoothingSigma(1)); % doesn't require image processing toolbox (symmetric kernels only)
            data(:,:,:,i,j) = imgaussfilt3(data(:,:,:,i,j),smoothingSigma); % Requires image processing toolbox
        end
    end
    % report time
    tSmooth = toc;
    fprintf('===Done! Took %.1f seconds.\n',tSmooth);

end

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
        fprintf('Phase step %d/%d...\n',i,size(data,1));
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
        fprintf('Phase step %d/%d...\n',i,size(data,1));
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
        fprintf('\bDone (%d seconds).\n',round(toc));
    end
end
tProc = toc;
fprintf('===Done! Took %.1f seconds.\n',tProc);
    
%% Save weights
% Save with NIFTI toolbox
weightOutFilename = sprintf('%s/%s/mSTARC_CoilWeights.nii',dataPath,dataName);
fprintf('===Writing voxelwise weights as %s...\n',weightOutFilename);
tic
Ima = make_nii(weights);
save_nii(Ima, weightOutFilename);
tWriteWts = toc;
fprintf('===Done! Took %.1f seconds.\n',tWriteWts);


%% Write reweighted data
% Reconstruct images
reconNew = squeeze(sum(repmat(weights,1,1,1,1,size(allData,5)).*allData,4));
% reconNew = squeeze(sum(repmat(1/nCoils,size(allData)).*allData,4)); % control version with straight averaging

% Save with NIFTI toolbox
reconOutFilename = sprintf('%s/%s/mSTARC_CombinedData.nii',dataPath,dataName);
fprintf('===Writing reweighted data as %s...\n',reconOutFilename);
tic
Ima = make_nii(reconNew);
save_nii(Ima, reconOutFilename);
tWrite = toc;
fprintf('===Done! Took %.1f seconds.\n',tWrite);

%% Write readme file
readmeOutFilename = sprintf('%s/%s/mSTARC_command.txt',dataPath,dataName);
fid = fopen(readmeOutFilename,'w');
fprintf(fid,'%s(''%s'',%d,''%s'',%d,[%s],%d)',mfilename,dataDir,nCoils,oddevenall,lastSampleForWeightCalc,num2str(smoothingSigma),usepar);
fclose(fid);