function handles =  initRadiobuttons(handles,reset_on)

% set curve plot properties:
handles = initPlots(handles);

if reset_on
    handles.CurrentButtonVals = zeros(1,handles.H.Priv.maxScale + 2);
end

handles.CurrentButtonVals(handles.CurrentButton) = 1;

% set radiobuttons:
for k = 1:handles.H.Priv.maxScale + 2
    set(handles.(['radiobutton' num2str(k)]),'Value',...
        handles.CurrentButtonVals(k),'FontWeight','normal')
end
V = [{'off'} {'on'}];
for k = 1:handles.H.Priv.maxScale + 2
    set(handles.(['textColor' num2str(k)]),'BackgroundColor',...
        handles.timePlotColors{k},'Visible',V{handles.CurrentButtonVals(k)+1})
end

set(handles.(['radiobutton' num2str(handles.CurrentButton)]),'Value',1,'FontWeight','bold')
set(handles.(['textColor' num2str(handles.CurrentButton)]),'Visible','on')
