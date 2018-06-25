function [coeff,pval] = RunIscOn100Runs(subject,runs,inputdir,dorandperm)

% Calculate the inter-subject correlation (ISC) for given 100-runs datasets
% [coeff,pval] = RunIscOn100Runs(subject,runs,inputdir,dorandperm)
% (NOTE: as described in Lerner JNeurosci 2013.)
%
% INPUTS:
% -subject is a scalar.
% -runs is an N-element vector.
% Loaded datasets are called ;cnmfamdtpSBJ<subject>_R<runs>+orig'. Each one
% should be a 4D matrix of equal size (X x Y x Z x T).
% -inputdir is a string indicating the location of the (preprocessed) input
% files.
% -dorandperm is a binary value indicating whether a random permutation
% should be run.
%
% OUTPUTS:
% -coeff is an X x Y x Z x N matrix in which coeff(:,:,:,i) is the
% correlation coefficient between subject/run i and the mean of all the
% others.
% -pval is an X x Y x Z matrix in which pval(i,j,k) has the result of a 
% t-test of coeff(i,j,k,:) against zero.
%
% Created 1/7/15 by DJ.
% Updated 1/8/15 by DJ - cleanup, comments.
% Updated 2/11/15 by DJ - merged with version from helix/felix, comments

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
if ~exist('dorandperm','var')
    dorandperm = false;
end

% load in runs
N = numel(runs);
[data, Info] = deal(cell(1,N));
fprintf('=== %s - Loading Data... ===\n',datestr(now,0));
for iRun=1:N
    fprintf('%s - run %d/%d...\n',datestr(now,0),iRun,N);
    filename = sprintf('%scnmfamdtpSBJ%02d_R%03d+orig',inputdir,subject,runs(iRun));
    [err, data{iRun}, Info{iRun}, ErrMessage] = BrikLoad(filename);
end
data = cat(5,data{:});
data = permute(data,[4 1 2 3 5]); % to avoid having to use 'squeeze' (speed-up)
    
%% Randomly permute each run's phase
if dorandperm
    fprintf('=== %s - Randomly Permuting Phases... ===\n',datestr(now,0));
    for iRun=1:N
        fprintf('%s - run %d/%d...\n',datestr(now,0),iRun,N);
        data(:,:,:,:,iRun) = PhaseScrambleData(data(:,:,:,:,iRun));
    end
end

%% calculate matrix of means across other subjects
fprintf('=== %s - Calculating Means ===\n',datestr(now,0));
meanothers = zeros(size(data));
for iRun=1:N
    fprintf('%s - run %d/%d...\n',datestr(now,0),iRun,N);
    meanothers(:,:,:,:,iRun) = mean(data(:,:,:,:,[1:iRun-1, iRun+1:N]),5);
end

%% find correlations
[T,X,Y,Z,N] = size(data);
% [X,Y,Z,T,N] = size(data);
coeff = zeros(X,Y,Z,N);
fprintf('=== %s - Calculating Correlation Coefficients ===\n',datestr(now,0));
for i=1:X
    fprintf('%s - x_slice %d/%d...\n',datestr(now,0),i,X);
    for j=1:Y
        for k=1:Z
            for iRun = 1:N
%                 this = squeeze(data(i,j,k,:,iRun));
                this = data(:,i,j,k,iRun);
%                 other = squeeze(mean(data(i,j,k,:,[1:iRun-1, iRun+1:N]),5));
                other = meanothers(:,i,j,k,iRun);
                r = corrcoef(this,other); 
                coeff(i,j,k,iRun) = r(1,2);               
            end
        end
    end
end

%% compare to zero
[hval, pval] = deal(zeros(X,Y,Z));
fprintf('=== %s - Calculating P Values ===\n',datestr(now,0));
for i=1:X
    fprintf('%s - x_slice %d/%d...\n',datestr(now,0),i,X);
    for j=1:Y
        for k=1:Z
            [hval(i,j,k),pval(i,j,k)] = ttest(coeff(i,j,k,:),0);            
        end
    end
end

%insert false discovery rate correction here

%% plot results
% fprintf('=== %s - Plotting Results ===\n',datestr(now,0));
% GUI_3View(mean(coeff,4));
% GUI_3View(pval);
fprintf('=== %s - Done! ===\n',datestr(now,0));
