% Created 9/17/12 by DJ for one-time use.

subjects = {'an02apr04', 'jeremy15jul04','paul21apr04','robin30jun04','vivek23jun04'};
[ALLEEG,EEG,~,RT] = loadSubjectData_facecar(subjects{i});
jlrWinOffset = [-200 800];%[-500 500] - mean([RT.face RT.car]);
jitterrange = [0 0];%[-300 300];
for i=1:numel(subjects)
    ALLEEG = run_logisticregression_jittered_EM_wrapper_RT(subjects{i},0,'10fold',jitterrange,1,jlrWinOffset);
end



