function [ALLEEG, v, Azloo, time] = run_logisticregression_jittered_EM_wrapper_oddball(subject,weightprior,cvmode,jitterrange,sigmamultiplier)

% Runs jittered logistic regression (EM version) on a given subject using 
% pre-defined paramters.
%
% [ALLEEG, v, Azloo, time] = run_logisticregression_jittered_EM_wrapper_oddball
%                  (subject,weightprior,cvmode,jitterrange,sigmamultiplier)
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

% Load data for given subject
[ALLEEG,~,setlist] = loadSubjectData_oddball(subject); % eeg info and saccade info
chansubset = 1:ALLEEG(setlist(1)).nbchan; 

% Jitter data
[ALLEEG(setlist(1)), jitter1] = jitterDataUniformly(ALLEEG(setlist(1)),jitterrange);
[ALLEEG(setlist(2)), jitter2] = jitterDataUniformly(ALLEEG(setlist(2)),jitterrange);

% Declare scope of analysis
scope_settings.subject = subject;
scope_settings.jitterrange = jitterrange; % In samples please!
scope_settings.trainingwindowlength = 50; % 13
scope_settings.trainingwindowinterval = 20; % 6
scope_settings.trainingwindowrange = [0 0]+375; %[0 0]; %[-500 500]; % in ms
scope_settings.parallel = 0;
scope_settings.cvmode = cvmode;

% Declare parameters of pop_logisticregressions_jittered_EM
pop_settings.convergencethreshold = 1e-2; %1e-6; % subspace between spatial weights at which algorithm converges
pop_settings.jitterrange = jitterrange; % In samples please!
pop_settings.weightprior = weightprior; % re-weight prior according to prevalence of each label
pop_settings.useFirstSaccade = 1; % 1st iteration prior is first saccade on each trial
pop_settings.removeBaselineYVal = 0; % Subtract average y value before computing posteriors
pop_settings.forceOneWinner = 1; % make all posteriors 0 except max (i.e. find 'best saccade' in each trial)
pop_settings.useTwoPosteriors = 1; % calculate posteriors separately for truth=0,1, use both for Az calculation
pop_settings.conditionPrior = 0; % calculate likelihood such that large values of y (in either direction) are rewarded
pop_settings.deNoiseData = 0; % only keep approved components (see pop code for selection) in dataset
pop_settings.deNoiseRemove = 1:4; % remove these components
pop_settings.null_sigmamultiplier = sigmamultiplier; % how much to expand the null y distribution

% Declare parameters of logist_weighted
logist_settings.eigvalratio = 1e-4;
logist_settings.lambda = 1e2;%1e-5;%1e-6;
logist_settings.lambdasearch = false;
logist_settings.regularize = true;


% Define output directory that encodes info about this run
outDirName = ['./results_',subject];
if weightprior == 1
    outDirName = [outDirName,'_weightprior'];
else
    outDirName = [outDirName,'_noweightprior'];
end
outDirName = [outDirName,'_',cvmode];
outDirName = [outDirName,'_jrange_',num2str(pop_settings.jitterrange(1)),'_to_',num2str(pop_settings.jitterrange(2))];
outDirName = [outDirName,'/'];

% run algorithm with given data & parameters
run_logisticregression_jittered_EM_oddball(outDirName,...
											ALLEEG,...
											setlist,...
											chansubset,...
											scope_settings,...
                                            pop_settings,...
                                            logist_settings);

v = []; Azloo = []; time = [];
