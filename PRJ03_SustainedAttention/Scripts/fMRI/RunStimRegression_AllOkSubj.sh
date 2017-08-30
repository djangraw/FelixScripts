#!/bin/bash
# RunStimRegression_AllOkSubj.sh
#
# Run this on Biowulf to do all 3 parts of processing in a row.
#  
# USAGE:
#   source RunStimRegression_AllOkSubj.sh
#
# Created 7/27/16 by DJ.

# Get subjects, folders, and iOkSubjects variables
source 00_CommonVariables.sh 

# Main loop
for iSubj in ${iOkSubjects[@]}; do
    # extract variables
    subj=${subjects[$iSubj]}
    outFolder=${folders[$iSubj]}
    # create batch command
cat <<EOF > 05p2_StimRegBatchCommand.$subj
#!/bin/bash
tcsh -xef 05p2_RunStimRegression.tcsh $subj $outFolder 2>&1 | tee output.05p2_RunStimRegression.$subj
EOF
    # submit job to biowiulf
    jobid[iSubj]=$(sbatch --partition=nimh 05p2_StimRegBatchCommand.$subj)
done