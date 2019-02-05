#!/bin/bash

# RunStoryIscAfniProc_swarm.sh
#
# Created 5/22/18 by DJ.
# Updated 2/4/19 by DJ - v2.0

# set up
source ./00_CommonVariables.sh
# swarmFile=StoryIscAfniProcSwarmCommand
swarmFile=StoryIscAfniProcSwarmCommand_v2.0

# Write for each subject
rm -f $swarmFile
for subj in ${okSubj[@]}; do
    # echo "bash $dataDir/afni_isc_d2.sh $subj" >> $swarmFile
    echo "bash $scriptDir/afni_A182story_v2.0.sh $subj" >> $swarmFile
done

# run swarm command
jobid=`swarm -g 8 -t 1 -f $swarmFile --partition=norm --module=afni --time=4:00:00 --job-name=AfProc --logdir=logs`
echo jobid=$jobid
