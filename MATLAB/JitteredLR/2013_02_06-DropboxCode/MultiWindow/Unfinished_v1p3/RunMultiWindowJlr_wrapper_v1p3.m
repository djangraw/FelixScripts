function RunMultiWindowJlr_wrapper_v1p2(subject,weightprior,cvmode,jitterrange,sigmamultiplier,windowOffset,resplock,lambda,suffix)

% Runs jittered logistic regression (EM version) on a given subject using 
% pre-defined paramters.
%
% RunMultiWindowJlr_wrapper_v1p2(subject,weightprior,cvmode,jitterrange,
%           sigmamultiplier, windowOffset,resplock,lambda,suffix)
% RunMultiWindowJlr_wrapper_v1p2(ALLEEG,scope_settings,pop_settings,
%           logist_settings,suffix)
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
% - lambda is a scalar indicating the regularization constant used in
% logist calculations.
% - suffix is a string describing the analysis.  It will show up in the
%   name of the folder saved by this program.
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
% Created 12/14/12 by DJ based on run_logisticregression_jittered_EM_wrapper_RT_v3p1
% Updated 12/17/12 by DJ - added uniform prior option, pop_settings.max_iter
% Updated 12/18/12 by DJ - added suffix input, made v1p1
% Updated 12/19/12 by DJ - v1p2 (soft EM)
% Updated 1/8/13 by DJ - v1p3 (reward c'=c and penalize c'=-c)


if isstruct(subject) % If using alternate usage RunMultiWindowJlr_wrapper_v1p2(ALLEEG,scope_settings,pop_settings,logist_settings)

    ALLEEG = subject;
    scope_settings = weightprior;
    pop_settings = cvmode;
    logist_settings = jitterrange;
    if ~exist('sigmamultiplier','var')
        suffix = '';
    else
        suffix = sigmamultiplier;
    end
    subject = ALLEEG(1).setname(1:find(ALLEEG(1).setname=='_',1)-1);
else
    
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
    if ~exist('suffix','var') || isempty(suffix);
        suffix = '';
    end

    % Load data for given subject
    [ALLEEG,~,setlist] = loadSubjectData_facecar(subject); % eeg info and saccade info
    chansubset = 1:ALLEEG(setlist(1)).nbchan; 
    % Get RTs
    RT1 = getRT(ALLEEG(setlist(1)),'RT');
    RT2 = getRT(ALLEEG(setlist(2)),'RT');

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
%     scope_settings.jitter_fn = @computeJitterPrior_uniform;
    % scope_settings.jitter_fn = @computeJitterPrior_exgaussian;
%     scope_settings.jitter_fn = @computeJitterPrior_templatematch;
    % scope_settings.jitter_fn = @computeJitterPrior_templatematch_exgauss;
    scope_settings.jitter_fn = @computeJitterPrior_templatematch_pca;
    % GAUSSIAN
    if isequal(scope_settings.jitter_fn,@computeJitterPrior_gaussian)
        scope_settings.jitterparams.mu = 0;
        scope_settings.jitterparams.sigma = std([RT1 RT2]);
    elseif isequal(scope_settings.jitter_fn,@computeJitterPrior_exgaussian)
        % EX-GAUSSIAN
    %     R = simple_egfit([RT1 RT2] - mean([RT1 RT2]));
        fit = load('AllSubjects_ExGaussianFit.mat');
        R = fit.R;
        scope_settings.jitterparams.mu = R(1);
        scope_settings.jitterparams.sigma = R(2);
        scope_settings.jitterparams.tau = R(3);
        scope_settings.jitterparams.mirror = resplock; % if we're looking for the stim time, fliplr the distribution!
    elseif isequal(scope_settings.jitter_fn,@computeJitterPrior_templatematch) || isequal(scope_settings.jitter_fn,@computeJitterPrior_templatematch_exgauss)
        scope_settings.jitterparams.smoothwidth = 50; 
        scope_settings.jitterparams.tWin = [-400 0]; %[-500 0];
    %     iChans = find(ismember({ALLEEG(1).chanlocs.labels},{'Oz' 'Cz' 'Fz' 'P3' 'P4'}));
        iChans = find(ismember({ALLEEG(1).chanlocs.labels},{'Cz'}));
        [scope_settings.jitterparams.template, scope_settings.jitterparams.data] = GetEegTemplate_iterative(ALLEEG,iChans,scope_settings.jitterparams.tWin,scope_settings.jitterparams.smoothwidth); % declare here, before de-meaning the data       
        scope_settings.jitterparams.times = ALLEEG(setlist(1)).times;
        scope_settings.jitterparams.useMax = false;
    elseif isequal(scope_settings.jitter_fn,@computeJitterPrior_templatematch_pca)    
        scope_settings.jitterparams.tWin = [-400 0]; %[-500 0];
        smoothwidth = 50; 
        iComps = 1:5;       
        [scope_settings.jitterparams.template, scope_settings.jitterparams.data] = GetPcaTemplate(ALLEEG, iComps, scope_settings.jitterparams.tWin, smoothwidth, jitterrange); % declare here, before de-meaning the data                   
        scope_settings.jitterparams.times = ALLEEG(setlist(1)).times;
        scope_settings.jitterparams.useMax = false;
    elseif isequal(scope_settings.jitter_fn,@computeJitterPrior_uniform)
        scope_settings.jitterparams.range = jitterrange;
        scope_settings.jitterparams.nTrials = 1;
        scope_settings.jitterparams.tInit = 0; % initial max time
    else
        scope_settings.jitterparams = [];
    end

    % Declare scope of analysis
    scope_settings.subject = subject;
    scope_settings.jitterrange = jitterrange; % In samples please!
    scope_settings.trainingwindowlength = 50; 
    scope_settings.trainingwindowinterval = 50; 
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
    pop_settings.max_iter = 2; % how many iterations the algorithm has to converge

    % Declare parameters of logist_weighted
    logist_settings.eigvalratio = 0;%1e-4; %None of the facecar data eliminates components with 1e-4
    logist_settings.lambda = lambda;%1e-5;
    logist_settings.lambdasearch = false;
    logist_settings.regularize = true;
    logist_settings.useOffset = ~scope_settings.demeandata; % otherwise offset will be set to zero
end

% Define output directory that encodes info about this run
nowstring = datestr(now,'_yyyy-mm-dd-HH:MM');
outDirName = ['./multiwinresults_',subject];

outDirName = [outDirName,'_',scope_settings.cvmode];
outDirName = [outDirName,'_jrange_',num2str(pop_settings.jitterrange(1)),'_to_',num2str(pop_settings.jitterrange(2))];
outDirName = [outDirName,'_lambda_',sprintf('%.2e',logist_settings.lambda)];
outDirName = [outDirName, nowstring, suffix, '/'];

% run algorithm with given data & parameters
RunMultiWindowJlr_v1p3(outDirName,...
                        ALLEEG,...
                        scope_settings,...
                        pop_settings,...
                        logist_settings);


