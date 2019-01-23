#!/bin/bash

#RunFastLocAfniProc_swarm.sh
#
# Created 5/22/18 by DJ.

# set up
# source ./00_CommonVariables.sh
scriptDir="/data/jangrawdc/PRJ18_HaskinsStory/Scripts"
dataDir="/data/NIMH_Haskins/a182_v2"
cd $dataDir
okSubj=`ls -d h*`
cd $scriptDir
swarmFile=FastlocAfniProcSwarmCommand

# Write for each subject
rm -f $swarmFile
for subj in ${okSubj[@]}; do
    echo "bash $scriptDir/afni_A182fastloc_v2.0.sh $subj" >> $swarmFile
done

# run swarm command
jobid=`swarm -g 8 -t 1 -f $swarmFile --partition=norm --module=afni --time=4:00:00 --job-name=AfPrFL --logdir=logsDJ`
echo jobid=$jobid
