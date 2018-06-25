function [pctSig_Bonf, pctSig_FDR, permFit] = FindIsfcSignificance(brickFile,permFile,maskFile,subject)
% Created 2/12/15 by DJ based on Find100RunsSignificance.m.

% Declare defaults
% brickFile = 'ISFC_ttest20files+orig';

% Set up
fitType = 'Normal';
% subject = 1;
% nRuns = 80;
iPerm = 1;
doPlot = false;

brickDir = '/Users/jangrawdc/Documents/PRJ02_100Runs/Results/ISFC/';
permDir = '/Users/jangrawdc/Documents/PRJ02_100Runs/Results/ISFC/Scrambled/';
maskDir = '/Users/jangrawdc/Documents/PRJ02_100Runs/PrcsData/';

fprintf('Loading brick file %s%s...\n',brickDir,brickFile);
[err,Info] = BrikInfo([brickDir brickFile]);
subbrick_names = strsplit(Info.BRICK_LABS,'~');
iFrames = find(strncmp('SetA_Zscr',subbrick_names,9));
[err,c_data,Info] = BrikLoad([brickDir brickFile],struct('Frames',iFrames));

fprintf('Loading perm file %s%s...\n',permDir,permFile);
[err,Info] = BrikInfo([permDir permFile]);
subbrick_names = strsplit(Info.BRICK_LABS,'~');
iFrames = find(strncmp('SetA_Zscr',subbrick_names,9));
[err,c_perm,Info] = BrikLoad([permDir permFile],struct('Frames',iFrames));
clear err Info subbrick_names iFrames

fprintf('Loading mask file %s%s...\n',maskDir,maskFile);
[err, mask, Info, ErrMessage] = BrikLoad([maskDir maskFile]);

fprintf('Evaluating significance...\n')
[pVal, permFit] = FindSignificance_permfit(c_data,c_perm,fitType);

%% correct for multiple comparisons
fprintf('Correcting for multiple comparisons...\n');

% Bonf: multiply by number of possible comparisons
pVal_flipped = 1-pVal;
pVal_bonf = pVal_flipped*sum(mask(:));
pVal_bonf(pVal_bonf>0.5) = 0.5;
% FDR: use matlab fn.
% isHigh = pVal_flipped>0.5;
% pVal_flipped(isHigh) = 1-pVal_flipped(isHigh);        
% pVal_FDR = reshape(mafdr(pVal_flipped(:),'bhfdr',true),size(pVal_flipped));
[~,foo] = fdr(pVal_flipped(mask(:)>0),0.05,'parametric');
isSig_FDR = zeros(size(pVal_flipped));
isSig_FDR(mask(:)>0) = foo;
% pVal_FDR = reshape(foo,size(pVal_flipped));
% pVal_FDR(isHigh) = 1-pVal_FDR(isHigh);


%% Plot results
if doPlot
    foo = cat(4,double(pVal_bonf<0.05),mask*0,mask*0.5);
    GUI_3View(foo);
end
%% print results
pctSig_Bonf = mean(pVal_bonf(mask(:)>0)<0.05)*100;
fprintf('Bonf: %.1f%% of intracranial voxels reached significance.\n',pctSig_Bonf);
pctSig_FDR = mean(isSig_FDR(mask(:)>0))*100;
fprintf('FDR: %.1f%% of intracranial voxels reached significance.\n',pctSig_FDR);