%% Run stim-locked analysis
for i=1:numel(subjects)
    subject = subjects{i};
    [LRresp LPresp] = LoadJlrResults(subject,0,'10fold',[0 0],'_resplocked');
    [jitter,truth,RTall] = GetJitter(LPresp.ALLEEG,'facecar');
    run_logisticregression_jittered_EM_wrapper_RT_v3p0(subject,0,'10fold',[0 0],1,[-700 0]+mean(RTall),false,1e4);
end
%% Run resp-locked analysis
for i=1:numel(subjects)
    subject = subjects{i};
    run_logisticregression_jittered_EM_wrapper_RT_v3p0(subject,0,'10fold',[0 0],1,[-700 0],true,1e4);
end

%% Run resp-locked JLR
for i=1:numel(subjects)
    subject = subjects{i};
    run_logisticregression_jittered_EM_wrapper_RT_v3p0(subject,0,'10fold',[-500 500],1,[-700 0],true, 1e4);
end
