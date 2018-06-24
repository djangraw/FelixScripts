function handles = setButton(handles,hObject,nr,h)

handles.CurrentButtonVals(nr) = get(hObject,'Value');
if handles.CurrentButtonVals(nr)
    set(h,'Visible','on')
    set(handles.timeAxesChildren(nr),'Visible','on')
else
    set(h,'Visible','off')
    set(handles.timeAxesChildren(nr),'Visible','off')
end

