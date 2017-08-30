#!/bin/bash
# 02to05_ProcessEpiData.sh
#
# Run this on Biowulf to do all 3 parts of processing in a row.
#  
# USAGE:
#   bash 02to05_ProcessEpiData.sh $subj $nRuns $echoTimes $outFolder
# 
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#	- nRuns is a scalar indicating how many runs are included (e.g., 4)
#   - echoTimes is a string with 3 comma-separated values for the echo times in ms
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- Many, many files.
#
# Created 11/20/15 by DJ.
# Updated 12/7/15 by DJ - switched to correct motion files in meica input
# Updated 12/17/15 by DJ - appended ".$outFile" to all outputs to avoid overwriting
# Updated 1/20/16 by DJ - change appending to ".$subj.$outFile" for clarity
# Updated 4/19/16 by DJ - switched afterany dependencies to afterok

# ======== SET UP ========
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj=SBJ05
fi
if [ ${#argv} > 1 ]; then
    nRuns=${argv[1]}
else
    nRuns=4
fi
if [ ${#argv} > 2 ]; then
    echoTimes=${argv[2]}
else
    echoTimes="14.6,26.8,39.0" #"14.7,26.9,39.1" # 17.5,35.3,53.1
fi
if [ ${#argv} > 3 ]; then
    outFolder=${argv[3]}
else
    outFolder=AfniProc_MultiEcho
fi

# Display inputs
# echo "$subj $nRuns \"$echoTimes\" $outFolder"

# Get project and output directory
source ./00_CommonVariables.sh # Get PRJDIR
output_dir="${PRJDIR}/Results/${subj}/${outFolder}"

# ======== RUN ========
# === 1. PREPROCESS AND SET UP MEICA
cat <<EOF > 02_PreprocBatchCommand.$subj
#!/bin/bash
./02_PreprocessForMeica.tcsh $subj $nRuns "$echoTimes" $outFolder 2>&1 | tee output.02_PreprocessForMeica.$subj.$outFolder
EOF
cat 02_PreprocBatchCommand.$subj
jobid1=$(sbatch --partition=nimh 02_PreprocBatchCommand.$subj)
echo "--> Job $jobid1"


# === 2. RUN MEICA SWARM JOB
# initialize Tedana swarm file
if [ -f 03_TedanaSwarmCommand.$subj ]; then
	rm 03_TedanaSwarmCommand.$subj # remove it if it exists
fi
touch 03_TedanaSwarmCommand.$subj
# Write each run's command to tedana swarm text file
runs=(`count -digits 2 1 ${nRuns}`)
for run in ${runs[@]}
do
	# Write this run's commands to a single semicolon-separated line so the commands are run in series
	cat <<EOF >> 03_TedanaSwarmCommand.$subj
module load Anaconda; source activate python27; OMP_NUM_THREADS=4; cd ${output_dir}; python ${PRJDIR}/Scripts/me-ica/meica.libs/tedana.py -e ${echoTimes} -d zcat_ffd_$subj.r${run}.nii.gz --sourceTEs=-1 --kdaw=10 --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 --label=$subj.r${run}; python ${PRJDIR}/Scripts/Meica_Report/meica_report.py -o ./meica.Report.$subj.r${run} -t TED.$subj.r${run} --overwrite  --motion dfile.r$run.1D
EOF
	
done

# Run Swarm Job
echo "swarm -g 8 -t 4 -f 03_TedanaSwarmCommand.$subj --dependency afterok:$jobid1"
jobid2=$(swarm -g 8 -t 4 -f 03_TedanaSwarmCommand.$subj --partition=nimh --dependency afterany:$jobid1) # Must be run on Biowulf2, not Helix/Felix.
echo "--> Job $jobid2"


# === 3. RUN MEICA CLEANUP 
cat <<EOF > 04_CleanupBatchCommand.$subj
#!/bin/bash
./04_CleanUpAfterMeica.sh $subj $nRuns $outFolder 2>&1 | tee output.04_CleanUpAfterMeica.$subj.$outFolder
EOF
cat 04_CleanupBatchCommand.$subj
jobid3=$(sbatch --partition=nimh --dependency=afterok:$jobid2 04_CleanupBatchCommand.$subj)
echo "--> Job $jobid3"


# === 4. RUN REGRESSION
cat <<EOF > 05_RegressionBatchCommand.$subj
#!/bin/bash
./05_RunRegressionOnMeicaResults.tcsh $subj $nRuns "$echoTimes" $outFolder 2>&1 | tee output.05_RunRegressionOnMeicaResults.$subj.$outFolder
EOF
cat 05_RegressionBatchCommand.$subj
jobid4=$(sbatch --partition=nimh --dependency=afterok:$jobid3 05_RegressionBatchCommand.$subj)
echo "--> Job $jobid4"