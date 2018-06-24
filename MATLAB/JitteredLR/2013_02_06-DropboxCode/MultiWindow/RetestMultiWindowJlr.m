function JLRnew = RetestMultiWindowJlr(P,R)

% Run testing on multi-window JLR, with training results held constant.
%
% RetestMultiWindowJlr(R,P)
%
% INPUTS:
% P = parameters, R=results
%
% Created 12/28/12 by DJ.

%% RERUN TESTING
cv = setGroupedCrossValidationStruct(P.scope_settings.cvmode,P.ALLEEG(1),P.ALLEEG(2));
for foldNum = 1:cv.numFolds
    disp(['Running fold #',num2str(foldNum),' out of ',num2str(cv.numFolds)]);pause(1e-9);

    % Set up cropped data for testing
    testsample{foldNum} = cat(3,P.ALLEEG(1).data(:,:,cv.valTrials1{foldNum}), P.ALLEEG(2).data(:,:,cv.valTrials2{foldNum}));

    % Perform testing
    [ps{foldNum},posts{foldNum},~,posts2{foldNum}] = TestMultiWindowJlr_v1p2(testsample{foldNum},R.trainingwindowlength,R.trainingwindowoffset,R.vout{foldNum},R.jitterPriorTest{foldNum},P.ALLEEG(1).srate,P.pop_settings);

end

%%
nPrior = diff(P.scope_settings.jitterrange)+1; % # samples in prior
N1= P.ALLEEG(1).trials;
N = P.ALLEEG(1).trials + P.ALLEEG(2).trials;
W = length(R.trainingwindowoffset); % number of windows
p = zeros(N,W);
posterior = zeros(N,nPrior-1,W);
posterior2 = zeros(N,nPrior-1,W);
for foldNum=1:cv.numFolds
    p([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:) = ps{foldNum};
    posterior([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:,:) = posts{foldNum};
    posterior2([cv.valTrials1{foldNum},cv.valTrials2{foldNum}+N1],:,:) = posts2{foldNum};
end

%% Calculate area under ROC curve (AZ)
truth = [zeros(P.ALLEEG(1).trials,1);ones(P.ALLEEG(2).trials,1)];
Azloo = zeros(1,W);
disp('---Cross-Validation Results---')
for iWin = 1:W
    Azloo(iWin) = rocarea(p(:,iWin),truth);
    fprintf('offset %d, %s Az: %6.2f\n',R.trainingwindowoffset(iWin),P.scope_settings.cvmode,Azloo(iWin));
end

%% Prepare output
JLRnew = R;
JLRnew.p = p;
JLRnew.posterior = posterior;
JLRnew.posterior2 = posterior2;
JLRnew.Azloo = Azloo;