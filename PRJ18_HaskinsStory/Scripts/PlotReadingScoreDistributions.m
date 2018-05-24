% PlotReadingScoreDistributions.m
%
% Created 5/23/18 by DJ.

%% Load
behFilename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
behTable = ReadSrttBehXlsFile(behFilename);
[readScore_beh,isOkSubj_beh] = GetFirstReadingScorePc(behTable);
% get motion for these same subjects
behSubj = cellfun(@(x) sprintf('tb%04d',str2num(x)),behTable.MRI_ID,'UniformOutput',false);
[subjMotion_beh, censorFraction_beh] = GetStorySubjectMotion(behSubj);

%%
figure(4); clf;
subplot(131); hold on;
hist(readScore_beh);
PlotVerticalLines(nanmean(readScore_beh),'r-');
PlotVerticalLines(nanmean(readScore_beh)-nanstd(readScore_beh),'m--');
PlotVerticalLines(nanmean(readScore_beh)-2*nanstd(readScore_beh),'k:');
xlabel('1st reading PC');
ylabel('# subjects');
subplot(132); hold on;
hist(behTable.WJ3_LW_SS);
PlotVerticalLines(nanmean(behTable.WJ3_LW_SS),'r-');
PlotVerticalLines(nanmean(behTable.WJ3_LW_SS)-nanstd(behTable.WJ3_LW_SS),'m--');
PlotVerticalLines(nanmean(behTable.WJ3_LW_SS)-2*nanstd(behTable.WJ3_LW_SS),'k:');
xlabel('WJ3_LW_SS','interpreter','none')
ylabel('# subjects');
subplot(133); hold on;
hist(behTable.TOWRE_TWRE_SS);
PlotVerticalLines(nanmean(behTable.TOWRE_TWRE_SS),'r-');
PlotVerticalLines(nanmean(behTable.TOWRE_TWRE_SS)-nanstd(behTable.TOWRE_TWRE_SS),'m--');
PlotVerticalLines(nanmean(behTable.TOWRE_TWRE_SS)-2*nanstd(behTable.TOWRE_TWRE_SS),'k:');
xlabel('TOWRE_TWRE_SS','interpreter','none')
ylabel('# subjects');
legend('histogram','mean','mean-std','mean-2*std');

figure(5);
subplot(131)
plot(readScore_beh,behTable.WJ3_LW_SS,'.');
xlabel('1st reading PC')
ylabel('WJ3_LW_SS','interpreter','none')
subplot(132)
plot(readScore_beh,behTable.TOWRE_TWRE_SS,'.');
xlabel('1st reading PC')
ylabel('TOWRE_TWRE_SS','interpreter','none')
subplot(133)
plot(behTable.WJ3_LW_SS,behTable.TOWRE_TWRE_SS,'.');
xlabel('WJ3_LW_SS','interpreter','none')
ylabel('TOWRE_TWRE_SS','interpreter','none')

figure(6);
subplot(131)
plot(readScore_beh,censorFraction_beh,'.');
xlabel('1st reading PC')
ylabel('Frac TRs censored','interpreter','none')
subplot(132)
plot(behTable.WJ3_LW_SS,censorFraction_beh,'.');
xlabel('1st WJ3_LW_SS','interpreter','none')
ylabel('Frac TRs censored','interpreter','none')
subplot(133)
plot(behTable.TOWRE_TWRE_SS,censorFraction_beh,'.');
xlabel('TOWRE_TWRE_SS','interpreter','none')
ylabel('Frac TRs censored','interpreter','none')
