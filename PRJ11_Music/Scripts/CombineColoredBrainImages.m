function imgCombo = CombineColoredBrainImages(imageNames)

% Created 5/18/17 by DJ.

nImg = numel(imageNames);
for i=1:nImg
    img = double(imread(imageNames{i}));
    if i==1 % first is baseline
        base = img;
        imgCombo = img;
    else
        mask = max(abs(img-base),[],3) > max(abs(imgCombo-base),[],3);
%         mask = any(img~=base,3) & ~any(imgCombo~=base,3);
%         mask = any(img~=imgCombo,3) & var(double(imgCombo),[],3)<10;
%         mask = var(double(img),[],3)>0 & var(double(imgCombo),[],3)==0;
        for j=1:3
            comboTemp = imgCombo(:,:,j);
            imgTemp = img(:,:,j);
            comboTemp(mask) = imgTemp(mask);
            imgCombo(:,:,j) = comboTemp;
        end
    end
end

imgCombo = uint8(imgCombo);