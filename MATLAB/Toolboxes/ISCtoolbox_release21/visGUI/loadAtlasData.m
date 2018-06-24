function handles = loadAtlasData(handles)

switch handles.AtlasThreshold
  case 1
    ind = 1;
  case 2
    ind = 3;
  case 3
    ind = 5;
end

dataCort = load_nii(handles.Priv.brainAtlases{ind});
dataSub =  load_nii(handles.Priv.brainAtlases{ind+1});
dataCort = dataCort.img;
dataSub = dataSub.img;


%handles.dataAt = handles.dataAt.img;

atlasInds = find(handles.atlasIndexList(:,1));
 % plot all regions:
%atlasInds = unique(handles.dataAt);
%atlasInds(atlasInds == 0) = [];

handles.atlas = zeros(size(dataCort));
for k = 1:length(atlasInds)
    if atlasInds(k) > handles.nrCorticalRegions
        handles.atlas = handles.atlas | ( dataSub == handles.regionLabelsOrig(atlasInds(k)) );
    else
        handles.atlas = handles.atlas | ( dataCort == handles.regionLabelsOrig(atlasInds(k)) );
    end
end

if handles.Perim == 1

% get perimeters of the regions for axial, sagittal and coronal views:
handles.atlasPerimAx = logical(zeros(size(dataCort)));
for m = 1:handles.Priv.dataSize(handles.dataset,3)
    for k = 1:length(atlasInds)
        if atlasInds(k) > handles.nrCorticalRegions
            B1 = bwperim( dataSub(:,:,m) == handles.regionLabelsOrig(atlasInds(k)) );
        else
            B1 = bwperim( dataCort(:,:,m) == handles.regionLabelsOrig(atlasInds(k)) );
        end
        handles.atlasPerimAx(:,:,m) = handles.atlasPerimAx(:,:,m) + B1;
    end
end

handles.atlasPerimCor = logical(zeros(size(dataCort)));
for m = 1:handles.Priv.dataSize(handles.dataset,2)
    for k = 1:length(atlasInds)
        if atlasInds(k) > handles.nrCorticalRegions
            B2 = bwperim( squeeze(dataSub(:,m,:)) == handles.regionLabelsOrig(atlasInds(k)) );
            C2 = logical(zeros(handles.Pub.dataSize(handles.dataset,1),1,handles.Pub.dataSize(handles.dataset,3)));
            C2(:,1,:) = B2;
        else
            B2 = bwperim( squeeze(dataCort(:,m,:)) == handles.regionLabelsOrig(atlasInds(k)) );
            C2 = logical(zeros(handles.Pub.dataSize(handles.dataset,1),1,handles.Pub.dataSize(handles.dataset,3)));
            C2(:,1,:) = B2;
        end
        handles.atlasPerimCor(:,m,:) = handles.atlasPerimCor(:,m,:) + C2;               
    end
end

handles.atlasPerimSag = logical(zeros(size(dataCort)));
for m = 1:handles.Priv.dataSize(handles.dataset,1)
    for k = 1:length(atlasInds)
        if atlasInds(k) > handles.nrCorticalRegions
            B3 = bwperim( squeeze(dataSub(m,:,:)) == handles.regionLabelsOrig(atlasInds(k)) );
            C3 = logical(zeros(1,handles.Pub.dataSize(handles.dataset,2),handles.Pub.dataSize(handles.dataset,3)));
            C3(1,:,:) = B3;
        else
            B3 = bwperim( squeeze(dataCort(m,:,:)) == handles.regionLabelsOrig(atlasInds(k)) );
            C3 = logical(zeros(1,handles.Pub.dataSize(handles.dataset,2),handles.Pub.dataSize(handles.dataset,3)));
            C3(1,:,:) = B3;        
        end
        handles.atlasPerimSag(m,:,:) = handles.atlasPerimSag(m,:,:) + C3;
               
    end
end

end

%handles.dataAt(find(handles.dataAt)) = handles.dataAt(find(handles.dataAt)) ...
%    + handles.colMapSize + handles.rangeAnatomy + 2;

