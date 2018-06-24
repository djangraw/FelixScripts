function W = anatomicOverlayAtlas(handles,S,dataAt)

% load anatomical image:
I=load_nii('MNI152_T1_2mm_brain.nii');
W = single(I.img);
W = W-min(min(min(nonzeros(W))));
W = W./max(max(max(W)));
W=round(63*W);
W(W<0) = 0;
W(W>64) = 64;
W = W + 67;
W(W==65) = size(get(gcf,'colormap'),1);

switch handles.orient
    case 3
        W = rot90(squeeze(W(S,:,:)));
    case 2
        W = rot90(squeeze(W(:,S,:)));
    case 1
        W = rot90(squeeze(W(:,:,S)));
end
regionInds = find(dataAt > 0);
if handles.At == 1
    W(regionInds) = dataAt(regionInds)+130;
else
    W(regionInds) = dataAt(regionInds)+130;
end
