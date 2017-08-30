function TimeShiftData(inFile,outFile,iShift)

% Loads data, shifts it in time (with wrap around), and saves it.
%
% TimeShiftData(inFile,outFile,iShift)
%
% INPUTS:
% -inFile is the filename of the AFNI brick you'd like to shift.
% -outFile is the filename where you'd like the result to be saved.
% -iShift is the number of samples you'd like to shift the data backward in
% time (default: random value between 1 and nSamples)
%
% OUTPUTS:
% -a file named <outFile> will be saved in the current directory.
% 
% Created 10/2/15 by DJ.

% load data
fprintf('Loading %s...\n',inFile);
[V,Info] = BrikLoad(inFile);

% determine shift
if ~exist('iShift','var') || isempty(iShift)    
    iShift = ceil(rand(1)*size(V,4));
    fprintf('iShift input not given... assigning random iShift = %d\n',iShift);
end

% shift
fprintf('Time shifting data...\n')
Vnew = cat(4,V(:,:,:,iShift+1:end),V(:,:,:,1:iShift));

% write result
fprintf('Saving result as %s...\n',outFile);
Opt = struct('Prefix',outFile,'OverWrite','y');
WriteBrik(Vnew,Info,Opt);
fprintf('Done!\n');