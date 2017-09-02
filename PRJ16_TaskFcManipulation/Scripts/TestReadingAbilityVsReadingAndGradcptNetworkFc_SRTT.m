function TestReadingAbilityVsReadingAndGradcptNetworkFc_SRTT()

% TestReadingAbilityVsReadingAndGradcptNetworkFc_SRTT()
%
% Created 9/1/17 by DJ.

%% Load networks
load('/data/jangrawdc/PRJ03_SustainedAttention/Results/GradCptNetwork_p01.mat'); %gradCptNetwork_p01
load('/data/jangrawdc/PRJ03_SustainedAttention/Results/ReadingNetwork_p01_Fisher.mat'); %readingNetwork_p01

%% Load SRTT FC
% load('/data/jangrawdc/PRJ16_TaskFcManipulation/Results/FC_StructUnstructBase_2017-08-16','fullTs'); % subjects with full timeseries file available
% fcSubj = fullTs;
% [FC_wholerun, FC_taskonly] = GetFc_SRTT_wholerun(fcSubj);
load('/data/jangrawdc/PRJ16_TaskFcManipulation/Results/FC_wholerun_2017-09-01.mat','FC_taskonly','fullTs'); 

%% Load SRTT behavior
filename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
fprintf('Loading reading behavior...\n');
behTable = ReadSrttBehXlsFile(filename);
fprintf('Done!\n');

% Get 1st PC of all reading scores
% Append all reading scores
allReadScores = [behTable.TOWRE_SWE_SS,behTable.TOWRE_PDE_SS,behTable.TOWRE_TWRE_SS,...
    behTable.WJ3_BscR_SS, behTable.WJ3_LW_SS, behTable.WJ3_WA_SS, behTable.WASI_PIQ];
isOkSubj = all(~isnan(allReadScores),2);

% normalize
nSubj = size(allReadScores,1);
meanScores = mean(allReadScores(isOkSubj,:),1);
stdScores = std(allReadScores(isOkSubj,:),[],1);
allReadScores = (allReadScores-repmat(meanScores,nSubj,1))./repmat(stdScores,nSubj,1);
% get SVD
[U,S,V] = svd(allReadScores(isOkSubj,:),0);

% Declare reading score as 1st principal component
readScore = allReadScores*V(:,1);
iqScore = behTable.WASI_PIQ(isOkSubj);
readSubj = behTable.MRI_ID(isOkSubj);
for i=1:numel(readSubj)
    readSubj{i} = sprintf('tb%04d',str2double(readSubj{i}));
end

%% Get network scores
readingMatch = GetFcMaskMatch(FC_taskonly,readingNetwork_p01>0,readingNetwork_p01<0); 
gradCptMatch = GetFcMaskMatch(FC_taskonly,gradCptNetwork_p01>0,gradCptNetwork_p01<0); 

%% Get overlapping subjects and get order to agree
isOkSubj_fc = ismember(fcSubj,readSubj);
isOkSubj_read = ismember(readSubj,fcSubj);

readingMatch_okSubj = readingMatch(isOkSubj_fc)';
gradCptMatch_okSubj = gradCptMatch(isOkSubj_fc)';
readScore_okSubj = readScore(isOkSubj_read);
iqScore_okSubj = iqScore(isOkSubj_read);

%% Correlate with behavior
[r_readRead,p_readRead] = corr(readingMatch_okSubj,readScore_okSubj,'rows','complete');
[r_gradCptRead,p_gradCptRead] = corr(gradCptMatch_okSubj,readScore_okSubj,'rows','complete');
[r_readIq,p_readIq] = corr(readingMatch_okSubj,iqScore_okSubj,'rows','complete');
[r_gradCptIq,p_gradCptIq] = corr(gradCptMatch_okSubj,iqScore_okSubj,'rows','complete');

fprintf('r_readRead = %.3g, p_readRead = %.3g\n',r_readRead,p_readRead);
fprintf('r_gradCptRead = %.3g, p_gradCptRead = %.3g\n',r_gradCptRead,p_gradCptRead);
fprintf('r_readIq = %.3g, p_readIq = %.3g\n',r_readIq,p_readIq);
fprintf('r_gradCptIq = %.3g, p_gradCptIq = %.3g\n',r_gradCptIq,p_gradCptIq);

% Plot results
lm = fitlm(readingMatch_okSubj,readScore_okSubj);
subplot(2,2,1);
lm.plot();
xlabel('FC in Reading Network');
ylabel('Reading Behavior Score');
title(sprintf('FC_{read} vs. beh_{read}\nr=%.3g, p=%.3g',r_readRead,p_readRead));

lm = fitlm(gradCptMatch_okSubj,readScore_okSubj);
subplot(2,2,2);
lm.plot();
xlabel('FC in GradCPT Network');
ylabel('Reading Behavior Score');
title(sprintf('FC_{gradcpt} vs. beh_{read}\nr=%.3g, p=%.3g',r_gradCptRead,p_gradCptRead));

lm = fitlm(readingMatch_okSubj,iqScore_okSubj);
subplot(2,2,3);
lm.plot();
xlabel('FC in Reading Network');
ylabel('IQ Behavior Score');
title(sprintf('FC_{read} vs. beh_{iq}\nr=%.3g, p=%.3g',r_readIq,p_readIq));

lm = fitlm(gradCptMatch_okSubj,iqScore_okSubj);
subplot(2,2,4);
lm.plot();
xlabel('FC in GradCPT Network');
ylabel('IQ Behavior Score');
title(sprintf('FC_{gradcpt} vs. beh_{iq}\nr=%.3g, p=%.3g',r_gradCptIq,p_gradCptIq));

