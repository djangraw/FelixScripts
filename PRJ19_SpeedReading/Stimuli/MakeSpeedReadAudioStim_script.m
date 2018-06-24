% MakeSpeedReadAudioStim_script.m
%
% Created 6/8/18 by DJ.f

%% Make all at the same speed
voice = 'Karen';
wpm = 250;
inTxt = 'test.txt';
outAiff = 'test_output.aiff';
cmd = sprintf('say -v %s -r %d -o %s -f %s',voice,wpm,outAiff,inTxt);

system(cmd);

%% Make each word at a speed that ramps up over time

% get words
fid = fopen('test.txt');
words = textscan(fid,'%s');
words = words{1};
nWords = numel(words);
for i=1:nWords
    words{i} = strrep(words{i},'''','\''');
end
fclose(fid);
% declare speeds
wpm_min = 60;
wpm_max = 400;
wpm_vec = linspace(wpm_min,wpm_max,nWords);

% create .aiff file for each word
outPrefix = 'JATB';
outFile = cell(1,nWords);
for i=1:nWords
    outFile{i} = sprintf('%s_word%03d.aiff',outPrefix,i);
    cmd = sprintf('say -v %s -r %d -o %s %s',voice,wpm_vec(i),outFile{i},words{i});
    system(cmd);
end

%% Append files
allSound = [];
for i=1:nWords
    % load
    [thisSound, fs] = audioread(outFile{i});
    % crop
    iFirst = find(abs(thisSound)>1e-3,1);
    iLast = find(abs(thisSound)>1e-3,1,'Last');
    thisSound = thisSound(iFirst:iLast);
    % append
    allSound = [allSound; thisSound];
end
outFile_ramp = sprintf('%s_ramp.wav',outPrefix);
audiowrite(outFile_ramp,allSound,fs);




%% That didn't work, so...
%% Use the phase vocoder to speed up regular speed words
voice = 'Karen';
% get words
fid = fopen('JackAndTheBeanstalk.txt');
words = textscan(fid,'%s');
words = words{1};
% nWords = numel(words);
% declare speeds
wpm_min = 60;
wpm_max = 500;
tTotal = 3*60; % 3 minutes!
nWords = GetNumWordsInRamp(wpm_min,wpm_max,tTotal);
if nWords>numel(words)
    error('Not enough words in text to fill desired time!');
end
for i=1:nWords
    words{i} = strrep(words{i},'''','\''');
    words{i} = strrep(words{i},'"','');
end
words(strcmpi(words,'the')) = {'thee'}; % to avoid very short 'the' sound
fclose(fid);
% get word-by-word speeds
wpm_vec = linspace(wpm_min,wpm_max,nWords);

%% create .aiff file for each word
outPrefix = 'JATB';
outFile = cell(1,nWords);
for i=1:nWords
    fprintf('Making word %d/%d...\n',i,nWords);
    outFile{i} = sprintf('%s_word%03d.aiff',outPrefix,i);
    cmd = sprintf('say -v %s -r %d -o %s %s',voice,wpm_vec(1),outFile{i},words{i});
    system(cmd);
end
fprintf('Done!\n');

%% Get word start times
[~, fs] = audioread(outFile{1});
dur_ideal = 60./wpm_vec;
tWord_ideal = [0, cumsum(dur_ideal(1:end-1))];
iStart_ideal = round(tWord_ideal*fs);
iStart_ideal(1) = 1;

%% Speed each one up with the vocoder and append them

pvoc_n = 1024;
pvoc_hop = pvoc_n/4;
allSound = [];
soundDur = nan(1,nWords);
for i=1:nWords
    if mod(i,50)==0
        fprintf('word %d/%d...\n',i,nWords);
    end
    % load
    [thisSound, fs] = audioread(outFile{i});
    % crop
    iFirst = find(abs(thisSound)>1e-3,1);
    iLast = find(abs(thisSound)>1e-3,1,'Last');
    thisSound = thisSound(iFirst:iLast);
    % speed it up
    newSound=pvoc(thisSound,wpm_vec(i)/wpm_vec(1),pvoc_n,pvoc_hop);
    % record duration
    soundDur(i) = length(newSound)/fs;
    % append in proper place
    allSound((1:length(newSound))+iStart_ideal(i)) = newSound;
%     % append
%     allSound = [allSound; newSound];
end
% normalize volume to avoid clipping
allSound = allSound/max(abs(allSound(:)));
% save result    
outFile_ramp = sprintf('%s_ramp2.wav',outPrefix);
fprintf('Writing result to %s...\n',outFile_ramp);
audiowrite(outFile_ramp,allSound,fs);
fprintf('Done!\n');

%% plot ideal vs. actual wpm
figure(62); clf; hold on;
wpm_actual = 60./soundDur;
plot(wpm_actual);
plot(wpm_vec);