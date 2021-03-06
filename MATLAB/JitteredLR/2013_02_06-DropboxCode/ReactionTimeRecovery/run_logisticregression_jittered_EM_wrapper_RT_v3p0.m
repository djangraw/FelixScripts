function [ALLEEG, v, Azloo, time] = run_logisticregression_jittered_EM_wrapper_RT_v3p0(subject,weightprior,cvmode,jitterrange,sigmamultiplier,windowOffset,resplock,lambda)

% Runs jittered logistic regression (EM version) on a given subject using 
% pre-defined paramters.
%
% [ALLEEG, v, Azloo, time] = run_logisticregression_jittered_EM_wrapper_RT_v2p1
%                  (subject,weightprior,cvmode,jitterrange,sigmamultiplier,
%                   windowOffset,resplock)
%
% INPUTS:
% - subject is a string indicating the common prefix of one subject's data 
%   files, e.g. '3DS-TAG-2' for subject 2 on the 3DSearch/TAG experiment.
% - weightprior is a binary value indicating whether the algorithm should
%   weight the priors by dividing by the number of trials of each type
%   (target or distractor), thus weighting each target trial more highly.
% - cvmode is a string specifying what type of cross-validation to run.  
%   Can be:
%		'nocrossval' - run full model (no cross-validation)
%		'loo' - run leave-one-out cross-validation
%		'XXfold', where XX is an integer, will run XX-fold cross-validation
% - jittterrange is a 2-element vector in samples.
% - sigmamultiplier is a scalar.
% - windowOffset is a scalar or 2-element vector in samples.
% - resplock is a binary value that should be true if you want to
%   response-lock the data (default), false if you want to stimulus-lock.
%
% OUTPUTS:
% -ALLEEG is the input array, but with info about the analysis stored in
% 		the ica-related fields of the datasets in setlist.  Specifically, 
% 		EEG.icawinv contains the forward model across all datasets.  
% 		EEG.icaweights contains the weight vector v (with no bias term).
% -v is the weight vector from the training data (the first d are spatial
% 		weights, and the last element is the bias.)  Negative values of
% 		y=x*v(1:end-1) + v(end) indicate that the sample is part of setlist(1)'s
% 		class.  Positive values indicate setlist(2)'s class.
% -Azloo and time are vectors of the leave-one-out Az values and the center
% 		of the time bin (in ms from setlist(1)'s time zero) at which they were 
% 		calculated.
%
% Created 8/15/12 by DJ based on run_logisticregression_jittered_EM_saccades.m
% Updated 9/18/12 by DJ - conditionPrior compatibility (v2p0)
% Updated 9/25/12 by DJ - demeandata option
% Updated 9/26/12 by DJ - resplock input, more jitter settings
% Updated 10/5/12 by DJ - v2p1
% TO DO: FIX OUTPUTS!

% Define defaults
if ~exist('weightprior','var') || isempty(weightprior)
    weightprior = 1;
end
if ~exist('cvmode','var') || isempty(cvmode)
    cvmode = '10fold';
end
if ~exist('jitterrange','var') || isempty(jitterrange)
    jitterrange = [0 500];
end
if ~exist('sigmamultiplier','var') || isempty(sigmamultiplier)
    sigmamultiplier = 1;
end
if ~exist('windowOffset','var') || isempty(windowOffset)
    windowOffset = 385;
end
if ~exist('resplock','var') || isempty(resplock)
    resplock = true;
end
if ~exist('lambda','var') || isempty(lambda)
    lambda = 1e-5;
end

% Load data for given subject
[ALLEEG,~,setlist] = loadSubjectData_facecar(subject); % eeg info and saccade info
chansubset = 1:ALLEEG(setlist(1)).nbchan; 
% Get RTs
RT1 = getRT(ALLEEG(setlist(1)),'RT');
RT2 = getRT(ALLEEG(setlist(2)),'RT');

demeandata = 0;
if demeandata~=0
    meanX = mean(cat(3,ALLEEG(1).data, ALLEEG(2).data),3);
    ALLEEG(1).data = ALLEEG(1).data-repmat(meanX,[1,1,ALLEEG(1).trials]);
    ALLEEG(2).data = ALLEEG(2).data-repmat(meanX,[1,1,ALLEEG(2).trials]);    
end



if resplock
    % Jitter data (for Response-locked Analysis)
    tWindow(1) = (ALLEEG(setlist(1)).times(1) - min([RT1 RT2]))/1000;
    tWindow(2) = (ALLEEG(setlist(1)).times(end) - max([RT1 RT2]))/1000;
    EEG = pop_epoch(ALLEEG(setlist(1)),{'RT'},tWindow);
    ALLEEG = eeg_store(ALLEEG,EEG,setlist(1));
    EEG = pop_epoch(ALLEEG(setlist(2)),{'RT'},tWindow);
    ALLEEG = eeg_store(ALLEEG,EEG,setlist(2)); 
else
    % For Stimulus-locked Analysis
    tWindow = [ALLEEG(1).xmin ALLEEG(1).xmax];
    EEG = pop_epoch(ALLEEG(setlist(1)),{'Stim'},tWindow);
    ALLEEG = eeg_store(ALLEEG,EEG,setlist(1));
    EEG = pop_epoch(ALLEEG(setlist(2)),{'Stim'},tWindow);
    ALLEEG = eeg_store(ALLEEG,EEG,setlist(2));
end

% Declare jitter parameters
scope_settings.jitter_fn = @computeJitterPrior_exgaussian;
% GAUSSIAN
if isequal(scope_settings.jitter_fn,@computeJitterPrior_gaussian)
    scope_settings.jitter_mu = 0;
    scope_settings.jitter_sigma = std([RT1 RT2]);
    scope_settings.jitter_tau = NaN;
    scope_settings.jitter_mirror = NaN;
elseif isequal(scope_settings.jitter_fn,@computeJitterPrior_exgaussian)
    % EX-GAUSSIAN
%     R = simple_egfit([RT1 RT2] - mean([RT1 RT2]));
    fit = load('AllSubjects_ExGaussianFit.mat');
    R = fit.R;
    scope_settings.jitter_mu = R(1);
    scope_settings.jitter_sigma = R(2);
    scope_settings.jitter_tau = R(3);
    scope_settings.jitter_mirror = resplock; % if we're looking for the stim time, fliplr the distribution!
else
    scope_settings.jitter_mu = NaN;
    scope_settings.jitter_sigma = NaN;
    scope_settings.jitter_tau = NaN;
    scope_settings.jitter_mirror = NaN;
end

% Declare scope of analysis
scope_settings.subject = subject;
scope_settings.jitterrange = jitterrange; % In samples please!
scope_settings.trainingwindowlength = 50; % 13
scope_settings.trainingwindowinterval = 20; % 6
scope_settings.trainingwindowrange = [0 0]+windowOffset; %+275; %[0 0]; %[-500 500]; % in ms
if scope_settings.trainingwindowrange(1) + jitterrange(1) - ceil(scope_settings.trainingwindowlength/2) < tWindow(1)*1000
    scope_settings.trainingwindowrange(1) = tWindow(1)*1000-jitterrange(1) + ceil(scope_settings.trainingwindowlength/2);
end
if scope_settings.trainingwindowrange(2) + jitterrange(2) + ceil(scope_settings.trainingwindowlength/2) > tWindow(2)*1000
    scope_settings.trainingwindowrange(2) = tWindow(2)*1000-jitterrange(2) - ceil(scope_settings.trainingwindowlength/2);
end
scope_settings.parallel = 0;
scope_settings.cvmode = cvmode;
scope_settings.demeandata = 0;

% Declare parameters of pop_logisticregressions_jittered_EM
pop_settings.convergencethreshold = 1e-2; %1e-6; % subspace between spatial weights at which algorithm converges
pop_settings.jitterrange = jitterrange; % In samples please!
pop_settings.weightprior = weightprior; % re-weight prior according to prevalence of each label
pop_settings.forceOneWinner = 0; % make all posteriors 0 except max (i.e. find 'best saccade' in each trial)
pop_settings.conditionPrior = 0; % calculate likelihood such that large values of y (in either direction) are rewarded
pop_settings.null_sigmamultiplier = sigmamultiplier; % how much to expand the null y distribution

% Declare parameters of logist_weighted
logist_settings.eigvalratio = 1e-4;
logist_settings.lambda = lambda;%1e-5;
logist_settings.lambdasearch = false;
logist_settings.regularize = true;


% Define output directory that encodes info about this run
nowstring = datestr(now,'_yyyy-mm-dd-HH:MM');
outDirName = ['./results_',subject];
if weightprior == 1
    outDirName = [outDirName,'_weightprior'];
else
    outDirName = [outDirName,'_noweightprior'];
end
outDirName = [outDirName,'_',cvmode];
outDirName = [outDirName,'_jrange_',num2str(pop_settings.jitterrange(1)),'_to_',num2str(pop_settings.jitterrange(2))];
outDirName = [outDirName,'_lambda_',sprintf('%.2e',lambda)];
outDirName = [outDirName, nowstring, '/'];

% run algorithm with given data & parameters
run_logisticregression_jittered_EM_gaussian_v3p0(outDirName,...
											ALLEEG,...
											setlist,...
											chansubset,...
											scope_settings,...
                                            pop_settings,...
                                            logist_settings);

% TO DO: FIX OUTPUTS!                                        
v = []; Azloo = []; time = [];
