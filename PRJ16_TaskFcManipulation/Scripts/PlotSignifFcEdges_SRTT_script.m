% PlotSignifFcEdges_SRTT_script.m
%
% Created 8/21/17 by DJ.


%% Get an overall view
thresh = 1e-7;
[FC_struct_base_thresh,FC_unstruct_base_thresh,FC_struct_unstruct_thresh] = ...
    GetFcDiffs_SRTT(FC_struct_fisher,FC_unstruct_fisher,FC_base_fisher,thresh);
fprintf('# edges unstruct>struct at q<%g: %d\n',thresh,sum(VectorizeFc(FC_unstruct_base_thresh>0)));
figure(622); clf;
PlotFc_SRTT(FC_struct,FC_unstruct,FC_base,atlas,[-1 1]*.1,thresh);

%% Vectorize to avoid double-counting and make operations easier
FC_struct_fisher_vec = VectorizeFc(FC_struct_fisher);
FC_unstruct_fisher_vec = VectorizeFc(FC_unstruct_fisher);
FC_base_fisher_vec = VectorizeFc(FC_base_fisher);

%% 
% Get thresholded version... then:
% Plot histograms
iSignif = find(VectorizeFc(FC_unstruct_base_thresh>0));
nRows = ceil(sqrt(numel(iSignif)));
nCols = ceil(numel(iSignif)/nRows);
figure(1); clf;
for i=1:numel(iSignif)
    subplot(nRows,nCols,i);
    hist([FC_struct_fisher_vec(iSignif(i),:); ...
        FC_unstruct_fisher_vec(iSignif(i),:); ...
        FC_base_fisher_vec(iSignif(i),:)]');
    hold on;
    PlotVerticalLines(median(FC_struct_fisher_vec(iSignif(i),:)),'b--');
    PlotVerticalLines(median(FC_unstruct_fisher_vec(iSignif(i),:)),'g--');
    PlotVerticalLines(median(FC_base_fisher_vec(iSignif(i),:)),'y--');
    title(sprintf('edge %d',iSignif(i)));
    xlabel('FC (Fisher norm)');
    ylabel('# subjects');
    legend('struct','unstruct','base');
end
MakeFigureTitle(sprintf('Edges where FC_uns>FC_base at q<%g',thresh));

%% Image each one
figure(522); clf;
[atlas,atlasInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc');
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);
for i=1:numel(iSignif)
    fooMat = UnvectorizeFc((1:nEdges)'==iSignif(i),0,false);
    subplot(nRows,nCols,i);
    PlotFcMatrix(fooMat,[0 1],atlas,shenLabels_hem,true,shenColors_hem,'sum');
    [iRow,iCol] = find(fooMat);
    title(sprintf('edge %d (%d, %d)',iSignif(i),iRow,iCol));
end

%% Show the visuo-motor ones in 2D
iRow = 80;
iCol = 166; %167;
figure(256); clf;
fooMat = zeros(268);
fooMat(iRow,iCol) = 1;
fooMat(iCol,iRow) = 1;
subplot(1,2,1);
VisualizeFcIn2d(fooMat,atlas,shenLabels_hem,shenColors_hem,shenLabelNames_hem,[],'left');
subplot(1,2,2);
VisualizeFcIn2d(fooMat,atlas,shenLabels_hem,shenColors_hem,shenLabelNames_hem,[],'top');
MakeFigureTitle(sprintf('Cxn (%s, %s)',num2str(iRow),num2str(iCol)));

%% In one subject, plot timecourses of these ROIs
PRJDIR = '/data/jangrawdc/PRJ16_TaskFcManipulation/RawData';
subj=fullTs{55};
filename = sprintf('%s/%s/%s.srtt/all_runs_nonuisance.%s.shen_ROI_TS.1D',PRJDIR,subj,subj,subj);
[err, roiTc] = Read_1D(filename);
% Load censor file
filename = sprintf('%s/%s/%s.srtt/censor_%s_combined_2.1D',PRJDIR,subj,subj,subj);
[err, isOk] = Read_1D(filename);
isOk = isOk>0;
% Get block timing
[iStruct,iUnstruct,iBase] = GetSrttBlockTiming();
nT = size(roiTc,1);
isStruct = ismember(1:nT,iStruct);
isUnstruct = ismember(1:nT,iUnstruct);
isBase = ismember(1:nT,iBase);
% Plot
figure(634); clf; hold on;
% hPatch = ErrorPatch();
plot([isStruct; isUnstruct; isBase]'/3);
plot(roiTc(:,iRow));
plot(roiTc(:,iCol));
legend('structured','unstructured','baseline',sprintf('ROI %d',iRow),sprintf('ROI %d',iCol));
title(sprintf('subject %s',subj));
xlabel('time (samples)');
ylabel('signal (A.U.)');
iSubj=find(strcmp(subj,fullTs));
fprintf('FC_struct(%d,%d) = %g\n',iRow,iCol,FC_struct(iRow,iCol,iSubj));
fprintf('FC_unstruct(%d,%d) = %g\n',iRow,iCol,FC_unstruct(iRow,iCol,iSubj));
fprintf('FC_base(%d,%d) = %g\n',iRow,iCol,FC_base(iRow,iCol,iSubj));



