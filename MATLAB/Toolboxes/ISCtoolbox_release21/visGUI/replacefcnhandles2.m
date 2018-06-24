function replacefcnhandles2(name)
try
    hFig = load('-mat', name);    
catch
    disp('Error Reading input file! Check File name.');
    return    
end
hFig = repStru(hFig);
save(name,'-struct','hFig');
end




function Stru = repStru(Stru)
for it = 1: numel(Stru)
    names = fieldnames(Stru(it));
    for nm_len = 1:length(names)
        %Stru(it).(names{nm_len})
        if(isa(Stru(it).(names{nm_len}),'struct'))
            Stru(it).(names{nm_len})=repStru(Stru(it).(names{nm_len}));
        else
            if isa(Stru(it).(names{nm_len}), 'function_handle')

                fstring = func2str(Stru(it).(names{nm_len}));
                fstring = strrep(fstring, '@(hObject,eventdata)', '');
                fstring = strrep(fstring, 'hObject', 'gcbo');
                fstring = strrep(fstring, 'eventdata', '[]');
                Stru(it).(names{nm_len}) = fstring;
                disp(fstring);
            end

        end
    end
end
end








