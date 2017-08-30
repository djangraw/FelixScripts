cd('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/SBJ01_S01/D01_Version02.AlignByAnat.Cubic/Video01');

% V1 = BrikLoad('p04.SBJ01_S01_Video01_e1.align_clp+orig');
% V2 = BrikLoad('p04.SBJ01_S01_Video01_e2.align_clp+orig');
% V3 = BrikLoad('p04.SBJ01_S01_Video01_e3.align_clp+orig');

V{1} = BrikLoad('p06.SBJ01_S01_Video01_e1.sm.nii.gz');
V{2} = BrikLoad('p06.SBJ01_S01_Video01_e2.sm.nii.gz');
V{3} = BrikLoad('p06.SBJ01_S01_Video01_e3.sm.nii.gz');
%% Load preprocessed versions
V{4} = BrikLoad('TED/ts_OC.nii');
V{5} = BrikLoad('TED/dn_ts_OC.nii');
%% Load control versions
cd('/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ01');
V{6} = BrikLoad('SBJ01_S01_R01_Video_Echo2_blur6+orig.BRIK');
V{7} = BrikLoad('SBJ01_S01_R01_1ECHO.nii');

%% clean up
% V2 = cell(size(V));
for i=1:numel(V)
    V{i}(V{i}==0) = NaN;
    meanV = repmat(mean(V{i},4),[1,1,1,size(V{i},4)]);
    V{i} = (V{i} - meanV)./meanV * 100;
end

%%

xHist = -2:.1:2;
figure(163); clf;
for i=1:numel(V)
    subplot(1,numel(V),i);
    hist(V{i}(:),xHist);
    xlim([-2 2]);
end

%%
iSlice = 6;
iFrames = 20:5:30;
nFrames = numel(iFrames);

figure(111); clf;
set(gcf,'Position',[232   234   595   713]);
for i=1:nFrames
    for j=1:3
        subplot(3,nFrames,nFrames*(j-1)+i); cla;
        imagesc(V{j}(:,:,iSlice,iFrames(i))');
        set(gca,'xtick',[],'ytick',[],'clim',[-1 1])
    end
end

figure(112); clf;
set(gcf,'Position',[828   234   595   713]);
for i=1:nFrames
    subplot(3,nFrames,i); cla;
    imagesc(V{4}(:,:,iSlice,iFrames(i))');
    set(gca,'xtick',[],'ytick',[])
    subplot(3,nFrames,nFrames+i); cla;
    imagesc(V{5}(:,:,iSlice,iFrames(i))');
    set(gca,'xtick',[],'ytick',[],'clim',[-1 1])
end

figure(113); clf;
set(gcf,'Position',[828   234   595   713]);
for i=1:nFrames
    subplot(3,nFrames,i); cla;
    imagesc(V{6}(:,:,iSlice,iFrames(i))');
    set(gca,'xtick',[],'ytick',[])
    subplot(3,nFrames,nFrames+i); cla;
    imagesc(V{7}(:,:,iSlice,iFrames(i))');
    set(gca,'xtick',[],'ytick',[],'clim',[-1 1])
end