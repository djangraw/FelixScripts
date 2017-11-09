function SaveLetterOrderTimingFiles(data,prefix)

% SaveLetterOrderTimingFiles(data,prefix)
%
% INPUTS:
% -data is an array of LetterOrderTask data structs from different runs.
% -prefix is a string indicating the session numbers.
%
% OUTPUTS:
% -stimulus timing files (<prefix>.<condition_name>.1D) will be saved to
% the current directory.
%
% Created 10/26/17 by DJ.
% Updated 11/2/17 by DJ - multiple runs in one file, prefix input, no ISI
% Updated 11/8/17 by DJ - added catch trials, disregard trigger keys

% Declare defaults
if ~exist('prefix','var') || isempty(prefix)
    prefix = sprintf('LetterOrder-%s-%d',data(1).params.subject,data(1).params.session);
end


for iRun=1:numel(data)
    % Set up
    if iRun==1
        fidMode = 'w'; % discard file contents and start at beginning
    else
        fidMode = 'a'; % append to existing file
    end
    % Extract event info
    tDisp = data(iRun).events.display.time;
    nameDisp = data(iRun).events.display.name;
    tKey = data(iRun).events.key.time(ismember(data(iRun).events.key.char,data(iRun).params.respKeys));
    tStart = data(iRun).events.key.time(find(strcmp(data(iRun).events.key.char,num2str(data(iRun).params.triggerKey)),1));

    % Get specific event times
    tEncoding = tDisp(strcmp(nameDisp,'string'));
    tCue = tDisp(strcmp(nameDisp,'cue'));
    tTest = tDisp(strcmp(nameDisp,'test'));
    isRem = data(iRun).events.trial.isRemember; % remember vs. alphabetize condition
    isCatch = data(iRun).events.trial.isCatchTrial; % no response required
    
    % Get response times
    tResp = nan(size(tTest));
    for i=1:numel(tTest)
        if i<numel(tEncoding)
            iResp = find(tKey>tTest(i) & tKey<tEncoding(i+1),1);
        else
            iResp = find(tKey>tTest(i),1);
        end
        if ~isempty(iResp)
            tResp(i) = tKey(iResp);
        end
    end

    % Convert into stim files
    % encoding
    filename = sprintf('%s.c0_encoding.1D',prefix);
    fid = fopen(filename,fidMode);
    for i=1:numel(tEncoding)
        fprintf(fid,'%.1f:%.1f ',tEncoding(i)-tStart,tCue(i)-tEncoding(i));
    end
    fprintf(fid,'\n');
    fclose(fid);
    % delay
    filename = sprintf('%s.c1_delay-remem.1D',prefix);
    fid1 = fopen(filename,fidMode);
    filename = sprintf('%s.c2_delay-alpha.1D',prefix);
    fid2 = fopen(filename,fidMode);
    for i=1:numel(tCue)
        if isRem(i)
            fprintf(fid1,'%.1f:%.1f ',tCue(i)-tStart,tTest(i)-tCue(i));
        else
            fprintf(fid2,'%.1f:%.1f ',tCue(i)-tStart,tTest(i)-tCue(i));
        end
    end
    fprintf(fid1,'\n'); fprintf(fid2,'\n');
    fclose(fid1); fclose(fid2);
    % test
    filename = sprintf('%s.c3_test-remem.1D',prefix);
    fid1 = fopen(filename,fidMode);
    filename = sprintf('%s.c4_test-alpha.1D',prefix);
    fid2 = fopen(filename,fidMode);
    filename = sprintf('%s.c4_test-catch.1D',prefix);
    fid3 = fopen(filename,fidMode);
    
    for i=1:numel(tCue)
        if isCatch(i)
            fprintf(fid3,'%.1f:%.1f ',tTest(i)-tStart,0);
        elseif isRem(i)
            fprintf(fid1,'%.1f:%.1f ',tTest(i)-tStart,tResp(i)-tTest(i));
        else
            fprintf(fid2,'%.1f:%.1f ',tTest(i)-tStart,tResp(i)-tTest(i));
        end
    end
    fprintf(fid1,'\n'); fprintf(fid2,'\n'); fprintf(fid3,'\n');
    fclose(fid1); fclose(fid2); fclose(fid3);
    % response
    filename = sprintf('%s.c5_resp-remem.1D',prefix);
    fid1 = fopen(filename,fidMode);
    filename = sprintf('%s.c6_resp-alpha.1D',prefix);
    fid2 = fopen(filename,fidMode);
    for i=1:numel(tCue)
        if isCatch(i) || isnan(tResp(i))
            % do nothing
        elseif isRem(i)
            fprintf(fid1,'%.1f:%.1f ',tResp(i)-tStart,0);
        else
            fprintf(fid2,'%.1f:%.1f ',tResp(i)-tStart,0);
        end
    end
    fprintf(fid1,'\n'); fprintf(fid2,'\n');
    fclose(fid1); fclose(fid2);
    % ISI
%     filename = sprintf('%s.c7_ISI.1D',prefix);
%     fid = fopen(filename,fidMode);
%     for i=1:numel(tCue)-1
%         fprintf(fid,'%.1f:%.1f ',tResp(i)-tStart,tEncoding(i+1)-tResp(i));
%     end
%     fprintf(fid,'\n');
%     fclose(fid);
end
