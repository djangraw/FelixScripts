function setAtlasAndMaskPath(atlasPath,Params,paramFileName)

maskPath = atlasPath;
Pub = Params.PublicParams;
Priv = Params.PrivateParams;

[dn,fn] = fileparts(Priv.brainMask);
dat = [maskPath fn];
Priv.brainMask = dat;

Pub.maskPath = maskPath;
Pub.atlasPath = maskPath;

atype = [{'cort'};{'sub'};{'cort'};{'sub'};{'cort'};{'sub'}];
disp('OK!')
for k = 1:length(atype)
    Priv.brainAtlases{k} = [atlasPath 'HarvardOxford-'...
        atype{k} '-maxprob-thr' num2str(Priv.atlasTh(k)) ...
        '-' num2str(Priv.voxelSize) 'mm.nii'];    
end

Params.PrivateParams = Priv;
Params.PublicParams = Pub;

save(paramFileName,'Params')
%disp('New atlas path succesfully saved to params-struct!')