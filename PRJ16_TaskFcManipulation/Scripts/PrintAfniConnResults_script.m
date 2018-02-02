contrastTypes = {'str.uns','str(1).uns(-1)'};
iRois = [167 33 151 16 197 64 184 47 200 71];
roiNames = {'lMot','rMot','lIFG','rIFG','lSTG','rSTG','lSMG','rSMG','lFus','rFus'};
viewTypes = {'left','top'};
thresh = 0.05;
for i=1:numel(contrastTypes)
    for j=1:numel(iRois)
        PrintAfniConnResults(contrastTypes{i},iRois(j),thresh,viewTypes,roiNames{j});
    end
end