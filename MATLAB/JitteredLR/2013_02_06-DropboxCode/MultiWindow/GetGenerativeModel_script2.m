% GetGenerativeModel_script.m
%
% Finds a mean template and correlation matrix for stim-locked data.
% TO DO: Turn results into a Gaussian for the generative model.
%
% Created 12/20/12 by DJ.

addpath('~/Dropbox/JitteredLogisticRegression/code/');
addpath('~/Dropbox/JitteredLogisticRegression/code/ReactionTimeRecovery/');
addpath('~/Dropbox/JitteredLogisticRegression/code/MultiWindow/');

%% Load data
%'an02apr04';%'paul21apr04';
subject = 'paul21apr04';
ALLEEG = loadSubjectData_facecar(subject);

%% Assemble data
smoothwidth = 50; % width of moving average smoothing window
tWin = [200 600]; % start and end of template window
isInWin = (ALLEEG(1).times>=tWin(1) & ALLEEG(1).times<=tWin(2));
raweeg = cat(3,ALLEEG(1).data, ALLEEG(2).data);
ntrials = size(raweeg,3);
npoints = sum(isInWin);
nchans = size(raweeg,1);
% Smooth data
smootheeg = nan(size(raweeg));
for i=1:size(raweeg,3)
     smootheeg(:,:,i) = conv2(raweeg(:,:,i),ones(1,smoothwidth)/smoothwidth,'same'); % same means output will be same size as input
end

njitters = 100;
SSQ = zeros(nchans,njitters);
for k=1:njitters
    if k==1
        jitters = zeros(1,ntrials);
    else
        jitters = round(k*randn(1,ntrials));
    end
    
    data = zeros(nchans,npoints,ntrials);
    for j=1:ntrials
        data(:,:,j) = squeeze(smootheeg(:,find(isInWin)+jitters(j),j));
    end
    JMS(k) = mean(abs(jitters));
    SSQ(:,k) = sum(sum((data-repmat(mean(data,3),[1,1,ntrials])).^2,3),2);
end
figure;scatter(JMS,SSQ);
disp('hi');

%% Get PCA data and template
iComps = 1:5; % PCs to use
ncomps = numel(iComps);
pca_input = reshape(smootheeg(:,isInWin,:),size(smootheeg,1),npoints*size(smootheeg,3))';
[U,S,V] = svd(pca_input,'econ');
%%
longsmootheeg = reshape(smootheeg,size(smootheeg,1),size(smootheeg,2)*size(smootheeg,3));
longdata = diag(1./diag(S(iComps,iComps))) * V(:,iComps)'*longsmootheeg;
data = reshape(longdata,ncomps,size(smootheeg,2),size(smootheeg,3));
template = mean(data(:,isInWin,:),3);
%% Plot
plotpcs = true;
if plotpcs
    % Plot top 8 PC's
    for i=1:8
        subplot(3,3,i);cla;
        topoplot(V(:,i),ALLEEG(1).chanlocs);
        title(sprintf('comp %d',i));
        colorbar;
    end
    % Plot S and cumulative S^2
    pctVar = (diag(S).^2)/sum(diag(S).^2);
    fprintf('components [%s] account for %.2f%% of variance\n',num2str(iComps),sum(pctVar(iComps))*100);
    subplot(3,3,9);cla;
    plot([diag(S)/S(1), cumsum(pctVar)],'.-');    
    xlabel('Comp #')
    ylabel('singular value')
    legend('S','cumsum(S^2)')
    drawnow; 
end
%% Get cross-correlation matrix
jitters = zeros(1,ntrials); % TO DO: investigate how jitter changes the distribution
% Set up loop
[C, invC] = deal(nan(npoints,npoints,ncomps));
detC = nan(1,ncomps);

njitters = 100;
JMS = zeros(njitters,1);
SSQ = zeros(njitters,1);
for i=1:ncomps    
    for k=1:njitters
        if k==1
            jitters = zeros(1,ntrials);
        else
            jitters = round(k*randn(1,ntrials));
        end
        JMS(k) = mean(abs(jitters));
        
    % Assemble component data from template window (with offset)
    data_comp = zeros(npoints,ntrials);
    for j=1:ntrials
        data_comp(:,j) = squeeze(data(i,find(isInWin)+jitters(j),j));
    end
    SSQ(k) = sum(sum((data_comp-repmat(mean(data_comp,2),1,79)).^2));
    continue;
    % Find temporal cross-correlation matrix
    data_comp_demeaned = zscore(data_comp,1,2);%-repmat(template(i,:)',1,ntrials));
    %lambdaI=1;%0.01;
    p = mvnpdf(data_comp_demeaned',0,diag(diag(1/79*data_comp_demeaned*data_comp_demeaned')));% + lambdaI*eye(size(data_comp_demeaned,1)));
    disp('hi');
    [Ut,St,~] = svd(data_comp_demeaned); % temporal SVD - keep extra columns of U      
    diagSt = 1/ntrials*diag(St).^2;
    lambdaI = 0.001;
    newSt = diag([diagSt+lambdaI; lambdaI*ones(size(St,1)-size(St,2),1)]);  
    C(:,:,i) = Ut*newSt*Ut';    
    % Find determinant and inverse for use in Gaussian
    detC(i) = det(C(:,:,i));
    invC(:,:,i) = inv(C(:,:,i));    
%     C(:,:,i) = 1/ntrials*data_comp_demeaned*data_comp_demeaned';
end
    figure(108);
    subplot(ncomps,1,i);
    scatter(JMS,SSQ);
end
