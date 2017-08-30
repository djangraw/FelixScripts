function PlotMaskTimecoursesForMovie_cvar(TC_mask,t,masks,iMasksToCheck)

% INPUTS:
% -TC_mask is an n-element cell array of matrices. Each cell is an mxp
% matrix. TC_mask{i}(j,:) is the the mean timecourse in mask i for run j
% (in units of % signal change). 
% -t is a p-element vector of the corresponding times.
% -masks is an n-element cell array of strings indicating the name of each
% mask.
% -iMasksToCheck is an optional argument determining which masks will have
% their peak frames plotted as lines with frames above them.
%
% Created 4/29/15 by DJ.

figure(168); clf;
% hAxes = subplot(2,1,2);
hAxes = axes('Position',[0.13, 0.11, 0.775, 0.775]); 
hold on;
colors = {'b','r','k','g','m','c','y'};
for i=1:numel(TC_mask)
    plot(0,0,colors{i},'linewidth',2);
end
movieFilename = 'Big_Buck_Bunny_420s_360p.mp4';
[hTC,hLines,hFrames] = deal(cell(1,numel(TC_mask)));
for i=1:numel(TC_mask)
    % get mean and stderr
    avg_Vroi = mean(TC_mask{i},1);
    std_Vroi = std(TC_mask{i},[],1);
    icvar_Vroi = avg_Vroi./std_Vroi;
    % Plot error-patched timecourse
%     [~,hTC{i}] = ErrorPatch(t,avg_Vroi,ste_Vroi,colors{i},colors{i});
    hTC{i} = plot(t,icvar_Vroi,colors{i},'linewidth',2);
    % Annotate plot
    PlotHorizontalLines(0,'k--');
    xlabel('time (s)');
    ylabel('Mean / Std Dev')
end
legend(masks,'interpreter','none')

for i=iMasksToCheck
    [hLines{i},hFrames{i}] = PlotPeakFrames(hAxes,hTC{i},12,movieFilename);
    set(hLines{i},'color',colors{i});
end

% Make a click on the axes trigger a movie.
movObj = VideoReader(movieFilename);
set(gca,'ButtonDownFcn',{@GetAndPlotMovieClip,movObj,4});

end


function GetAndPlotMovieClip(hObj,hOther, movieFilename, tWidth)
    a = get(gca,'CurrentPoint');
    tFrame = a(1,1);
%     y = a(1,2);
    % note current figure
    currentFig = gcf;
    % Get movie
    [mov, frameRate] = GetMovie(movieFilename,tFrame-tWidth/2, tFrame+tWidth/2);
    % Create figure, annotate it, and play movie
    figure(298); 
    MakeFigureTitle(sprintf('%.2f +/- %.2f s',tFrame,tWidth/2),0);
    PlayMovie(mov, frameRate, figure(298), true);
    % move focus back to other figure
    figure(currentFig);
end