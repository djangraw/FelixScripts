function ApplyTemporalFilter(inputFile,filterVec,outputFile)

% ApplyTemporalFilter(inputFile,filterVec,outputFile)
%
% Created 11/17/16 by DJ.

[err, inputBrick, inputInfo, errMsg] = BrikLoad(inputFile);
nT = size(inputBrick,4);

% Make into temporal filter
filterVec = permute(filterVec(:),[4 3 2 1]);

outputBrick = convn(inputBrick,filterVec,'same');

Opt = struct('Prefix',outputFile,'OverWrite','y');
WriteBrik(outputBrick,inputInfo,Opt);
