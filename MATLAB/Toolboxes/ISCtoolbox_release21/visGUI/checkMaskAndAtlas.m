function flag = checkMaskAndAtlas(atlasPath,Params)


flag = 1;
try
    maskPath = atlasPath;
    
    Pub = Params.PublicParams;
    Priv = Params.PrivateParams;
    
%    atlasPath = Pub.atlasPath;
%    maskPath = Pub.atlasPath;
    
    [dn,fn] = fileparts(Priv.brainMask);
    dat = [maskPath fn];
    
    if strcmp(Pub.fileFormat,'nii')
        if ~strcmp(dat,'nii')
            ext = '.nii';
        else
            ext = '';
        end
        D = load_nii([dat ext]);
    else
        D = load(dat);
    end
    
    Priv.brainMask = dat;
    %  Pub.maskPath = maskPath;
    atype = [{'cort'};{'sub'};{'cort'};{'sub'};{'cort'};{'sub'}];
%    disp('OK!')
    for k = 1:length(atype)
        Priv.brainAtlases{k} = [atlasPath 'HarvardOxford-'...
            atype{k} '-maxprob-thr' num2str(Priv.atlasTh(k)) ...
            '-' num2str(Priv.voxelSize) 'mm.nii'];
        if ~strcmp(Priv.brainAtlases{k}(end-2:end),'nii')
            ext = '.nii';
        else
            ext = '';
        end
        at = load_nii([Priv.brainAtlases{k} ext]);
        at = at.img;
    end
    
catch
    flag = 0;
    disp(lasterr)
end

