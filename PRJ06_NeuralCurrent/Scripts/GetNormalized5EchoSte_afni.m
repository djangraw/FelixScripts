% GetNormalized5EchoSte_afni
%
% Created 10/2/15 by DJ based on Get5echoFitResiduals_afni.
% Updated 10/22/15 by DJ - save out stderr results for all voxels into AFNI
%  brick.

subject = 1;
session = 9;
runs = 8:11;
echoTimes = 15.4:14.3:(15.4+14.3*4);

[sse_allvoxels,R2_all, sse_all, V_all] = deal(cell(1,numel(runs)));
for iRun = 1:numel(runs)
    run = runs(iRun);
    fprintf('Running Run %d/%d...\n',iRun,numel(runs));
    
    for i=1:5
        filenames{i} = sprintf('SBJ%02d_S%02d_R%02d_Task_Echo%dof5_detrended+orig.BRIK',subject,session,run,i);
    end
    S0filename =  sprintf('SBJ%02d_S%02d_R%02d_Task_All_S0+orig.BRIK',subject,session,run);
    R2filename =  sprintf('SBJ%02d_S%02d_R%02d_Task_All_R2+orig.BRIK',subject,session,run);


    %% Load data
    for i=1:numel(filenames)
        [V(:,:,:,:,i),Info] = BrikLoad(filenames{i});
    end
    % Get amplitudes and decay constants
    S0 = BrikLoad(S0filename);
    R2 = BrikLoad(R2filename);

    %% Normalize each echo to have a range of 0-1, then define SSE as stderr across echoes
    fprintf('Normalizing...\n')
    for i=1:size(V,1)
        fprintf('%d/%d...\n',i,size(V,1));
        for j=1:size(V,2)
            for k=1:size(V,3)
                for m=1:size(V,5)
                    if ~all(V(i,j,k,:,m)==0)
%                         minV = min(V(i,j,k,:,m));
%                         maxV = max(V(i,j,k,:,m));
                        minV = GetValueAtPercentile(V(i,j,k,:,m),10);
                        maxV = GetValueAtPercentile(V(i,j,k,:,m),90);
                        V(i,j,k,:,m) = (V(i,j,k,:,m) - minV)/(maxV-minV);
                    end
                end
            end
        end
    end
    fprintf('Done!\n')
    sse = std(V,[],5);
    
    % RECORD THE RESULT
    sse_allvoxels{iRun} = sse;
    %% Try the GLM version
    % nVoxels = size(V,1)*size(V,2)*size(V,3);
    % Vreshaped = reshape(V,[nVoxels, size(V,4),size(V,5)]);
    % y=(isStim*1)';
    % for i=1:size(V,5)
    %     fprintf('%d/%d...\n',i,size(V,5));
    %     isOk = ~all(Vreshaped(:,:,i)==0,2);
    %     X = Vreshaped(isOk,:,i)';   
    %     betas = (X'*X)^(-1)*X'*y;
    %     Vreshaped(isOk,:,i) = (X./repmat(betas,1,size(Vreshaped,2)))';
    % end

    %% Other plot
    coords = [10 47 5; 21 48 6; 16 16 16];
    % meanR2 = nanmean(R2,4);
    isStim = false(1,size(V,4));
    isStim([1:10, 31:40, 61:70, 91:100, 121:130]+8) = true;

    legendstr = cell(1,size(V,5));
    for i=1:numel(legendstr)
        legendstr{i} = sprintf('echo %d',i);
    end

    figure(380+iRun); clf;
    subplot(2,1,1);
    % get and normalize R2 fit for this voxel
    R2_this = squeeze(R2(coords(2,1),coords(2,2),coords(2,3),:));
    minR = GetValueAtPercentile(R2_this,10);%min(R2_this);%
    maxR = GetValueAtPercentile(R2_this,90);%max(R2_this);%
    R2_this_norm = (R2_this - minR)/(maxR-minR);
    % get and normalize "sse" for this voxel
    sse_this = squeeze(sse(coords(2,1),coords(2,2),coords(2,3),:));
    minSse = GetValueAtPercentile(sse_this,10);%min(sse_this);%
    maxSse = GetValueAtPercentile(sse_this,90);%max(sse_this);%
    sse_this_norm = (sse_this - minSse)/(maxSse-minSse);

    plot([squeeze(V(coords(2,1),coords(2,2),coords(2,3),:,:)), R2_this_norm, isStim']);
    xlabel('time (samples)')
    ylabel('normalized signal')
    legend([legendstr {'R2','stim on'}]);
    title(sprintf('signal at ijk = (%d, %d, %d)',coords(2,:)))
    subplot(2,1,2);
    plot([squeeze(sse_this_norm), R2_this_norm, isStim']);
    xlabel('time (samples)')
    ylabel('stderr of normalized acitivity across echoes')
    legend({'stderr','R2','stim on'});
    title(sprintf('stderr at ijk = (%d, %d, %d)',coords(2,:)))
    
    R2_all{iRun} = R2_this_norm;
    sse_all{iRun} = sse_this_norm;
    V_all{iRun} = squeeze(V(coords(2,1),coords(2,2),coords(2,3),:,:));
end

%% Plot average results

figure(380+numel(runs)+1); clf;
subplot(2,1,1);
% get and normalize R2 fit for this voxel
R2_this = mean(cat(2,R2_all{:}),2);
minR = GetValueAtPercentile(R2_this,10);%min(R2_this);%
maxR = GetValueAtPercentile(R2_this,90);%max(R2_this);%
R2_this_norm = (R2_this - minR)/(maxR-minR);
% get and normalize "sse" for this voxel
sse_this = mean(cat(2,sse_all{:}),2);
minSse = GetValueAtPercentile(sse_this,10);%min(sse_this);%
maxSse = GetValueAtPercentile(sse_this,90);%max(sse_this);%
sse_this_norm = (sse_this - minSse)/(maxSse-minSse);
% get and normalize activity for this voxel
V_this = mean(cat(3,V_all{:}),3);
V_this_norm = V_this*nan;
for i=1:5
    minV = GetValueAtPercentile(V_this(:,i),10);%min(V_this(:,i));%
    maxV = GetValueAtPercentile(V_this(:,i),90);%max(V_this(:,i));%
    V_this_norm(:,i) = (V_this(:,i) - minV)/(maxV-minV);
end

plot([V_this_norm, R2_this_norm, isStim']);
xlabel('time (samples)')
ylabel('normalized signal')
legend([legendstr {'R2','stim on'}]);
title(sprintf('signal at ijk = (%d, %d, %d)',coords(2,:)))
subplot(2,1,2);
plot([squeeze(sse_this_norm), R2_this_norm, isStim']);
xlabel('time (samples)')
ylabel('stderr of normalized acitivity across echoes')
legend({'stderr','R2','stim on'});
title(sprintf('stderr at ijk = (%d, %d, %d)',coords(2,:)))


%% Write mean abs residuals to file
sse_allvoxels_combo = cat(4,sse_allvoxels{:});
Info2 = Info;
BrickLabs2 = '';
for i=1:numel(sse_allvoxels)
    for j=1:size(sse_allvoxels{i},5)
        BrickLabs2 = [BrickLabs2 ''];
    end            
end
outFilename = sprintf('SBJ%02d_S%02d_R%02dto%02d_Task_NormStdErr',subject,session,runs(1),runs(end));
Opt = struct('Prefix',outFilename,'OverWrite','y');
WriteBrik(sse_allvoxels_combo,Info,Opt);