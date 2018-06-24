function [] = RunClvCodeOnStoryData()


%% Set up and get data
info = GetStoryConstants();
method = 'gCCA2'; % generalized CCA

%
% create and prepare the datasets
% - train and test
% - each subject has two ROIs: informative and uninformative
% - informative ROI (ROI1) has one latent variable that is common across subjects, one that is specific
% - uninformative ROI (ROI2) has two subject-specific sources
%

nSubjects     = numel(info.okReadSubj);
nTime         = info.nT;
% [roiTc, isOk] = GetStoryTc_ShenAtlas(info.okReadSubj,'_d2');
nRois = size(roiTc,2);

% commonVariableTrain = 2*rand(nTime,1)-1 + activation;
% commonVariableTest  = 2*rand(nTime,1)-1 + activation;

[datasetsTrain,voxelAssignmentToROI] = deal(cell(1,nSubjects));
for is = 1:nSubjects
    datasetsTrain{is} = roiTc(:,:,is);
    % assignments of ROIs to voxels
    voxelAssignmentToROI{is} = 1:nRois;
end
% Copy for now
datasetsTest = datasetsTrain;

%
% run generalized CCA to build a model
% (the model structure contains everything learned, will unpack below)

method = 'gCCA2';
k = 4; % # of latent variables
fprintf('===Learning CLV...\n');
tic;
model = learnCommonLatentVariableModel(datasetsTrain,method,{'k',k});
fprintf('===Done! Elapsed time = %d s.\n',toc);

%
% extract the estimated latent variables and mixing/unmixing matrices
% (not needed for recovering sources on test set)
%

% #examples x #sources
estimatedVariablesTrain = model.S;
estimatedVariablesTrainPerSubject = model.SforDataset;

% these are cell arrays, one cell per subject containing
% 1) mixing matrix - #variables x #voxels (multiply sources by this, get dataset reconstruction)
matricesMixing   = model.datasetTransformationsMixing;
% 2) unmixing matrix - #voxels x #variables (multiply dataset by this, get source estimate)
matricesUnmixing = model.datasetTransformationsUnmixing;

%
% estimate latent variables and reconstructed datasets from train/test set 
%

fprintf('===Applying to datasets...\n');
[estimatedVariablesTrain,estimatedVariablesTrainPerSubject,datasetsReconstructedTrain] = applyCommonLatentVariableModel(model,datasetsTrain);
[estimatedVariablesTest,estimatedVariablesTestPerSubject,datasetsReconstructedTest] = applyCommonLatentVariableModel(model,datasetsTest);
fprintf('===Done! Elapsed time = %d s.\n',toc);


%% plot
nrows = 4; ncols = nSubjects + 1;
dscale = [-1 1]*0.4;

fprintf('===Plotting results...\n');
for id = 1:2

    switch id
      case {1}
        % training data
        ptxt = 'training';
        datasetsToPlot = datasetsTrain;
        commonVariableToPlot = [];%commonVariableTrain;
        estimatedVariablesToPlot = estimatedVariablesTrain;
        estimatedVariablesToPlotPerSubject = estimatedVariablesTrainPerSubject;
        datasetsReconstructedToPlot = datasetsReconstructedTrain;
      case {2}
        % test data
        datasetsToPlot = datasetsTest;
        commonVariableToPlot = [];%commonVariableTest;
        estimatedVariablesToPlot = estimatedVariablesTest;
        estimatedVariablesToPlotPerSubject = estimatedVariablesTestPerSubject;
        datasetsReconstructedToPlot = datasetsReconstructedTest;
        ptxt = 'test';
    end
        
    clf; idx = 1;

    % row 1
    idx = idx + 1;
    for is = 1:nSubjects
        subplot(nrows,ncols,idx);
        imagesc(datasetsToPlot{is},dscale);
        title(sprintf('data subject %d',is));
        idx = idx + 1;
    end

    % row 2
    % ground truth
    tmp = [commonVariableToPlot,NaN(nTime,1),estimatedVariablesToPlot];
    subplot(nrows,ncols,idx);
    imagesc(tmp,dscale);
    title('common variable + group estimates');
    idx = idx + 1;

    for is = 1:nSubjects
        subplot(nrows,ncols,idx);
        imagesc(estimatedVariablesToPlotPerSubject{is}),dscale;
        title(sprintf('estimates S%d',is));
        idx = idx + 1;
    end

    % row 3 (subjects reconstructed via common latent variables)
    idx = idx + 1; % skip in the first row
    for is = 1:nSubjects
        subplot(nrows,ncols,idx);
        imagesc(datasetsReconstructedToPlot{is},dscale);
        title(sprintf('reconstructed data S%d',is));
        idx = idx + 1;
    end

    % row 4 (residuals)
    idx = idx + 1; % skip in the first row
    for is = 1:nSubjects
        subplot(nrows,ncols,idx);
        imagesc(datasetsToPlot{is}-datasetsReconstructedToPlot{is},dscale);
        title(sprintf('residual data S%d',is));
        idx = idx + 1;
    end

    fprintf('plots on %s data, press any key to continue\n',ptxt);pause
end
    
fprintf('===Done! Elapsed time = %d s.\n',toc);

