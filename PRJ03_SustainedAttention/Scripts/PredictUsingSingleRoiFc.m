% PredictUsingSingleRoiFc.m
%
% Created 2/16/17 by DJ.

subjects = [9:11 13:19 22 24:25 28 30:33 36];

afniProcFolder = 'AfniProc_MultiEcho_2016-09-22'; % 9-22 = MNI
tsFilePrefix = 'shen268_withSegTc'; % 'withSegTc' means with BPFs
runComboMethod = 'avgRead'; % average of run-wise FC, limited to reading samples
doPlot = false;

%% Get FC
[FC,isMissingRoi,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);

%% Get performance
[fracCorrect, RT] = GetFracCorrect_AllSubjects(subjects);


%% Crop
iRoi = 212;
FC_roi = zeros(size(FC));
FC_roi(iRoi,:,:) = FC(iRoi,:,:);
FC_roi(:,iRoi,:) = FC(:,iRoi,:);
thresh = 0.01;
[read_roi_pos,read_roi_neg,read_roi_combo] = deal(nan(numel(subjects),1));
for j=1:numel(subjects)
    % Get mask
    isPos = read_cp(:,:,j)<thresh & read_cr(:,:,j)>0;
    isNeg = read_cp(:,:,j)<thresh & read_cr(:,:,j)<0;
    % Get mask size
%     maskSizePos_subj(i,j) = sum(isPos(:));
%     maskSizeNeg_subj(i,j) = sum(isNeg(:));
    % Get FC match scores
    read_roi_pos(j) = GetFcTemplateMatch(FC_roi(:,:,j),isPos,[],[],'meanmult');
    read_roi_neg(j) = GetFcTemplateMatch(FC_roi(:,:,j),isNeg,[],[],'meanmult');
    read_roi_combo(j) = GetFcTemplateMatch(FC_roi(:,:,j),double(isPos)-double(isNeg),[],[],'meanmult');
end



%% Crop FC to ROI212 and get networks

iRoi = 212;
FC_roi = zeros(size(FC));
FC_roi(iRoi,:,:) = FC(iRoi,:,:);
FC_roi(:,iRoi,:) = FC(:,iRoi,:);

% [read_roi_pos,read_roi_neg,read_roi_combo] = GetFcMaskMatch(FC_roi,readingNetwork_p01>0,readingNetwork_p01<0);
% [read_roi_pos,read_roi_neg,read_roi_combo] = deal(read_roi_pos',read_roi_neg',read_roi_combo');
[gradcpt_roi_pos,gradcpt_roi_neg,gradcpt_roi_combo] = GetFcMaskMatch(FC_roi,attnNets.pos_overlap,attnNets.neg_overlap);
[gradcpt_roi_pos,gradcpt_roi_neg,gradcpt_roi_combo] = deal(gradcpt_roi_pos',gradcpt_roi_neg',gradcpt_roi_combo');

%% Evaluate prediction
isPosExpected = [1 0 1];
networks = {'gradcpt_roi','read_roi'};%{'gradcpt','dandmn','read'};
networkNames = {'GradCPT (ROI 212 only)','Reading (ROI 212 only)'};%{'gradCPT','DAN/DMN','Reading'};
types = {'pos','neg','combo'};
typeNames = {'High-Attention','Low-Attention','Combined'};
figure(623); clf;
for j=1:numel(networks)
    for i=1:numel(types)
        eval(sprintf('x = %s_%s;',networks{j},types{i}));
        [p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,x,isPosExpected(i));
    %     r = sqrt(lm.Rsquared.Ordinary);
        r = corr(fracCorrect*100,x);
        % Plot and annotate
        iPlot = (i-1)*numel(networks)+j;
        subplot(numel(types),numel(networks),iPlot); cla; hold on;
        h = lm.plot;
        xlabel('% correct');
        ylabel(sprintf('%s %s Network score',networkNames{j},typeNames{i}));
        title(sprintf('%s %s Network Prediction\nr=%.3g, p=%.3g',networkNames{j},typeNames{i},r,p));
        legend('Subject','Linear Fit');%,'Location','Northwest')
    end
end