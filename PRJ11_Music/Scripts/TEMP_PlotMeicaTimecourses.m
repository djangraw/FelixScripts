subject = 2;
run = 6;
iSession = 1;
TR = 2;
nFirstRemoved = 3;
hrfOffset = 6;
motion_file = 'motion_demean.1D';
cd(sprintf('/data/jangrawdc/PRJ11_Music/Results/SBJ%02d/run%03d',subject,run));

ts = Read_1D(sprintf('TED.SBJ%02d.r%03d/meica_mix.1D',subject,run));
t = (1:size(ts,1))*TR + nFirstRemoved*TR - hrfOffset;
betas = BrikLoad(sprintf('TED.SBJ%02d.r%03d/betas_OC.nii',subject,run));
nComps = size(ts,2);
iAccepted = str2num(fileread(sprintf('TED.SBJ%02d.r%03d/accepted.txt',subject,run)));

%% Get task data
% filename='Singing-2-1-Apr_05_1123.log';
% data = ImportSingingData(filename);
conditions = data(iSession).params.trialTypes;
nConditions = numel(conditions);
tOff = data(iSession).events.display.time(ismember(data(iSession).events.display.name,{'Fixation','TheEnd'}));
tParadigm = data(iSession).events.display.time(1):0.1:data(iSession).events.key.time(end);
blockData = zeros(size(tParadigm));
for j=1:nConditions
    tOn = data(iSession).events.display.time(strncmp(data(iSession).events.display.name,[conditions{j} '(1/'],length(conditions{j})+3));
    for k=1:numel(tOn)
        tOff_this = tOff(find(tOff>tOn(k),1));
        blockData(tParadigm>=tOn(k) & tParadigm<tOff_this) = j;
    end
end
tT = data(iSession).events.key.time(strcmp(data(iSession).events.key.char,'t'));
tScanStart = tT(1);

%% Get Motion data

[err,motion] = Read_1D(motion_file);

%%
nRows = ceil(sqrt(nComps));
nCols = ceil(nComps/nRows);
for i=1:nComps
    subplot(nRows,nCols,i); cla; hold on;
    plot(tParadigm-tScanStart,blockData);
    plot(t,ts(:,i));
    if ismember(i,iAccepted)
        ylabel(sprintf('*comp %d*',i));
    else
        ylabel(sprintf('comp %d',i));
    end
end



%% Pick & Plot
iComp = 2;

GUI_3View(betas(:,:,:,iComp));