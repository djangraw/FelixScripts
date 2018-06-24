
% Load matrices for 2 models
foo1 = load(sprintf('sf-%d-TargDis-v3pt6-Matrices.mat',subject));
foo2 = load(sprintf('sf-%d-Type-v3pt6-Matrices.mat',subject));

%% Solve and get MSE
n = size(foo1.X,1);
iTest = 1:floor(n/10); % 1:n;
iTrain = (floor(n/10)+1):n; % 1:n;
lambdas = 0:0.04:1;
XTX1 = foo1.X(iTrain,:)'*foo1.X(iTrain,:);
XTY1 = full(foo1.X(iTrain,:)')*foo1.Y(iTrain,:);
XTX2 = foo2.X(iTrain,:)'*foo2.X(iTrain,:);
XTY2 = full(foo2.X(iTrain,:)')*foo2.Y(iTrain,:);

%%
[MSE1, MSE2] = deal(nan(1,numel(lambdas)));
tic
disp('Getting MSE1 & 2...')
for i=1:numel(lambdas)
    fprintf('.')
    lambda = lambdas(i);
    % Get response functions
    beta1 = full(XTX1 + lambda*eye(size(foo1.X,2)))^(-1)*XTY1;
    beta2 = full(XTX2 + lambda*eye(size(foo2.X,2)))^(-1)*XTY2;
    % Reconstruct and find error
    Y1 = full(foo1.X(iTest,:))*beta1;
    Y2 = full(foo2.X(iTest,:))*beta2;
    err1 = Y1-foo1.Y(iTest,:);
    err2 = Y2-foo2.Y(iTest,:);
    % get MSE
    MSE1(i) = mean(err1(:).^2);
    MSE2(i) = mean(err2(:).^2);
end
disp('Done!')
toc
%% get event types
% iTrain = 1:n;
% iTest = 1:n;
% get
R = load(sprintf('sf-%d-GLMresults-Type-v3pt6.mat',subject));
events = R.regressor_events{1}(2:12);
p = size(foo2.X,2);
iReg0 = 1:(2*101);
iReg1 = (2*101+1):p;
%% split model 2 into 2 steps
lambdas = 0:.04:1;
MSE3 = nan(1,numel(lambdas));
disp('Getting MSE3...')
for i=1:numel(lambdas);
    fprintf('.')
    lambda = lambdas(i);
    beta3p0 = full(XTX2(iReg0,iReg0) + lambda*eye(length(iReg0)))^(-1)*XTY2(iReg0,:);
    Y3p0 = full(foo2.X(:,iReg0))*beta3p0;
    resid3p0 = Y3p0-foo2.Y;
    beta3p1 = full((XTX2(iReg1,iReg1) + lambda*eye(length(iReg1)))^(-1)*foo2.X(iTrain,iReg1)')*resid3p0(iTrain,:);
    Y3p1 = full(foo2.X(iTest,iReg1))*beta3p1;
    resid3p1 = resid3p0(iTest,:)-Y3p1;
    MSE3(i) = mean(resid3p1(:).^2);
end
disp('Done!')
toc
%% Use model 1, then model 2
MSE4 = nan(1,numel(lambdas));
disp('Getting MSE4...')
for i=1:numel(lambdas);
    fprintf('.')
    lambda = lambdas(i);
    beta4p0 = full(XTX1 + lambda*eye(size(foo1.X,2)))^(-1)*XTY1;
    Y4p0 = full(foo1.X(:,:))*beta4p0;
    resid4p0 = foo2.Y-Y4p0;
    beta4p1 = full((XTX2(iReg1,iReg1) + lambda*eye(length(iReg1)))^(-1)*foo2.X(iTrain,iReg1)')*resid4p0(iTrain,:);
    Y4p1 = full(foo2.X(iTest,iReg1))*beta4p1;
    resid4p1 = resid4p0(iTest,:)-Y4p1;
    MSE4(i) = mean(resid4p1(:).^2);
end
disp('Done!')
toc
%% Use model 1, then model 2
MSE5 = nan(1,numel(lambdas));
disp('Getting MSE5...')
lambda_best = lambdas(MSE1==min(MSE1));
beta5p0 = full(XTX1 + lambda_best*eye(size(foo1.X,2)))^(-1)*XTY1;
Y5p0 = full(foo1.X(:,:))*beta5p0;
resid5p0 = foo2.Y-Y5p0;
for i=1:numel(lambdas);
    fprintf('.')
    lambda = lambdas(i);    
    beta5p1 = full((XTX2(iReg1,iReg1) + lambda*eye(length(iReg1)))^(-1)*foo2.X(iTrain,iReg1)')*resid5p0(iTrain,:);
    Y5p1 = full(foo2.X(iTest,iReg1))*beta5p1;
    resid5p1 = resid5p0(iTest,:)-Y5p1;
    MSE5(i) = mean(resid5p1(:).^2);
end
disp('Done!')
toc


%% plot results
figure;
plot(lambdas,[MSE1; MSE2; MSE3; MSE4; MSE5]');
legend('TargDis','Type','CircleStart-Type','TargDis-Type','TargDis (best \lambda)-Type')
xlabel('lambda');
ylabel('MSE');
title(sprintf('sf-%d, fold 1',subject));
save(sprintf('sf-%d-OrthogTest',subject),'MSE*','resid*','beta*','lambdas');