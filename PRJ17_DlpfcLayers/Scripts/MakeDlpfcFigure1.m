% MakeDlpfcFigure1.m
%
% Plots the hypothesized fMRI response for the Alpha/Rem conditions in 
% upper layers and the Resp/NoResp conditions in deeper layers.
% 
% Created 5/21/18 by DJ.

%% Get highly sampled HRF
RT = 0.01;
P = spm_get_defaults('stats.fmri.hrf');
T = spm_get_defaults('stats.fmri.t');

[hrf,p] = spm_hrf(RT,P,T);

%% Make block prediction

% declare times
tLetters = 4;
tCue = 8;
tProbe = 18;
tResp = 23;

% make time vector
n = 30/RT;
t = (1:n)*RT;
T = t(end);

% make signal vector (without HRF)
yAlp = zeros(1,n);
yAlp(t==tLetters) = 2;
yAlp(t==tCue) = .5;
yAlp(t>tCue & t<tProbe) = 3/(tProbe-tCue)*RT;
yAlp(t==tProbe) = 1;

yRem = zeros(1,n);
yRem(t==tLetters) = 2;
yRem(t==tCue) = 0;
yRem(t>tCue & t<tProbe) = 1/(tProbe-tCue)*RT;
yRem(t==tProbe) = 1;

[yRes,yNor] = deal(yAlp/4);
yRes(t==tProbe)=1;
yNor(t==tProbe)=0;

% yRes = zeros(1,n);
% yRes(t==tLetters) = 0.5;
% yRes(t==tCue) = 0.1;
% yRes(t>tCue & t<tProbe) = 1/(tProbe-tCue)*RT;
% yRes(t==tProbe) = 1;
% 
% yNor = zeros(1,n);
% yNor(t==tLetters) = 0.5;
% yNor(t==tCue) = 0.1;
% yNor(t>tCue & t<tProbe) = 1/(tProbe-tCue)*RT;
% yNor(t==tProbe) = 0;

% convolve with HRF
clear y;
y(1,:,1) = conv(yAlp,hrf,'full');
y(2,:,1) = conv(yRem,hrf,'full');
y(1,:,2) = conv(yRes,hrf,'full');
y(2,:,2) = conv(yNor,hrf,'full');
y(2,:,:) = y(2,:,:) - 8e-5; % to separate the early stuff
y = y(:,1:n,:);

% plot middle section
figure(1);
subplot(2,1,1); cla;
plot(t,[yAlp;yRem]');
subplot(2,1,2); cla;
plot(t,[yRes;yNor]');

figure(2); clf;
for i=1:2
    % Plot responses
    subplot(2,1,i); cla; hold on;
    hResp = plot(t,y(:,:,i),'linewidth',2);
    xlim([0 T]);
    yLimits = get(gca,'ylim');
    yMin = yLimits(1);
    yMax = yLimits(2);
    % Annotate plot
    PlotVerticalLines([tLetters,tCue,tProbe],'k--');
    patch([tCue,tCue,tProbe-.2,tProbe-.2],[yMin yMax yMax yMin],'k','FaceAlpha',0.2,'EdgeColor','none');
    patch([tProbe+.2,tProbe+.2,tResp,tResp],[yMin yMax yMax yMin],'k','FaceAlpha',0.2,'EdgeColor','none');
    plot([tCue+0.2,tProbe-0.2],[yMax,yMax],'k','LineWidth',2);
    plot([tProbe+0.2,tResp-0.2],[yMax,yMax],'k','LineWidth',2);
    set(gca,'xtick',[],'ytick',[]);
    ylabel('fMRI');
    if i==1
        set(hResp(1),'Color','b');
        set(hResp(2),'Color','g');
        legend('Alphabetize','Remember','Location','NorthWest');
    else
        set(hResp(1),'Color','r');
        set(hResp(2),'Color',[1 0.5 0]);
        legend('Response','No Response','Location','NorthWest');
        xlabel('Time');
    end
end