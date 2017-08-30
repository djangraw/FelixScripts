function [tcClustered, iCluster, order]  = ClusterRois(tc,nClusters)

% Use k-means to find clusters of ROIs (based on their timecourses).
%
% [tcClustered, iCluster, order]  = ClusterRois(tc,nClusters)
%
% INPUTS:
% -tc is a nxt matrix containing the timecourse of activity in each ROI (as
% extracted, for example, using GetTimecourseInRoi.m.
% -nClusters is a scalar indicating the number of clusters you would like
% to extract.
%
% OUTPUTS:
% -tcClustered is the input matrix tc with the rows reordered so that
% clusters are near each other.
% -iCluster is an n-element vector in which iCluster(i) is the number of
% the cluster to which ROI i belongs.
% -order is an n-element vector in which order(i) is the new index of rois
% in tcClustered. That is, tcClustered(i,:) = tc(order(i),:).
%
% Created 11/18/15 by DJ.

[N,T] = size(tc);
% de-mean
tc_norm = nan(size(tc));
for i=1:N
    tc_norm(i,:) = (tc(i,:) - mean(tc(i,:)))/std(tc(i,:));
end
% Get clusters
iCluster_orig = kmeans(tc_norm,nClusters); % get clusters of ROIs
[iCluster, order] = sort(iCluster_orig,'ascend'); % reorder to group clusters together
tcClustered = tc(order,:); % apply ordering to tc

% Plot results
FC_clust_all = GetFcMatrices(tcClustered,T);
cla; hold on;
imagesc(FC_clust_all);
iClustChange = [0; find(diff(iCluster)); N];
for i=1:nClusters
    rectangle('Position',[iClustChange(i)+.5, iClustChange(i)+.5, iClustChange(i+1)-iClustChange(i), iClustChange(i+1)-iClustChange(i)]);
end