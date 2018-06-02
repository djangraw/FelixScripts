function [examplesTrainCombined,examplesTestCombined] = combineParallelDatasetsBySearchlight(varargin)

% 
% process parameters
%

ranking = []; scores = []; 

if nargin < 3
    fprintf('syntax: combineParallelDatasetsBySearchlight(<train A>,<test A>,<train B>,<test B>,<meta>,<method>,\[<method parameters>\])\n');return;
end

examplesTrainA = varargin{1}; [nA1,mA1] = size(examplesTrainA);
examplesTestA  = varargin{2}; [nA2,mA2] = size(examplesTrainA);
examplesTrainB = varargin{3}; [nB1,mB1] = size(examplesTrainB);
examplesTestB  = varargin{4}; [nB2,mB2] = size(examplesTrainB);
if (nA1~=nB1) | (nA2~=nB2)
    fprintf('error: training and test sets must have matching #s of examples, respectively\n'); return;
end
if (mA1~=mB1) | (mA2~=mB2) | (mA1~=mB2)
    fprintf('error: training and test sets must have matching #s of voxels\n'); return;
end 

nTrain = nA1; nTest = nA1;
nVoxels = mA1;

meta   = varargin{5};
method = varargin{6};

switch method
  case {'CCA'}
  otherwise
    fprintf('error: unknown method %s\n',method);
end

methodParameters = {};
if nargin > 6; methodParameters = varargin{7}; end

nFeaturesPerSearchlight = 1;

idx = 1;
while idx <= length(methodParameters)
    argval = varargin{idx}; idx = idx + 1;
    switch argval
      case {'numberOfFeaturesPerSearchlight'}
        nFeaturesPerSearchlight = varargin{idx}; idx = idx + 1;
      otherwise
        fprintf('error: unknown parameter %s\n',argval);return;
    end
end

%
% produce examples
%

nVoxelsCombined = nVoxels * nFeaturesPerSearchlight;
examplesTrainCombined = zeros(nTrain,nVoxelsCombined);
examplesTestCombined  = zeros(nTest ,nVoxelsCombined);

fidx = 1;

for v = 1:nVoxels
    if rem(v,1000)==0; fprintf('%d ',v); end
    
    % number of neighbouring voxels
    nn = meta.numberOfNeighbours(v);
    
    % voxels in the searchlight
    voxels = [v,meta.voxelsToNeighbours(v,1:nn)];

    % create datasets
    dataTrainA = examplesTrainA(:,voxels);
    dataTrainB = examplesTrainB(:,voxels);
    dataTestA  = examplesTestA( :,voxels);
    dataTestB  = examplesTestB( :,voxels);

    %
    % Ahmet:
    % - create a CCA model with <nFeaturesPerSearchlight>
    % - project training data to yield <nFeaturesPerSearchlight> features
    % - apply projection to test data to yield <nFeaturesPerSearchlight> features
    % - replace these
    STrain = zeros(nTrain,nFeaturesPerSearchlight);
    STest  = zeros(nTest, nFeaturesPerSearchlight);
    
    % store
    frange = idx:(idx+nFeaturesPerSearchlight-1);
    examplesTrainCombined(:,frange) = STrain;
    examplesTestCombined( :,frange) = STest;
    
    fidx = fidx + nFeaturesPerSearchlight;
end



function [] = testThis()

load('examples_pictures.mat');
examplesPictures = examples;

load('examples_sentences.mat');
examplesSentences = examples;

n = 180; m = size(examples,2);

nFolds = 20;
indicesGroup = rem((1:n)',nFolds)+1;


for ig = 1:nFolds
    fprintf('\nfold %d\n',ig);
    mask = (indicesGroup == ig);
    indicesTrain = find(~mask);
    indicesTest  = find( mask);
    
    examplesPicturesTrain  = examplesPictures(indicesTrain,:);
    examplesPicturesTest   = examplesPictures(indicesTest, :);
    examplesSentencesTrain = examplesSentences(indicesTrain,:);
    examplesSentencesTest  = examplesSentences(indicesTest, :);
    
    [examplesCombinedTrain,examplesCombinedTest] = combineParallelDatasetsBySearchlight(examplesPicturesTrain,examplesPicturesTest,examplesSentencesTrain,examplesSentencesTest,meta,'CCA');
end