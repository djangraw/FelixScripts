function generate_swarm_kmeans_image(swarm_name,shell_script_dir,shell_script_name,dir_in,bin_path,kclusters,reps,dir_out,fmt)
% generate_swarm_kmeans_image(swarm_name,shell_script_dir,shell_script_name,dir_in,kclusters,reps,dir_out,file_out,fmt)
%
% This function demonstrates a simple way to build swarm files from within 
% matlab for deploying matlab code in SLURM.
%
% Written by godlovedc@helix.nih.gov 2015-10-27
%
%
% INPUT:
%     swarm_name        = A name for the swarm file that will be saved
%     shell_script_dir  = Location of the run.sh file created by compiling
%                         the code. 
%     shell_script_name = The name of the run.sh file created by compiling
%                         the code.
%     dir_in            = Directory containing a bunch of images to be 
%                         processed
% 
% 
% OPTIONAL INPUT:
%     kclusters = k in the kmeans algorithm. i.e. the number of colors to
%                 reduce the image to (default = 3)
%     reps      = Number of times to perform kmeans clustering in search
%                 of optimal solution.  Higher reps lead to more
%                 reproducible results but also makes the function take
%                 longer to complete (default = 1)
%     dir_out   = Directory to save the new image with reduced colors
%                 (NOTE: if dir_out is specified, file_out and fmt must 
%                 also be specified.)
%     fmt       = Format of files to read and files to write 
%                 (NOTE: if fmt is specified, dir_out and file_out must 
%                 also be specified.)
%
% see also mcc2, kmeans_image, par_kmeans_image


% supply any default values if the user didn't provide them
%--------------------------------------------------------------------------
if nargin < 8, fmt       = []; end
if nargin < 7, dir_out   = []; end
if nargin < 6, reps      = 1;  end
if nargin < 5, kclusters = 3;  end


% variables for building the shell script call and saving the swarm file
%--------------------------------------------------------------------------
pathNscript = fullfile(shell_script_dir,shell_script_name); % full name of run.sh file
        
                                                    
% convert variables for supplying arguments to the shell script to strings
%--------------------------------------------------------------------------
kclusters = num2str(kclusters); % make a string
reps      = num2str(reps);      % make a string

if isempty(dir_out),  dir_out  = ['"' '[]' '"']; end % this will need special treatment in matlab script
if isempty(fmt),      fmt      = ['"' '[]' '"']; end % this will need special treatment in matlab script

% a list of all the images in the directory (the argument that changes)
file_list = dir(fullfile(dir_in,['*' fmt]));


% now iterate through all the files and make a single command to analyze
% each one
%--------------------------------------------------------------------------   
command_list = [];
for ii = 1:length(file_list)
    
    file_in  = file_list(ii).name; 
    file_out = ['out_' file_in];
     
    curr_command = sprintf('%s %s %s %s %s %s %s %s %s',...
        pathNscript,...
        bin_path,...
        dir_in,...
        file_in,...
        kclusters,...
        reps,...
        dir_out,...
        file_out,...
        fmt); % this formats a single command for each file    
    
    command_list = [command_list curr_command '\n']; %#ok<AGROW> suppress the warning (no big deal)
    
end


% create (or overwrite the previous) swarm file
%-------------------------------------------------------------------------- 
h = fopen(fullfile(shell_script_dir,swarm_name),'w+');
fprintf(h,command_list);
fclose(h);



