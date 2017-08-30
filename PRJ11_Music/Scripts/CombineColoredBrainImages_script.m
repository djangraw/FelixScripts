% CombineColoredBrainImages_script
%
% Created 5/24/17 by DJ.

view = 'R';

imgNames = {sprintf('Blank%s.jpg',view), sprintf('Speak%s.jpg',view), ...
    sprintf('Sing%s.jpg',view), sprintf('Imagine%s.jpg',view)};

imgCombo = CombineColoredBrainImages(imgNames(1:2));
imwrite(imgCombo,sprintf('Speak_%s_qwarp.jpg',view))
imgCombo = CombineColoredBrainImages(imgNames(1:3));
imwrite(imgCombo,sprintf('SpeakPlusSing_%s_qwarp.jpg',view))
imgCombo = CombineColoredBrainImages(imgNames);
imwrite(imgCombo,sprintf('SpeakPlusSingPlusImagine_%s_qwarp.jpg',view))
