function TestVoxelLocator_script(subject,filetype)
% TestVoxelLocator_script.m
%
% Wrapper script for LocateSignificantVoxels.m.
%
% Created 4/2/15 by DJ.

% subject = 'SBJ01';
% nFiles = 16;
% subject = 'SBJ02';
% nFiles = 17;
% filetype = 'Echo2';
% filetype='MEICA';

%% 
switch subject
    case 'SBJ01'
        nFiles=16;
    case 'SBJ02'
        nFiles=17;
end

% cd(sprintf('/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/%s',subject));
% GM = BrikLoad(sprintf('%s_Gray_EPIRes+orig.BRIK',subject))/10000;
% WM = BrikLoad(sprintf('%s_White_EPIRes+orig.BRIK',subject))/10000;
% CSF = BrikLoad(sprintf('%s_CSF_EPIRes+orig.BRIK',subject))/10000;
% % GMbin = GM>WM & GM>CSF;
% % WMbin = WM>GM & WM>CSF;
% % CSFbin = CSF>GM & CSF>WM;
% GMbin = GM>0.5; WMbin = WM>0.9; CSFbin = CSF>0.9;
% masks = cat(4,GM,WM,CSF);
% masksbin = cat(4,GMbin,WMbin,CSFbin);

cd(sprintf('/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/%s/ISC',subject));
masks_temp = BrikLoad(sprintf('%s_TissueMasks+orig.BRIK',subject));
masksbin = cat(4,masks_temp==1,masks_temp==2,masks_temp==3);
maskNames = {'GM','WM','CSF'};

cd(sprintf('/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/%s/ISC',subject));
params = struct('Frames',2); % slice 2 is z scores
% filename = sprintf('ISCpw_%s-fb_%s_%dfiles+orig.BRIK',filetype,subject,nFiles);
filename = sprintf('%s_%s_ISC_%dfiles+orig.BRIK',subject,filetype,nFiles);
zscores = BrikLoad(filename,params);
filename = sprintf('%s_FullBrain_EPIRes+orig.BRIK',subject);
fbmask = BrikLoad(filename);

isSig = isSignificant_voxelwise(zscores,fbmask,'fdr');
% plot
figure(537);
LocateSignificantVoxels(isSig,masksbin,maskNames);
MakeFigureTitle(sprintf('%s: %s',filename,filetype),0);

%% 
cd(sprintf('/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/%s/ISC',subject));

% filename = sprintf('ISCpw_Echo2-fb_%s_%dfiles+orig.BRIK',subject,nFiles);
filename = sprintf('%s_Echo2_ISC_%dfiles+orig.BRIK',subject,nFiles);
zscores_e2 = BrikLoad(filename,params);
% filename = sprintf('ISCpw_OptCom-fb_%s_%dfiles+orig.BRIK',subject,nFiles);
filename = sprintf('%s_OptCom_ISC_%dfiles+orig.BRIK',subject,nFiles);
zscores_optcom = BrikLoad(filename,params);
% filename = sprintf('ISCpw_MEICA-fb_%s_%dfiles+orig.BRIK',subject,nFiles);
switch subject
    case 'SBJ01'
        filename = sprintf('%s_MEICA_ISC_%dfiles+orig.BRIK',subject,nFiles);
    case 'SBJ02'
        filename = sprintf('%s_MeicaDenoised_ISC_%dfiles+orig.BRIK',subject,nFiles);
end
zscores_meica = BrikLoad(filename,params);
filename = sprintf('%s_FullBrain_EPIRes+orig.BRIK',subject);
fbmask = BrikLoad(filename);

isSig_e2 = isSignificant_voxelwise(zscores_e2,fbmask,'fdr');
isSig_optcom =isSignificant_voxelwise(zscores_optcom,fbmask,'fdr');
isSig_meica =isSignificant_voxelwise(zscores_meica,fbmask,'fdr');
isNew = isSig_meica & ~isSig_e2;
isNew_fbmask = fbmask & ~isSig_e2;

masksbin_new = masksbin;
% for i=1:size(masksbin,4)
%     foo = masksbin_new(:,:,:,i);
%     foo(isSig_e2) = 0;
%     masksbin_new(:,:,:,i) = foo;
% end
% plot
% LocateSignificantVoxels(isNew,masksbin_new,maskNames);
figure(538);
set(gcf,'Position',[528   606   775   350]);
LocateSignificantVoxels_multi(cat(4,isSig_e2,isSig_optcom,isSig_meica),masksbin_new,{'Echo2','OptCom','MEICA'},maskNames);
MakeFigureTitle(sprintf('%s: Significant Voxels Across Methods',filename),0);

figure(539);
set(gcf,'Position',[527   181   775   350]);
LocateSignificantVoxels_multi(cat(4,isNew,isNew_fbmask),masksbin_new,{'Revealed by MEICA','whole brain'},maskNames);
MakeFigureTitle(sprintf('%s: Voxels Revealed by MEICA',filename),0);

%% Get GM stats
isAvailable = fbmask & ~isSig_e2;
nNew = sum(isNew(:));
GMbin = masksbin(:,:,:,strcmp(maskNames,'GM'));
nGM_new = sum(isNew(:) & GMbin(:));
pGM_avail = sum(isAvailable(:) & GMbin(:))/sum(isAvailable(:));

yBin = binocdf(nGM_new,nNew,pGM_avail);


%% Get blurring and 1ECHO results

filename = sprintf('%s_1ECHO_ISC_%dfiles+orig.BRIK',subject,nFiles);
zscores_1e = BrikLoad(filename,params);
filename = sprintf('%s_Echo2-blur6_ISC_%dfiles+orig.BRIK',subject,nFiles);
zscores_blur = BrikLoad(filename,params);

isSig_1e = isSignificant_voxelwise(zscores_1e,fbmask,'fdr');
isSig_blur =isSignificant_voxelwise(zscores_blur,fbmask,'fdr');

isNew_1e = isSig_1e & ~isSig_e2;
isNew_blur = isSig_blur & ~isSig_e2;

figure(540);
set(gcf,'Position',[528   606   775   350]);
LocateSignificantVoxels_multi(cat(4,isSig_1e,isSig_blur,isSig_meica),masksbin_new,{'Component Removal','Blurring','MEICA'},maskNames);
MakeFigureTitle(sprintf('%s: Significant Voxels Across Methods',filename),0);

figure(541);
set(gcf,'Position',[527   181   775   350]);
LocateSignificantVoxels_multi(cat(4,isNew_1e,isNew_blur,isNew,isNew_fbmask),...
    masksbin_new,{'CompRem-Echo2','Blurring-Echo2','MEICA-Echo2','WholeBrain-Echo2'},maskNames);
MakeFigureTitle(sprintf('%s: Voxels Revealed by various',filename),0);

