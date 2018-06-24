function [data cData kc cc] = loadTS(linInd3D,coefType,wavlevel)

% ex: [data cData kc cc] = loadTS(300970,'app',5);

dataSize = [91 109 91];
[x,y,z] = ind2sub(dataSize,linInd3D);
blockNR = getDatablockIndex(dataSize,x,y);

switch coefType
    case 'det'
        load(['C:\fMRI data\DSig_SWT\wavblock' num2str(blockNR)])
        BLOCK = DSig_SWT;
        load(['C:\fMRI data\DSig_SWT\corrData\corrData' num2str(blockNR)])
        COR_BLOCK = DSig_SWT;
    case 'app'
        load(['C:\fMRI data\ASig_SWT\wavblock' num2str(blockNR)])
        BLOCK = ASig_SWT;
        load(['C:\fMRI data\ASig_SWT\corrData\corrData' num2str(blockNR)])
    otherwise
        error('coefType must be ''det'' or ''app''!!')
   return
end

data = squeeze(BLOCK(wavlevel,:,z,:));
cData = squeeze(corrData(:,:,z,wavlevel));

kc = calcKendall(data);
cc = calcPearson(cData);

cData2 = corrcoef(data);
% sum(sum((abs(cData2 - cData) < 1e-12)~=1)) == 0
%kc
%cc








