% subjContrast = 'AllSubjects(0).ReadingPC1(1)';
subjContrast = 'AllSubjects';
% fcContrasts = {'str.uns','str(1).uns(-1)'};
fcContrasts = {'Uns_run1(-1).Str_run1(1).Ba5952083861382886'};
fcContrastNames = {'Str-Uns'};
iRois = [167 33 151 16 197 64 184 47 200 71, 261 124, 258 121];
roiNames = {'lMot','rMot','lIFG','rIFG','lSTG','rSTG','lSMG','rSMG','lFus','rFus','lPut','rPut','lCaud','rCaud'};
viewTypes = {'left','top'};
thresh = 0.05;
connProject = 'conn_project_SRTT_d5';
analysisName = 'RoiToRoi';
for i=1:numel(fcContrasts)
    for j=1:numel(iRois)
        PrintAfniConnResults(subjContrast,fcContrasts{i},iRois(j),thresh,viewTypes,roiNames{j},fcContrastNames{i},connProject,analysisName);
    end
end