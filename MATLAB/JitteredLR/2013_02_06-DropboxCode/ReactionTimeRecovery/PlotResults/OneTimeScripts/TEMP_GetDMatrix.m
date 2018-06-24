% TEMP_GetDMatrix
%
% Gets the true jitter at a 
%
% Created 9/21/12 by DJ for one-time use.

%% Load jitter
subject
[~,~,~,RT] = loadSubjectData_facecar(subject);
RT1 = RT.face;
RT2 = RT.car;
% Get truth info
jitter = -[RT1 RT2]+mean([RT1 RT2])-25; % 25 for a 50ms window
nTrials = length(jitter);


%% Make D
jlrWinOffset = -400;
jitterrange = [-300 300];
jittertime = jitterrange(1):jitterrange(2);
D = zeros(nTrials,diff(jitterrange)+1);
for i=1:nTrials
    iTime = find(jittertime>=jitter(i),1);
    if isempty(iTime), iTime = length(jittertime); end
    D(i,iTime) = 1;
end


%% plot
figure(189);
ImageSortedData(D(faces,:),jittertime,faces,jitter(faces));
ImageSortedData(D(cars,:),jittertime,cars,jitter(cars));

%% Run JLR
run_logisticregression_jittered_EM_wrapper_RT_v2p0(subject,0,'10fold',jitterrange,5,jlrWinOffset);