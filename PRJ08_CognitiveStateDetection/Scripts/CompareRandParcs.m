function dice = CompareRandParcs(parc1,parc2)

% Created 2/22/16 by DJ.

if ischar(parc1)
    fprintf('Loading %s...\n',parc1);
    [err,parc1,Info] = BrikLoad(parc1);
end
if ischar(parc2)
    fprintf('Loading %s...\n',parc2);
    [err,parc2,Info] = BrikLoad(parc2);
end

% Get roi #s
iParcs1 = unique(parc1(parc1>0));
iParcs2 = unique(parc2(parc2>0));

% Get Dice coefficients for each ROI pair
dice = nan(numel(iParcs1),numel(iParcs2));
fprintf('Getting Dice coefficients for %dx%d ROIs...\n',numel(iParcs1),numel(iParcs2));
for i=1:numel(iParcs1)
%     fprintf('parc1 ROI %d/%d...\n',i,numel(iParcs1));
    isIn1 = parc1(:)==iParcs1(i);    
    for j=1:numel(iParcs2);
        isIn2 = parc2(:)==iParcs2(j);
        dice(i,j) = 2*sum(isIn1 & isIn2) / (sum(isIn1) + sum(isIn2));
    end
end
fprintf('Done!\n');