function [Azloo,posterior,posterior2] = RerunJlrTesting(JLR,JLP,pop_settings)

% Reruns just the test part of Jittered LR.
%
% function RerunTest_JLR(JLR,JLP)
%
% INPUTS:
% -JLR and JLP are the outputs of LoadJlrResults
%
% Created 10/1/12 by DJ.

if nargin<3
    pop_settings = JLR.pop_settings_out;
elseif numel(pop_settings) == 1
    pop_settings = repmat(pop_settings,1,numel(JLR.pop_settings_out));   
end


% Set up
srate = JLP.ALLEEG(1).srate;
nFolds = numel(JLR.vout);
trainingwindowlength = JLR.trainingwindowlength;
trainingwindowoffset = JLR.trainingwindowoffset;
testsample = JLR.testsample;
jitterPriorTest = JLR.jitterPriorTest;
vout = JLR.vout;
nPrior = diff(JLP.pop_settings.jitterrange)+1; 
N = JLP.ALLEEG(1).trials + JLP.ALLEEG(2).trials;
N1 = JLP.ALLEEG(1).trials;
cv = JLP.cv;

% Main Loop
[ps posts,posts2] = deal(cell(1,nFolds));
for foldNum=1:nFolds  
    fprintf('Testing Fold %d...\n',foldNum);
    ps{foldNum} = zeros(size(testsample{foldNum},3),length(trainingwindowoffset));
    posts{foldNum} = zeros(size(testsample{foldNum},3),nPrior,length(trainingwindowoffset));
    posts2{foldNum} = zeros(size(testsample{foldNum},3),nPrior,length(trainingwindowoffset));
%         valTrials = [cv.valTrials1{foldNum}, ALLEEG(setlist(1)).trials + cv.valTrials2{foldNum}]; % TEMP 9/24/12
    
    [ps{foldNum},posts{foldNum},~,posts2{foldNum}] = test_logisticregression_jittered_EM_v2p0(testsample{foldNum},trainingwindowlength,trainingwindowoffset,vout{foldNum},jitterPriorTest{foldNum},srate,pop_settings(foldNum));

%     for k=1:size(testsample{foldNum},3)
% %             jitterPriorTest{foldNum}.params.saccadeTimes = jitterPrior.params.saccadeTimes(valTrials(k)); % TEMP 9/24/12
%         [ps{foldNum}(k,:), thisPost, thisPost2] = runTest(testsample{foldNum}(:,:,k),trainingwindowlength,trainingwindowoffset,vout{foldNum},jitterPriorTest{foldNum},srate,pop_settings(foldNum));
%         posts{foldNum}(k,:,:) = permute(thisPost,[3 2 1]);
%         posts2{foldNum}(k,:,:) = permute(thisPost2,[3 2 1]);
%     end     

end

fprintf('Reshaping results...\n');
% Reshape posteriors
p = zeros(N,length(trainingwindowoffset));
posterior = zeros(N,nPrior,length(trainingwindowoffset));
posterior2 = zeros(N,nPrior,length(trainingwindowoffset));
for foldNum=1:nFolds
    p([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:) = ps{foldNum};
    posterior([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:,:) = posts{foldNum};
    posterior2([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:,:) = posts2{foldNum};
end

% Get Az values
truth = [zeros(JLP.ALLEEG(JLP.setlist(1)).trials,1);ones(JLP.ALLEEG(JLP.setlist(2)).trials,1)];
Azloo = nan(1,length(trainingwindowoffset));
for wini = 1:length(trainingwindowoffset)
    [Azloo(wini),~,~] = rocarea(p(:,wini),truth);
    fprintf('Window Onset: %d; LOO Az: %6.2f\n',trainingwindowoffset(wini),Azloo(wini));
end

disp('Success!');

end


% ---------------------------- %
% ----- Helper Functions ----- %
% ---------------------------- %

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