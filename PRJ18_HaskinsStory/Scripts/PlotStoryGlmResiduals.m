% PlotStoryGlmResiduals.m
%
% Created 5/17/18 by DJ.

info = GetStoryConstants();
roiCoords = [41 34 42]; %lMot
% roiCoords = [27 41 28]; %PCC
zSlice = 16;
nT = 360;
nSubj = numel(info.okSubj);
tc = nan(nT,nSubj);
for i=1:nSubj
    fprintf('%d/%d...\n',i,nSubj);
    cd(sprintf('%s/%s/%s.storyISC/',info.dataDir,info.okSubj{i},info.okSubj{i}));
    files = dir('errts.*.tproject+tlrc.HEAD');
    foo = BrikLoad(files(1).name);
    % foo = BrikLoad(sprintf('MEAN_all_runs_%s+tlrc.HEAD',lower(versions{i})));
    tc(:,i) = squeeze(foo(roiCoords(1),roiCoords(2),roiCoords(3),:));
end

%% Get condition timecourse
[iAud,iVis,iBase] = GetStoryBlockTiming();
iCond = zeros(nT,1);
iCond(iAud)=1;
iCond(iVis)=2;

%% Plot
figure(773); clf;
plot(mean(tc,2));
hold on;
plot(iCond/2*max(abs(mean(tc,2))));
title('SRTT GLM residuals comparison');
xlabel('time (samples)');
ylabel('% signal change');
legend('BOLD','condition (Base,Aud,Vis)','interpreter','none');
