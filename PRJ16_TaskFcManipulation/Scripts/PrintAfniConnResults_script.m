subjContrast = 'AllSubjects(0).ReadingPC1(1)';
fcContrasts = {'str.uns','str(1).uns(-1)'};
iRois = [167 33 151 16 197 64 184 47 200 71];
roiNames = {'lMot','rMot','lIFG','rIFG','lSTG','rSTG','lSMG','rSMG','lFus','rFus'};
viewTypes = {'left','top'};
thresh = 0.05;
for i=1:numel(fcContrasts)
    for j=1:numel(iRois)
        PrintAfniConnResults(subjContrast,fcContrasts{i},iRois(j),thresh,viewTypes,roiNames{j});
    end
end