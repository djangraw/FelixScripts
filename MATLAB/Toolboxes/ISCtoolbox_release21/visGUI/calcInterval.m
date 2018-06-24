function intVal = calcInterval(timeVal,handles,F,mapType)

if nargin < 4
    mapType = 'ISC';
end
if nargin < 3
    F = 0;
end

switch mapType
    case 'ISC'
        
        winStep = round(handles.Pub.windowStep/handles.Pub.samplingFrequency);
        Secs = (timeVal-1)*winStep;
        Mins1 = floor(Secs/60); % minutes
        Secs1 = Secs - 60*Mins1;
        Secs = Secs + round(handles.Pub.windowSize/handles.Pub.samplingFrequency);
        
        %Secs = Secs + win;
        Mins2 = floor(Secs/60); % minutes
        Secs2 = Secs - 60*Mins2;
        
        % WinLen = handles.Pub.windowSize;
        % WinStep = handles.Pub.windowStep;
        
        % WinLen = 2; % in minutes
        % WinStep = 30; % in seconds
        
        %Mins = floor((WinStep*timeVal-WinStep)/60);
        %Secs = ((WinStep*timeVal-WinStep)/60 - floor((WinStep*timeVal-WinStep)/60))*60;
        
        if Secs1 < 10
            SecFill1 = '0';
        else
            SecFill1 = '';
        end
        if Secs2 < 10
            SecFill2 = '0';
        else
            SecFill2 = '';
        end
        if Secs1 == 0
            SecFill1_end = '0';
        else
            SecFill1_end = '';
        end
        if Secs2 == 0
            SecFill2_end = '0';
        else
            SecFill2_end = '';
        end
        
        
        intVal_Start = [num2str(Mins1) ':' SecFill1 num2str(Secs1)];
        intVal_End = [num2str(Mins2) ':' SecFill2 num2str(Secs2)];
        
        if F == 1
            intVal = [{[intVal_Start '-']} ;{intVal_End}];
        else
            intVal = [intVal_Start '-' intVal_End];
        end
        
    case 'phase'
        
        intVal = num2str((1/handles.Pub.samplingFrequency)*timeVal);        
        
    otherwise
        disp('Unknown temporal map')
end

