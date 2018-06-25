% Created 4/6/15 by DJ.

%% Video Multi-echo: test 5-file vs. 16-file.

cd /Users/jangrawdc/Documents/PRJ05_100RUNS_3Tmultiecho/Results

Opt = struct('Frames',2); % 2nd subbrick is z scores
[err,V_e2_5f,Info_e2_5f,ErrMessage] = BrikLoad('ISCpw_Echo2-fb_SBJ01_5files+orig',Opt);
[err,V_meica_5f,Info_meica_5f,ErrMessage] = BrikLoad('ISCpw_MEICA-fb_SBJ01_5files+orig',Opt);
% Get group lifted over significance by MEICA
isLifted = V_e2_5f<2 & V_meica_5f>2;
isNotLifted = V_e2_5f<2 & V_meica_5f<2 & V_meica_5f~=0;
% Plot results
h = GUI_ScatterSelect(V_e2_5f,V_meica_5f,Info_e2_5f,Info_meica_5f,isLifted);
% save results as 'MeicaLifts5file'
%% See results in 16-file plot
[err,V_e2,Info_e2,ErrMessage] = BrikLoad('ISCpw_Echo2-fb_SBJ01_16files+orig',Opt);
[err,V_meica,Info_meica,ErrMessage] = BrikLoad('ISCpw_MEICA-fb_SBJ01_16files+orig',Opt);

h = GUI_ScatterSelect(V_e2_5f,V_e2,Info_e2_5f,Info_e2,isNotLifted);

%% plot histogram
xHist = -4:.1:14;

figure(33); clf;
subplot(2,1,1);
n_e2_nolift = hist(V_e2_5f(isNotLifted),xHist)/sum(isNotLifted(:));
n_e2_lift = hist(V_e2_5f(isLifted),xHist)/sum(isLifted(:));
plot(xHist,[n_e2_nolift;n_e2_lift]);
xlabel('z score with echo 2, 5 files');
ylabel('% of voxels')

subplot(2,1,2);
n_e2_nolift = hist(V_e2(isNotLifted),xHist)/sum(isNotLifted(:));
n_e2_lift = hist(V_e2(isLifted),xHist)/sum(isLifted(:));
plot(xHist,[n_e2_nolift;n_e2_lift]);
xlabel('z score with echo 2, 16 files');
ylabel('% of voxels')
legend('under significance with or without MEICA with 5 files','lifted over significance by MEICA with 5 files')




%% Match distributions by selecting from isNotLifted
xHist = -4:.05:14;
isKeeper = (V_e2~=0 | V_meica~=0); % in brain
% get Before Histogram
subplot(2,2,1);
is1 = (isNotLifted & isKeeper);
is2 = (isLifted & isKeeper);
[~,p_0] = kstest2(V_e2_5f(is1),V_e2_5f(is2));  
z_after = norminv(p_0); % initialize
n1 = hist(V_e2_5f(is1),xHist);
n2 = hist(V_e2_5f(is2),xHist);
n = [sum(is1(:)); sum(is2(:))];
plot(xHist,[n1;n2]);
title(sprintf('Before matching: p = %g',p_0))
%% SBS METHOD

% method = 'SBS';
method = 'Hist';
switch method
    case 'SBS'
        % set up
        chunk = ceil(500*rand(size(V_e2)));
        chunk(is2) = 0;
        while true

            is1 = (isNotLifted & isKeeper);
            is2 = (isLifted & isKeeper);
            n = cat(2,n,[sum(is1(:)); sum(is2(:))]);

            [~,p_before] = kstest2(V_e2_5f(is1),V_e2_5f(is2));            
            % Find chunk that will improve p_before the most    
            chunksInPlay = unique(chunk(is1));% | is2));
            fprintf('%d chunks in play...',numel(chunksInPlay));
            p_new = zeros(1,numel(chunksInPlay));        
            for j=1:numel(chunksInPlay)
                [~,p_new(j)] = kstest2(V_e2_5f(is1 & chunk~=chunksInPlay(j)),V_e2_5f(is2 & chunk~=chunksInPlay(j))); 
            end

            [p_after,iRemove] = max(p_new);
            if p_after<=p_before
                break
            else
                z_after = cat(2,z_after, norminv(p_after));
                fprintf('removed 1 to make Z = %g\n',z_after(end));
                isKeeper(chunk==chunksInPlay(iRemove)) = false;
        %                 % plot histogram
        %                 classhist = GetClassHist(classes,class,squarefixtime,isKeeper,histedges);
            end

        end
        z_after = cat(2,z_after, norminv(p_after));
    case 'Hist'
%         okbins = find(n2>10);
%         [minratio, iMin] = min(n1(okbins)./n2(okbins));
        minratio = 1;
        for i=2:numel(n2)
            i1 = find(isNotLifted & isKeeper & V_e2_5f>xHist(i-1) & V_e2_5f<xHist(i));
            nToKeep = round(n2(i)*minratio);
            randOrder = randperm(numel(i1));
            isKeeper(i1(randOrder(nToKeep+1:end))) = false; % throw out non-keepers
        end
end
disp('SUCCESS!');

%% get After Histogram
subplot(2,2,2)
% xHist = -4:.1:14;
is1 = (isNotLifted & isKeeper);
is2 = (isLifted & isKeeper);
n1 = hist(V_e2_5f(is1),xHist);
n2 = hist(V_e2_5f(is2),xHist);
plot(xHist,[n1;n2]);
title(sprintf('After matching: p = %g',p_after))
set(subplot(2,2,2),'ylim',get(subplot(2,2,1),'ylim'));
% disp('---BEFORE Matching:---')
% fprintf('KSTest: p = %g\n',p_0);
% for i=1:numel(classes)
%     fprintf('%s: %d examples\n',classes{i},nPerClass_before(i));
% end
% disp('---AFTER Matching:---')
% fprintf('KSTest: p = %g\n',p_after);
% for i=1:numel(classes)
%     fprintf('%s: %d examples\n',classes{i},nPerClass_after(i));
% end
% disp('---------------------');

% Plot z timecourse
subplot(2,1,2);
h_ax = plotyy(0:length(z_after)-1, n, 0:length(z_after)-1, z_after);
xlabel('iterations');
ylabel(h_ax(1),'nInClass');
legend(h_ax(1),'selected','not','Location','North');
ylabel(h_ax(2),'Z');
% ylabel('KSTest z score');

%% HIST OF RESULTS

isNotLifted2 = isNotLifted & isKeeper;
isLifted2 = isLifted & isKeeper;

figure(33); clf;
subplot(2,1,1);
n_e2_nolift = hist(V_e2_5f(isNotLifted2),xHist)/sum(isNotLifted2(:));
n_e2_lift = hist(V_e2_5f(isLifted2),xHist)/sum(isLifted2(:));
plot(xHist,cumsum([n_e2_nolift;n_e2_lift]'));
xlabel('z score with echo 2, 5 files');
ylabel('% of voxels')
p_e2_5f = ranksum(V_e2_5f(isNotLifted2),V_e2_5f(isLifted2)); 
title(sprintf('Matched distributions (n=5): ranksum p=%.3g',p_e2_5f))
legend('Not lifted to significance by MEICA', 'Lifted to significance by MEICA','Location','SouthEast');
ylim([0 1])

subplot(2,1,2);
n_e2_nolift = hist(V_e2(isNotLifted2),xHist)/sum(isNotLifted2(:));
n_e2_lift = hist(V_e2(isLifted2),xHist)/sum(isLifted2(:));
plot(xHist,cumsum([n_e2_nolift;n_e2_lift]'));
xlabel('z score with echo 2, 16 files');
ylabel('% of voxels')
legend('under significance with or without MEICA with 5 files','lifted over significance by MEICA with 5 files')
p_e2 = ranksum(V_e2(isNotLifted2),V_e2(isLifted2));
title(sprintf('Same runs with more Statistical Power (n=16): ranksum p=%.3g',p_e2))
legend('Not lifted to significance by MEICA at n=5', 'Lifted to significance by MEICA at n=5','Location','SouthEast');
ylim([0 1])

%% Scatter
Vx = V_meica_5f; Vx(Vx==0 & V_e2==0) = NaN;
h = GUI_ScatterSelect(Vx,V_e2,Info_meica_5f,Info_e2,isLifted2);
% h = GUI_ScatterSelect(Vx,V_e2,Info_meica_5f,Info_e2,isNotLifted2);
