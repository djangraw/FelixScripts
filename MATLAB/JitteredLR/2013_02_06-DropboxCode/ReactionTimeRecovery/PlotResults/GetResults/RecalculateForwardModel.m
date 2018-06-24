function [fwdmodels,fwdmodels_old] = RecalculateForwardModel(JLR,JLP)

% Created 9/28/12 by DJ.

nWin = numel(JLR.trainingwindowoffset);
nFolds = JLP.cv.numFolds;
trainingwindowlength = JLR.trainingwindowlength;
trainingwindowoffset = JLR.trainingwindowoffset;
UnpackStruct(JLP.pop_settings); % jitterrange,weightprior,forceOneWinner,conditionPrior
jitterPrior = JLR.jitterPriorTest{1};

% Extract data
raweeg1 = JLP.ALLEEG(1).data;
raweeg2 = JLP.ALLEEG(2).data;
% Smooth data
smootheeg1 = nan(size(raweeg1,1),size(raweeg1,2)-trainingwindowlength+1, size(raweeg1,3));
smootheeg2 = nan(size(raweeg2,1),size(raweeg2,2)-trainingwindowlength+1, size(raweeg2,3));
for i=1:size(raweeg1,3)
     smootheeg1(:,:,i) = conv2(raweeg1(:,:,i),ones(1,trainingwindowlength)/trainingwindowlength,'valid'); % valid means exclude zero-padded edges without full overlap
end
for i=1:size(raweeg2,3)
     smootheeg2(:,:,i) = conv2(raweeg2(:,:,i),ones(1,trainingwindowlength)/trainingwindowlength,'valid'); % valid means exclude zero-padded edges without full overlap
end
clear raweeg1 raweeg2
% Compute prior
[bigprior, priortimes] = jitterPrior.fn((1000/JLP.ALLEEG(1).srate)*(jitterrange(1):jitterrange(2)),jitterPrior.params);
priorrange = round((JLP.ALLEEG(1).srate/1000)*[min(priortimes),max(priortimes)]);


% Main loop
fwdmodels = cell(nFolds,1);
fwdmodels_old = cell(nFolds,1);
for i=1:nFolds
    % Get data, truth and prior for the trials in this fold
    data1 = smootheeg1(:,:,JLP.cv.incTrials1{i});
    data2 = smootheeg2(:,:,JLP.cv.incTrials2{i});
    ntrials1 = length(JLP.cv.incTrials1{i});
    ntrials2 = length(JLP.cv.incTrials2{i});    
    ptprior = repmat(bigprior/sum(bigprior),ntrials1+ntrials2,1);    
    truth=[zeros((diff(priorrange)+1)*ntrials1,1); ones((diff(priorrange)+1)*ntrials2,1)];

    for j=1:nWin        
        
        v = JLR.vout{i}(j,:)';        
        x = AssembleData(data1,data2,trainingwindowoffset(j),trainingwindowlength,priorrange);      
        y = x*v(1:end-1)+v(end);
        [nullx.mu, nullx.covar] = GetNullDistribution(data1,data2,trainingwindowoffset(j),trainingwindowlength,priorrange);
        nully.mu = nullx.mu'*v(1:end-1)+v(end);
        nully.sigma = sqrt(v(1:end-1)'*nullx.covar*v(1:end-1) + v(1:end-1)'*(nullx.mu'*nullx.mu)*v(1:end-1));
        nully.sigmamultiplier = null_sigmamultiplier; % widen distribution by the specified amount   
        
        D = ComputePosterior(ptprior,y,truth,trainingwindowlength,weightprior,forceOneWinner,conditionPrior,nully);        
        Dvec = reshape(D',numel(D),1);
        Dmat = repmat(Dvec,1,size(x,2));

        fwdmodels{i}(:,j) = (y\(x.*Dmat))';
        fwdmodels_old{i}(:,j) = (y\x)';
        fprintf('%d, ',j);
    end
    fprintf('Done with fold %d!\n',i);
end

end
        

%% HELPER FUNCTIONS FROM POP_...


function [muX,covarX] = GetNullDistribution(data1,data2,thistrainingwindowoffset,trainingwindowlength,jitterrange) 
    % Crop data to null parts
%     inull = [1:(thistrainingwindowoffset+jitterrange(1)-1), (thistrainingwindowoffset+jitterrange(2)+trainingwindowlength):length(data1)];
    inull = [1:(thistrainingwindowoffset+jitterrange(1)-1), (thistrainingwindowoffset+jitterrange(2)+1):size(data1,2)];
    X = cat(3,data1(:,inull,:),data2(:,inull,:));
    X = reshape(X,[size(X,1),size(X,3)*length(inull)]);
    % Get mean and std
    muX = mean(X,2);
    covarX = X*X'/size(X,2); % if y=v*X, std(y,1)=sqrt(v*covarX*v'-v*muX^2);
    % if y=w*X+b, std(y,1) = sqrt(w*covarX*w' + w*muX*muX'*w')
    
end % function GetNullDistribution

% FUNCTION AssembleData:
% Put de-jittered data into [(N*T) x D] matrix for input into logist
function [x, trialnum] = AssembleData(data1,data2,thistrainingwindowoffset,trainingwindowlength,jitterrange) 
    % Declare constants
%     iwindow = (thistrainingwindowoffset+jitterrange(1)) : (thistrainingwindowoffset+jitterrange(2)+trainingwindowlength-1);
    iwindow = (thistrainingwindowoffset+jitterrange(1)) : (thistrainingwindowoffset+jitterrange(2));
    
    x = cat(3,data1(:,iwindow,:),data2(:,iwindow,:));
    trialnum = repmat(reshape(1:size(x,3), 1,1,size(x,3)), 1, size(x,2));
    x = reshape(x,[size(x,1),size(x,3)*length(iwindow)])';
    trialnum = reshape(trialnum,[size(trialnum,1),size(trialnum,3)*length(iwindow)])';
    
end % function AssembleData


function [posterior,likelihood] = ComputePosterior(prior, y, truth, trainingwindowlength,weightprior,forceOneWinner,conditionPrior,nully)
    % put y and truth into matrix form 
    ntrials = size(prior,1);
    ymat = reshape(y,length(y)/ntrials,ntrials)';
    truthmat = reshape(truth,length(truth)/ntrials,ntrials)';
    
    % calculate likelihood
    likelihood = ones(size(prior));
    for i=1:size(prior,2)
        likelihood(:,i) = bernoull(truthmat(:,i),ymat(:,i));
    end
    
    if conditionPrior % condition prior on y value: more extreme y values indicate more informative saccades
%         null_y = yavg(isNull); % get y values for non-saccade timepoints
%          [nully.mu, nully.sigma] = normfit(null_y(:)); % gaussian fit of y values
%        nully.mu = -1; nully.sigma = 0.1;
        condprior = (1-normpdf(ymat,nully.mu,nully.sigma)/normpdf(0,0,nully.sigma)).*prior; % prior conditioned on y (p(t|y))    
%         condprior./repmat(sum(condprior,2),1,size(condprior,2)); % NOT NEEDED... WE NORMALIZE THE POSTERIOR LATER.
    else
        condprior = prior;
    end
    
    % calculate posterior
    posterior = likelihood.*condprior;
    
    % If requested, make all posteriors 0 except max
    if forceOneWinner
        [~,iMax] = max(posterior,[],2); % finds max posterior on each trial (takes first one if there's a tie)
        posterior = full(sparse(1:size(posterior,1),iMax,1,size(posterior,1),size(posterior,2))); % zeros matrix with 1's at the iMax points in each row
    end
    
    % normalize rows
    posterior = posterior./repmat(sum(posterior,2),1,size(posterior,2));
    
    % Re-weight priors according to the number of trials in each class
    if weightprior
        posterior(truthmat(:,1)==1,:) = posterior(truthmat(:,1)==1,:) / sum(truthmat(:,1)==1);
        posterior(truthmat(:,1)==0,:) = posterior(truthmat(:,1)==0,:) / sum(truthmat(:,1)==0);
    end

end % function ComputePosterior

