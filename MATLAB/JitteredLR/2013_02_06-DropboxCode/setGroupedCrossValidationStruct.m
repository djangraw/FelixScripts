% Automatically separates two eeglab datasets into multi-fold trials.
%
% cv = setGroupedCrossValidationStruct(cvmode,ALLEEG1,ALLEEG2)
% 
% INPUTS:
% -cvmode is a string indicating the type of cross-validation to be
% performed. The options are 'nocrossval' (1 fold),'loo' (leave one out),
% or '<x>fold', where x is a whole number.
% -ALLEEG1 and 2 are eeglab datasets whose trials you wish to separate out
% into folds.
%
% OUTPUTS:
% -cv is a struct with fields incTrials1/2, outTrials1/2, valTrials1/2, and
%  numFolds.
%
% Created 8/27/11 (?) by BC.
% Updated 2/6/13 by DJ - comments.

%% ******************************************************************************************
function cv = setGroupedCrossValidationStruct(cvmode,ALLEEG1,ALLEEG2)

cv = [];
cv.mode = cvmode;
ntrials1 = ALLEEG1.trials;
ntrials2 = ALLEEG2.trials;
ntrials = ntrials1 + ntrials2;
if strcmp(cvmode,'nocrossval')
    cv.numFolds = 1;
    cv.incTrials1 = cell(1);cv.incTrials2 = cell(1);
    cv.outTrials1 = cell(1);cv.outTrials2 = cell(1);
    cv.valTrials1 = cell(1);cv.valTrials2 = cell(1);
    cv.incTrials1{1} = 1:ntrials1;
    cv.incTrials2{1} = 1:ntrials2;
    cv.outTrials1{1} = [];
    cv.outTrials2{1} = [];
    cv.valTrials1{1} = [];
    cv.valTrials2{1} = [];
elseif strcmp(cvmode,'loo')
    cv.numFolds = ntrials;
    cv.incTrials1 = cell(1,cv.numFolds);cv.incTrials2 = cell(1,cv.numFolds);
    cv.outTrials1 = cell(1,cv.numFolds);cv.outTrials2 = cell(1,cv.numFolds);
    cv.valTrials1 = cell(1,cv.numFolds);cv.valTrials2 = cell(1,cv.numFolds);
    for j=1:ntrials
    	if j <= ntrials1
    		cv.incTrials1{j} = setdiff(1:ntrials1,j);
    		cv.incTrials2{j} = 1:ntrials2;
    		cv.outTrials1{j} = j;
    		cv.outTrials2{j} = [];
    		cv.valTrials1{j} = j;
    		cv.valTrials2{j} = [];
    	else
    		j2 = j - ntrials1;
    		cv.incTrials1{j} = 1:ntrials1;
    		cv.incTrials2{j} = setdiff(1:ntrials2,j2);
    		cv.outTrials1{j} = [];
    		cv.outTrials2{j} = j2;
    		cv.valTrials1{j} = [];
    		cv.valTrials2{j} = j2;
    	end
    end
elseif strcmp(cvmode((end-3):end),'fold')
    cv.numFolds = str2num(cvmode(1:(end-4)));
    cv.incTrials1 = cell(1,cv.numFolds);cv.incTrials2 = cell(1,cv.numFolds);
    cv.outTrials2 = cell(1,cv.numFolds);cv.outTrials2 = cell(1,cv.numFolds);
    cv.valTrials1 = cell(1,cv.numFolds);cv.valTrials2 = cell(1,cv.numFolds);
    
    % Split the data into roughly equally-sized folds
    foldSizes = floor(ntrials/cv.numFolds)*ones(1,cv.numFolds);
    foldSizes(1:(ntrials-foldSizes(1)*cv.numFolds)) = foldSizes(1)+1;
    
    % We are now going to sort the trials based on urevent id
    epochID1 = zeros(1,ntrials1);
    epochID2 = zeros(1,ntrials2);
    for j=1:ntrials1; epochID1(j) = ALLEEG1.epoch(j).eventurevent{1}; end;
    for j=1:ntrials2; epochID2(j) = ALLEEG2.epoch(j).eventurevent{2}; end;
    
    [~,epochOrdering] = sort([epochID1,epochID2],'ascend');
    epochGrouping = ones(1,ntrials);
    locs = find(epochOrdering > ntrials1);
    epochGrouping(locs) = 2;
    epochOrdering(locs) = epochOrdering(locs) - ntrials1;

	eInd = 0;
	for j=1:cv.numFolds
		sInd = eInd + 1;
		eInd = sInd + foldSizes(j) - 1;
        sset = sInd:eInd;

		locs1 = find(epochGrouping(sset) == 1);
		locs2 = find(epochGrouping(sset) == 2);
		cv.outTrials1{j} = epochOrdering(sset(locs1));cv.valTrials1{j} = cv.outTrials1{j};
		cv.outTrials2{j} = epochOrdering(sset(locs2));cv.valTrials2{j} = cv.outTrials2{j};
		
		cv.incTrials1{j} = setdiff(1:ntrials1,cv.outTrials1{j});
		cv.incTrials2{j} = setdiff(1:ntrials2,cv.outTrials2{j});
		
	end
else
	error('Unknown cross-validation mode');
end
end
%% ************************************************************************
%% ******************