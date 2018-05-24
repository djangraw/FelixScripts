#!/bin/bash

# RunStoryIscAfniProc_swarm.sh
#
# Created 5/22/18 by DJ.

# set up
source ./00_CommonVariables.sh
swarmFile=StoryIscAfniProcSwarmCommand

# Write for each subject
rm -f $swarmFile
for subj in ${okSubj[@]}; do
    echo "bash $dataDir/afni_isc_d2.sh $subj" >> $swarmFile
done

# run swarm command
jobid=`swarm -g 8 -t 1 -f $swarmFile --partition=nimh,norm --module=afni --time=4:00:00 --job-name=AfPrd2 --logdir=logsDJ`
echo jobid=$jobid
