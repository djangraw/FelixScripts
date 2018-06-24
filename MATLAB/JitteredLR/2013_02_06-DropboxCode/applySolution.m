function [Az,posterior] = applySolution(ALLEEG,v,prior,scope_settings)

% Apply a known set of spatial and temporal weights to given data.
%
% [Az,posterior] = applySolution(ALLEEG,v,prior,scope_settings)
%
% INPUTS:
% -ALLEEG is a 2-element vector of eeglab data structs.  ALLEEG(1) is 
%  distractor trials, and ALLEEG(2) is target trials.  
% -v is the set of spatial weights you want applied to the data. v is an 
%  n+1 element vector, where n is the number of channels.
% -prior is a matrix of the jitter priors you want applied to the data.
%  prior is an m x k matrix, where m is the number of trials (distractors 
%  first, then targets) and k is the number of time points.
% -scope_settings is a struct determining the scope of data used, as in
%  run_logisticregression_jittered_EM_saccades().  It must contain fields
%  trainingwindowlength, trainingwindowinterval, and trainingwindowrange.
%
% OUTPUTS:
% -Az is a k-element vector indicating the area under the ROC curve based
%  on the results in each window.
% -posterior is a matrix of the jitter posteriors (prior x likelihood).
%  posterior is the same size as the input 'prior'.
%
% Created 10/18/11 by DJ.
% Updated 10/19/11 by DJ - normalize posterior

% extract trainingwindowlength, trainingwindowinterval, trainingwindowrange
UnpackStruct(scope_settings); 

% Create data
data = cat(3,ALLEEG(1).data, ALLEEG(2).data);
truth = [zeros(ALLEEG(1).trials,1);ones(ALLEEG(2).trials,1)];
nTrials = numel(truth);

% Get trainingwindowoffset
loc1 = find(ALLEEG(1).times <= trainingwindowrange(1), 1, 'last' ); 
loc2 = find(ALLEEG(1).times >= trainingwindowrange(2), 1 );
loc1 = loc1 - floor(trainingwindowlength/2);
loc2 = loc2 - floor(trainingwindowlength/2);
trainingwindowoffset = loc1 : trainingwindowinterval : loc2;
nWindows = numel(trainingwindowoffset);

% Set up
p = nan(nTrials,nWindows);
posterior = nan(size(prior));
Az = nan(1,nWindows);

% Discriminate
for i=1:nWindows
    % Extract samples that could possibly be in the window 
    iwindow = trainingwindowoffset(i) : (trainingwindowoffset(i)+length(prior)+trainingwindowlength-2);
       
    for j=1:nTrials
        % crop the data in this trial
        croppeddata = data(:,iwindow,j);

        % Find the y value for each sample
        yfull = v(1:end-1)*croppeddata+v(end);
        
        % Use a sliding average and put the result through a bernoulli fn.
        yavg = zeros(1,size(prior,2));
        likelihood = ones(size(yavg));
        for k=1:length(prior)
            iwindow2 = (1:trainingwindowlength)+k-1;
            yavg(k) = mean(yfull(iwindow2));
            likelihood(k) = bernoull(1,yavg(k));    
        end
        
        % Find posterior probability at each time point
        posterior(j,:,i) = likelihood.*prior(j,:);
        % Sum to find posterior label
        p(j,i) = sum(posterior(j,:,i));
        
        % normalize posterior for output
        posterior(j,:,i) = posterior(j,:,i)/p(j,i);
    end
    
    % Calculate area under ROC curve
    [Az(i),Ryloo,Rxloo] = rocarea(p(:,i),truth);
    fprintf('Window Onset: %d; LOO Az: %6.2f\n',trainingwindowoffset(i),Az(i));
end

end








    