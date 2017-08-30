% MapMotionSensitvity.m
%
% Created 11/1/16 by DJ.

%% Load
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ09/AfniProc_MultiEcho_2016-01-19
dataBrick = BrikLoad('SBJ09_Anat_bc_ns_al_keep+orig');

%% Local Variance
% Get
dataVar = MapLocalVar(dataBrick,3);
% Scale
dataVar_scaled = dataVar/GetValueAtPercentile(dataVar(dataVar>0),95);
dataVar_scaled(dataVar_scaled>1) = 1;
% Plot
GUI_3View(dataVar_scaled)

%% Local gradients
[Gx,Gy,Gz] = MapLocalGradient(dataBrick);
% scale
val95 = GetValueAtPercentile(abs([Gx(Gx~=0); Gy(Gy~=0); Gz(Gz~=0)]),95);
Gx_scaled = Gx/val95;
Gx_scaled(Gx_scaled>1) = 1;
Gx_scaled(Gx_scaled<-1) = -1;
Gy_scaled = Gy/val95;
Gy_scaled(Gy_scaled>1) = 1;
Gy_scaled(Gy_scaled<-1) = -1;
Gz_scaled = Gz/val95;
Gz_scaled(Gz_scaled>1) = 1;
Gz_scaled(Gz_scaled<-1) = -1;
% Plot
GUI_3View(cat(4,Gx_scaled,Gy_scaled,Gz_scaled))

%% Maps of motion-weighted averages
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ09/AfniProc_MultiEcho_2016-01-19
dataBrick = BrikLoad('pb06.SBJ09.scaled+tlrc');
motionTimecourse = Read_1D('motion_demean.1D');
sizeData = size(dataBrick);
motWeightedSum = nan([sizeData(1:3),6]);
for i=1:6
    motBrick = repmat(permute(motionTimecourse(:,i),[4 3 2 1]),...
        sizeData(1),sizeData(2),sizeData(3),1);
    motWeightedSum(:,:,:,i) = sum(dataBrick.*motBrick,4);
end
%% Plot result
val95 = GetValueAtPercentile(abs(motWeightedSum(motWeightedSum~=0)),95);
GUI_3View(motWeightedSum(:,:,:,4:6)/val95)