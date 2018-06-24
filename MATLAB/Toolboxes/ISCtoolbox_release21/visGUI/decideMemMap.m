function Map = decideMemMap(handles)

handles.dim(1) = handles.dataset;
handles.dim(2) = handles.wavLevel;
handles.dim(3) = handles.coefType;
handles.dim(4) = handles.SimMeasure;

if handles.dim(3) == 1 && handles.dim(2) == 1
     handles.dim(3) = 2;
end

dSet = [{'Set1'} {'Set2'}];
Wtype = [{'D'} {'A'}];
WLev = [{'Orig'} {'Lev1'} {'Lev2'} {'Lev3'} {'Lev4'}];

if ~handles.freqCompOn

    if handles.win
        SI = [{'cor'} {'ken'} {'ssi'} {'nmi'}];
        Map = handles.memMap2.([dSet{handles.dim(1)} Wtype{handles.dim(3)} WLev{handles.dim(2)} SI{handles.dim(4)}]);
    else
        SI = [{'cor'} {'ken'} {'ssi'} {'nmi'}];
        Map = handles.memMap1.([dSet{handles.dim(1)} Wtype{handles.dim(3)} WLev{handles.dim(2)} SI{handles.dim(4)}]);
    end
end

