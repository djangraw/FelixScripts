function [I_oW,I_dW,I_fW] = createSynchMaps

load('C:\fMRI data\GUI\at')
Cort = at(:,:,:,1);

I_oW = zeros(91,109,91,5);
I_dW = I_oW;
I_fW = I_oW;


for k = 1:48
    disp('Creating synchronization maps......')
    disp(['Region: ' num2str(k)])
    load(['C:\fMRI data\verifiedRegions\coefs_area' num2str(k)])
    for m = 1:5
        I = I_oW(:,:,:,m);
        I(find(Cort==k)) = oW(m,:)';
        I_oW(:,:,:,m) = I;
        
        I = I_dW(:,:,:,m);
        I(find(Cort==k)) = dW(m,:)';
        I_dW(:,:,:,m) = I;
        
        I = I_fW(:,:,:,m);
        I(find(Cort==k)) = fW(m,:)';
        I_fW(:,:,:,m) = I;
    end
end

    
    