% PlotOrSaveOutSrttFcOfShenRoi.m
%
% Created 1/30/18 by DJ.

%% Load
load('/Volumes/data/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d3/results/secondlevel/ANALYSIS_01/AllSubjects/str(1).uns(-1)/ROI.mat');

%% Plot
close all;
foo = zeros(268);
iRoi = 167;
thresh = 1e-5;
isSig = (ROI(iRoi).p(1:268)<(thresh/2)) - (ROI(iRoi).p(1:268)>(1-thresh/2));
foo(iRoi,:) = isSig;
foo(:,iRoi) = isSig;
h = PlotShenFcIn3d_Conn(foo);

%% Save as afni brick
vars = GetDistractionVariables();
[shenAtlas,shenInfo] = BrikLoad([vars.homedir '/Results/Shen_2013_atlas/EPIres_shen_1mm_268_parcellation+tlrc.BRIK']);
% BrickToWrite = MapValuesOntoAtlas(shenAtlas,isSig);
BrickToWrite = cat(4,MapValuesOntoAtlas(shenAtlas,ROI(iRoi).h(1:268)), MapValuesOntoAtlas(shenAtlas,ROI(iRoi).p(1:268)));
Opt = struct('Prefix',sprintf('SrttAfniConn_Str-Uns_roi%03d_p%g+tlrc',iRoi,thresh));
cd('/Volumes/data/PRJ16_TaskFcManipulation/Results/');
WriteBrik(BrickToWrite,shenInfo,Opt);