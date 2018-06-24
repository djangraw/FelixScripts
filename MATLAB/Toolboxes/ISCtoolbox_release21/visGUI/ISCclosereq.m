% my_closereq
% User-defined close request function
% to display a question dialog box

selection = questdlg('Do you want to close?',...
    'Close GUI',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        delete(gcf)
    case 'No'
        return
end