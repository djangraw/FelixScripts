function kmeans_image(dir_in,file_in,kclusters,reps,dir_out,file_out,fmt)
% kmeans_image(ipath,ifile,kclusters,reps,dir_out,file_out,fmt)
%
% This silly little function uses the kmeans clustering algorithm to reduce
% the number of colors in an image.  It is a bit like using an elephant gun
% to kill flies, but it might serve as a useful example for how to compile
% and run code in SWARM.
%
% Written by godlovedc@helix.nih.gov 2015-10-23
%
%
% INPUT:
%     dir_in    = Directory containing the image
%     file_in   = Input image file (.jpg .png .tiff etc.)
%
% OPTIONAL INPUT:
%     kclusters = k in the kmeans algorithm. i.e. the number of colors to
%                 reduce the image to (default = 3)
%     reps      = Number of times to perform kmeans clustering in search
%                 of optimal solution.  Higher reps lead to more
%                 reproducable results but also makes the function take
%                 longer to complete (default = 1)
%     dir_out   = Directory to save the new image with reduced colors
%                 (NOTE: if dir_out is specified, file_out and fmt must
%                 also be specified.)
%     file_out  = Name of the new image file to save
%                 (NOTE: if file_out is specified, dir_out and fmt must
%                 also be specified.)
%     fmt       = Format to save new file in
%                 (NOTE: if fmt is specified, dir_out and file_out must
%                 also be specified.)
%
% see also mcc2, generate_swarm_kmeans_image, par_kmeans_image


% supply any default values if the user didn't provide them
%--------------------------------------------------------------------------
if nargin < 7, fmt       = []; end
if nargin < 6, file_out  = []; end
if nargin < 5, dir_out   = []; end
if nargin < 4, reps      = 1;  end
if nargin < 3, kclusters = 3;  end


% make sure to include the following for compiling
%--------------------------------------------------------------------------
if ischar(reps),          eval(sprintf('reps = %s;',reps)),           end
if ischar(kclusters),     eval(sprintf('kclusters = %s;',kclusters)), end
if strcmp(dir_out,'[]'),  eval(sprintf('dir_out = %s;',dir_out)),     end
if strcmp(file_out,'[]'), eval(sprintf('file_out = %s;',file_out)),   end
if strcmp(fmt,'[]'),      eval(sprintf('fmt = %s;',fmt)),             end


% do the analysis
%--------------------------------------------------------------------------
% read the image into pixel x pixel x rgb array
image_in = imread(fullfile(dir_in,file_in));

% convert data type from uint8 to double
image_out = double(image_in);

% reshape the image so that rows are pixels and columns are rgb values
[xx,yy,zz] = size(image_out);
image_out   = reshape(image_out,[xx*yy,zz]);

% find and cluster into kmeans
clusteri = kmeans(image_out,kclusters,'Replicates',reps);

% set each pixel equal to the mean value of the cluster it resides in
for this_cluster = 1:kclusters
    for ii = 1:3
        
        % pull out the current color
        this_rgb = image_out(:,ii);
        
        % use logical indexing to find pixels in the current cluster and
        % set them to the mean value
        this_rgb(clusteri == this_cluster) = ...
            mean(this_rgb(clusteri == this_cluster));
        
        % stick the current color back into the image
        image_out(:,ii) = this_rgb;
        
    end
end

% reshape the image back to its original size
image_out   = reshape(image_out,[xx,yy,zz]);

% convert image back into a uint8
image_out = uint8(image_out);


% save the figure if the user supplied a directory, filename, and format
%--------------------------------------------------------------------------
if ~isempty(dir_out) &&...
        ~isempty(file_out) &&...
        ~isempty(fmt)
    
    % make the output directory if it doens't exist
    if ~isdir(dir_out) 
        mkdir(dir_out) 
    end
    
    % save the output file
    imwrite(image_out,fullfile(dir_out,file_out),fmt)
    
end


% display the image in a figure window
%--------------------------------------------------------------------------
% use isdeployed when compiling so that figures are not printed from swarm
if ~isdeployed
    figure
    set(gcf,'menubar','none','position',[10 10 yy xx/2])
    hold on
    
    subplot(1,2,1)
    image(image_in)
    set(gca,'Position',[0 0 .5 1])
    axis off
    
    subplot(1,2,2)
    image(image_out)
    set(gca,'Position',[.5 0 .5 1])
    axis off
end

