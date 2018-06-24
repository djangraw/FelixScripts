function constructMapsFromBlocks(BlockDirectoryPath,DestinationPath)

% Ex: 
% BlockDirectoryPath = 'D:\Tutkimus\fMRI\data\ASig_SWT';
% DestinationPath = 'D:\Tutkimus\fMRI\data';
% constructMapsFromBlocks(BlockDirectoryPath,DestinationPath);

nrSubjects = 12;
dirNames = [{'s1'};{'s2'};{'s3'};{'s4'};{'s5'};{'s6'};{'s7'};{'s8'};{'s9'};{'s10'};{'s11'};{'s12'}];

for k = 1:nrSubjects
    dPath = [DestinationPath '/' dirNames{k}];
    constructMap(BlockDirectoryPath,dPath,k);
end



function constructMap(BlockDirectoryPath,DestinationPath,subjectNR)

Level = 1;
nrBlocks = 9919;
BlockDirectoryPath = [BlockDirectoryPath '/wavblock'];
testBlock = load([BlockDirectoryPath num2str(1)]);
fi = fields(testBlock);
testBlock = testBlock.(char(fi));

dataSize = [91 109 size(testBlock,3) size(testBlock,2)];
M = load_nii('MNI152_T1_2mm_brain_mask.nii');
M = logical(M.img);
I = zeros(dataSize);

for iter = 1:nrBlocks
    disp(['Iteration: ' num2str(iter) '/' num2str(nrBlocks)])
    for m = 1:dataSize(1)
        for n = 1:dataSize(2)
            if sum(M(m,n,:)) > 0
                Block = load([BlockDirectoryPath num2str(iter)]);
                fi = fields(S);
                Block = S.(char(fi));
                I(m,n,:,:) = squeeze(Block(Level,:,:,subjectNR))';
            end
        end
    end
end
save(DestinationPath,I)
