function RunMultiWindowJlr_v1p2(outDirName,ALLEEG,scope_settings, pop_settings, logist_settings)
% Perform logistic regression with trial jitter on a dataset.
%
%
% RunMultiWindowJlr_v1p2(outDirName,ALLEEG,scope_settings, pop_settings,
%       logist_settings)
%
% INPUTS:
% -outDirName: a string specifying where results are to be saved (DEFAULT: './results/')
% -ALLEEG is an array of EEGlab data structures
% -setlist is a 2-element vector of the ALLEEG indices you wish to discriminate
% -chansubset is a d-element array of the channel numbers you wish to use for discrimination 
%		(DEFAULT: [] -- use all channels)
% -trainingwindowlength is the number of samples that are in the training window
% -trainingwindowinterval is the number of samples by which you want to slide your training window each time
% -jitterrange specifies the minimum and maximum 
% -reactionTimes1 and reactionTimes2 are the times in ms...
% -convergencethreshold
% -cvmode is a string specifying what type of cross-validation to run.  Can be:
%		'nocrossval' - run full model (no cross-validation)
%		'loo' - run leave-one-out cross-validation
%		'XXfold', where XX is an integer, will run XX-fold cross-validation
%	(DEFAULT:  '10fold')
% -weightprior is a boolean 
%
% Created 12/14/12 by DJ based on run_logisticregression_jittered_EM_gaussian_v3p1
% Updated 12/18/12 by DJ - v1p1.
% Updated 12/19/12 by DJ - v1p2 (soft EM), multi-offset posts & p values

% ******************************************************************************************

% Declare settings
UnpackStruct(scope_settings); % jitterrange, trainingwindowlength/interval/range, parallel, cvmode, convergencethreshold
plotAz = 0;

% Subtract mean across both datasets
if demeandata~=0
    meanX = mean(cat(3,ALLEEG(1).data, ALLEEG(2).data),3);
    ALLEEG(1).data = ALLEEG(1).data-repmat(meanX,[1,1,ALLEEG(1).trials]);
    ALLEEG(2).data = ALLEEG(2).data-repmat(meanX,[1,1,ALLEEG(2).trials]);    
end

% Find offset (in samples) of each training window given desired times
loc1 = find(ALLEEG(1).times <= trainingwindowrange(1), 1, 'last' ); 
loc2 = find(ALLEEG(1).times >= trainingwindowrange(2), 1 );
loc1 = loc1 - floor(trainingwindowlength/2);
loc2 = loc2 - floor(trainingwindowlength/2);
trainingwindowoffset = loc1 : trainingwindowinterval : loc2; %1-jitterrange(1) : trainingwindowinterval : ALLEEG(1).pnts-trainingwindowlength-jitterrange(2);

% Set initial weights
vinit = zeros(ALLEEG(1).nbchan+1,length(trainingwindowoffset));

% Set up prior struct
jitterPrior = [];
    jitterPrior.fn = jitter_fn;
    jitterPrior.params = jitterparams;
nPrior = diff(jitterrange)+1; % # samples in prior
    
% Set cross-validation parameters
if ~isdir(outDirName); mkdir(outDirName); end;
tic;
N1 = ALLEEG(1).trials;
N2 = ALLEEG(2).trials;
N = ALLEEG(1).trials + ALLEEG(2).trials;
cv = setGroupedCrossValidationStruct(cvmode,ALLEEG(1),ALLEEG(2));

% Save parameters
save([outDirName,'/params_',cvmode,'.mat'], 'ALLEEG','cv','trainingwindowoffset','scope_settings','pop_settings','logist_settings');

% Set up parallel computing
poolsize = min(10,cv.numFolds); % max 15 workers for cluster, 4 for local machine
if poolsize == 1; parallel = 0; end;
if parallel == 1
    warning('Run pctconfig(''hostname'', ''ip'') before running this function');
    mls = matlabpool('size');
    if mls > 0; matlabpool close; end;
    matlabpool('open',poolsize);
    trainingwindowlength = trainingwindowlength;
end

% Declare cross-fold variables ('sliced' for compatibility with parfor loops)
ps = cell(cv.numFolds,1);
posts = cell(cv.numFolds,1);
posts2 = cell(cv.numFolds,1);
vout = cell(cv.numFolds,1);
testsample = cell(cv.numFolds,1);
jitterPriorLoop = repmat({jitterPrior},cv.numFolds,1);
jitterPriorTest = repmat({jitterPrior},cv.numFolds,1);
if isfield(jitterPrior.params,'data');
    for j=1:cv.numFolds
        jitterPriorLoop{j}.params.data = jitterPrior.params.data(:,:,[cv.incTrials1{j}, cv.incTrials2{j}+N1]); % crop data to just training trials
        jitterPriorTest{j}.params.data = jitterPrior.params.data(:,:,[cv.valTrials1{j}, cv.valTrials2{j}+N1]); % crop data to just testing trials
    end
end
fwdmodels = cell(cv.numFolds,1);
pop_settings_out = cell(cv.numFolds,1);
foldALLEEG = cell(cv.numFolds,1);

% Run cross-validation loop
if parallel == 1
    parfor foldNum = 1:cv.numFolds % PARFOR!
        disp(['Running fold #',num2str(foldNum),' out of ',num2str(cv.numFolds)]);pause(1e-9);
	
        % Set up cropped ALLEEG struct for training
        foldALLEEG{foldNum}(1) = ALLEEG(1);
        foldALLEEG{foldNum}(2) = ALLEEG(2);
        foldALLEEG{foldNum}(1).data = foldALLEEG{foldNum}(1).data(:,:,cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(1).epoch = foldALLEEG{foldNum}(1).epoch(cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(1).trials = length(cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(2).data = foldALLEEG{foldNum}(2).data(:,:,cv.incTrials2{foldNum});
        foldALLEEG{foldNum}(2).epoch = foldALLEEG{foldNum}(2).epoch(cv.incTrials2{foldNum});
        foldALLEEG{foldNum}(2).trials = length(cv.incTrials2{foldNum});	
        % Set up cropped data for testing
        testsample{foldNum} = cat(3,ALLEEG(1).data(:,:,cv.valTrials1{foldNum}), ALLEEG(2).data(:,:,cv.valTrials2{foldNum}));

        % Perform training
        [vout{foldNum},fwdmodels{foldNum}] = SetUpMultiWindowJlr_v1p2(foldALLEEG{foldNum},trainingwindowlength,trainingwindowoffset,vinit,jitterPriorLoop{foldNum},pop_settings,logist_settings);

        % Perform testing
        [ps{foldNum},posts{foldNum},~,posts2{foldNum}] = TestMultiWindowJlr_v1p2(testsample{foldNum},trainingwindowlength,trainingwindowoffset,vout{foldNum},jitterPriorTest{foldNum},ALLEEG(1).srate,pop_settings);
       
        % Save settings
        pop_settings_out{foldNum} = pop_settings;
    end
else
    for foldNum = 1:cv.numFolds
        disp(['Running fold #',num2str(foldNum),' out of ',num2str(cv.numFolds)]);pause(1e-9);
	
        % Set up cropped ALLEEG struct for training
        foldALLEEG{foldNum}(1) = ALLEEG(1);
        foldALLEEG{foldNum}(2) = ALLEEG(2);
        foldALLEEG{foldNum}(1).data = foldALLEEG{foldNum}(1).data(:,:,cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(1).epoch = foldALLEEG{foldNum}(1).epoch(cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(1).trials = length(cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(2).data = foldALLEEG{foldNum}(2).data(:,:,cv.incTrials2{foldNum});
        foldALLEEG{foldNum}(2).epoch = foldALLEEG{foldNum}(2).epoch(cv.incTrials2{foldNum});
        foldALLEEG{foldNum}(2).trials = length(cv.incTrials2{foldNum});	
        % Set up cropped data for testing
        testsample{foldNum} = cat(3,ALLEEG(1).data(:,:,cv.valTrials1{foldNum}), ALLEEG(2).data(:,:,cv.valTrials2{foldNum}));

        % Perform training
        [vout{foldNum},fwdmodels{foldNum}] = SetUpMultiWindowJlr_v1p2(foldALLEEG{foldNum},trainingwindowlength,trainingwindowoffset,vinit,jitterPriorLoop{foldNum},pop_settings,logist_settings);

        % Perform testing
        [ps{foldNum},posts{foldNum},~,posts2{foldNum}] = TestMultiWindowJlr_v1p2(testsample{foldNum},trainingwindowlength,trainingwindowoffset,vout{foldNum},jitterPriorTest{foldNum},ALLEEG(1).srate,pop_settings);
       
        % Save settings
        pop_settings_out{foldNum} = pop_settings;
    end
end

% Convert cell arrays (compatible with parfor loops) to arrays for
% convenient calculations in the future
pop_settings_out = [pop_settings_out{:}]'; % convert from cells to struct array
W = length(trainingwindowoffset); % number of windows
p = zeros(N,W);
posterior = zeros(N,nPrior-1,W);
posterior2 = zeros(N,nPrior-1,W);
for foldNum=1:cv.numFolds
    p([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:) = ps{foldNum};
    posterior([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:,:) = posts{foldNum};
    posterior2([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:,:) = posts2{foldNum};
end

%% Calculate area under ROC curve (AZ)
truth = [zeros(ALLEEG(1).trials,1);ones(ALLEEG(2).trials,1)];
Azloo = zeros(1,length(trainingwindowoffset));
disp('---Cross-Validation Results---')
for iWin = 1:W
    Azloo(iWin) = rocarea(p(:,iWin),truth);
    fprintf('offset %d, %s Az: %6.2f\n',trainingwindowoffset(iWin),cvmode,Azloo(iWin));
end


% Record time elapsed during training + testing
t = toc; 
disp('Saving...')
% Save results
if ~isdir(outDirName); mkdir(outDirName); end;
save([outDirName,'/results_',cvmode,'.mat'],'vout','testsample','trainingwindowlength','truth','trainingwindowoffset','p','Azloo','t','fwdmodels','jitterPriorTest','pop_settings_out','posterior','posterior2');
    
% Plot LOO Results if requested
if plotAz
    disp('Plotting...')
    figure; hold on;
    plot(time,Azloo);
    plot(get(gca,'XLim'),[0.5 0.5],'k--');
    plot(get(gca,'XLim'),[0.75 0.75],'k:');
    ylim([0.3 1]);
    title('Cross-validation analysis');
    xlabel('time (s)');
    ylabel([cvmode ' Az']);
end

% Close parallel computing worker pool
mls = matlabpool('size');
if mls > 0; matlabpool close; end;

disp('Done!')

end

