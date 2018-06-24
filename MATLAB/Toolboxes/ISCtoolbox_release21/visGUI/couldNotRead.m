function handles = couldNotRead(handles)

% h = errordlg(lasterr,'Could not read the data!!','modal');
ll = 'Could not locate data!';
disp(ll)

locationOK = 0;

while ~locationOK
    
    %okButtonMemMapsModal('Title',ll);
    %prompt = {'Analysis results location','Brain atlas location','Brain mask location'};
    prompt = {'Results directory:'};
    title = 'Set paths';
    lines = 1;
    pn = fileparts(handles.paramFile);
    s = what;
    [crap slashOrient] = max([length(strfind(pn,'/')) length(strfind(pn,'\'))]);
    slashes = '/\';
    sl = slashes(slashOrient);
    def = {[pn sl]};%,handles.Pub.atlasPath,handles.Pub.maskPath};
    Answer = inputdlg(prompt,title,lines,def);
    if isempty(Answer)
        handles.repeatLoadingImages = -1;
        return
    end
    for k = 1:1
        if ~strcmp(Answer{k}(end),sl)
            Answer{k} = [Answer{k} sl];
        end
    end
    answer = [];
    try
        load([Answer{k} 'Tag.mat'])
        load([Answer{k} Tag]);
        Pub = Params.PublicParams;
        Priv = Params.PrivateParams;
        atlasPath = Pub.atlasPath;
        maskPath = Pub.atlasPath;
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
        disp('OK!')        
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
        answer{1} = Answer{1};
        answer{2} = atlasPath;
    catch
        prompt = {'Brain atlas location'};
        def = {''};%,handles.Pub.atlasPath,handles.Pub.maskPath};
        answ = inputdlg(prompt,title,lines,def);
        answer = [];
        answer{1} = Answer{1};
        answer{2} = answ{1};
    end
    
    %button = saveSettingsModal('Title','Save settings');
    %button = 'yes';
    
    %if strcmp(button,'Yes')
    fileSave = 1;
    [memMaps,Params,flag] = changeDirectory(answer{1},answer{2});
    %       okButtonModal('title',lasterr);
    if ~flag
        handles.loadMemMaps = 0;
        handles.memMaps = memMaps;
        %okButtonModal('title',lasterr);
        %        okButtonModal(lasterr,'Could not save parameter files for future sessions!');
        %        h = warndlg(lasterr,'Could not save parameter files for future sessions!');
        %Construct a questdlg with two options
        choice = questdlg('Could not locate data. Try again?', ...
            'Problem!', ...
            'Yes','No','Yes');
        % Handle response        
%        button = saveSettingsModal('Title','Could not locate data! Try again?');
        if strcmp(choice,'No')
            return
        end
    else
        handles.loadMemMaps = 1;
        locationOK = 1;
    end
    
end

%elseif strcmp(button,'No') || strcmp(button,'Cancel')
%    fileSave = 0;
%    [memMaps,Params,flag] = changeDirectory([answer{1} sl],[answer{2} sl],[answer{3} sl],fileSave);
%    handles.loadMemMaps = 0;
%    handles.memMaps = memMaps;
%end
handles.Priv = Params.PrivateParams;
handles.Pub = Params.PublicParams;
%handles.repeatLoadingImages = handles.repeatLoadingImages + 1;
