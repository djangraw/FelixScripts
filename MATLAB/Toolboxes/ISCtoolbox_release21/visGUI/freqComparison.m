function [data,R] = freqComparison(handles,memMaps)

for k = 1:handles.Priv.maxScale+1
    if ~handles.win
        if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
            b.(['d' num2str(k)]) = swapbytes(memMaps.resultMap.whole.(['band' num2str(k)]).(['Session' num2str(handles.dataset)]).cor.Data.xyz);
        else
            b.(['d' num2str(k)]) = memMaps.resultMap.whole.(['band' num2str(k)]).(['Session' num2str(handles.dataset)]).cor.Data.xyz;
        end
        if handles.swapBytesOn % swap bytes if option is specified
            b.(['d' num2str(k)]) = swapbytes(b.(['d' num2str(k)]));
        end
    else
        
        if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
            b.(['d' num2str(k)]) = swapbytes(memMaps.resultMap.win.(['band' num2str(k)]).(['Session' num2str(handles.dataset)]).cor.Data(handles.timeVal).xyz);
        else
            b.(['d' num2str(k)]) = memMaps.resultMap.win.(['band' num2str(k)]).(['Session' num2str(handles.dataset)]).cor.Data(handles.timeVal).xyz;
        end
        if handles.swapBytesOn % swap bytes if option is specified
            b.(['d' num2str(k)]) = swapbytes(b.(['d' num2str(k)]));
        end                
    end
%    load([handles.Priv.statsDestination 'Thband' num2str(k) 'Session' num2str(handles.dataset) 'win' num2str(handles.win)])
%    w=b.(['d' num2str(k)]);
%    w(w<Th(6))=0;
%    b.(['d' num2str(k)])=w;
end

data = zeros(handles.Priv.dataSize(handles.dataset,1:3));
R = zeros(handles.Priv.dataSize(handles.dataset,1:3));
Z = ones(handles.Priv.dataSize(handles.dataset,1:3));
for m = 1:handles.Priv.maxScale+1
    w = b.(['d' num2str(m)]);
    for n = 1:handles.Priv.maxScale+1
        if m ~= n
            Z = and(Z, w > b.(['d' num2str(n)]));
        end
    end
    R(Z)  = m;
    data(Z) = w(Z);
    Z = ones(handles.Priv.dataSize(handles.dataset,1:3));
end



% R2 = zeros(Params.PrivateParams.dataSize(handles.dataset,1:3));
% R2(b.d1 > b.d2 & b.d1 > b.d3 & b.d1 > b.d4 & b.d1 > b.d5) = 1;
% R2(b.d2 > b.d1 & b.d2 > b.d3 & b.d2 > b.d4 & b.d2 > b.d5) = 2;
% R2(b.d3 > b.d1 & b.d3 > b.d2 & b.d3 > b.d4 & b.d3 > b.d5) = 3;
% R2(b.d4 > b.d1 & b.d4 > b.d2 & b.d4 > b.d3 & b.d4 > b.d5) = 4;
% R2(b.d5 > b.d1 & b.d5 > b.d2 & b.d5 > b.d3 & b.d5 > b.d4) = 5;
%
% figure;a=colormap(lines(6));a(1,:)=0;set(gcf,'Colormap',a);for k=1:91;imagesc([rot90(R(:,:,k)) 6*ones(109,1) rot90(R2(:,:,k))]);axis equal;colorbar;pause(0.2);end;
%figure;a=colormap(lines(6));a(1,:)=0;set(gcf,'Colormap',a);for k=1:91;image(R(:,:,k));colorbar;pause;end

