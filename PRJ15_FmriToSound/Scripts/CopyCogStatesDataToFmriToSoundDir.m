% CopyCogStatesDataToFmriToSoundDir.m
%
% Created 12/18/17 by DJ.

subjects = 6:27;

for i=1:numel(subjects)
    oldFilename = sprintf('/data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001/SBJ%02d_CTask001.Craddock_RandParc_200ROIs_-1_10VoxelMin.lowSigma.WL045.1D',subjects(i),subjects(i));
    newFilename = sprintf('/data/jangrawdc/PRJ15_FmriToSound/TestData/CogStates_SBJ%02d_Craddock200_WL045.1D',subjects(i));
    copyfile(oldFilename,newFilename);
end
%%
for i=1:numel(subjects)
    oldFilename = sprintf('/data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001/SBJ%02d_CTask001.Shen-scaled_WL045_ROI_TS.1D',subjects(i),subjects(i));
    newFilename = sprintf('/data/jangrawdc/PRJ15_FmriToSound/TestData/CogStates_SBJ%02d_Shen268_WL045.1D',subjects(i));
    try
        copyfile(oldFilename,newFilename);
    end
end

%% Load in files

subject = 6;
newFilename = sprintf('/data/jangrawdc/PRJ15_FmriToSound/TestData/CogStates_SBJ%02d_Craddock200_WL045.1D',subject);

foo = Read_1D(newFilename);
[nT,nRoi] = size(foo);
