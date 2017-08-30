% PlotFcFftMatrices_script.m
%
% Created 3/24/16 by DJ.

subjects = 9:16;

for i=1:numel(subjects);
    fprintf('===SUBJECT %d/%d: SBJ%02d===\n',i,numel(subjects),subjects(i));
    subject = subjects(i);
    % cd /spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/SBJ09/
    cd(sprintf('/spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/',subject));
    % foo = load('SBJ09_FC_MultiEcho_2016-01-19_Craddock.mat','tc','atlas');
%     D = dir(sprintf('SBJ%02d_FC_MultiEcho_*_Craddock.mat',subject));
%     fprintf('Loading %s...\n',D.name);
%     foo = load(D.name,'tc','atlas');
    [err,tc,Info] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
    [err,censorM,Info] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));
    isNotCensoredSample = censorM>0;
    tc(~isNotCensoredSample,:) = nan;

    % fill in missing data points using spline interp1
%     tc = foo.tc';
%     isZero = all(tc==0,2);
    isZero = ~isNotCensoredSample;
    tc(isZero,:) = interp1(find(~isZero),tc(~isZero,:),find(isZero),'spline');
    atlas = foo.atlas;

    % declare params
    winLength=10;
    N=50; % to get roughly -.25:.01:.25
    TR= 2;

    % Get Fc FFT!
    [FcFft3d{i},freq] = GetFcFft(tc',winLength,N,TR);
end

FcFft4d = cat(4,FcFft3d{:});

%% Plot results
figure(728); clf;
nClusters = 5;
% idx = ClusterRoisSpatially(atlas,nClusters);
clear h
for i=1:9
    h(i) = subplot(3,3,i);
%     PlotFcMatrix(FcFft3d(:,:,i),[],atlas,idx);
    PlotFcMatrix(mean(FcFft4d(:,:,i,:),4),[],atlas,idx);
    title(sprintf('Freq = %.3g Hz',freq(i)));
end
linkaxes(h);
% MakeFigureTitle(sprintf('Distraction Task SBJ%02d FC Frequency Breakdown',subject));
MakeFigureTitle(sprintf('Distraction Task, SBJ%02d-%02d: FC Frequency Breakdown',subjects(1),subjects(end)));
    