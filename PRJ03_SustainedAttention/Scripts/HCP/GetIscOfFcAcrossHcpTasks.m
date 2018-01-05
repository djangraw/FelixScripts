% GetIscOfFcAcrossHcpTasks.m
%
% Created 1/3/18 by DJ.

tasks = {'emotion','gambling','language','motor','relational','social','wm'};

cd /data/jangrawdc/PRJ03_SustainedAttention/Results/FromEmily
foo = load('HCP900_emotion_mats.mat');
nSubj=numel(foo.HCP900_sub_id);
nEdges = numel(VectorizeFc(foo.HCP900_emotion_mats(:,:,1)));

nTasks = numel(tasks);
fcMats = nan(nEdges,nSubj,nTasks);
for i=1:nTasks
    fprintf('Task %d/%d...\n',i,nTasks);
    foo = load(sprintf('HCP900_%s_mats.mat',tasks{i}));
    fcMats(:,:,i) = VectorizeFc(foo.(sprintf('HCP900_%s_mats',tasks{i})));
end

%% How many have each subj correlate with the mean of the others across tasks?
[r,p] = deal(nan(nSubj,nEdges));
for i=1:nSubj
    fprintf('subj %d/%d...\n',i,nSubj);
    iOthers = [1:(i-1), (i+1):nSubj];
    this = squeeze(fcMats(:,i,:))';
    meanOthers = squeeze(mean(fcMats(:,iOthers,:),2))';
    for j=1:nEdges
        [r(i,j),p(i,j)] = corr(this(:,j),meanOthers(:,j));
    end
end