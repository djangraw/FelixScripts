function setAndSaveMemMapField(Pub,Priv,fieldN,memMap)

fileName = [Pub.dataDestination 'memMaps.mat'];
if exist(fileName,'file') == 2
    load(fileName)
    if ~isfield(memMaps,fieldN)
        memMaps.(fieldN) = [];
    end
else
    memMaps.(fieldN) = [];
end

memMaps = setfield(memMaps,fieldN,memMap);
save([Pub.dataDestination 'memMaps'],'memMaps')
disp(' ')
