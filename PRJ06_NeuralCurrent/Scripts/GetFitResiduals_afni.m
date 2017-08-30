function residuals = GetFitResiduals_afni(filenames,echoTimes,S0filename,T2filename)

% Created 8/17/15 by DJ as GetFitResiduals.
% Updated 9/3/15 by DJ - converted to _afni version, where fits are loaded
%  from AFNI bricks.

% Load data
for i=1:numel(filenames)
    V(:,:,:,:,i) = BrikLoad(filenames{i});
end
% Get amplitudes and decay constants
S0 = BrikLoad(S0filename);
T2 = BrikLoad(T2filename);

%% main loop
nE = size(V,5);
residuals = nan(size(V));
for i=1:size(V,1)
    for j=1:size(V,2)
        for k=1:size(V,3)
            for t=1:size(V,4)
                if S0(i,j,k,t)>0
                    Vfit = S0(i,j,k,t) * exp(T2(i,j,k,t) * echoTimes);
                    residuals(i,j,k,t,:) = reshape(Vfit,1,1,1,1,nE) - V(i,j,k,t,:);                 
                end
            end
        end
    end
end


