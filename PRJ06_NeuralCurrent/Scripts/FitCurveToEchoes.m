function [fits,offsets,sse,residuals] = FitCurveToEchoes(filenames,echoTimes,fitType)

% Created 8/26/15 by DJ.

% Declare defaults
if ~exist('fitType','var') || isempty(fitType)
    fitType = 'linear';
end

% Load data
fprintf('Loading data...\n')
for i=1:numel(filenames)
    fprintf('%d/%d... ',i,numel(filenames))
    V(:,:,:,:,i) = BrikLoad(filenames{i});
end
fprintf('Done!\n')
fprintf('Setting up...\n')
% Get size constants
sizeV = size(V);
nVoxels = prod(sizeV(1:3));
nT = sizeV(4);
nE = sizeV(5);

% set up for regression
fitMat = nan(2,nVoxels*nT); % matrix of fit results
sseMat = nan(1,nVoxels*nT);
residMat = nan(nE,nVoxels*nT);
fprintf('Getting %d fit...\n',fitType)
tic
switch fitType
    case 'linear'
        % reshape and transform into log space to get fit
        Vreg = reshape(log(abs(V)),nVoxels*nT,nE)';
        echoTimeReg = [ones(size(echoTimes)); -echoTimes]'; % include ones for offset
        % get least squares solution
        for i=1:size(Vreg,2)
            if mod(i,100000)==0
                fprintf('%.1f%% done\n',i/size(Vreg,2)*100);
            end
        %     solve echoTimeReg*fitMat=Vlog for fitMat
            if all(~isinf(Vreg(:,i)))
                fitMat(:,i) = echoTimeReg\Vreg(:,i);
                residMat(:,i) = Vreg(:,i)-echoTimeReg*fitMat(:,i);
                sseMat(i) = sum(residMat(:,i).^2);
            end
        end
    case 'exp'
        Vreg = reshape(V,nVoxels*nT,nE)';
        echoTimeReg = echoTimes'; % include ones for offset
        % get least squares solution
        for i=1:size(Vreg,2)
            if mod(i,100000)==0
                fprintf('%.1f%% done\n',i/size(Vreg,2)*100);
            end
        %     solve echoTimeReg*fitMat=Vlog for fitMat
            if all(Vreg(:,i)~=0)
                % Call fminsearch with a random starting point.
                start_point = rand(1, 2);
                [fitMat(:,i),sseMat(i)] = fminsearch(@(x) expfun(echoTimeReg,Vreg(:,i),x),start_point);
                [~,~,residMat(:,i)] = expfun(echoTimeReg,Vreg(:,i),fitMat(:,i));
            end
        end
end
tRun = toc;
fprintf('Done! took %.2f seconds.\n',tRun);


% mold fits back into shape of V 
fits = reshape(fitMat(2,:),sizeV(1:4));
offsets = reshape(fitMat(1,:),sizeV(1:4));
sse = reshape(sseMat,sizeV(1:4));
residuals = reshape(residMat',sizeV);


% expfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A*exp(-lambda*xdata)-ydata,
% and the FittedCurve. FMINSEARCH only needs sse, but we want
% to plot the FittedCurve at the end.
function [sse, FittedCurve, ErrorVector] = expfun(xdata,ydata,params)
    A = params(1);
    lambda = params(2);
    FittedCurve = A .* exp(-lambda * xdata);
    ErrorVector = FittedCurve - ydata;
    sse = sum(ErrorVector .^ 2);
