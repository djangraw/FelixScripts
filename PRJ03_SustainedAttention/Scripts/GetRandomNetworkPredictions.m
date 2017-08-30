% GetRandomNetworkPredictions.m
% Show p-value distribution for random edges
%
% Created 2/17/17 by DJ.

nSubj = 25;
nEdges = 300;
nRand = 500;
dprime = randn(nSubj,1);
fcRand = rand(nSubj,nEdges,nRand)*0.95;
[r1,p1] = corr(dprime,reshape(fcRand,nSubj,nEdges*nRand));
subplot(2,2,1); cla;
hist(p1);
xlabel('FC vs. d'' p value');
%% imitate training-testing circularity
isPos = reshape(r1>0 & p1<0.01,[nEdges nRand]);
[r2,p2] = deal(nan(nRand,1));
for i=1:nRand
    posScore = fcRand(:,:,i)*isPos(:,i);
    [r2(i),p2(i)] = corr(posScore,dprime);
end
subplot(222); cla;
hist(p2);

%% imitate LOO
[r3,p3] = deal(nan(nRand,1));
for i=1:nRand
    posScore = nan(nSubj,1);
    for j=1:nSubj
        iTest = j;
        iTrain = [1:(j-1), (j+1):nSubj];
        [r,p] = corr(dprime(iTrain),fcRand(iTrain,:,i));
        isPos = r>0 & p<0.01;
        posScore(j) = fcRand(iTest,:,i)*isPos';        
    end
    [r3(i),p3(i)] = corr(dprime,posScore);
end
%% Make one-tailed
p4 = nan(size(p3));
p4(r3>0) = p3(r3>0)/2;
p4(r3<=0) = 1-p3(r3<=0)/2;
subplot(223); cla;
hist(p4);