function filenames = SavePhaseScrambled(subject,runs,inputdir,newprefix)

% Randomly the data in specified afni bricks and save out the results.
% filenames = SavePhaseScrambled(subject,runs,inputdir,newprefix)
%
% INPUTS:
% -subject is a scalar.
% -runs is an N-element vector.
% Loaded datasets are called ;cnmfamdtpSBJ<subject>_R<runs>+orig'. Each one
% should be a 4D matrix of equal size (X x Y x Z x T).
% -inputdir is a string indicating the location of the (preprocessed) input
% files.
% -newprefix is a string - the output filename for run i will be
% <newprefix>-<subject>-<run(i)>.brik/.head .
%
% OUTPUTS:
% -filenames is an N-element cell array of strings containing the filenames
% to which the permuted data has been saved.
%
% Created 2/11/15 by DJ - merged with version from helix/felix, comments

%% Load
if ~exist('subject','var')
    subject = 1;
end
if ~exist('runs','var')
    runs = 1:10;
end
if ~exist('inputdir','var')
    inputdir = '';
end
if ~exist('newprefix','var')
    newprefix = 'scrambled';
end

% load in runs
N = numel(runs);
[filenames] = deal(cell(1,N));
fprintf('=== %s - Loading Data... ===\n',datestr(now,0));
for iRun=1:N
    fprintf('%s - loading run %d/%d...\n',datestr(now,0),iRun,N);
    filename = sprintf('%scnmfamdtpSBJ%02d_R%03d+orig',inputdir,subject,runs(iRun));
    [err, data, Info, ErrMessage] = BrikLoad(filename);
    fprintf('%s - scrambling phase data...\n',datestr(now,0));
    scramdata = permute(data,[4 1 2 3]); % shift time to 1st dimension
    scramdata = PhaseScrambleData(scramdata);
    scramdata = permute(scramdata,[2 3 4 1]); % shift time back to last dimension
    % save result
    filenames{iRun} = sprintf('%sSBJ%02d_R%03d+orig',newprefix,subject,runs(iRun));
    fprintf('%s - saving results to %s...\n',datestr(now,0),filenames{iRun});
    [err,ErrMessage,InfoOut] = WriteBrik(scramdata,Info,struct('prefix',filenames{iRun}));
end
fprintf('%s - Done!\n',datestr(now,0));
