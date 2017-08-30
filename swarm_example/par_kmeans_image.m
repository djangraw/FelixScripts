% this script goes through all of the steps to submitting a compiled matlab
% job to SLURM via swarm
% 
% Written by godlovedc@helix.nih.gov 2015-10-27
%
% see also mcc2, kmeans_image, generate_swarm_kmeans_image

% ====================================================================================
% user defined variables, parameters, and arguments (feel free to experiment!)
% ====================================================================================

% make this true if you want to recompile the matlab code
% (see ***IMPORTANT*** under STEP 2 below.)
recompile_code = true;  

% set up all the variables for the code to run
kclusters  = 7;                    % supply the "k" in "kmeans" (i.e. number of clusters)
reps       = 15;                   % how many repetitions to ensure that kmeans algorithm converges properly
dir_in     = 'lots-o-images';      % input directory (where the imput image files reside)
dir_out    = 'analyzed-images';    % output directory (where the analyzed images will be saved)
fmt        = 'png';                % format of input and output images  

% set up parameters for swarm (must all be strings)
% see the swarm and sbatch man pages for all available arguments (there are a ton!)
memory             = '1';                       % in GBs per cpu 
partition          = 'norm';                    % see freen for other ideas
processes_per_task = '1';                       % set to 2 to "pack" jobs on hyperthreaded cpus (NOT RECOMENDED for MATLAB) 
bundleN            = '1';                       % set bundleN > 1 to run several jobs sequentially on 1 cpu
time               = '00:05:00';                % "hours:minutes:seconds or days-hours:minutes:seconds"
extra_args         = '--job-name MyAwesomeJob'; % name the job for accounting and .o and .e files (optional)

% set up the environmental variable so that mcr cache will be local
user = deblank(evalc('!whoami'));
setenv('MCR_CACHE_ROOT',fullfile('/tmp',user,'mcr_cache'))

% make a few assumptions about filenames and directory structures
% ***THIS IS ONLY HERE TO MAKE SURE THE DEMO RUNS WHEREVER THE USER COPIES IT***
% ***IT'S USUALLY EASIER TO JUST HARDCODE PATHS AND FILENAMES IN THE TOP LEVEL SCRIPT AND CHANGE AS NEEDED***
swarm_name        = 'kmeans_image.swarm';                 % give the swarm file a name that you like.
dependancy_name   = 'dir2avi.job';                        % give the dependency job file a name.
shell_script_name = 'run_kmeans_image.sh';                % the name of the compiled mat code that will be called by the swarm
depend_job_name   = 'run_dir2avi.sh';                     % the name of the second matlab function we compile to run the dependant job
parent_dir        = pwd;                                  % we are going to assume all relevant subdirectories live here
dir_in            = fullfile(parent_dir,dir_in);          % get full directory location
dir_out           = fullfile(parent_dir,dir_out);         % get full directory location
swarm_dir         = fullfile(parent_dir,'swarm_output');  % where to put the swarm .o and .e files for checking later
shell_script_dir  = fullfile(parent_dir,'shell_scripts'); % where the compiled mat code is located and where the swarm file will be saved


% ====================================================================================
% Code could be passed to another user with instructions not to modify below this line
% ====================================================================================


% STEP 1) develop the code (already done)

% STEP 2) recompile the code (if the user wants it)
% ------------------------------------------------------------------------------
if recompile_code
    
    % make the directory if it doesn't exist
    if ~isdir(shell_script_dir)
        mkdir(shell_script_dir)
    end
    evalc(sprintf('!rm %s/*',shell_script_dir)); % empty the directory (quietly)    
    
    % the nodisplay and singleCompThread options will ensure our code plays 
    % nicely on the cluster
    % the -d, shell_script_dir option will send the compiled code to a
    % subdirectory keeping everything nice and neat
    mcc2('-m','-R','-nodisplay','-R','-singleCompThread','-d',shell_script_dir,'kmeans_image.m')
    mcc2('-m','-R','-nodisplay','-R','-singleCompThread','-d',shell_script_dir,'dir2avi.m')
    
end


% STEP 3a) generate the swarm script and save it 
% ------------------------------------------------------------------------------
% ***IMPORTANT: THIS IS DEPENDANT ON THE VERSION OF MATLAB USED TO COMPILE***
% This switch statement will determine the current version of matlab and 
% use that info to select the matlab component runtime (mcr).  A user could
% compile the code using one version of matlab, set the recompile_code flag
% to false, open this script in a different version of matlab and try to
% run it without recompiling the code.  This will result in an error
% because the wrong mcr will be selected.
mcr_path = '/usr/local/matlab-compiler';
mlab_ver = version('-release');
switch mlab_ver
    case '2015b'
        mcr_ver = 'v90';
    case '2015a'
        mcr_ver = 'v85';
    case '2014b'
        mcr_ver = 'v84';
    case '2013a'
        mcr_ver = 'v81';
    case '2012b'
        mcr_ver = 'v80';
end
mcr_path = fullfile(mcr_path,mcr_ver);

% make the swarm file that will be used to run the swarm
generate_swarm_kmeans_image(swarm_name,...
    shell_script_dir,...
    shell_script_name,...
    dir_in,...
    mcr_path,...
    kclusters,...
    reps,...
    dir_out,...
    fmt)


% STEP 3b) spawn the swarm
% ------------------------------------------------------------------------------
% make a subdirectory for the swarm .o and .e files and empty it
% if it already exists (this is just a convenience)
if ~isdir(swarm_dir)
    mkdir(swarm_dir)
end
evalc(sprintf('!rm %s/*',swarm_dir)); % empty the directory (quietly)

% this is the command that spawns the swarm
jobid = deblank(evalc(sprintf('!swarm -f %s -g %s -p %s -b %s -partition %s --time %s --logdir %s %s',...
    fullfile(shell_script_dir,swarm_name),...
    memory,...
    processes_per_task,...
    bundleN,...
    partition,...
    time,...
    swarm_dir,...
    extra_args...
    )));

fprintf('Spawned job number %s to analyze images.\n',jobid)


% STEP 3c) create and run any subsequent dependant jobs
% ------------------------------------------------------------------------------
% first use the jobid to make the argument that will set up the dependancy
depend_string = sprintf('--dependency=afterany:%s',jobid); 

% now save the appropriate command to a file
h = fopen(fullfile(shell_script_dir,dependancy_name),'w+');

fprintf(h,sprintf('%s %s %s %s %s',...
    fullfile(shell_script_dir,depend_job_name),...
    mcr_path,...
    dir_out,...
    'MyMovie',...
    ['.' fmt]...
    ));

fclose(h);

% and finally, call swarm again to run the dependant job
jobid = deblank(evalc(sprintf('!swarm -f %s -partition %s --time %s --logdir %s --job-name %s %s',...
    fullfile(shell_script_dir,dependancy_name),...
    partition,...
    '00:05:00',...
    swarm_dir,...
    dependancy_name,...
    depend_string...
    )));

fprintf('Spawned job number %s to make .avi file from images.\n',jobid)


% STEP 4) monitor the swarm
% ------------------------------------------------------------------------------
monitorjobs(jobid)



















































