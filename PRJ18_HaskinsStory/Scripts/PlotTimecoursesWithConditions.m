function PlotTimecoursesWithConditions(t,timecourses,steTimecourses,colors)
% PlotTimecoursesWithConditions(t,timecourses,steTimecourses)
%
% Created 4/10/19 by DJ.
% Updated 5/24/19 by DJ - added colors input.
    
% Set defaults
if ~exist('steTimecourses','var') || isempty(steTimecourses)
    steTimecourses = zeros(size(timecourses));
end
if ~exist('colors','var') || isempty(colors)
    colors = {'r','g','b','c','m','y','k'};
end

%% Plot
cla; hold on;
TR = 2;
for i=1:size(timecourses,2)
    ErrorPatch(t,timecourses(:,i),steTimecourses(:,i),colors{i},colors{i});
end
% title(sprintf('mean timecourse in ROI %d (%s)',iRoi,roiName));
% MakeLegend({'r','b'},{'Good Readers','Poor Readers'},[2 2],[.23 .22]);
% Show task blocks
yLimits = get(gca,'YLim');
yMax = yLimits(2);
[iAud,iVis,iBase] = GetStoryBlockTiming();
% iAud = iAud-6; iVis = iVis-6; % subtract removed TRs
iGap = find(diff(iAud)>1);
iAudStart = iAud([1 iGap+1]);
iAudEnd = iAud([iGap, end]);
iAudAll = [iAudStart;iAudEnd;nan(size(iAudStart))];
plot(iAudAll(:)*TR,yMax*ones(numel(iAudAll),1),'m-','linewidth',2)
for i=1:numel(iAudStart)
    text(mean([iAudStart(i),iAudEnd(i)])*TR,yMax*0.9,'Aud','HorizontalAlignment','center');
end

iGap = find(diff(iVis)>1);
iVisStart = iVis([1 iGap+1]);
iVisEnd = iVis([iGap, end]);
iVisAll = [iVisStart;iVisEnd;nan(size(iVisStart))];
plot(iVisAll(:)*TR,yMax*ones(numel(iVisAll),1),'c-','linewidth',2)
for i=1:numel(iAudStart)
    text(mean([iVisStart(i),iVisEnd(i)])*TR,yMax*0.9,'Vis','HorizontalAlignment','center');
end

% annotate
PlotHorizontalLines(0,'k');
xlim([t(1) t(end)]);
% legend('bottom half of readers','top half of readers','Auditory blocks','Visual blocks');
xlabel('time (sec)');
ylabel('BOLD (% signal change)');