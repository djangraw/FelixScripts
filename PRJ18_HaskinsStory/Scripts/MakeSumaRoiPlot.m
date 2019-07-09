roiTerms = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG','CG'};
roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'};
nRois = numel(roiTerms);
constants = GetStoryConstants();
%%
% Load all masks
Info = cell(1,nRois);
for i=1:nRois
    fprintf('loading mask %d/%d...\n',i,nRois);
    maskFile = sprintf('%s/atlasRois/atlas_%s+tlrc',constants.dataDir,roiTerms{i});
    [V, Info{i}] = BrikLoad(maskFile);
    if i==1
        allMask = V;
    else
        allMask = allMask + i*V;
    end
end

%% Save

filename = sprintf('%s/atlasRois/%dRois',constants.dataDir,nRois);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(allMask,Info{1},Opt);


%% Make Figure
SetUpSumaMontage_8view(sprintf('%s/atlasRois/',constants.dataDir),'TEMP_ROIS.tcsh','MNI152_2009_SurfVol.nii',...
    sprintf('%dRois+tlrc',nRois),'suma_MNI152_2009/MNI152_2009_both.spec','MNI152_2009_SurfVol.nii',...
    0,0,'./SUMA_IMAGES','',sprintf('SUMA_IMAGES/%dRois.jpg',nRois),[],nRois,'0','ROI_i32');
          