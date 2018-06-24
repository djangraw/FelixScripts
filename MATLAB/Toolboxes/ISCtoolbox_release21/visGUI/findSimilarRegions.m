function R = findSimilarRegions(Params)

Th = 0.25;
load([Params.PublicParams.dataDestination 'memMaps'])
Priv = Params.PrivateParams;
Pub = Params.PublicParams;
R = cell(Priv.nrSessions,Priv.maxScale+2,max(Priv.nrTimeIntervals));
for k = 0:Priv.maxScale+2
    for m = 1:Priv.nrSessions
        for t = 1:Priv.nrTimeIntervals(m)
            Q = memMaps.resultMap.win.([Priv.prefixFreqBand num2str(k)]...
                ).([Priv.prefixSession num2str(m)]).cor.Data(t).xyz;
            R{m,k+1,t} = find(Q >= Th);
        end
    end
end
