function th = thresholdMaps(Wcor_z)



I = load_nii('MNI152_T1_2mm_brain_mask.nii');
I = logical(double(I.img));

if length(size(Wcor_z)) == 4
    for k = 1:size(Wcor_z,4);
        W = Wcor_z(:,:,:,k);
        W(find(imag(W(1:end))))=0;
        
        mW = mean(W(find(I)));
        sW = std(W(find(I)));
        Zmean = mW*ones(size(W));
        Zstd = sW*ones(size(W));
        th(k) = mW + 2.29*sW;
        %W2(:,:,:,k) = I.*((W - Zmean)./Zstd);
    end
else
        W = Wcor_z;
        W(find(imag(W(1:end))))=0;
        mW = mean(W(find(I)));
        sW = std(W(find(I)));
        Zmean = mW*ones(size(W));
        Zstd = sW*ones(size(W));
        th = mW + 2.29*sW;
      %  W2 = I.*((W - Zmean)./Zstd);
end