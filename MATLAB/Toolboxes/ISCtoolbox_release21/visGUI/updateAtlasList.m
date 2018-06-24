function handles = updateAtlasList(handles)

switch handles.AtlasThreshold
    case 1
        txt = handles.txtCort;
        table = handles.tableCort;
    case 2
        txt = handles.txtSub;
        table = handles.tableSub;
end

Titl{1} = '';
ite = 1;
isCurrent = 0;
dsind = 0;



for s = 1:length(table)
    regionInds = find(handles.dataA == table(s));
    if ~isempty(regionInds)
        % add region to the listbox:
        Titl{ite} = txt{s};
        % identify if currently selected brain region is still present after the update:
        if s + 48 == handles.CurrentRegion
            isCurrent = 1;
            dsind = ite;
        end
        ite = ite + 1;
    end
end

if ~isempty(Titl{1})
    % if currently selected brain region is still present, set new listbox
    % value that corresponds to the same region also after the update:
    if isCurrent
        set(handles.listboxAtlas,'Value',dsind)
    else
        % if currently selected brain region is no anymore present, select
        % brain region that is closest to that region and set new listbox
        % value accordingly:
        for w = 1:length(Titl)
            ds(w) = abs(str2double(Titl{w}(1:2)) - handles.CurrentRegion);
        end
        [dsmin dsind] = min(ds);
        set(handles.listboxAtlas,'Value',dsind)
    end
    % update atlas listbox:
    set(handles.listboxAtlas,'String',Titl)
end

if dsind == 0
    handles.CurrentRegion = 0;
else
    handles.CurrentRegion = str2double(Titl{dsind}(1:2));
end
