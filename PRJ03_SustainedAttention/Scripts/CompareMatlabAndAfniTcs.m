function CompareMatlabAndAfniTcs(dataFile,atlasFile,afniTcFile)

% Created 8/31/16 by DJ.

data = BrikLoad(dataFile);
atlas = BrikLoad(atlasFile);

afniTc = Read_1D(afniTcFile);

nRois = max(atlas(:));
nT = size(data,4);
matlabTc = nan(nT,nRois);

for i=1:nT
    fprintf('t=%d/%d...\n',i,nT);
    dataThis = data(:,:,:,i);
    for j=1:nRois
        matlabTc(i,j) = mean(dataThis(atlas==j));
    end
end
%%
scaleFactor = mean(afniTc(:))/mean(matlabTc(:));
clim = [-1 1]*.2;
clf;
subplot(221);
imagesc(afniTc);
set(gca,'clim',clim);
xlabel('ROI')
ylabel('t (samples)')
title('AFNI (SVD) timecourse')
colorbar;
subplot(222);
imagesc(matlabTc*scaleFactor);
set(gca,'clim',clim);
xlabel('ROI')
ylabel('t (samples)')
title('MATLAB (mean) timecourse (scaled)')
colorbar;
subplot(223);
imagesc(afniTc-matlabTc*scaleFactor);
set(gca,'clim',clim);
colorbar;
xlabel('ROI')
ylabel('t (samples)')
title('AFNI-MATLAB timecourse')


%% Correlate
r = nan(1,nRois);
p = nan(1,nRois);
for i=1:nRois
    [r(i),p(i)] = corr(afniTc(:,i),matlabTc(:,i));
end
subplot(224);
plot(r);
ylabel('rho')
xlabel('ROI')
title('Correlation between AFNI and MATLAB timecourses')