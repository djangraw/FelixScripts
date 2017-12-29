#!/bin/bash

# c.sh
#
# Created 12/27/17 by DJ.

# Set up
source 00_CommonVariables.sh
rm -f RemoveSrttNuisanceRegressors_swarm.sh

# For each subject, write a 1-line bash command to the swarm script
for i in `seq 0 $iLastOkSubj`;
do
  echo "bash RemoveSrttNuisanceRegressors.sh ${okSubjects[$i]}" >> RemoveSrttNuisanceRegressors_swarm.sh
done

# Run the Resulting swarm script
swarm -g 8 -t 1 -f RemoveSrttNuisanceRegressors_swarm.sh \
--partition=nimh,norm --module=afni --time=0:15:00 --job-name=RemNui
