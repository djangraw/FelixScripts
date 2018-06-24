function JLRavg = AverageJlrResults(JLR,JLP)

% JLRavg = AverageJlrResults(JLR)
%
% INPUTS:
% -JLR and JLP are the outputs of LoadJlrResults.
%
% OUTPUTS:
% - JLRavg is a struct with fields:
%   * vout: avg weights across folds
%   * fwdmodels: avg forward models across folds
%   * vFirstIter: avg 1st iteration weights across folds
%   * truth, pred: true and predicted labels for each trial in each window
%   * post_truth: normalized posterior given the true label
%   * post_pred: normalized posterior given the predicted label
%   * post_avg: normalized posterior given the predicted probability of each label
%   * post: normalized posterior of choice (currently =post_avg)
%
% Created 9/27/12 by DJ.
% Updated 10/2/12 by DJ - added post_ output fields, switched to weighted
% avg posterior
% Updated 11/15/12 by DJ - use vout transverse
% Updated 11/26/12 by DJ - copy out post_0 and post_1
% Updated 12/14/12 by DJ - fixed post_1 bug
% Updated 12/28/12 by DJ - added multi-window kluge for postTimes,
% fwdmodels size correction for multiwin weirdness

% Average across folds
JLRavg.vout = mean(cat(3,JLR.vout{:}),3);
JLRavg.fwdmodels = mean(cat(3,JLR.fwdmodels{:}),3);
if isfield(JLR,'vFirstIter')
    JLRavg.vFirstIter = mean(cat(3,JLR.vFirstIter{:}),3);
end
% Flip JLRavg if necessary
if size(JLRavg.vout,2)~=size(JLRavg.fwdmodels,2)
    JLRavg.vout = JLRavg.vout';
end
% Crop fwdmodels if necessary (Kluge for MultiWin JLR)
if size(JLRavg.fwdmodels,1)==size(JLRavg.vout,1)
    JLRavg.fwdmodels = JLRavg.fwdmodels(1:end-1,:);
end

% Get posteriors from proper field and normalize them to sum to 1
[post_truth, post_pred, post_avg] = deal(zeros(size(JLR.posterior)));

% Use posterior of true label for each trial
truth = [zeros(1, JLP.ALLEEG(1).trials), ones(1,JLP.ALLEEG(2).trials)]; % true label
post_truth(truth==0,:,:) = JLR.posterior2(truth==0,:,:);
post_truth(truth==1,:,:) = JLR.posterior(truth==1,:,:);
post_truth = post_truth./repmat(sum(post_truth,2),[1,size(post_truth,2),1]); % Normalize each row to sum to 1

% Use posterior of predicted label for each trial
pred = (JLR.p>0.5); % predicted label
for i=1:size(JLR.posterior,3)
    post_pred(pred(:,i)==1,:,i) = JLR.posterior(pred(:,i)==1,:,i);
    post_pred(pred(:,i)==0,:,i) = JLR.posterior2(pred(:,i)==0,:,i);
end
post_pred = post_pred./repmat(sum(post_pred,2),[1,size(post_pred,2),1]); % Normalize each row to sum to 1

% Use average of the two posteriors weighted by the probability of each one
for i=1:size(JLR.posterior,3)
    post_avg(:,:,i) = JLR.posterior(:,:,i).*repmat(JLR.p(:,i),1,size(JLR.posterior,2)) + JLR.posterior2(:,:,i).*(repmat(1-JLR.p(:,i),1,size(JLR.posterior,2)));
end
post_avg = post_avg./repmat(sum(post_avg,2),[1,size(post_avg,2),1]); % Normalize each row to sum to 1

% Use posterior of label 0
post_0 = JLR.posterior2;
post_0 = post_0./repmat(sum(post_0,2),[1,size(post_0,2),1]); % Normalize each row to sum to 1

% Use posterior of label 1
post_1 = JLR.posterior;
post_1 = post_1./repmat(sum(post_1,2),[1,size(post_1,2),1]); % Normalize each row to sum to 1

% Include all three posteriors in output struct
JLRavg.truth = truth; % true label
JLRavg.pred = pred; % predicted label
JLRavg.post = post_avg; % AVERAGE IS THE WINNER!
JLRavg.post_truth = post_truth;
JLRavg.post_pred = post_pred;
JLRavg.post_avg = post_avg;
JLRavg.post_0 = post_0;
JLRavg.post_1 = post_1;

% Add in posterior times
JLRavg.postTimes = (1000/JLP.ALLEEG(1).srate*(JLP.scope_settings.jitterrange(1):JLP.scope_settings.jitterrange(2)));
if length(JLRavg.postTimes)-1 == length(JLRavg.post) % Kluge for multi-window code
    JLRavg.postTimes = JLRavg.postTimes(2:end);
end