function [Az,t,vout,fwdmodels] = AverageJlrResults_AcrossSubjects(JLR,JLP)

% Created 12/6/12 by DJ.

nSubjects = numel(JLR);
% Average results within subjects
JLRavg = cell(1,nSubjects);
for i=1:nSubjects
    JLRavg{i} = AverageJlrResults(JLR{i},JLP{i});
end

%% Average results across subjects
nOffsets = numel(JLR{1}.Azloo);
[Az,t] = deal(nan(nSubjects,nOffsets));
vout = nan([size(JLRavg{1}.vout), nSubjects]);
fwdmodels = nan([size(JLRavg{1}.fwdmodels), nSubjects]);
for i=1:nSubjects
    % Compile results    
    Az(i,:) = JLR{i}.Azloo;    
    t(i,:) = JLP{i}.ALLEEG(1).times(round(JLR{i}.trainingwindowoffset...
        +JLP{i}.scope_settings.trainingwindowlength/2));
    for j=1:nOffsets
        mean_offset = sum(JLRavg{i}.postTimes.*mean(JLRavg{i}.post(:,:,j),1));
        t(i,j) = t(i,j) + mean_offset;
    end
    % Compile topo
    vout(:,:,i) = JLRavg{i}.vout;
    fwdmodels(:,:,i) = JLRavg{i}.fwdmodels;
end


