% CompareCpmWithMultipleCpmTasks.m
%
% Created 1/17/18 by DJ.


%% Set up
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

% Load behavior
fprintf('Loading behavior...\n');
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/FromEmily
% info = readtable('unrestricted_esfinn_7_14_2016_8_52_0.csv');
% beh = [info.PicSeq_Unadj, info.CardSort_Unadj, info.Flanker_Unadj, info.PicVocab_Unadj, info.ProcSpeed_Unadj, info.ListSort_Unadj, info.ReadEng_Unadj, info.PMAT24_A_CR];  
% behNames = {'Pic Seq (ep mem)','Card Sort (cog flex)','Flanker (inhib)','Pic Vocab (lang)','Pattern Compl (proc speed)','List Sort (WM)','Oral Reading Recog', 'PMAT (IQ)'};
[info, beh, behNames,taskBeh,taskBehNames,otherBeh,otherBehNames] = LoadHcpBehavior();
beh = [beh,taskBeh];
behNames = [behNames, taskBehNames];
nBeh = size(beh,2);

%% Crop both to ok subjects
fprintf('Cropping...\n');
bothSubj = intersect(foo.HCP900_sub_id, info.Subject);
fcMats = fcMats(:,ismember(foo.HCP900_sub_id,bothSubj),:);
beh = beh(ismember(info.Subject,bothSubj),:);

% Remove any subjects with nans/zeros.
isBadSubj = any(any(isnan(fcMats),1),3) | any(isnan(beh),2)' | any(all(fcMats==0,1),3);
fcMats = fcMats(:,~isBadSubj,:);
beh = beh(~isBadSubj,:);
nSubj = size(beh,1);

%% Try CPM with each task


thresh = 1;
corr_method = 'corr';
mask_method = 'cpcr';
nFolds = 5;
[cp_all,cr_all] = deal(cell(nTasks,nBeh));
for i=1:nTasks
    % Set up
    fprintf('Task %d/%d...\n',i,nTasks);
    FC = UnvectorizeFc(fcMats(:,:,i),0,true);
    for j=1:nBeh
        fprintf('Behavior %d/%d...\n',j,nBeh);
        behav = beh(:,j);
        % Run CPM
        switch mask_method
            case 'cpcr'
                [~, ~, ~,cp_all{i,j},cr_all{i,j}] = RunKfoldBehaviorRegression(FC,behav,thresh,corr_method,mask_method,nFolds);        
            otherwise
                [~,~,pred_glm,mask_pos_all,mask_neg_all] = RunKfoldBehaviorRegression(FC,behav,thresh,corr_method,mask_method,nFolds);
        end
    end
end
    
%% Pick threshold and evaluate results

thresh = 0.01;
corrtype = 'Spearman';
[r_true, p_true] = deal(nan(nTasks,nBeh));
pred_glm = deal(cell(nTasks,nBeh));

% Get CV folds
cv = setCrossValidationStruct(sprintf('%dfold',nFolds),nSubj);
testingSubj = cv.outTrials;

for i=1:nTasks
    fprintf('Task %d/%d...\n',i,nTasks);
    for j=1:nBeh
        fprintf('Behavior %d/%d...\n',j,nBeh);
        % Get scores
        pred_glm{i,j} = nan(1,nSubj);
        for k=1:nFolds            
            comboMask = GetNetworkAtThreshold(cr_all{i,j}(:,:,k),cp_all{i,j}(:,:,k),thresh);
            [~,~,pred_glm{i,j}(testingSubj{k})] = GetFcMaskMatch(UnvectorizeFc(fcMats(:,testingSubj{k},i),0,true),comboMask>0,comboMask<0);
        end
        % Correlate with behavior
        [r_true(i,j),p_true(i,j)] = corr(pred_glm{i,j}', beh(:,j),'tail','right','type',corrtype);        
    end
end

%% Plot results
figure(653); clf;
subplot(1,2,1);
imagesc(r_true);
colorbar;
title('R values');
set(gca,'xtick',1:nBeh,'xticklabel',behNames,'ytick',1:nTasks,'yticklabel',tasks)
xlabel('behavior');
ylabel('fMRI task');
xticklabel_rotate([],45);
subplot(1,2,2);
imagesc(p_true);
colorbar;
title('P values')
set(gca,'xtick',1:nBeh,'xticklabel',behNames,'ytick',1:nTasks,'yticklabel',tasks)
xticklabel_rotate([],45);
xlabel('behavior');
ylabel('fMRI task');

%% Use all tasks instead of just one

% Get CV folds
cv = setCrossValidationStruct(sprintf('%dfold',nFolds),nSubj);
testingSubj = cv.outTrials;

% Append FC vecs
fcMats_append = reshape(permute(fcMats,[1 3 2]),[size(fcMats,1)*nTasks,nSubj]);
[cp_all_append, cr_all_append] = deal(cell(1,nBeh));
for j=1:nBeh
    for i=1:nTasks
        cp_vec = VectorizeFc(cp_all{i,j});
        cr_vec = VectorizeFc(cr_all{i,j});
        cp_all_append{j} = cat(1,cp_all_append{j}, cp_vec);
        cr_all_append{j} = cat(1,cr_all_append{j}, cr_vec); 
    end
end

%% Get correlations at given threshold
% Set up
thresh = 0.01;
corrtype = 'Spearman';
[r_true_append, p_true_append] = deal(nan(1,nBeh));
pred_glm_append = deal(cell(1,nBeh));
for j=1:nBeh
    fprintf('Behavior %d/%d...\n',j,nBeh);
    % Get scores
    pred_glm{j} = nan(1,nSubj);
    for k=1:nFolds            
        comboMask = GetNetworkAtThreshold(cr_all_append{j}(:,k),cp_all_append{j}(:,k),thresh);
        [~,~,pred_glm_append{j}(testingSubj{k})] = GetFcMaskMatch(fcMats_append(:,testingSubj{k}),comboMask>0,comboMask<0);
    end
    % Correlate with behavior
    [r_true_append(j),p_true_append(j)] = corr(pred_glm_append{j}', beh(:,j),'tail','right','type',corrtype);        
end

%% Plot results
figure(654); clf;
subplot(1,2,1);
imagesc([r_true; r_true_append]);
colorbar;
title('R values');
set(gca,'xtick',1:nBeh,'xticklabel',behNames,'ytick',1:nTasks+1,'yticklabel',[tasks, {'ALL'}])
xlabel('behavior');
ylabel('fMRI task');
xticklabel_rotate([],45);
subplot(1,2,2);
imagesc(log10([p_true; p_true_append]));
colorbar;
title('log_{10}(P) values')
set(gca,'xtick',1:nBeh,'xticklabel',behNames,'ytick',1:nTasks+1,'yticklabel',[tasks, {'ALL'}])
xticklabel_rotate([],45);
xlabel('behavior');
ylabel('fMRI task');
