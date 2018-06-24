function handles = exportCurves(handles)

[filename, pathname] = uiputfile({'*.xls';'*.mat'},'Save Current Data as');

if ~(isequal(filename,0) | isequal(pathname,0))
    ffn = fullfile(pathname,filename);
    DD = get(handles.listboxAtlasList,'String');
    D = updateTemporalData(handles);
    D = D';
    if ~handles.Synch
        DD = ['time (s)';DD];
        T = ((1/handles.Pub.samplingFrequency)*(1:size(D,2)));
    else
        DD = ['time interval';DD];
        for k = 1:size(D,2);
            T{k} = calcInterval(k,handles);
        end
    end
    if strcmp(ffn(end-2:end),'xls') % save data as a xls-file
        [SUCCESS msg] = xlswrite(ffn,D,1,'B2');
        if SUCCESS == 0
            errordlg(msg.message,'File Saving Error')
            return
        end
        [SUCCESS msg] = xlswrite(ffn,DD,1,'A1');
        if SUCCESS == 0
            errordlg(msg.message,'File Saving Error')
            return
        end
        [SUCCESS msg] = xlswrite(ffn,T,1,'B1');
        if SUCCESS == 0
            errordlg(msg.message,'File Saving Error')
            return
        end
    else
        Curves = D;
        for k = 2:length(DD)
            Regions{k-1,1} = DD{k};
        end
        xlab = T;
        save(ffn,'Curves','Regions','xlab');
    end
end
