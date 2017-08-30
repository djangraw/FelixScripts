function tsAgreement = TEMP_CompareShenTsBeforeAndAfter()

% TEMP_CompareShenTsBeforeAndAfter.m
%
% Find correlation between timecourses in old and new versions of analysis.
%
% Created 11/16/16 by DJ.

%%
% subjects = [9:22 24:36];
subjects = [9:11 13:19 22 24:25 28 30:33 36];
% subjects = [9:11 13:19 22 24:25 28 30:34 36];

homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';

nRois = 268;
tsAgreement = nan(nRois,numel(subjects),3);
fcAgreement = nan(numel(subjects),3);
for i=1:numel(subjects)
    % set up
    cd(homedir);
    subject = sprintf('SBJ%02d',subjects(i));
    fprintf('Getting FC for subject %d...\n',subjects(i))
    filename = sprintf('shen268_withSegTc_%s_ROI_TS.1D',subject);

    cd(subject)
    foo = dir('AfniProc*');
    cd(foo(1).name);
    [err,M1,Info,Com] = Read_1D(filename);

    % Do same for new analysis
    cd('../AfniProc_MultiEcho_2016-09-22');
    % Load data
    [err,M2,Info,Com] = Read_1D(filename);
    [err,M3,Info,Com] = Read_1D(sprintf('shen268_withSegTc2_%s_ROI_TS.1D',subject));
    isOk = any([M1,M2,M3]~=0,2);
    for j=1:nRois
        tsAgreement(j,i,1) = corr(M1(isOk,j), M2(isOk,j));
        tsAgreement(j,i,2) = corr(M1(isOk,j), M3(isOk,j));
        tsAgreement(j,i,3) = corr(M2(isOk,j), M3(isOk,j));
    end
    
    FC1 = GetFcMatrices(M1','sw',length(M1));
    FC2 = GetFcMatrices(M2','sw',length(M2));
    FC3 = GetFcMatrices(M3','sw',length(M3));

    rho = corr([VectorizeFc(FC1), VectorizeFc(FC2), VectorizeFc(FC3)]); 
    fcAgreement(i,:) = [rho(1,2),rho(1,3),rho(2,3)];

end
fprintf('Done!\n');

%% Plot agreement
figure(652); clf;
subplot(2,1,1);
plot(squeeze(mean(tsAgreement,2)));
ylim([0 1]); grid on;

legend('old (with BPF) vs new (no BPF)','old (with BPF) vs new (with BPF)','new (no BPF) vs new (with BPF)')
xlabel('Shen ROI')
ylabel('timecourse correlation')

subplot(2,1,2);
bar(nanmean(fcAgreement,1));
ylim([0 1]); grid on;
set(gca,'xticklabel',{'old (with BPF) vs new (no BPF)','old (with BPF) vs new (with BPF)','new (no BPF) vs new (with BPF)'})
ylabel('timecourse correlation')

%% Plot some samples
figure(855); clf;
for i=1:16
    subplot(4,4,i);
    plot([M1(:,i),M2(:,i),M3(:,i)]);
end
linkaxes(GetSubplots(gcf),'xy');