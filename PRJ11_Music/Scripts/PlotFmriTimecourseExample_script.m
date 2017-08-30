% Created 5/26/17 by DJ.

V = BrikLoad('wholesong_30s+tlrc',struct('Slices',22));

M = any(V>0,4);
%%
V_mat = nan(size(V,4),sum(M(:)));
iCol=0;
for i=1:size(V,1)
    for j=1:size(V,2)
        if M(i,j)
            iCol = iCol+1;
            V_mat(:,iCol) = squeeze(V(i,j,:,:));
        end
    end
end

[X,Y] = meshgrid(1:size(V_mat,2),1:size(V_mat,1));
%%

figure(1); clf;
iCols = 1;
plot(V_mat(:,iCols)+X(:,iCols));
xlim([0 size(V_mat,1)])
ylim([min(iCols)-1 max(iCols)+2]);

%%
figure(2); clf;
iCols = 1:100;
plot(V_mat(:,iCols)+X(:,iCols));
xlim([0 size(V_mat,1)])
ylim([min(iCols)-1 max(iCols)+1]);