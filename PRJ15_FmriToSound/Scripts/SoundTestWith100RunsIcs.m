% SoundTestWith100RunsIcs.m
% 
% Created 12/20/17 by DJ.

%% Load betas
subjects = 1; % 1:2 would be more complete
sessions = 1:3; % 1:9 would be more complete
tasks = 1:13;

cd /Volumes/data/PRJ15_FmriToSound/TestData/100RUNS_3Tmultiecho
% Load timecourses and betas
[icTcs_accepted,betas_accepted,iAccepted,taskTc] = deal(cell(numel(subjects),numel(sessions),numel(tasks)));

for i=1:numel(subjects)
    for j=1:numel(sessions)
        for k=1:numel(tasks)            
            if exist(sprintf('SBJ%02d_S%02d_Task%02d_accepted.txt',subjects(i),sessions(j),tasks(k)),'file')
                fprintf('%d, %d, %d...\n',i,j,k);            
                [icTcs_accepted{i,j,k},betas_accepted{i,j,k},iAccepted{i,j,k}] = Get100RunsAcceptedCompTcs(subjects(i),sessions(j),tasks(k));
                betas_accepted{i,j,k} = betas_accepted{i,j,k}.img;
                [taskTc{i,j,k}, tTask] = Get100RunsTaskTimecourse(subjects(i),sessions(j),tasks(k));

            end
        end
    end
end
fprintf('Done!\n');
%% Get matches

% iFound = find(~cellfun(@isempty,icTcs_accepted));
% 
% [iBest,match] = deal(cell(numel(iFound)));
% for i=1:numel(iFound)
%     comps1 = betas_accepted{iFound(i)};
%     for j=(i+1):numel(iFound)
%         fprintf('%d vs. %d/%d...\n',i,j,numel(iFound))
%         comps2 = betas_accepted{iFound(j)};
%         [iBest{i,j},match{i,j}] = MatchAllComponents(comps1,comps2);
%     end
% end
% fprintf('Done!\n');

%% Cluster components
iFound = find(~cellfun(@isempty,icTcs_accepted));

% Turn each weight matrix into a single column
betas_all = cat(4,betas_accepted{iFound});
nComps = size(betas_all,4);
X = reshape(betas_all,numel(betas_all)/nComps,nComps)';
% Cluster using distance matrices
[idx,C,sumd,D] = kmeans(X,30);

%% Plot clusters
iComp = 8;
% plot centroid
betaComp = reshape(C(iComp,:),[size(betas_all(:,:,:,1)),numel(iComp)]);
GUI_3View(betaComp);

%% For a given run, grab comp closest to each centroid

%% Select components from one run
i=1;j=1;k=1;
icTcs_this = icTcs_accepted{i,j,k};
betas_this = betas_accepted{i,j,k};
taskTc_this = taskTc{i,j,k};
tTask_this = tTask;

% save TestData100RunsSound *this
% load TestData100RunsSound

%% Rank components in terms of their variance explained.
varex = var(icTcs_this);
[varex_sorted,order] = sort(varex,'descend');
icTcs_sorted = icTcs_this(:,order);
betas_sorted = betas_this(:,:,:,order);  

iComps = 1:9; % pick useful components(?)
icTcs_cropped = icTcs_sorted(:,iComps)';
betas_cropped = betas_sorted(:,:,:,iComps);
%% Plot components
figure(562); clf;
nRows = ceil(sqrt(numel(iComps)));
nCols = ceil(numel(iComps)/nRows);
mask = any(betas_cropped~=0,4)/2;
for i=1:numel(iComps)
    subplot(nRows,nCols,i);
    betas_temp = betas_cropped(:,:,:,i);
    betas_temp = betas_temp/GetValueAtPercentile(betas_temp(:),99.9)*0.5;
    betasOnMask = cat(4,mask,mask+betas_temp,mask);
    Plot3Planes(betasOnMask);    
    axis([0 3 0 1]);
    title(sprintf('component %d: variance %.3g',iComps(i),varex_sorted(iComps(i))));
end
colormap gray
%% Turn into sound
slowFactor = 0.1;
percentileCutoff = 50;
TR = 2;
% Plot timecourse of task
figure(3);
imagesc(tTask_this*slowFactor/TR,1:3,taskTc_this);
% scale IC TCs
icTcs_scaled = (icTcs_cropped-GetValueAtPercentile(icTcs_cropped,percentileCutoff))*100;
icTcs_scaled(icTcs_scaled<0) = 0;

[atlasSound,Fs] = SonifyAtlasTimecourses_midi(icTcs_scaled,slowFactor,'pentatonic','sine');
PlotAndPlaySonifiedData(icTcs_scaled,slowFactor,atlasSound,Fs);