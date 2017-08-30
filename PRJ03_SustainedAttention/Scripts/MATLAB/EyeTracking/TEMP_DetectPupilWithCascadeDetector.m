

%% get positive images/ROIs from calib frames

trainingImageLabeler

%% Make negative images
for i=1:100
    imwrite(video(1:100,:,i*10),sprintf('TopFrame%d.jpg',i),'jpg');
    imwrite(video(140:end,:,i*10),sprintf('BotFrame%d.jpg',i),'jpg');
    imwrite(video(:,1:120,i*10),sprintf('LeftFrame%d.jpg',i),'jpg');
    imwrite(video(:,200:end,i*10),sprintf('RightFrame%d.jpg',i),'jpg');
end

%% Get negative images
% Get negative images from a blink
blinkImages = cell(1,6);

for i=1:6
    blinkImages{i} = sprintf('/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S09_2016-01-15/TestImages/BlinkFrame%d.jpg',i+7);
end

% Get negative images from top & bottom
[topImages, botImages, leftImages, rightImages] = deal(cell(1,100));

for i=1:100
    topImages{i} = sprintf('/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S09_2016-01-15/TestImages/TopFrame%d.jpg',i);
    botImages{i} = sprintf('/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S09_2016-01-15/TestImages/BotFrame%d.jpg',i);
    leftImages{i} = sprintf('/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S09_2016-01-15/TestImages/leftFrame%d.jpg',i);
    leftImages{i} = sprintf('/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S09_2016-01-15/TestImages/rightFrame%d.jpg',i);
end

negativeImages = cat(2,topImages,botImages,blinkImages);

%%
outputXMLFileName = 'PupilTest.xml';
trainCascadeObjectDetector(outputXMLFileName, positiveInstances_pupil, negativeImages)
outputXMLFileName = 'CrTest.xml';
trainCascadeObjectDetector(outputXMLFileName, positiveInstances_CR, negativeImages)