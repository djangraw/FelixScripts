% DemoRandomClusterCodeForDavidJangraw.m
%
% Created 10/11/16 by DH.

numsbjlist = 10:5:70; % I created this script to simulate multiple sample sizes
numedges=40000;
clear rval slopeval intersectval rvalLO slopevalLO intersectvalLO SignifTotal SignifByLO SignifEdgesByLO
tic
for nsbjidx=1:length(numsbjlist), % for each sample size

  numsbj=numsbjlist(nsbjidx);
  disp(['NEW NUM SBJ ' num2str(numsbj)]);
  % You could probably play with the types of random data to simulate
  RandMatrices = atanh(1-2*rand([numedges  numsbj]));
  RandBehavioral = rand(numsbj,1);
  RepRandBehavioral = repmat(reshape(RandBehavioral,[1 numsbj]),[numedges 1]);

  % Calculate regressions with all subjects
  [rval(:,nsbjidx) slopeval(:,nsbjidx) intersectval(:,nsbjidx)] = regression(squeeze(RandMatrices),RepRandBehavioral);


  % Calculate regressions leaving one subject out
  % LO is leave one out
  sbjlist=1:numsbj;

  for sbjidx=1:numsbj,
    disp(sbjidx);
    LOsbjlist = setdiff(sbjlist,sbjidx);
  
    [rvalLO{nsbjidx}(:,sbjidx) slopevalLO{nsbjidx}(:,sbjidx) intersectvalLO{nsbjidx}(:,sbjidx)] ...
        = regression(squeeze(RandMatrices(:,LOsbjlist)),RepRandBehavioral(:,1:(numsbj-1)));
    
     % Predictive fit with leave-one-out
     ResponseFit{nsbjidx}(:,sbjidx) = RandMatrices(:,sbjidx).*slopevalLO{nsbjidx}(:,sbjidx)+intersectvalLO{nsbjidx}(:,sbjidx);
     ResponseFitDiff{nsbjidx}(:,sbjidx) = ResponseFit{nsbjidx}(:,sbjidx)-RandBehavioral(sbjidx);
 
  end;

% calculate edges across LO with different r thresholds
rsigniflist = 0.01:0.01:0.6;

for ridx=1:length(rsigniflist),
  SignifTotal{nsbjidx}(:,ridx) = abs(rval(:,nsbjidx))>rsigniflist(ridx);
  SignifByLO{nsbjidx}(:,:,ridx) = abs(rvalLO{nsbjidx})>rsigniflist(ridx);
end;
SignifEdgesByLO(:,:,nsbjidx) = squeeze(sum(SignifByLO{nsbjidx},2));
% Above threshold edges when all subjects are included
TotalNumSignif(:,nsbjidx) = squeeze(sum(SignifTotal{nsbjidx},1));

% Above threshold edges when any subject is left out
tmp = zeros(size(SignifEdgesByLO(:,:,nsbjidx)));
tmp(find(SignifEdgesByLO(:,:,nsbjidx)==numsbj)) = 1;
LOAlwaysSignif(:,:,nsbjidx)=tmp;
LONumAlwaysSignif(:,nsbjidx) = sum(LOAlwaysSignif(:,:,nsbjidx),1);

% Above threshold edges with at least 90% of the leave-one-out tests
tmp = zeros(size(SignifEdgesByLO(:,:,nsbjidx)));
tmp(find(SignifEdgesByLO(:,:,nsbjidx)>=(0.9*numsbj))) = 1;
LO90Signif(:,:,nsbjidx) = tmp;
LONum90Signif(:,nsbjidx) = sum(LO90Signif(:,:,nsbjidx),1);


toc;
end;
clear RandMatrices RandBehavioral
save('/home/handwerkerd/DemoOutputRandomClusterCodeForDavidJangraw.mat');


clear signifhist
for nsbjidx=1:length(numsbjlist),
for ridx=1:length(rsigniflist),
  tmp = SignifEdgesByLO(:,ridx,nsbjidx);
  signifhist{nsbjidx}(:,ridx) = hist(tmp(find(tmp)), 1:numsbjlist(nsbjidx));
end;
end;

nsbjidx=5;
subplot(2,1,1)
plot(1:numsbjlist(nsbjidx),100*signifhist{nsbjidx}(:,5:5:end)/numedges);
legend(num2str(rsigniflist(5:5:end)'))
ylabel('% of edges above r threhold')
xlabel('# of subjects with the an edge above a threshold');
title(['Histogram ' num2str(numsbjlist(nsbjidx)) ' subjects'])

subplot(2,1,2);
plot(rsigniflist, 100*[TotalNumSignif(:,nsbjidx) LONumAlwaysSignif(:,nsbjidx) LONum90Signif(:,nsbjidx)]/numedges)
legend('Edges above r threshold using all subjects', ...
       'Edges above r threshold regardless of which sbj was left out', ...
        'Edges above r threshold when 90% of the leave-one-out subject choices');
xlabel('r threshold');
ylabel('% of edges above the threshold');