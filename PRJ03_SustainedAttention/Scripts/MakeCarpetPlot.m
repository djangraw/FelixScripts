function MakeCarpetPlot(filename,maskName,Opt,normalize)

% MakeCarpetPlot(filename,maskName,Opt,normalize)
%
% INPUTS:
% -filename is a string or matrix indicating an Afni brick of size MxNxP.
% filename can also be a cell array of srtings, in which case each file
% will be plotted in a separate subplot.
% -maskName is a string or matrix indicating an Afni brick of the same size.
% -Opt is a struct to be used as input to BrikLoad.
% -normalize is a binary value indicating whether you'd like to subtract
% the mean across voxels at each time point before plotting.
%
% Created 11/3/15 by DJ.
% Updated 5/23/16 by DJ - added comments and input options.

if ~exist('Opt','var') || isempty(Opt)
    Opt = struct();
end
if ~exist('normalize','var') || isempty(normalize)
    normalize=false;
end
if ~exist('maskName')
    maskName = '';
end

% Load files and call recursively.
if iscell(filename)
    nFiles = numel(filename);
    for i=1:nFiles
        fprintf('===File %d/%d===\n',i,nFiles)
        h(i)=subplot(nFiles,1,i); cla;
        MakeCarpetPlot(filename{i},maskName,Opt,normalize);
    end
    linkaxes(h);
    return
end

if ischar(filename)
    fprintf('Loading %s...\n',filename);
    [err, V, Info, ErrMessage] = BrikLoad (filename, Opt);
else
    V = filename;
end
if isempty(maskName)
    V_mask = V(:,:,:,1);
elseif ischar(maskName)
    fprintf('Loading Mask %s...\n',maskName);
    [err_mask, V_mask, Info_mask, ErrMessage_mask] = BrikLoad (maskName,struct('Frames',1));
else
    V_mask = maskName;
end

% Reshape masked-in voxels of V into 2d matrix
sizeV = size(V);
if length(sizeV)==3
    sizeV = [sizeV, 1];
end
Vvec = reshape(V,prod(sizeV(1:3)),sizeV(4));
% De-mean if requested
if normalize
    fprintf('De-meaning...\n')
    Vvec = (Vvec-repmat(mean(Vvec,2),1,size(Vvec,2)));%./repmat(std(Vvec,[],2),1,size(Vvec,2));
end


% Plot results    
fprintf('Plotting...\n')
imagesc(Vvec(V_mask(:)~=0,:));
% Annotate plot
xlabel('time (TR)');
ylabel('voxel');
title(filename,'Interpreter','None');
colorbar
colormap gray
fprintf('Done!\n')
