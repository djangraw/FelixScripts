function [pctSig_Bonf, pctSig_FDR, permFit] = Find100RunsSignificance(subject,nRuns,prefix)
% Created 1/12/15 by DJ.
% Updated 2/12/15 by DJ - added prefix input.

% Declare defaults
if ~exist('prefix','var') || isempty(prefix)
    prefix='ISC_';
end

% Set up
fitType = 'Normal';
% subject = 1;
% nRuns = 80;
iPerm = 1;
doPlot = false;

data = load(sprintf('%sSBJ%02d_%dRuns.mat',prefix,subject,nRuns));
c_data = mean(data.coeff,4);
% c_data(isnan(c_data)) = 0; % CHECK WHY THERE ARE NANs!

perm = load(sprintf('%sSBJ%02d_%dRuns_randperm%03d.mat',prefix,subject,nRuns,iPerm));
c_perm = mean(perm.coeff,4);

[pVal, permFit] = FindSignificance_permfit(c_data,c_perm,fitType);

%% correct for multiple comparisons
% get mask
thisdir = cd;
maskdir = '/Users/jangrawdc/Documents/PRJ02_100Runs/PrcsData/';
maskname = sprintf('cSBJ%02d_FB_Mask_v02+orig',subject);
cd(maskdir)
[err, mask, Info, ErrMessage] = BrikLoad([maskdir maskname]);
cd(thisdir)
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