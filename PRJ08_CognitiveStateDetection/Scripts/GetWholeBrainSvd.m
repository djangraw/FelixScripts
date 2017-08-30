function [U,S,V] = GetSvdOfWholeBrain(data,mask)

% Created 2/23/16 by DJ.


% Load
if ischar(data)
    fprintf('Loading %s...\n',data);
    [err,data,Info] = BrikLoad(data);
end
if ischar(mask)
    fprintf('Loading %s...\n',mask);
    [err,mask,Info] = BrikLoad(mask);
end

% Reshape
fprintf('Reshaping and cropping data...\n');
[X,Y,Z,T] = size(data);
data = reshape(data,[X*Y*Z, T]);
data = data(mask>0,:);

% Run SVD
fprintf('Running SVD...\n')
tic;
[U,S,V] = svd(data,0);
t = toc;
fprintf('Done! Took %d seconds.\n',t);


