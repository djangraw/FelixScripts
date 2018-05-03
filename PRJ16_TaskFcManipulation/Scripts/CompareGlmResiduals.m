versions = {'v3','v3_noWmCsf','v3_filter','v3_noNRs','v3_CensorBase','v3_CensorBase-nofilt','PPI'};
iStrUns = [16 16 16 16 16 16 98];

info = GetSrttConstants();
lMotCoords = [19 36 47];
zSlice = 16;
nT = 450;

tc = nan(nT,numel(versions));
for i=1:numel(versions)
    fprintf('%d/%d...\n',i,numel(versions));
    cd(sprintf('%s/RawData/GROUP_MEAN_%s',info.PRJDIR,versions{i}));
    files = dir('MEAN*.HEAD');
    foo = BrikLoad(files(1).name);
    % foo = BrikLoad(sprintf('MEAN_all_runs_%s+tlrc.HEAD',lower(versions{i})));
    tc(:,i) = squeeze(foo(lMotCoords(1),lMotCoords(2),lMotCoords(3),:));
    % Get axial slice thru ventricles
    cd(sprintf('%s/RawData/GROUP_TTEST_%s',info.PRJDIR,versions{i}));
    files = dir('ttest*.HEAD');
    [foo,fooInfo] = BrikLoad(files(1).name);
    [err,Indx] = AFNI_XYZcontinuous2Index ([0 0 zSlice], fooInfo);
    axSlice(:,:,i) = foo(:,:,Indx(3),iStrUns(i)); % z score of Str-Uns
end
%%
ijk = repmat((1:max(size(foo)))',1,3);
[err,XYZdic] = AFNI_Index2XYZcontinuous (ijk, fooInfo);
 
%%
fprintf('Getting anat...\n')
% Get anat slice for underlay
atlasFile = '/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/GROUP_TTEST_v3_CensorBase-nofilt/MNI152_T1_2009c.nii';
[foo,fooInfo] = BrikLoad(atlasFile);
[err,Indx] = AFNI_XYZcontinuous2Index ([0 0 zSlice], fooInfo);
ulaySlice = foo(:,:,Indx(3));
ulaySlice = ulaySlice/max(ulaySlice(:)); % scale
fprintf('Done!\n');

%%
figure(773); clf;
plot(tc);
title('SRTT GLM residuals comparison');
xlabel('time (samples)');
ylabel('% signal change');
legend(versions,'interpreter','none');
%%
figure(774); clf;
MakeFigureTitle('Str-Uns contrast p<0.01');
nRows = ceil(sqrt(numel(versions)));
nCols = ceil(numel(versions)/nRows);
thr = 2.576; %p<0.01;
for i=1:numel(versions)
    subplot(nRows,nCols,i);
%     ulayOlay = ulaySlice;
%     ulayOlay(flipud(axSlice(:,:,i)')>thr) = 1;
%     imagesc(cat(3,ulaySlice,ulayOlay,ulaySlice));
    imagesc(double(flipud(axSlice(:,:,i)')>thr) - double(flipud(axSlice(:,:,i)')<-thr));
    set(gca,'clim',[-1 1]);
    axis equal
    colorbar;
%     set(gca,'clim',)
    title(versions{i},'interpreter','none')
end