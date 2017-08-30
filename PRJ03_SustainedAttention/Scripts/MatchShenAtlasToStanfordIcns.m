% MatchShenAtlasToStanfordIcns
%
% Created 1/10/17 by DJ.

IcnNames = {'Auditory','LECN','Precuneus','Sensorimotor','anterior_Salience',...
    'high_Visual','prim_Visual','Basal_Ganglia','Language','RECN',...
    'Visuospatial','dorsal_DMN','post_Salience','ventral_DMN'};
nIcns = numel(IcnNames);
M = cell(1,nIcns);
for i=1:nIcns
    fprintf('%d/%d...\n',i,nIcns);
    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/StanfordFineLab_Functional_ROIs/%s',IcnNames{i}));
    files = dir('*.nii.gz');
    iOk = find(~strncmp('.',{files.name},1),1);
    [M{i},mInfo] = BrikLoad(files(iOk).name);
end
M = cat(4,M{:});
fprintf('Done!\n');

%% Convert Shen atlas into bricks

[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
nRois = max(shenAtlas(:));
ROIs = nan([size(shenAtlas),nRois]);
for i=1:nRois
    ROIs(:,:,:,i) = shenAtlas==i;
end
%% Match
% [iBest,match] = MatchAllComponents(ROIs,M);
match = nan(nRois,nIcns);
for i=1:nRois
    fprintf('ROI %d/%d...\n',i,nRois);
    for j=1:nIcns
        match(i,j) = sum(sum(sum(ROIs(:,:,:,i) & M(:,:,:,j)))) / sum(sum(sum(ROIs(:,:,:,i))));
    end
end
[~,iBest] = max(match,[],2);
iBest(all(match==0,2)) = NaN;

%% Print results
for i=1:nRois
    if isnan(iBest(i))
        fprintf('ROI #%d: no match\n',i);
    else
        fprintf('ROI #%d: %s, match=%.3g\n',i,IcnNames{iBest(i)},match(i,iBest(i)));
    end
end

%% Plot in GUI_3View
colors = distinguishable_colors(nIcns);
shenIcn = zeros(size(shenAtlas));
for i=1:nRois
    shenIcn(shenAtlas==i) = iBest(i);
end
GUI_3View(MapColorsOntoAtlas(shenIcn,colors));

%% Save results
icnLabels = iBest;
icnLabels(isnan(icnLabels)) = nIcns+1;
icnNames = [IcnNames, {'Other'}];
icnColors = distinguishable_colors(numel(icnNames));
save('/data/jangrawdc/PRJ03_SustainedAttention/StanfordFineLab_Functional_ROIs/ShenIcnLabels.mat','icnLabels','icnNames','icnColors');