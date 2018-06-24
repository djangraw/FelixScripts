% Created 9/27/12 by DJ for one-time use
subjects = {'an02apr04', 'jeremy15jul04','paul21apr04','robin30jun04','vivek23jun04','jeremy29apr04'};
clear RTall
for i=1:numel(subjects)
    [~,~,RTall{i}] = GetJitter(subjects{i},'facecar');
end
RTvec = [RTall{:}];

%% Fit to ex-gaussian distribution

R = simple_egfit(RTvec - mean(RTvec));

%% To just use results from before
subjects = {'an02apr04', 'jeremy15jul04','paul21apr04','robin30jun04','vivek23jun04','jeremy29apr04'};
 
% R = [-100.1325   49.6453  100.1325];
