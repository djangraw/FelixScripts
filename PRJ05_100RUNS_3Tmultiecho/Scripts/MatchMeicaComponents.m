% MatchMeicaComponents.m
%
% Created 4/1/15 by DJ.

% load in the components for two different runs
subject = 'SBJ01';
sessions = [1 1 2 2 3 3 5 5 6 6];
runs = [1 2 1 2 1 2 1 2 1 2];

%% Load
fprintf('===Loading Data...\n')
for i=1:numel(runs)
    fprintf('Loading run %d/%d...\n',i,numel(runs));
%     dir = sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/%s_S%02d/D01_MeicaAnalysis/Video%02d/meica.%s_S%02d_Video%02d_e1/TED/',subject,sessions(i),runs(i),subject,sessions(i),runs(i));
    dir = sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/%s_S%02d/D01_Version02.AlignByAnat.Cubic/Video%02d/TED/',subject,sessions(i),runs(i));
    [err, betas{i}, Info, ErrMessage] = BrikLoad([dir 'betas_OC.nii']);
    kappas{i} = csvread([dir 'Kappas.txt']);
    rhos{i} = csvread([dir 'Rhos.txt']);
    varex{i} = csvread([dir 'varex.txt']);
    iAccepted{i} = csvread([dir 'accepted.txt'])+1;
    TC{i} = load([dir 'meica_mix.1D']);
    nComponents(i) = size(TC{i},2);
    nT(i) = size(TC{i},1);
end
fprintf('===Done!\n')

%% Find correlations
nVoxels = size(betas{1},1)*size(betas{1},2)*size(betas{1},3);
isInBrain = mean(cat(4,betas{:}),4)~=0;
nInBrain = sum(isInBrain);

match_cell = cell(numel(betas),numel(betas));%zeros(nComponents(1),nComponents(2));
p_match_cell = match_cell;

for k=1:numel(betas)
    for l=(k+1):numel(betas)
        fprintf('run %d vs. %d',k,l);
        match_cell{k,l} = zeros(nComponents(k),nComponents(l));
        for i=1:nComponents(k)
            fprintf('.')
            for j=1:nComponents(l)
        %         match(i,j) = mean(mean(mean(betas{1}(:,:,:,i) .* betas{2}(:,:,:,j))));
                b1 = betas{k}(:,:,:,i);
                b2 = betas{l}(:,:,:,j);
                [foo,foop] = corrcoef(b1(isInBrain),b2(isInBrain)); 
                match_cell{k,l}(i,j) = foo(1,2);
                p_match_cell{k,l}(i,j) = foop(1,2);
            end
        end
        fprintf('\n');
    end
end
fprintf('Done!\n');

%% Get groups of components
iMatches = cell(size(match_cell{1,2},1),1);
for i=1:size(match_cell{1,2},1)
    iMatches{i} = [1 i];
    for j=2:numel(betas)
        newMatches = find(abs(match_cell{1,j}(i,:))>0.15);
        iMatches{i} = [iMatches{i}; j*ones(size(newMatches))',newMatches'];
    end
end

%% Plot results
match = match_cell{1,2};
figure(1); clf;
subplot(1,2,1); cla; hold on;
imagesc(abs(match)); 
colorbar
% set(gca,'clim',[-100 100]);
ylabel(sprintf('%s_S%02d_R%02d',subject,sessions(1),runs(1)),'interpreter','none');
xlabel(sprintf('%s_S%02d_R%02d',subject,sessions(2),runs(2)),'interpreter','none');
title('Component match (abs(corrcoef))')
[bestMatch1, iBest1] = max(abs(match(iAccepted{1},:)),[],2);
[bestMatch2, iBest2] = max(abs(match(:,iAccepted{2})),[],1);
plot(iBest1,iAccepted{1},'k+');
plot(iAccepted{2},iBest2,'k.');
axis([0,nComponents(2),0,nComponents(1)]+.5);
legend('Best for each row (accepted components)',...
    'Best for each column (accepted components)')

subplot(1,2,2); hold on;
xHist = linspace(0,1,50);
nMatch = hist(abs(match(:)),xHist);
nBest1 = hist([bestMatch1', bestMatch2],xHist);
plot(xHist,[nMatch/sum(nMatch); nMax/sum(nMax)]'*100);
legend('All pairs','Best match for each component')
xlabel('Match score');
ylabel('% component pairs');
title('Match score histogram');
%% View Matching areas of two specific components 
i1 = 2; i2 = 4;
% i1=8; i2=7;
% i1=30; i2=29;
combo_temp = betas{1}(:,:,:,i1).*betas{2}(:,:,:,i2);
combo_temp_sc = combo_temp/max(abs(combo_temp(:)));
comboR_sc = combo_temp_sc.*(combo_temp_sc>0);
comboG_sc = (mean(betas{1},4)~=0)*.1;
comboB_sc = -combo_temp_sc.*(combo_temp_sc<0);
combo_sc = cat(4,comboR_sc,comboG_sc,comboB_sc);
GUI_3View(combo_sc);

%% Get best match for each component


