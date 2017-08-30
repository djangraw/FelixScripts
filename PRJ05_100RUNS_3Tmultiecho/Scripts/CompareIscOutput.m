function CompareIscOutput(prefix,subject,types,nFiles)

% CompareIscOutput(subject,types,nFiles)
%
% Created 4/2/15 by DJ.

if nargin<1 || isempty(prefix)
    prefix = 'ISCpw';
end
if nargin<2 || isempty('subject')
    subject = 1;
end
if nargin<3 || isempty(types)
    types = {'OptCom-fb','MEICA-fb'};
end
if nargin<4 || isempty(nFiles)
    nFiles = 16;
end

file1 = sprintf('%s_%s_SBJ%02d_%dfiles+orig.BRIK',prefix,types{1},subject,nFiles);
file2 = sprintf('%s_%s_SBJ%02d_%dfiles+orig.BRIK',prefix,types{2},subject,nFiles);

params = struct('Frames',1);
[V1] = BrikLoad(file1,params);
[V2] = BrikLoad(file2,params);

isInMask = (V1~=0) & (V2~=0);

% Fit line
p = polyfit(V1(isInMask),V2(isInMask),1);
xFit = [min(V1(isInMask)), max(V1(isInMask))];
yFit = polyval(p,xFit);

figure(55); clf;
scatter(V1(isInMask),V2(isInMask),'.');
hold on; grid on;
plot(xFit,yFit,'r');
plot(xFit,xFit,'k--');
legend('all non-zero voxels',sprintf('fit: y=%.2f x + %.2f',p(1),p(2)),'y = x','Location','NorthWest');
xlabel(file1,'Interpreter','none');
ylabel(file2,'Interpreter','none');
title('Mean inter-run correlation coefficient across runs')

