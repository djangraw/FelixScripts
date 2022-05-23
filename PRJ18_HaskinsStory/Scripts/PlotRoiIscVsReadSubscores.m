% PlotRoiIscVsReadSubscores.m
%
% Created 8/16/19 by DJ.
% Updated 5/23/22 by DJ - updated behFile

constants = GetStoryConstants();
roiTerms = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG','CG'};
roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'};
roiTypes = 'atlas';
groupDiffMaps = {''};
sides = {''};

[readScores, IQs,weights,weightNames] = GetStoryReadingScores(constants.okReadSubj);
[readScore_sorted,order] = sort(readScores,'ascend');
subj_sorted = constants.okReadSubj(order);

roiBrick = GetRoiBrick(roiTerms,roiNames,roiTypes,groupDiffMaps,sides);
iscInRoi = GetIscInRoi(subj_sorted,roiBrik,1:nRoi);

%% Get reading scores

behFile = constants.behFile;
behTable = readtable(behFile);
allReadScores = [behTable.TOWREVerified__SWE_SS,behTable.TOWREVerified__PDE_SS,behTable.TOWREVerified__TWRE_SS,...
    behTable.WoodcockJohnsonVerified__BscR_SS, behTable.WoodcockJohnsonVerified__LW_SS, behTable.WoodcockJohnsonVerified__WA_SS];
weightNames = {'TOWRE_SWE_SS','TOWRE_PDE_SS','TOWRE_TWRE_SS','WJ3_BscR_SS','WJ3_LW_SS','WJ3_WA_SS'};
% re-sort table
[~,tableOrder] = ismember(subj_sorted,behTable.haskinsID);
allReadScores_sorted = allReadScores(tableOrder,:);

%% Plot
figure(234); clf;
nRoi = size(iscInRoi,3);
nScores = size(allReadScores_sorted,2);
% nCols = ceil(sqrt(nRoi));
% nRows = ceil(nRoi/nCols);
[rho,p] = deal(nan(nRoi,nScores));
for i=1:nRoi
    temp = iscInRoi(:,:,i);
    temp(isnan(temp))=0;
    temp = temp+temp';
    meanIscInRoi = mean(temp);
    for j=1:nScores
%     subplot(nRows,nCols,i);
        subplot(nScores,nRoi,(j-1)*nRoi+i);
        plot(meanIscInRoi,allReadScores_sorted(:,j),'.') 
        [rho(i,j),p(i,j)] = corr(meanIscInRoi',allReadScores_sorted(:,j),'Type','Spearman');
        xlabel(roiNames{i})
        ylabel(weightNames{j})
    end
end
figure(235);clf;
subplot(2,1,1);
bar(rho);
set(gca,'xtick',1:nRoi,'xticklabel',roiNames);
legend(weightNames);
title('Spearman rho values');

subplot(2,1,2);
bar(p);
set(gca,'xtick',1:nRoi,'xticklabel',roiNames);
legend(weightNames);
title('p values');