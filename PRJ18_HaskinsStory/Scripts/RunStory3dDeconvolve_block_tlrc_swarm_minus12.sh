#!/bin/bash

# RunStory3dDeconvolve_block_tlrc_swarm.sh
#
# Created 5/22/18 by DJ.

# set up
source ./00_CommonVariables.sh
swarmFile=3ddBlockSwarmCommand_minus12

# Write for each subject
rm -f $swarmFile
for subj in ${okSubj[@]}; do
    echo "bash RunStory3dDeconvolve_block_tlrc_minus12.sh $subj" >> $swarmFile
done

# run swarm command
jobid=`swarm -g 2 -t 1 -f $swarmFile --partition=norm --module=afni --time=0:20:00 --job-name=3ddBlk --logdir=logsDJ`
echo jobid=$jobid
