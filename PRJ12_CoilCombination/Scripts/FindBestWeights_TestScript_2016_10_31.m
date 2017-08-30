% FindBestWeights_TestScript.m
%
% Created 10/28/16 by DJ.

% Set up and load coil-by-coil data
nCoils = 32;
dataDir = '/data/jangrawdc/MATLAB/RenzoCoilWeights/uncombined_data';

% Initialize
foo = BrikLoad(sprintf('%s/%d.nii',dataDir,0));
allData = nan([size(foo),nCoils]);
for i=1:nCoils
    % Load data
    fprintf('Loading coil %d/%d...\n',i,nCoils);
    [allData(:,:,:,:,i), inputInfo] = BrikLoad(sprintf('%s/%d.nii',dataDir,i-1));
end
% Extract odd time points
allData = permute(allData,[1 2 3 5 4]); % make time last dimension
data = allData(:,:,:,:,1:2:end); % select only odd time points
fprintf('Done!\n');

%% Solve minimization problem for each voxel

% weights = nan(size(data,1),size(data,2),size(data,3),size(data,4));
weights_cell = cell(1,size(data,1)); % designed for parfor construct
winit = ones(nCoils,1)/nCoils; % start optimization with equal weights
tic;
fprintf('calculating weights...\n');
parfor i=1:size(data,1)
    fprintf('slice %d/%d...\n',i,size(data,1));
    weights_cell{i} = nan(1,size(data,2),size(data,3),size(data,4));
    for j=1:size(data,2)
        for k=1:size(data,3)
            C = squeeze(data(i,j,k,:,:));
            if ~all(C==0)
                wts = FindBestWeights(C,winit,false);
%                 weights(i,j,k,:) = permute(wts,[4 3 2 1]);
                weights_cell{i}(1,j,k,:) = permute(wts,[4 3 2 1]);
            end
        end
    end
end
tProc = toc;
fprintf('Done! Took %.1f seconds.\n',tProc);
    
%% Save result
weightOutFile = 'MatlabMethodWeights_TNSR';
% Reconsitute
weights = cat(1,weights_cell{:});
save(weightOutFile,'weights');

%% Compare Figure of Merit (FOM) to equal weights or gold standard
% Reconsitute
if ~exist('weights','var')
    weights = cat(1,weights_cell{:});
end
% Load gold standard
goldWeightFile = '/data/jangrawdc/MATLAB/RenzoCoilWeights/Cpp_results/optimaced_weigtings_that_are_used_at_the_end.nii';
goldWeights = BrikLoad(goldWeightFile);
equalWts = ones(nCoils,1)/nCoils;
% Compare
[fomNew,fomGold,fomEqual] = deal(nan(size(data,1),size(data,2),size(data,3)));
tic;
fprintf('Getting figures of merit...\n');
for i=1:size(data,1)
    fprintf('slice %d/%d...\n',i,size(data,1));
    for j=1:size(data,2)-1
        for k=1:size(data,3)  
            % reformat data & weights for this voxel
            C = squeeze(data(i,j,k,:,:));
            % New weights
            w = squeeze(weights(i,j,k,:));
            wC = w'*C;
            fomNew(i,j,k) = var(wC)/mean(wC)^2;
            % Gold standard weights
            w = squeeze(goldWeights(i,j,k,:));
            w = w/sum(w);
            wC = w'*C;
            fomGold(i,j,k) = var(wC)/mean(wC)^2;
            % Equal weights
            w = equalWts;
            wC = w'*C;
            fomEqual(i,j,k) = var(wC)/mean(wC)^2;
        end
    end
end
% Take square root to get 1/TSNR
fomNew = sqrt(fomNew);
fomGold = sqrt(fomGold);
fomEqual = sqrt(fomEqual);
tProc = toc;
fprintf('Done! Took %.1f seconds.\n',tProc);

%% Plot histogram of FOMs
figure(562); clf;
xHist = linspace(nanmin(fomNew(:)),nanmax(fomNew(:))*2,100);
% xHist = linspace(nanmin(fomGold(:)),nanmax(fomGold(:)),100);
nNew = hist(fomNew(~isnan(fomNew)),xHist);
nGold = hist(fomGold(~isnan(fomNew)),xHist);
nConst = hist(fomEqual(~isnan(fomNew)),xHist);
plot(xHist,[nConst;nGold;nNew]');
xlabel('1/TSNR of voxel')
ylabel('# voxels')
legend('Constant Weights','Gold Standard','Matlab Minimization');

%% Visualize single-coil weights

iCoil = 4; % which coil do you want to see?
GUI_3View(weights(:,:,:,iCoil))

%% Visualize reconstructed images
% Reconstruct images
nT = size(data,5);
reconNew = squeeze(sum(repmat(weights,1,1,1,1,nT).*data,4));
reconGold = squeeze(sum(repmat(goldWeights,1,1,1,1,nT).*data,4));
reconEqual = squeeze(sum(1/nCoils*data,4));

% iT = 10; % time point to plot
iMid = round(size(data)/2); % Middle slice

% Set up figure
figure(234); clf;

% Plot mean across time points for each weighting method
subplot(3,1,1);
% imagesc(reconEqual(:,:,iMid(3),iT));
imagesc(mean(reconEqual(:,:,iMid(3),:),4)');
% h = Plot3Planes(reconEqual(:,:,:,iT),iMid(1:3));
title('Equal Weights recon')
colorbar
axis equal

subplot(3,1,2);
% imagesc(reconGold(:,:,iMid(3),iT));
imagesc(mean(reconGold(:,:,iMid(3),:),4)');
% Plot3Planes(reconGold(:,:,:,iT),iMid(1:3));
title('Gold Standard recon')
colorbar
axis equal

subplot(3,1,3);
% imagesc(reconNew(:,:,iMid(3),iT));
imagesc(mean(reconNew(:,:,iMid(3),:),4)');
% Plot3Planes(reconNew(:,:,:,iT),iMid(1:3));
title('Matlab Minimization recon')
colorbar
axis equal

%% Save out results as AFNI brick
% Save reconstructed data
% Set up
outPrefix = '/data/jangrawdc/MATLAB/RenzoCoilWeights/ReconData';
outputInfo = inputInfo;
[outPath,outName,outExt] = fileparts(outPrefix);
outputInfo.RootName = sprintf('%s/%s',outPath,outName);
Opts = struct('Prefix',outPrefix,'OverWrite','y');
% Write AFNI brick
fprintf('Saving reconstructed data to %s...\n',outPrefix);
WriteBrik(reconNew,inputInfo,Opts);
fprintf('Done!\n');