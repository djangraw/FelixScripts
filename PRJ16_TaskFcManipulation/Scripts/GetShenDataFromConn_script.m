% GetShenDataFromConn_script.m
%
% Created 11/1/17 by DJ.

nSubj = 145;
nT = 450;
nRoi = 268;
fprintf('Loading ROI data...\n');
shenData = nan(nT,nRoi,nSubj);
for iSubj=1:nSubj
    if mod(iSubj,10)==0
        fprintf('Subj %d/%d...\n',iSubj,nSubj);
    end
    filename = sprintf('ROI_Subject%03d_Condition000.mat',iSubj);
    roiData = load(filename);

    isShenRoi = strncmpi(roiData.names,'Shen',4);
    try
        shenData(:,:,iSubj) = cat(2,roiData.data{isShenRoi});
    catch
        fprintf('Subject %d data size does not match...\n',iSubj);
    end
end
fprintf('Done!\n');
%%
iRoi = 20;
scale = 0.1;
figure(744); clf;
hold on;
plot(roiData.conditionsweights{1}{1}*scale);
plot(roiData.conditionsweights{2}{1}*scale);
plot(roiData.conditionsweights{3}{1}*scale);
plot(nanmean(shenData(:,iRoi,:),3));
legend(roiData.conditionsnames{:}, sprintf('Shen ROI%03d',iRoi));

%% Try ISC on an ROI level
roiCorr = nan(nSubj,nSubj,nRoi);
for iRoi = 1:nRoi
    roiCorr(:,:,iRoi) = corr(squeeze(shenData(:,iRoi,:)));
end
roiCorr(roiCorr==1) = nan; % ditch the diagonal!
roiCorr_2d = reshape(roiCorr,[nSubj*nSubj,nRoi]);
pRoiCorr = nan(1,nRoi);
for iRoi=1:nRoi
    pRoiCorr(iRoi) = signrank(roiCorr_2d(:,iRoi));
end
    

