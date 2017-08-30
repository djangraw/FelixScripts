% TestAudioPredictions_script.m
%
% Created 1/4/17 by DJ.

afniProcFolder = 'AfniProc_MultiEcho_2016-09-22'; % 9-22 = MNI
tsFilePrefix = 'shen268_withSegTc'; % 'withSegTc' means with BPFs
% tsFilePrefix = 'shen268_withSegTc_Rose'; % _Rose means with motion squares regressed out and gaussian filter
runComboMethod = 'avgRead'; % average of run-wise FC, limited to reading samples
doPlot = false; 

%% Get FC and audio performance
[FC,isMissingRoi,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);
% [fracCorrect_audio] = GetFracCorrect_AllSubjects(subjects,'audio');
[fracCorrect_audio] = GetFracCorrect_AllSubjects(subjects,'attendSound');
%% Get Reading Network and predictions
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
[audio_pos, audio_neg, audio_combo,audio_posMask_all,audio_negMask_all] = RunLeave1outBehaviorRegression(FC,fracCorrect_audio,thresh,corr_method,mask_method);

%% Plot results
figure(577); clf;
set(gcf,'Position',[159         122        1660        1165]);
networks = {'read','audio'};
networkNames = {'reading-visual','reading-audio'};
types = {'pos','neg','combo'};
isPosExpected = [true false true];
for i=1:numel(networks)
    for j=1:numel(types)
        % Regress
        eval(sprintf('x = %s_%s;',networks{i},types{j}));
        if ismember(networks{i},{'audio','ignoreSound','attendSound'})
            fprintf('sound\n')
            [p,Rsq,lm] = Run1tailedRegression(fracCorrect_audio*100,x,isPosExpected(j));
        else
            [p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,x,isPosExpected(j));
        end
%         eval(sprintf('x = %s_%s2;',networks{i},types{j}));
%         [p2,Rsq2,lm2] = Run1tailedRegression(fracCorrect*100,x,isPosExpected(j));
        % Plot and annotate
        iPlot = (i-1)*numel(types)+j;
        subplot(numel(networks),numel(types),iPlot); cla; hold on;
        h = lm.plot;
%         set(h,'color','r');
%         h = lm2.plot;
%         set(h,'color','b');
        xlabel('% correct');
        ylabel(sprintf('%s %s score',networkNames{i},types{j}));
%         title(sprintf('%s %s: R^2= %.3g, p=%.3g\nR^2_{GSR}= %.3g, p_{GSR}=%.3g',networkNames{i},types{j},Rsq,p,Rsq2,p2));
        title(sprintf('%s %s: R^2= %.3g, p=%.3g\n',networkNames{i},types{j},Rsq,p));
    end
end

%% Plot matrix
audio_comboMask = all(audio_posMask_all>0,3)-all(audio_negMask_all>0,3);
figure(578); clf;
PlotFcMatrix(audio_comboMask,[-1 1]*5,shenAtlas,shenLabels_hem,true,shenLabelColors_hem,'sum');