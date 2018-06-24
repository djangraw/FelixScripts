function [txtSub txtCort] = loadLabels

[numSub txtSub] = xlsread('D:\Tutkimus\fMRI\matlab codes\GUI\HarvardOxfordSubCort');
[numCort txtCort] = xlsread('D:\Tutkimus\fMRI\matlab codes\GUI\HarvardOxfordCort');
for k = 1:size(txtSub,1)
    if k > 1
        tmpSub{k-1,1} = txtSub{k,1};
    end
end
for k = 1:size(txtCort,1)
    tmpCort{k,1} = txtCort{k,1};
end
txtSub = tmpSub;
txtCort = tmpCort;
