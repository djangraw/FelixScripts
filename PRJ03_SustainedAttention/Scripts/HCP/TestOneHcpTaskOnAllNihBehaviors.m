% TestOneHcpTaskOnAllNihBehaviors.m
%
% Created 12/13/17 by DJ.

%% Get HCP Data from single task
task = 'language';%'rest1'; % <------SELECT TASK HERE

% Load
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/FromEmily
foo = load(sprintf('HCP900_%s_mats',task));
hcpMats = foo.(sprintf('HCP900_%s_mats',task));
hcpVecs = VectorizeFc(hcpMats);
hcpSubj = foo.HCP900_sub_id;
info = readtable('unrestricted_esfinn_7_14_2016_8_52_0.csv');
beh = [info.PicSeq_Unadj, info.CardSort_Unadj, info.Flanker_Unadj, info.PicVocab_Unadj, info.ProcSpeed_Unadj, info.ListSort_Unadj, info.ReadEng_Unadj, info.PMAT24_A_CR];  
behNames = {'Pic Seq (ep mem)','Card Sort (cog flex)','Flanker (inhib)','Pic Vocab (lang)','Pattern Compl (proc speed)','List Sort (WM)','Oral Reading Recog', 'PMAT (IQ)'};

% Get Reading Network
cd ..
foo = load('ReadingAndGradcptNetworks_optimal.mat');
readingNetwork = foo.readingNetwork;
readingNetwork_vec = VectorizeFc(readingNetwork);
clear foo
% Get reading scores
readScore_oksubj = hcpVecs'*readingNetwork_vec/sum(readingNetwork_vec~=0);

% Remove subjs with incomplete data
behSubj = info.Subject;
[~,iSubj] = ismember(hcpSubj,behSubj);
beh_oksubj = beh(iSubj,:);
isIncompleteSubj = all(hcpVecs==0) | any(isnan(hcpVecs)) | any(isnan(beh_oksubj),2)';
beh_oksubj_crop = beh_oksubj(~isIncompleteSubj,:);
readScore_oksubj_crop = readScore_oksubj(~isIncompleteSubj);

%% Use Reading Network on task data to Predict all behaviors from single task
ylimits = [-0.06, 0.26];
% Correlate with reading scores
[r_true,p_true] = deal(nan(1,size(beh_oksubj_crop,2)));
for i=1:size(beh_oksubj_crop,2)
    [r_true(i),p_true(i)] = corr(readScore_oksubj_crop, beh_oksubj_crop(:,i),'tail','right');
end
q_true = p_true*numel(p_true); % bonf
% q_true = mafdr2(p_true,'bhfdr',true);

figure(633); clf; subplot(2,1,1); hold on;
bar(r_true);
isSig = q_true<0.05;
plot(find(isSig),r_true(isSig)+0.01,'k*');
set(gca,'xtick',1:numel(r_true),'xticklabel',behNames);
ylim(ylimits);
title(sprintf('Ability of Reading Network Score (from %s task) to Predict Behavior',task));
ylabel('Correlation with Reading Network Score');
xticklabel_rotate([],45);
grid on;

% Partial out fluid intelligence and redo
iControl = find(strcmp(behNames,'PMAT (IQ)'));
for i=1:size(beh_oksubj_crop,2)
    [r_true(i),p_true(i)] = partialcorr(readScore_oksubj_crop, beh_oksubj_crop(:,i),beh_oksubj_crop(:,iControl),'tail','right');
end

% q_true = p_true*numel(p_true); % bonf
q_true = mafdr(p_true,'bhfdr',true);

figure(633); subplot(2,1,2); cla; hold on;
bar(r_true);
isSig = q_true<0.05;
plot(find(isSig),r_true(isSig)+0.01,'k*');
set(gca,'xtick',1:numel(r_true),'xticklabel',behNames);
ylim(ylimits);
title(sprintf('Partial Correlation with Reading Network Score\nControlling for PMAT (IQ)'));
ylabel('Partial correlation with Reading Network Score')
xticklabel_rotate([],45);
grid on;
legend('r','q<0.05');


