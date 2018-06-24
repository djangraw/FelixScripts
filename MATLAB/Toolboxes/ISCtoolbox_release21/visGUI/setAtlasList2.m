function handles = setAtlasList(handles)

% fid = fopen(['txtSub.txt'], 'r');
% iter = 1;
% while 1
%     tline = fgetl(fid);
%     if ~ischar(tline),   
%         break
%     end
%     if ~isempty(tline)
%         txtSub{iter,1} = tline;
%         iter = iter + 1;
%     end
% end
% 
% fclose(fid);
% fid = fopen(['txtCort.txt'], 'r');
% iter = 1;
% while 1
%     tline = fgetl(fid);
%     if ~ischar(tline)
%         break
%     end
%     if ~isempty(tline)
%         txtCort{iter,1} = tline;
%         iter = iter + 1;
%     end
% end
% fclose(fid);
%handles.Priv
load txtCort
load txtSub

A = load_nii(handles.Priv.brainAtlases{1});
A = A.img;
handles.labels{1} = nonzeros(unique(A));

labCort = 1:size(txtCort,1); % label cortical regions as 1,2,...,48
for w = 1:length(labCort)
    handles.txtCort{w} = [num2str(labCort(w)) ' ' txtCort{w}];
end

A = load_nii(handles.Priv.brainAtlases{2});
A = A.img;
handles.labels{2} = nonzeros(unique(A));

labSub = 49:48+size(txtSub,1); % label sub-cortical regions as 49,50,51,...
for w = 1:length(labSub)
    handles.txtSub{w} = [num2str(labSub(w)) ' ' txtSub{w}];
end
set(handles.popupmenuAtlas,'String',handles.txtCort)
set(handles.popupmenuAtlas,'Value',1)

