function [coeff,pval] = RunIscOnSrtt(subjects,inputdir,dorandperm)

% Created 1/2/18 by DJ based on RunIscOn100Runs.m.

%% Load
if ~exist('subjects','var')
    subjects = 1;
end
if ~exist('inputdir','var')
    inputdir = '';
end
if ~exist('dorandperm','var')
    dorandperm = false;
end

% load in runs
nSubj = numel(subjects);
[data, Info] = deal(cell(1,nSubj));
fprintf('=== %s - Loading Data... ===\n',datestr(now,0));
for iSubj=1:nSubj
    fprintf('%s - subj %d/%d...\n',datestr(now,0),iSubj,nSubj);
    subjstr = sprintf('%04d',subjects(iSubj));
    filename = sprintf('%s/%s/%s.srtt_v2/all_runs_nonuisance.%s.scale+tlrc',inputdir,subjStr,subjStr,subjStr);
    [err, data{iSubj}, Info{iSubj}, ErrMessage] = BrikLoad(filename);
end
data = cat(5,data{:});
data = permute(data,[4 1 2 3 5]); % to avoid having to use 'squeeze' (speed-up)
    
%% Randomly permute each run's phase
if dorandperm
    fprintf('=== %s - Randomly Permuting Phases... ===\n',datestr(now,0));
    for iSubj=1:nSubj
        fprintf('%s - run %d/%d...\n',datestr(now,0),iSubj,nSubj);
        data(:,:,:,:,iSubj) = PhaseScrambleData(data(:,:,:,:,iSubj));
    end
end

%% calculate matrix of means across other subjects
fprintf('=== %s - Calculating Means ===\n',datestr(now,0));
meanothers = zeros(size(data));
for iSubj=1:nSubj
    fprintf('%s - run %d/%d...\n',datestr(now,0),iSubj,nSubj);
    meanothers(:,:,:,:,iSubj) = mean(data(:,:,:,:,[1:iSubj-1, iSubj+1:nSubj]),5);
end

%% find correlations
[T,X,Y,Z,nSubj] = size(data);
% [X,Y,Z,T,N] = size(data);
coeff = zeros(X,Y,Z,nSubj);
fprintf('=== %s - Calculating Correlation Coefficients ===\n',datestr(now,0));
for i=1:X
    fprintf('%s - x_slice %d/%d...\n',datestr(now,0),i,X);
    for j=1:Y
        for k=1:Z
            for iSubj = 1:nSubj
%                 this = squeeze(data(i,j,k,:,iRun));
                this = data(:,i,j,k,iSubj);
%                 other = squeeze(mean(data(i,j,k,:,[1:iRun-1, iRun+1:N]),5));
                other = meanothers(:,i,j,k,iSubj);
                r = corrcoef(this,other); 
                coeff(i,j,k,iSubj) = r(1,2);               
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
