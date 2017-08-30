function CompareRoiInfoToMaskEdges(subjects,fcMask)

% Created 10/20/16
%%
nSubj = numel(subjects);
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';

atlas = cell(1,nSubj);
tsnr = cell(1,nSubj);

fprintf('---Loading data...\n');
for i=1:nSubj
    % Navigate to correct folder
    cd(homedir);
    subject = sprintf('SBJ%02d',subjects(i));
    fprintf('Getting atlas & TSNR for subject %d...\n',subjects(i))
    cd(subject)
    foo = dir('AfniProc*');
    cd(foo(1).name);
    % Load
    atlas{i} = BrikLoad('Mask_EPIres_shen_1mm_268_parcellation+tlrc');
    tsnr{i} = BrikLoad(sprintf('TSNR.SBJ%02d+tlrc',subjects(i)));
end

%% Get and print results
fprintf('---Plotting results...\n');
clf;
subplot(121);
fprintf('ROI size:\n');
CompareRoiSizeToMaskEdges(fcMask,atlas);

subplot(122);
fprintf('ROI TSNR:\n');
CompareTsnrToMaskEdges(fcMask,atlas,tsnr);
fprintf('---Done!\n');
