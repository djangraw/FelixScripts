% SaveSrttFcConnAndSumaFiles_script.m
%
% Created 8/14/17 by DJ.

%% Set up Conn
conn;
basedir = '/Volumes/data/PRJ16_TaskFcManipulation';
%% Load
cd([basedir '/Results']);
% load FC_StructUnstructBase_diff_p01_2017-08-14.mat
load FC_StructUnstructBase_diff_q0000001_2017-08-16.mat
%% Plot
atlasFile='/Volumes/data/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc.HEAD';
% foo = (FC_struct_unstruct_thresh.*double(FC_struct_unstruct_thresh~=0));
foo = (FC_struct_base_thresh.*double(FC_struct_base_thresh>0));
h = PlotAtlasFcIn3d_Conn(atlasFile,foo);

%% Save
cd([basedir '/Results']);
Save3dFcImages_Conn(h);

%% Plot as matrix
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);
figure(6); clf;
foo = double(FC_struct_unstruct_thresh>0) - double(FC_struct_unstruct_thresh<0);
subplot(1,2,1);
PlotFcMatrix(foo,[-1 1]*.1,atlasFile,shenLabels_hem,true,shenColors_hem,'mean');
subplot(1,2,2);
PlotFcMatrix(foo,[-1 1]*7,atlasFile,shenLabels_hem,true,shenColors_hem,'sum');
%% Save struct > unstruct as AFNI file
[err,atlas,Info] = BrikLoad(atlasFile);
foo = (FC_struct_unstruct_thresh.*double(FC_struct_unstruct_thresh>0));
outBrik = MapValuesOntoAtlas(atlas,sum(foo));
Opt = struct('Prefix',[basedir '/Results/FC_struct_gt_unstruct_thresh_q0001']);
WriteBrik(outBrik,Info,Opt);
%% Same for struct < unstruct
foo = (FC_struct_unstruct_thresh.*double(FC_struct_unstruct_thresh<0));
outBrik = MapValuesOntoAtlas(atlas,sum(foo));
Opt = struct('Prefix', [basedir '/Results/FC_struct_lt_unstruct_thresh_q0001']);
WriteBrik(outBrik,Info,Opt);
%% Save less-both-greater brik
foo = FC_struct_unstruct_thresh;
boo = 1*(any(foo<0) & ~any(foo>0)) + 2*(any(foo<0) & any(foo>0)) + 3*(~any(foo<0) & any(foo>0));
outBrik = MapValuesOntoAtlas(atlas,boo);
Opt = struct('Prefix',[basedir '/Results/FC_struct_lt-both-gt_unstruct_thresh_q0001']);
WriteBrik(outBrik,Info,Opt);

%% Find significant edges for unstructured vs. baseline

threshes = [.01 .001 .0001 .00001 .000001 .0000001];
[nStruct,nUnstruct] = deal(nan(1,numel(threshes)));
for i=1:numel(threshes)
    threshstr = sprintf('%.8f',threshes(i));
    threshstr = threshstr(3:find(threshstr=='1'));
    load(sprintf('FC_StructUnstructBase_diff_q%s_2017-08-16.mat',threshstr));
    nStruct(i) = sum(VectorizeFc(FC_struct_base_thresh)>0);
    nUnstruct(i) = sum(VectorizeFc(FC_unstruct_base_thresh)>0);
end

%% Load edges
load('FC_StructUnstructBase_2017-08-16.mat');

%% Get histogram of these significant edges
iUnStruct = find(VectorizeFc(FC_unstruct_base_thresh)>0);
nRows = ceil(sqrt(numel(iUnstruct)));
nCols = ceil(numel(iUnstruct)/nRows);
FC_unstruct_fisher_vec = atanh(VectorizeFc(FC_unstruct));
FC_base_fisher_vec = atanh(VectorizeFc(FC_base));
figure(882); clf;
for i=1:numel(iUnstruct)
    subplot(nRows,nCols,i);
    hist([FC_unstruct_fisher_vec(iUnstruct(i),:), FC_base_fisher_vec(iUnstruct(i),:)]);
    title(sprintf('edge %d',iUnstruct(i)));
    xlabel('FC')
    ylabel('# subjects');
    legend('unstructured','baseline');
end
