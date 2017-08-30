%% TEMP_MakeRandomParcellations_wrapper
% Created ~2/10/16 by DJ.

subjects = 6:7;
nROIs = 200;
nParc = 10;
for i=1:numel(subjects)
    subjStr = sprintf('SBJ%02d',subjects(i));
    dir = sprintf('/data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/%s/D02_CTask001',subjStr);
    cd(dir);
    outPrefix = sprintf('%s_CTask001.RandParc',subjStr);
    MakeRandomParcellations(sprintf('%s_CTask001.Craddock_T2Level_0200+orig',subjStr),nROIs,nParc,outPrefix);
    mkdir('RandParc');
    movefile([outPrefix '*'], 'RandParc/')
end