function UpsampleFmriFile(inFile,outFile,upFactor)

% UpsampleFmriFile(inFile,outFile,upFactor)
%
% INPUTS:
% -inFile and outFile are strings indicating the input file and the output
% filename.
% -upFactor is the factor by which you'd like to upsample the dataset. 
%
% 7th order polynomial interpolation is used by AFNI's command 3dUpsample.
%
% Created 5/17/17 by DJ.


cmd = sprintf('3dUpsample -prefix %s %d %s',outFile,upFactor,inFile);
fprintf('%s\n',cmd);
% system(cmd);