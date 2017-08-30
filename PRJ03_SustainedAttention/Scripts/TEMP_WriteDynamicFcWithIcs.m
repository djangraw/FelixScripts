% Load
% cd /spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/SBJ05/AfniProc_MultiEcho_2015-12-08/TED.SBJ05.r01
cd /spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/SBJ06/AfniProc_MultiEcho_2015-12-17/TED.SBJ05.r01
[err, IC_ts, Info, Com] = Read_1D ('meica_mix.1D');
[dataErr,data,dataInfo,ErrMsg] = BrikLoad('dn_ts_OC.nii');
[atlasErr,atlas,atlasInfo,ErrMsg] = BrikLoad('../CraddockAtlas_200Rois_epires+tlrc.BRIK');
[betasErr,betas,betasInfo,ErrMsg] = BrikLoad('betas_OC.nii');

%% Get constants & 2D data matrix
[nT,nComps] = size(IC_ts);
[nX,nY,nZ,nT] = size(data);
nVoxels = nX*nY*nZ;

data2D = reshape(data,nVoxels,nT);
isInBrain = ~all(data2D==0,2);

%% Get FC btw ICs and denoised voxels

Ic2Vox_FC = corr(data2D',IC_ts);

%% Plot results
coords = [19,8,24];
Ic2Vox_FC_mat = reshape(Ic2Vox_FC,nX,nY,nZ,nComps);
GUI_3View(Ic2Vox_FC_mat(:,:,:,1:3),coords);
% GUI_3View(cat(4,Ic2Vox_FC_mat(:,:,:,1:2),atlas==12),coords);

%% Get dynamic FC btw ICs and denoised voxels
winLength = 20;

% get # of windows
nWin = nT - winLength + 1;
% get FC between them
fprintf('Getting sliding-window FC in %d windows...\n',nWin);
FC = nan(nVoxels,nComps,nWin);
for i=1:nWin
    fprintf('window %d/%d...\n',i,nWin)
    iInWin = (1:winLength) + i - 1; % indices in window
    FC(:,:,i) = corr(data2D(:,iInWin)',IC_ts(iInWin,:)); % find corellation between all ROIs at once
end

%% Write out results (not working yet)
FC1_brick = reshape(FC(:,1,:),nX,nY,nZ,nWin);
FC1_brick = cat(4,FC1_brick,zeros(nX,nY,nZ,winLength-1));
FC2_brick = reshape(FC(:,2,:),nX,nY,nZ,nWin);
FC2_brick = cat(4,FC2_brick,zeros(nX,nY,nZ,winLength-1));
Opt = struct('View','orig','Prefix','TEST1','OverWrite','y');
WriteBrik(FC1_brick,dataInfo,Opt);
Opt = struct('View','orig','Prefix','TEST2','OverWrite','y');
WriteBrik(FC2_brick,dataInfo,Opt);

%% Get average within atlas ROI
% iROI = 75;
for iROI = 1:16
    isInRoi = (atlas==iROI);
    FC_ROI = squeeze(nanmean(FC(isInRoi,:,:),1));
    subplot(4,4,iROI)
    cla;
    plot(FC_ROI(1:3,:)');
    grid on
    Plot3Planes(cat(4,atlas>0,atlas*0,atlas==iROI),round(pos(iROI,:)),[0 -1 100 0.5]);
    xlim([0 nWin])
    ylim([-1 1]);
    xlabel('time (TR)')
    ylabel('Corr Coeff')
    title(sprintf('Craddock ROI %d',iROI));
end
legend('MEICA IC #1','MEICA IC #2','MEICA IC #3')
MakeFigureTitle('SBJ05, Run 1');