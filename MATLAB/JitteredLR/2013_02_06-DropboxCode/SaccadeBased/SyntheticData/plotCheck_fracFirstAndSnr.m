function plotCheck_fracFirstAndSnr(filename,fracFirst_toplot,SNR_parallel_toplot,SNR_orthogonal_toplot,sigmamultiplier_toplot)

% plotCheck_fracFirstAndSnr(filename,fracFirst_toplot,SNR_parallel_toplot,S
% NR_orthogonal_toplot)
%
% NOTE: must be in JLR code directory to run properly.
%
% Created 11/23/11 by DJ (from file check_fracfirstAndSnr)
% Updated 12/12/11 by DJ - added sigmamultiplier options

%% SET UP
if nargin<1 || isempty(filename)
    filename = 'fracfirstresults_last';
end
load(filename)
if ~exist('sigmamultiplier','var') % for backward compatibility
    sigmamultiplier = 1;
end

%% SELECT FOR PLOTTING
if nargin<2 || isempty(fracFirst_toplot)
    i=1;
else
    i = find(fracFirst == fracFirst_toplot);
end
if nargin<3 || isempty(SNR_parallel_toplot)
    j=1;
else
    j = find(SNR_parallel == SNR_parallel_toplot);
end
if nargin<4 || isempty(SNR_orthogonal_toplot)
    k=1;
else
    k = find(SNR_orthogonal == SNR_orthogonal_toplot);
end
if nargin<5 || isempty(sigmamultiplier_toplot)
    l=1;
else
    l = find(sigmamultiplier == sigmamultiplier_toplot);
end


%% Plot Weights
figure(121);

subplot(1,3,1);
topoplot(startweights{i,j,k,l},ALLEEG(1).chanlocs,'electrodes','on');
title('Synth data weights')
colorbar

subplot(1,3,2);
topoplot(resweights{i,j,k,l},ALLEEG(1).chanlocs,'electrodes','on');
title('fold 1 weights')
colorbar

subplot(1,3,3);
topoplot(resfm{i,j,k,l},ALLEEG(1).chanlocs,'electrodes','on');
title('fold 1 fwd model')
colorbar

%% Plot posteriors
figure(122);
clear c
[nRows, nCols] = size(startpost{i,j,k,l});
times = (0:nCols-1)*4;

c(1) = subplot(2,2,1);
imagesc(times,1:nRows,startpost{i,j,k,l})
xlabel('time (ms)')
ylabel('trial')
title('synthetic data posteriors - synth params')
colorbar;

c(2) = subplot(2,2,2);
imagesc(times,1:nRows,respost{i,j,k,l});
xlabel('time (ms)')
ylabel('trial')
title('synthetic data posteriors - JLR results')
colorbar;

c(3) = subplot(2,2,3);
imagesc(times,1:nRows,diffpost{i,j,k,l});
xlabel('time (ms)')
ylabel('trial')
title('synthetic data posteriors - (results-synth)')
colorbar;

subplot(2,2,4);
saccadeTimes = load('../Data/3DS-TAG-2-synth/3DS-TAG-2-synth-AllSaccadesToObject.mat');
ps.saccadeTimes = saccadeTimes.target_saccades_end;
posteriors1 = computeSaccadeJitterPrior(times,ps);
ps.saccadeTimes = saccadeTimes.distractor_saccades_end;
posteriors0 = computeSaccadeJitterPrior(times,ps);
posteriors = [posteriors0;posteriors1];
diffpost_saccades = nan(size(posteriors));
for m=1:nRows
    iNon0 = find(posteriors(m,:)~=0);
    diffpost_saccades(m,1:numel(iNon0)) = diffpost{i,j,k,l}(m,iNon0);    
end
% crop out zero columns
diffpost_saccades = diffpost_saccades(:,1:find(sum(~isnan(diffpost_saccades)),1,'last'));
imagesc(diffpost_saccades);
xlabel('saccade #')
ylabel('trial')
nCorrect = nansum(nansum(abs(diffpost_saccades),2)==0);
title(sprintf('results-synth at saccade times (%d/%d=%.1f%% trials perfect)',nCorrect,nRows,nCorrect/nRows*100))
colorbar
clear posteriors* ps saccadeTimes l iNon0
    
linkaxes(c)

plotorientation = 3;

switch plotorientation
    case 1
        %%% Plot FOM's across parameters - SNR_parallel on x axis, fracFirst on y axis
        for l=1:numel(sigmamultiplier)
            figure(122+l); clf;
            for k=1:numel(SNR_orthogonal)  
                subplot(3,numel(SNR_orthogonal),k)
                imagesc(cell2mat(Azloo(:,:,k,l)))
                set(gca,'xtick',1:numel(SNR_parallel),'xticklabel',20*log10(SNR_parallel))
                set(gca,'ytick',1:numel(fracFirst),'yticklabel',fracFirst) 
                set(gca,'clim',[0 1])
                xlabel('SNR\_parallel (dB)')
                ylabel('fracFirst')
                title(['10-fold Az, SNR\_orthogonal = ' num2str(20*log10(SNR_orthogonal(k))) ' dB'])
                colorbar

                subplot(3,numel(SNR_orthogonal),k+numel(SNR_orthogonal))
                imagesc(cell2mat(weightSubspace(:,:,k,l)))
                set(gca,'clim',[0 pi])
                set(gca,'xtick',1:numel(SNR_parallel),'xticklabel',20*log10(SNR_parallel))
                set(gca,'ytick',1:numel(fracFirst),'yticklabel',fracFirst)                 
                xlabel('SNR\_parallel (dB)')
                ylabel('fracFirst')
                title(['subspace between weights, SNR\_orthogonal = ' num2str(20*log10(SNR_orthogonal(k))) ' dB'])
                colorbar


                subplot(3,numel(SNR_orthogonal),k+numel(SNR_orthogonal)*2)    
                imagesc(cell2mat(postMeanSqErr(:,:,k,l)))
                if min(cell2mat(postMeanSqErr(:))) ~= max(cell2mat(postMeanSqErr(:)))
                    caxis([min(cell2mat(postMeanSqErr(:))) max(cell2mat(postMeanSqErr(:)))])
                end
                title(['mean squared error of posteriors, SNR\_orthogonal = ' num2str(20*log10(SNR_orthogonal(k))) ' dB'])
            %     imagesc(cell2mat(pctPostCorrect(:,:,k)))
            %     caxis([0 100])
            %     title(['% posteriors correct, SNR\_orthogonal = ' num2str(20*log10(SNR_orthogonal(k))) ' dB'])
                set(gca,'xtick',1:numel(SNR_parallel),'xticklabel',20*log10(SNR_parallel))
                set(gca,'ytick',1:numel(fracFirst),'yticklabel',fracFirst) 
                xlabel('SNR\_parallel (dB)')
                ylabel('fracFirst')   
                colorbar   
            end
            MakeFigureTitle(sprintf('sigmamultiplier = %g',sigmamultiplier(l)));
        end
        
    case 2
        %%% Plot FOM's across parameters - SNR_parallel on x axis, SNR_orthogonal on y axis
        for l=1:numel(sigmamultiplier)
            figure(122+l); clf;
            for k=1:numel(fracFirst)  
                subplot(3,numel(fracFirst),k)
                imagesc(cell2mat(permute(Azloo(k,:,:,l),[3 2 1 4])))
                set(gca,'clim',[0 1])
                set(gca,'xtick',1:numel(SNR_parallel),'xticklabel',20*log10(SNR_parallel))
                set(gca,'ytick',1:numel(SNR_orthogonal),'yticklabel',20*log10(SNR_orthogonal))                 
                xlabel('SNR\_parallel (dB)')
                ylabel('SNR\_orthogonal (dB)')
                title(['10-fold Az, fracFirst = ' num2str(fracFirst(k))])
                colorbar

                subplot(3,numel(fracFirst),k+numel(fracFirst))
                imagesc(cell2mat(permute(weightSubspace(k,:,:,l),[3 2 1 4])))
                set(gca,'xtick',1:numel(SNR_parallel),'xticklabel',20*log10(SNR_parallel))
                set(gca,'ytick',1:numel(SNR_orthogonal),'yticklabel',20*log10(SNR_orthogonal)) 
                set(gca,'clim',[0 pi])
                xlabel('SNR\_parallel (dB)')
                ylabel('SNR\_orthogonal (dB)')
                title(['subspace between weights, fracFirst = ' num2str(fracFirst(k))])
                colorbar


                subplot(3,numel(fracFirst),k+numel(fracFirst)*2)    
                imagesc(cell2mat(permute(postMeanSqErr(k,:,:,l),[3 2 1 4])))
                if min(cell2mat(postMeanSqErr(:))) ~= max(cell2mat(postMeanSqErr(:)))
                    caxis([min(cell2mat(postMeanSqErr(:))) max(cell2mat(postMeanSqErr(:)))])
                end
                title(['mean squared error of posteriors, fracFirst = ' num2str(fracFirst(k))])
                set(gca,'xtick',1:numel(SNR_parallel),'xticklabel',20*log10(SNR_parallel))
                set(gca,'ytick',1:numel(SNR_orthogonal),'yticklabel',20*log10(SNR_orthogonal)) 
                xlabel('SNR\_parallel (dB)')
                ylabel('SNR\_orthogonal (dB)')   
                colorbar   
            end
            MakeFigureTitle(sprintf('sigmamultiplier = %g',sigmamultiplier(l)));
        end
        
    case 3

        %% Plot FOM's across parameters - SNR_orthogonal on x axis, fracFirst on y axis
        for l=1:numel(sigmamultiplier)
            figure(122+l); clf;
            for k=1:numel(SNR_parallel)  
                subplot(3,numel(SNR_parallel),k)
                imagesc(cell2mat(permute(Azloo(:,k,:,l),[1 3 2 4])))
                set(gca,'clim',[0 1])
                set(gca,'xtick',1:numel(SNR_orthogonal),'xticklabel',20*log10(SNR_orthogonal))
                set(gca,'ytick',1:numel(fracFirst),'yticklabel',fracFirst) 
                xlabel('SNR\_orthogonal (dB)')   
                ylabel('fracFirst')
                title(['10-fold Az, SNR\_parallel = ' num2str(20*log10(SNR_parallel(k))) ' dB'])
                colorbar

                subplot(3,numel(SNR_parallel),k+numel(SNR_parallel))
                imagesc(cell2mat(permute(weightSubspace(:,k,:,l),[1 3 2 4])))
                set(gca,'clim',[0 pi])
                set(gca,'xtick',1:numel(SNR_orthogonal),'xticklabel',20*log10(SNR_orthogonal))
                set(gca,'ytick',1:numel(fracFirst),'yticklabel',fracFirst) 
                xlabel('SNR\_orthogonal (dB)')   
                ylabel('fracFirst')
                title(['subspace between weights, SNR\_parallel = ' num2str(20*log10(SNR_parallel(k))) ' dB'])
                colorbar


                subplot(3,numel(SNR_parallel),k+numel(SNR_parallel)*2)    
                imagesc(cell2mat(permute(postMeanSqErr(:,k,:,l),[1 3 2 4])))
                if min(cell2mat(postMeanSqErr(:))) ~= max(cell2mat(postMeanSqErr(:)))
                    caxis([min(cell2mat(postMeanSqErr(:))) max(cell2mat(postMeanSqErr(:)))])
                end
                set(gca,'clim',[0 0.3])
                title(['mean squared error of posteriors, SNR\_parallel = ' num2str(20*log10(SNR_parallel(k))) ' dB'])
                set(gca,'xtick',1:numel(SNR_orthogonal),'xticklabel',20*log10(SNR_orthogonal))
                set(gca,'ytick',1:numel(fracFirst),'yticklabel',fracFirst) 
                xlabel('SNR\_orthogonal (dB)')   
                ylabel('fracFirst')
                colorbar   
            end
            MakeFigureTitle(sprintf('sigmamultiplier = %g',sigmamultiplier(l)));
        end
end