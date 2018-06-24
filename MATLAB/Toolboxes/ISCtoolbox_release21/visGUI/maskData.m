function DATA = maskData(DATA)

I = load_nii('MNI152_T1_2mm_brain_mask.nii');
I = double(I.img);

if isstruct(DATA)
    D = fields(DATA);
    for W = 1:length(D)
        if ( strcmp(D{W},'nmi') || strcmp(D{W},'ssi') || ...
                strcmp(D{W},'det') || strcmp(D{W},'cor') || ...
                strcmp(D{W},'cor_abs') || strcmp(D{W},'ken') )
            DA = DATA.(D{W});
            DA = doMasking(DA,I);
            DATA.(D{W}) = DA;
            
        end
    end
else
    DATA = doMasking(DATA,I);
end

function DA = doMasking(DA,I)

DA(isnan(DA)) = 0;
DA(isinf(DA)) = 0;

if length(size(DA)) == 3
    DA = I.*DA; 
else
    for k = 1:size(DA,4)
        DA(:,:,:,k) = I.*DA(:,:,:,k);
    end
end
