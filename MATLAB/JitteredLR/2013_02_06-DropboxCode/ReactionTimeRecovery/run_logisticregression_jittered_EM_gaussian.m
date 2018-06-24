function run_logisticregression_jittered_EM_gaussian(outDirName,ALLEEG,setlist, chansubset, scope_settings, pop_settings, logist_settings)
% Perform logistic regression with trial jitter on a dataset.
%
%
% [ALLEEG,v,Azloo,time] = run_logisticregression_jittered_EM_gaussian(
%		outDirName,ALLEEG,setlist,chansubset,scope_settings,pop_settings,
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
% Created 5/12/11 by BC.
% Updated 8/3/11 by BC - include x-fold cross-validation
% Updated 9/14/11 by DJ - made sure fwd models are saved 
% Updated 9/20/11 by DJ - pass pop_settings struct to test function
% Updated 9/21/11 by DJ - switched to settings structs
% Updated 10/26/11 by DJ - fixed jitterprior bug
% Updated 12/13/11 by DJ - made plotting optional

%% ******************************************************************************************
%% Set up
% if ~exist('outDirName','var') || isempty(outDirName); outDirName = './results/'; end;
% if ~exist('setlist','var'); setlist = [1,2]; end;
% if ~exist('chansubset','var'); chansubset = []; end;
% if ~exist('trainingwindowlength','var'); trainingwindowlength = []; end;
% if ~exist('trainingwindowinterval','var'); trainingwindowinterval = []; end;
% if ~exist('jitterrange','var'); jitterrange = []; end;
% if ~exist('convergencethreshold','var'); convergencethreshold = []; end;
% if ~exist('cvmode','var'); cvmode = '10fold'; end;
% if ~exist('weightprior','var'); weightprior = 1; end;
UnpackStruct(scope_settings); % jitterrange, trainingwindowlength/interval/range, parallel, cvmode, convergencethreshold

% There may be other loaded EEG datasets, so let's save some memory and only keep the ones we need
ALLEEG = ALLEEG(setlist);
setlist = [1 2];

% Start -500ms and end +500ms relative to stimulus onset 
loc1 = find(ALLEEG(setlist(1)).times <= trainingwindowrange(1), 1, 'last' ); 
loc2 = find(ALLEEG(setlist(1)).times >= trainingwindowrange(2), 1 );
loc1 = loc1 - floor(trainingwindowlength/2);
loc2 = loc2 - floor(trainingwindowlength/2);
trainingwindowoffset = loc1 : trainingwindowinterval : loc2; %1-jitterrange(1) : trainingwindowinterval : ALLEEG(1).pnts-trainingwindowlength-jitterrange(2);
% trainingwindowoffset = 245;%190;%264;
iMidTimes = trainingwindowoffset + floor(trainingwindowlength/2); % middle of time window
time = ALLEEG(setlist(1)).times(iMidTimes)*0.001; % crop and convert to seconds

% Set parameters
vinit = zeros(length(chansubset)+1,1);

% Set up prior struct
jitterPrior = [];
    jitterPrior.fn = @computeJitterPrior_gaussian;
    jitterPrior.params = [];
    jitterPrior.params.mu = jitter_mu;
    jitterPrior.params.sigma = jitter_sigma;
    jitterPrior.params.nTrials = ALLEEG(setlist(1)).trials + ALLEEG(setlist(2)).trials;
[~,priortimes] = jitterPrior.fn((1000/ALLEEG(setlist(1)).srate)*(jitterrange(1):jitterrange(2)),jitterPrior.params);
nPrior = numel(priortimes);    
    
% Save parameters
if ~isdir(outDirName); mkdir(outDirName); end;

tic;
N1 = ALLEEG(setlist(1)).trials;
N2 = ALLEEG(setlist(2)).trials;
N = ALLEEG(setlist(1)).trials + ALLEEG(setlist(2)).trials;
cv = setGroupedCrossValidationStruct(cvmode,ALLEEG(setlist(1)),ALLEEG(setlist(2)));

save([outDirName,'/params_',cvmode,'.mat'], 'ALLEEG','setlist','cv','chansubset','trainingwindowoffset','scope_settings','pop_settings','logist_settings');
% save([outDirName,'/params_',cvmode,'.mat'], 'ALLEEG','setlist','cv','chansubset','trainingwindowlength', 'trainingwindowinterval', 'jitterrange', 'reactionTimes1', 'reactionTimes2', 'convergencethreshold', 'cvmode','weightprior');

poolsize = min(15,cv.numFolds); % 15 for einstein, 4 for local
if poolsize == 1; parallel = 0; end;
if parallel == 1
    warning('Make sure you run pctconfig(''hostname'', ''ip'')');
    mls = matlabpool('size');
    if mls > 0; matlabpool close; end;
    matlabpool('open',poolsize);
    % declare some variables
    trainingwindowlength = trainingwindowlength;
end

ps = cell(cv.numFolds,1);
posts = cell(cv.numFolds,1);
posts2 = cell(cv.numFolds,1);
vout = cell(cv.numFolds,1);
testsample = cell(cv.numFolds,1);
jitterPriorLoop = cell(cv.numFolds,1);
for j=1:cv.numFolds; jitterPriorLoop{j} = jitterPrior; end;
jitterPriorTest = cell(cv.numFolds,1);
for j=1:cv.numFolds; jitterPriorTest{j} = jitterPrior; end;
fwdmodels = cell(cv.numFolds,1);
foldALLEEG = cell(cv.numFolds,1);
pop_settings_out = cell(cv.numFolds,1);
if parallel == 1
    parfor foldNum = 1:cv.numFolds % PARFOR!
        disp(['Running fold #',num2str(foldNum),' out of ',num2str(cv.numFolds)]);pause(1e-9);
	
        foldALLEEG{foldNum}(1) = ALLEEG(setlist(1));
        foldALLEEG{foldNum}(2) = ALLEEG(setlist(2));
        foldALLEEG{foldNum}(1).data = foldALLEEG{foldNum}(1).data(:,:,cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(1).epoch = foldALLEEG{foldNum}(1).epoch(cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(1).trials = length(cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(2).data = foldALLEEG{foldNum}(2).data(:,:,cv.incTrials2{foldNum});
        foldALLEEG{foldNum}(2).epoch = foldALLEEG{foldNum}(2).epoch(cv.incTrials2{foldNum});
        foldALLEEG{foldNum}(2).trials = length(cv.incTrials2{foldNum});
        jitterPriorLoop{foldNum}.params.nTrials = length(cv.incTrials1{foldNum}) + length(cv.incTrials2{foldNum});
	
        testsample{foldNum} = cat(3,ALLEEG(setlist(1)).data(:,:,cv.valTrials1{foldNum}), ALLEEG(setlist(2)).data(:,:,cv.valTrials2{foldNum}));
        jitterPriorTest{foldNum}.params.nTrials = 1; % test one sample at a time
	
        [ALLEEGout,~,vout{foldNum}] = pop_logisticregression_jittered_EM(foldALLEEG{foldNum},[1 2],chansubset,trainingwindowlength,trainingwindowoffset,vinit,jitterPriorLoop{foldNum},pop_settings,logist_settings);
        fwdmodels{foldNum} = ALLEEGout(setlist(1)).icawinv;
        ps{foldNum} = zeros(size(testsample{foldNum},3),length(trainingwindowoffset));
        posts{foldNum} = zeros(size(testsample{foldNum},3),nPrior,length(trainingwindowoffset));
        posts2{foldNum} = zeros(size(testsample{foldNum},3),nPrior,length(trainingwindowoffset));
        for k=1:size(testsample{foldNum},3)
            [ps{foldNum}(k,:), thisPost, thisPost2] = runTest(testsample{foldNum}(:,:,k),trainingwindowlength,trainingwindowoffset,vout{foldNum},jitterPriorTest{foldNum},ALLEEG(setlist(1)).srate,ALLEEGout(setlist(1)).etc.pop_settings);
            posts{foldNum}(k,:,:) = permute(thisPost,[3 2 1]);
            posts2{foldNum}(k,:,:) = permute(thisPost2,[3 2 1]);
        end  
        pop_settings_out{foldNum} = ALLEEGout(setlist(1)).etc.pop_settings;
%        ps{foldNum} = runTest(testsample{foldNum},trainingwindowlength,trainingwindowoffset,jitterrange,vout{foldNum},jitterPriorTest{foldNum},ALLEEG(setlist(1)).srate);
    end
else
    for foldNum = 1:cv.numFolds
        disp(['Running fold #',num2str(foldNum),' out of ',num2str(cv.numFolds)]);pause(1e-9);
	
        foldALLEEG{foldNum}(1) = ALLEEG(setlist(1));
        foldALLEEG{foldNum}(2) = ALLEEG(setlist(2));
        foldALLEEG{foldNum}(1).data = foldALLEEG{foldNum}(1).data(:,:,cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(1).epoch = foldALLEEG{foldNum}(1).epoch(cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(1).trials = length(cv.incTrials1{foldNum});
        foldALLEEG{foldNum}(2).data = foldALLEEG{foldNum}(2).data(:,:,cv.incTrials2{foldNum});
        foldALLEEG{foldNum}(2).epoch = foldALLEEG{foldNum}(2).epoch(cv.incTrials2{foldNum});
        foldALLEEG{foldNum}(2).trials = length(cv.incTrials2{foldNum});
        jitterPriorLoop{foldNum}.params.nTrials = length(cv.incTrials1{foldNum}) + length(cv.incTrials2{foldNum});
	
        testsample{foldNum} = cat(3,ALLEEG(setlist(1)).data(:,:,cv.valTrials1{foldNum}), ALLEEG(setlist(2)).data(:,:,cv.valTrials2{foldNum}));
        jitterPriorTest{foldNum}.params.nTrials = 1; % test one sample at a time
	
        [ALLEEGout,~,vout{foldNum}] = pop_logisticregression_jittered_EM(foldALLEEG{foldNum},[1 2],chansubset,trainingwindowlength,trainingwindowoffset,vinit,jitterPriorLoop{foldNum},pop_settings,logist_settings);
        fwdmodels{foldNum} = ALLEEGout(setlist(1)).icawinv;
        ps{foldNum} = zeros(size(testsample{foldNum},3),length(trainingwindowoffset));
        posts{foldNum} = zeros(size(testsample{foldNum},3),nPrior,length(trainingwindowoffset));
        posts2{foldNum} = zeros(size(testsample{foldNum},3),nPrior,length(trainingwindowoffset));
        for k=1:size(testsample{foldNum},3)
            [ps{foldNum}(k,:), thisPost, thisPost2] = runTest(testsample{foldNum}(:,:,k),trainingwindowlength,trainingwindowoffset,vout{foldNum},jitterPriorTest{foldNum},ALLEEG(setlist(1)).srate,ALLEEGout(setlist(1)).etc.pop_settings);
            posts{foldNum}(k,:,:) = permute(thisPost,[3 2 1]);
            posts2{foldNum}(k,:,:) = permute(thisPost2,[3 2 1]);
        end        
%        ps{foldNum} = runTest(testsample{foldNum},trainingwindowlength,trainingwindowoffset,jitterrange,vout{foldNum},jitterPriorTest{foldNum},ALLEEG(setlist(1)).srate);
        pop_settings_out{foldNum} = ALLEEGout(setlist(1)).etc.pop_settings;
    end
end
pop_settings_out = [pop_settings_out{:}]'; % convert from cells to struct array

p = zeros(N,length(trainingwindowoffset));
posterior = zeros(N,nPrior,length(trainingwindowoffset));
posterior2 = zeros(N,nPrior,length(trainingwindowoffset));
for foldNum=1:cv.numFolds
    p([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:) = ps{foldNum};
    posterior([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:,:) = posts{foldNum};
    posterior2([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:,:) = posts2{foldNum};
end

truth = [zeros(ALLEEG(setlist(1)).trials,1);ones(ALLEEG(setlist(2)).trials,1)];
for wini = 1:length(trainingwindowoffset)
    [Azloo(wini),Ryloo,Rxloo] = rocarea(p(:,wini),truth);
    fprintf('Window Onset: %d; LOO Az: %6.2f\n',trainingwindowoffset(wini),Azloo(wini));
end
t = toc;

%fwdmodel = ALLEEG(setlist(1)).icawinv; % forward model, defined in pop_logisticregression as a=y\x.

if ~isdir(outDirName); mkdir(outDirName); end;
save([outDirName,'/results_',cvmode,'.mat'],'vout','testsample','trainingwindowlength','truth','trainingwindowoffset','p','Azloo','t','fwdmodels','jitterPriorTest','pop_settings_out','posterior','posterior2');
    
%% Plot LOO Results
plotAz = 0;
if plotAz
    figure; hold on;
    plot(time,Azloo);
    plot(get(gca,'XLim'),[0.5 0.5],'k--');
    plot(get(gca,'XLim'),[0.75 0.75],'k:');
    ylim([0.3 1]);
    title('Cross-validation analysis');
    xlabel('time (s)');
    ylabel([cvmode ' Az']);
end

mls = matlabpool('size');
if mls > 0; matlabpool close; end;

end
%% ******************************************************************************************


%% ******************************************************************************************
function [p, posterior,posterior2] = runTest(testsample,trainingwindowlength,trainingwindowoffset,vout,jitterPrior,srate,pop_settings)
    p = zeros(1,length(trainingwindowoffset));
    post = cell(1,length(trainingwindowoffset));
    post2 = cell(1,length(trainingwindowoffset));
	for wini = 1:length(trainingwindowoffset)
	    [p(wini),post{wini},~,post2{wini}] = test_logisticregression_jittered_EM(testsample,trainingwindowlength,trainingwindowoffset(wini),vout(wini,:),jitterPrior,srate,pop_settings);
%	    p(wini)=bernoull(1,y(wini));
    end
    posterior = cat(1,post{:});
    posterior2 = cat(1,post2{:});
end
%% ******************************************************************************************
