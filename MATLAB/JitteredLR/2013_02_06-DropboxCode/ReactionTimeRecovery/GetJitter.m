function [jitter,truth,RTall] = GetJitter(subject,experimenttype)

% [jitter,truth,RTall] = GetJitter(subject,experimenttype)
%                        GetJitter(ALLEEG,experimenttype)
%
% INPUTS:
% -subject is a string
% -experimenttype is a string ('facecar' or 'oddball')
% -ALLEEG is a 2-element vector of eeglab structs.
%
% OUTPUTS:
% -jitter is a vector of length n, where n is the number of trials. 
%  jitter(i) the opposite of the reaction time on trial i plus the mean of
%  all the reaction times.
% -truth is a binary vector of length n. 
%  truth(i) is true if jitter(i) is from a trial in dataset 2.
% -RTall is a vector of length n.
%  RTall(i) is the reaction time on trial i.
%
% Created 9/27/12 by DJ.

if isstruct(subject)
    ALLEEG = subject;
    switch experimenttype
        case 'facecar'
            RT1 = getRT(ALLEEG(1),'RT')-getRT(ALLEEG(1),'Stim');
            RT2 = getRT(ALLEEG(2),'RT')-getRT(ALLEEG(2),'Stim');
            RTall = [RT1 RT2];
        case 'oddball' % TO DO: CHECK THIS!
            RT1 = getRT(ALLEEG(1),200)-getRT(ALLEEG(1),50);
            RT2 = gETRT(ALLEEG(2),150)-getRT(ALLEEG(2),100);
            RTall = [RT1 RT2];
    end 
elseif ischar(subject)
    switch experimenttype
        case 'facecar'
            [ALLEEG,~,~,RT] = loadSubjectData_facecar(subject);
            RTall = [RT.car, RT.face];
        case 'oddball'
            [ALLEEG,~,~,RT] = loadSubjectData_oddball(subject);
            RTall = [RT.standard, RT.oddball];
    end
end
    
truth = [zeros(1,ALLEEG(1).trials), ones(1,ALLEEG(2).trials)];
jitter = -RTall + mean(RTall);