% MakeAfniConnResultsShortcuts.m
%
% Created 2/22/18 by DJ.

analysis = 'SeedToVoxel';
rois = {'ShenAtlas.ROI167'};
roiNames = {'Shen167'};
groups = {'AllSubjects','AllSubjects(0).ReadingPC1(1)'};
groupNames = {'AllSubj','ReadingPc1'};
contrasts = {'str.uns','str(1).uns(-1)'};
contrastNames = {'Task-Rest','Str-Uns'};
% /data/jangrawdc/PRJ16_TaskFcManipulation/AfniConn/conn_project_SRTT_d3/results/secondlevel/SeedToVoxel/AllSubjects/str(1).uns(-1)/ShenAtlas.ROI167
info = GetSrttConstants();
targetDir = sprintf('%s/Results/AfniConn_d3-shortcuts',info.PRJDIR);

% make directory
mkdir(targetDir);

for i=1:numel(groups)
    for j=1:numel(contrasts)
        for k=1:numel(rois)
            oldDir = sprintf('%s/AfniConn/conn_project_SRTT_d3/results/secondlevel/%s/%s/%s/%s',...
                info.PRJDIR,analysis,groups{i},contrasts{j},rois{k});
            oldImg = sprintf('%s_%s_FcW%s.img',contrastNames{j},groupNames{i},roiNames{k});
            oldHdr = sprintf('%s_%s_FcW%s.hdr',contrastNames{j},groupNames{i},roiNames{k});
            cmd = sprintf('ln -s "%s/%s" %s',oldDir,oldImg,targetDir);
            disp(cmd);
            system(cmd);
            cmd = sprintf('ln -s "%s/%s" %s',oldDir,oldHdr,targetDir);
            disp(cmd);
            system(cmd);
        end
    end
end