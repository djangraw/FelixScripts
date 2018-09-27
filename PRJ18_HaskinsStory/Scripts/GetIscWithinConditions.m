%function GetIscWithinConditions(subjects,maskFile)
%% Declare
constants = GetStoryConstants();
subjects = constants.okReadSubj;
dataDir = '/data/NIMH_Haskins/a182';
maskFile = sprintf('%s/GROUP_block_tlrc_d2/MNI_mask_epiRes.nii',dataDir);
cd(dataDir);

%% Load mask
fprintf('Loading mask...\n')
[mask,maskInfo] = BrikLoad(maskFile);
mask_vec = mask(:)>0;

%% Load fMRI
fprintf('Loading subject data...\n');
for i=1:numel(subjects)
    fprintf('%d/%d...\n',i,numel(subjects));
    V = BrikLoad(sprintf('%s/%s.storyISC_d2/all_runs.%s+tlrc',subjects{i},subjects{i},subjects{i}));
    sizeV = size(V);
    V = reshape(V,[prod(sizeV(1:3)),size(V,4)]);
    if i==1
        Vall = nan([sum(mask_vec),size(V,2),numel(subjects)]);
    end
    Vall(:,:,i) = V(mask_vec,:);
end

%% Get ISC
% get events
[iAud,iVis,iBase] = GetStoryBlockTiming();

fprintf('Calculating ISC...\n');
nVoxels = size(Vall,1);
nSubj = size(Vall,3);
nPairs = nSubj*(nSubj-1)/2;
[Xaud,Xvis] = deal(nan(nPairs,nVoxels));
for i=1:nVoxels
    if mod(i,1000)==0
        fprintf('%d/%d...\n',i,nVoxels);
    end
    % extract 
    Vaud = squeeze(Vall(i,iAud,:));
    Vvis = squeeze(Vall(i,iVis,:));
    % Correlate
    Xaud(:,i) = VectorizeFc(corr(Vaud,'rows','complete'));
    Xvis(:,i) = VectorizeFc(corr(Vvis,'rows','complete'));    
end

%% Check distribution of pairwise comparisons against zero & each other

fprintf('Running t-tests...\n');
[~,p_Xaud_vs_0] = ttest(Xaud,0,'tail','left');
[~,p_Xvis_vs_0] = ttest(Xvis,0,'tail','left');
[~,p_Xaud_vs_Xvis] = ttest(Xaud,Xvis,'tail','left');

z_Xaud_vs_0 = norminv(p_Xaud_vs_0);
z_Xvis_vs_0 = norminv(p_Xvis_vs_0);
z_Xaud_vs_Xvis = norminv(p_Xaud_vs_Xvis);

%% Plot histos
figure(62);clf;
subplot(3,1,1);
xHist = linspace(-8,8,20);
hist(z_Xaud_vs_0,xHist);
xlabel('z(Aud > 0)')
ylabel('# voxels')
subplot(3,1,2);
hist(z_Xvis_vs_0,xHist);
xlabel('z(Vis> 0)')
ylabel('# voxels')
xlim([xHist(1) xHist(end)])
subplot(3,1,3);
hist(z_Xaud_vs_Xvis,xHist);
xlabel('z(Aud > Vis)')
ylabel('# voxels')
xlim([xHist(1) xHist(end)])

%% Map back onto bricks
fprintf('Writing to AFNI bricks...\n')
cd(dataDir);
mkdir('ConditionwiseIsc')
cd('ConditionwiseIsc')
brik = mask;
brik(mask>0) = z_Xaud_vs_0;
opt = struct('Prefix','z_Xaud_vs_0','OverWrite','y');
WriteBrik(brik,maskInfo,opt);
brik(mask>0) = z_Xvis_vs_0;
opt = struct('Prefix','z_Xvis_vs_0','OverWrite','y');
WriteBrik(brik,maskInfo,opt);
brik(mask>0) = z_Xaud_vs_Xvis;
opt = struct('Prefix','z_Xaud_vs_Xvis','OverWrite','y');
WriteBrik(brik,maskInfo,opt);
brik(mask>0) = -z_Xaud_vs_Xvis;
opt = struct('Prefix','z_Xvis_vs_Xaud','OverWrite','y');
WriteBrik(brik,maskInfo,opt);