#!/bin/bash
# CorrectForBreathing.sh
#
# USAGE:
#   bash CorrectForBreathing.sh $subj $run $outFolder
#
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#	  - run is a 3-digit string indicating the scan's scan number.
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- Many, many files.
#
# Created 4/12/17 by DJ.

# ======== SET UP ========
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj=SBJ05
fi
if [ ${#argv} > 1 ]; then
    run=${argv[1]}
else
    run=006
fi
if [ ${#argv} > 2 ]; then
    outFolder=${argv[2]}
else
    outFolder=AfniProc_MultiEcho
fi
