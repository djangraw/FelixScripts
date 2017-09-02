% SteigersZ_TestScript.m
%
% Created 9/1/17 by DJ.

% Set up
r_const1=0.5;
r_const2=0.5;
r_var=0:0.01:1;
n = 19;
figure(253); clf;

[z,p] = deal(1,numel(r_var));
for i=1:numel(r_var)
    [z(i),p(i)] = SteigersZTest(r_var(i),r_const1,r_const2,n);
end
subplot(2,3,1);
plot(r_var,z);
xlabel('r12')
ylabel('z');
title(sprintf('r13=%g, r23=%g',r_const1,r_const2));

[z,p] = deal(1,numel(r_var));
for i=1:numel(r_var)
    [z(i),p(i)] = SteigersZTest(r_const1,r_var(i),r_const2,n);
end
subplot(2,3,2);
plot(r_var,z);
xlabel('r13')
ylabel('z');
title(sprintf('r12=%g, r23=%g',r_const1,r_const2));

[z,p] = deal(1,numel(r_var));
for i=1:numel(r_var)
    [z(i),p(i)] = SteigersZTest(r_const1,r_const2,r_var(i),n);
end
subplot(2,3,3);
plot(r_var,z);
xlabel('r23')
ylabel('z');
title(sprintf('r12=%g, r13=%g',r_const1,r_const2));

[z,p] = deal(numel(r_var));
for i=1:numel(r_var)
    for j=1:numel(r_var)
        [z(i,j),p(i,j)] = SteigersZTest(r_const1,r_var(i),r_var(j),n);
    end
end
z = real(z);
subplot(2,3,4);
imagesc(r_var',r_var,z);
ylabel('r13');
xlabel('r23');
title(sprintf('r12=%g',r_const1));
colorbar
set(gca,'clim',[-1 1]*5);

[z,p] = deal(numel(r_var));
for i=1:numel(r_var)
    for j=1:numel(r_var)
        [z(i,j),p(i,j)] = SteigersZTest(r_var(i),r_const1,r_var(j),n);
    end
end
z = real(z);
subplot(2,3,5);
imagesc(r_var',r_var,z);
ylabel('r12');
xlabel('r23');
title(sprintf('r13=%g',r_const1));
colorbar
set(gca,'clim',[-1 1]*5);

[z,p] = deal(numel(r_var));
for i=1:numel(r_var)
    for j=1:numel(r_var)
        [z(i,j),p(i,j)] = SteigersZTest(r_var(i),r_var(j),r_const1,n);
    end
end
z = real(z);
subplot(2,3,6);
imagesc(r_var',r_var,z);
ylabel('r12');
xlabel('r13');
title(sprintf('r23=%g',r_const1));
colorbar
set(gca,'clim',[-1 1]*5);
