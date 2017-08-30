function [tParadigm,blockData] = PlotPhysioAndMotion(data,motion_file,TR)

% Created 3/31/17 by DJ.
% Updated 4/19/17 by DJ - fixed for click-track version (no count)

% Call recursively if there are multiple files
if numel(data)>1
    for i=1:numel(data)
        figure(724+i); clf;
        PlotPhysioAndMotion(data(i),motion_file{i},TR(i))
    end
    return;
end

% Load motion data

if ischar(motion_file)
    [err,motion] = Read_1D(motion_file);
else
    motion = motion_file;
end
tMotion = (0:(length(motion)-1))*TR;

% Get conditions
conditions = data.params.trialTypes;
nConditions = numel(conditions);

% Align times and plot
fprintf('Plotting...\n');
% Physio
iPhysioStart = find(data.physio.trigger.data>2,1);
tPhysioStart = data.physio.time(iPhysioStart);
tPhysio = data.physio.time-tPhysioStart;
% Paradigm
if any(ismember(data.events.display.name,conditions))
    tOff = data.events.display.time(~ismember(data.events.display.name,conditions));
else
    tOff = data.events.display.time(strcmp(data.events.display.name,'Fixation'));
end
tParadigmStart = data.events.key.time(find(strcmp(data.events.key.char,'t'),1));
tParadigmEnd = data.events.key.time(find(strcmp(data.events.key.char,'t'),1,'last'));
tParadigm = tParadigmStart:0.1:tParadigmEnd;
blockData = zeros(size(tParadigm));
for j=1:nConditions
    if any(strcmp(data.events.display.name,conditions{j}))
        tOn = data.events.display.time(strcmp(data.events.display.name,conditions{j}));
    else
        tOn = data.events.display.time(strncmp(data.events.display.name,[conditions{j} '(1/'],length(conditions{j})+3));
    end
    for k=1:numel(tOn)
        tOff_this = tOff(find(tOff>tOn(k),1));
        blockData(tParadigm>=tOn(k) & tParadigm<tOff_this) = j;
    end
end
tParadigm = tParadigm-tParadigmStart;
% Plot
subplot(3,1,1); cla; hold on;
plot(tParadigm,blockData,'b','linewidth',2);
set(gca,'ytick',1:nConditions,'yticklabel',conditions);

subplot(3,1,2); cla; hold on;
plot(tPhysio,data.physio.resp.data,'k','linewidth',2);
PlotVerticalLines(tParadigm(diff(blockData)>0),'k:');
ylabel(sprintf('respiration signal (%s)',data.physio.resp.units));

subplot(3,1,3); cla; hold on;
plot(tMotion,motion);
PlotVerticalLines(tParadigm(diff(blockData)>0),'k:');
xlabel('time from start of scan (s)');
ylabel('motion (mm/deg)');
labels = {'\Delta A-P','\DeltaR-L','\DeltaI-S','Yaw','Pitch','Roll'};
legend(labels);

linkaxes(GetSubplots(gcf),'x');

fprintf('Done!...\n');