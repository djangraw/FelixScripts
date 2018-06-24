function SessionStruct = GetEyelinkSaccadesToObject(BigSaccade,dist_threshold)

% Finds the times at which saccades were made to the object or away from it
% in each epoch.
%
% [saccade_start_times, saccade_end_times] = GetEyelinkSaccadesToObject(BigSaccade,EEG,dist_threshold,t_discrim) 
%
% Like GetEpochSaccades, but (1) works off of BigSaccade instead of EEG
% event info, and (2) allows the use of a distance threshold.
%
% INPUTS:
% -BigSaccade is a bigsaccade struct created using GetBigSaccadeStruct
% (called with the same EEG input as this function's EEG input).
% -dist_threshold is a scalar indicating the max distance from an object
% that will still count as a saccade to the object.
%
% OUTPUTS:
% -SessionStruct is a structure with fields 'target/distractor_session',
% 'target/distractor_trial_time', 'target/distractor_saccades_start/end'.
%
% Created 10/14/11 by DJ based on GetEpochSaccadesToObject
% Updated 2/6/13 by DJ - comments
 
% Set up
BS = BigSaccade;
isOk = (BS.saccade_end_disttoobj<dist_threshold); % saccades to objects
sess = unique(BS.eyelink_session(~isnan(BS.eyelink_session))); % session numbers
iTargTrial = 0;
iDisTrial = 0;
% Main loop
for i=1:numel(sess)
    tri = unique(BS.eyelink_trial_number(BS.eyelink_session==sess(i))); %trials in this session
    tri = tri(~isnan(tri)); % remove nans
    for j=1:numel(tri)
        isThis = BS.eyelink_session==sess(i) & BS.eyelink_trial_number==tri(j) & isOk; % find relevant saccades
        % Parse out info to either target or distractor fields
        if BS.eyelink_trial_istarget(find(isThis,1));
            iTargTrial = iTargTrial+1; % increment index
            S.target_session(iTargTrial) = sess(i);
            S.target_trial_time(iTargTrial) = BS.eyelink_trial_time(find(isThis,1));
            S.target_saccades_end{iTargTrial} = BS.eyelink_end_latency(isThis);
            S.target_saccades_start{iTargTrial} = BS.eyelink_start_latency(isThis);
        else
            iDisTrial = iDisTrial + 1; % incremet index
            S.distractor_session(iDisTrial) = sess(i);
            S.distractor_trial_time(iDisTrial) = BS.eyelink_trial_time(find(isThis,1));
            S.distractor_saccades_end{iDisTrial} = BS.eyelink_end_latency(isThis);
            S.distractor_saccades_start{iDisTrial} = BS.eyelink_start_latency(isThis);
        end
    end
end

SessionStruct = S;