function [flag,atlasPath] = checkAndSetMaskAndAtlasPath(atlasPath,Params,closeFig)

if nargin < 3
   closeFig = 1; 
end

flag = 1;
flag = checkMaskAndAtlas(atlasPath,Params);
while ~flag % if atlas path is not correct, ask it from a user:
    
    h = warndlg('Select atlas directory!','Invalid atlas path','modal');
    uiwait(h);
    atlasPath = uigetdir(cd,'PICK ATLAS DIRECTORY');
    if ~isequal(atlasPath,0)
        atlasPath = [atlasPath '/'];
        flag = checkMaskAndAtlas(atlasPath,Params);
    else
        flag = 0;
    end
    if ~flag
        if closeFig
        user_response = confCloseModal('Title','WRONG PATH!');
        switch lower(user_response)
            case 'no'
                % take no action
            case 'yes'
                % handles.output = handles;
                % guidata(hObject, handles)
                % uiresume(handles.figure1)
                flag = 0;
                return
        end
        else
           flag = 0;
           return
        end
    end
end

