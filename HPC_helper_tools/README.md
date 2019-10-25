# NIH HPC helper tools

Simple shell scripts for making your life on the [NIH HPC system](https://hpc.nih.gov) easier.


## spersist helpers

The pair of spersist helper scripts store environment information about and re-connect to a continuous spersist session.
`spersist-store.sh` is a script that should be kept remotely, whereas `spersist-connect.sh` should be stored locally. 

The workflow occurs in two steps:

**1.** Create an `spersist` session (only required once after each Biowulf reboot)
  * Log onto the Biowulf login node: `ssh user@biowulf.nih.gov`
  * Load tmux `module load tmux`
  * Start a tmux session: `tmux`
  * Initiate an spersist session: `spersist --vnc --tunnel`
    - NB: At least one `--tunnel` is required, and `--vnc` is optional. Any number of `--tunnel`s greater than 1 are also accepted
  * Save your session environment variables using helper script: `spersist-store.sh`

  At this point you can keep your terminal open, or close out. As long as you do not `exit` the session, it will remain open.

`spersist-store.sh` records relevant session environment variables to `~/.spersist`, which will allow you to re-connect to the session. Perhaps unintuitively, the `.spersist` environment variables are not preserved when you re-connect to your session. If you'd like access to these variables (say to run a jupyter notebook), you can run `source ~/.spersist` or examine the file to manually enter the port numbers.

**2.** Re-connect to your `spersist` session
  * Open Terminal
  * Run helper script from your local machine: `spersist-connect.sh`


`spersist-connect.sh` downloads your remote `.spersist` file and uses it to create an ssh tunnel from your local computer to the compute node. Since we used `--vnc` in the above example you can also open a TurboVNC Desktop, if you so choose.


**Note**: It is in your best interest to set up [ssh keys](https://www.cyberciti.biz/faq/how-to-set-up-ssh-keys-on-linux-unix/) to connect to the system. Otherwise you will need to enter your password three (yes *three*) times to run `spersist-connect.sh`. The purpose of this is not to annoy you, but to 1) check the existence of the remote `.spersist` file, 2) download `.spersist`, and 3) connect to the compute node.

### .spersist environment variables
`$PORT1 ... $PORTn`: tunnels to the compute node, any number of tunnels are accepted. One example of port usage is to connect your local browser to a remote jupyter notebook:

`jupyter notebook --no-browser --port=$PORT1`

`$PORT_VNC`: VNC port, include this port to connect to a [TurboVNC](https://www.turbovnc.org/) session

The script also records all your favorite slurm environment variables.

## is_bids

This shell script helps you run the [bids-validator](https://github.com/bids-standard/bids-validator).

**HPC usage note**: Script must be run from a compute node since Singularity is not available on the login node. Use `sinteractive` or `spersist` to connect to an interactive session. See [here](https://hpc.nih.gov/docs/userguide.html) for more information.


Usage: `is_bids.sh [options] directory`

Default usage assumes that `is_bids.sh` and a bids-validator singularity image (included in this repo) are contained within the same directory.
If this is not the case or if you'd like to use another singularity image, please specify with the `-simg` option.

<pre>
[options]:  
  -h             display this help file and exit  
  -v             specify for `--verbose` option in the validator  
                     default is no verbosity  
  -docker        specify to use the latest docker image instead of singularity    
                    default is no docker (docker is not available on the HPC)  
  -simg image    specify path to singularity image  
                    default will look in the same directory as is_bids.sh  
</pre>



