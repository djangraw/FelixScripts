function handles = saveExcelWorkSheet(handles)

[filename, pathname] = uiputfile({'*.xls';'*.mat'},'Save Current Data as');
if ~(isequal(filename,0) | isequal(pathname,0))
    ffn = fullfile(pathname,filename);
    if strcmp(ffn(end-2:end),'xls')
        D2L = {'original','0.07-0.15Hz','0.04-0.07Hz','0.02-0.04Hz','0.01-0.02Hz','0-0.01Hz'};
        d = get(handles.popupmenuTotalSynchMeasure,'String');
        C = {'A5','A17', 'A29'};
        C2 = {'A1:A4','A13:A16', 'A25:A28'};
        S = get(handles.popupmenuSimilarityMeasure,'String');
        S = S{handles.H.SimMeasure};
        x = {[' (threshold = ' num2str(handles.H.Threshold) ')'],'',''};
        for m = 1:3
            D = handles.CurrentPlotData{handles.H.dataset}(:,:,handles.H.SimMeasure,m)';
            D = mat2cell(D,[ones(1,size(D,1))],[ones(1,size(D,2))]);
            D2 = [['Time interval';handles.intVals'] [D2L;D]]';
            warning off MATLAB:xlswrite:AddSheet
            [SUCCESS msg] = xlswrite(ffn,D2,1,C{m});
            if SUCCESS == 0
                errordlg(msg.message,'File Saving Error')
                break
            end
            [SUCCESS msg] = xlswrite(ffn,{handles.CurrentRegionName(3:end);['Dataset ' num2str(handles.H.dataset)];['Similarity measure: ' S];['Synchronization measure: ' d{m} x{m}]},1,C2{m});
            if SUCCESS == 0
                errordlg(msg.message,'File Saving Error')
            break
            end
        end
    else
        save(ffn)
    end
end
