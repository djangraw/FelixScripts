#!/bin/bash
# CopyPhysioFilesOnly subject
# 
# Should be called from inside the inner directory (the one containing mr_0001, realtime, etc.)
# 
# Created 10/28/15 by DJ.

# stop if error
set -e

# Parse inputs
subject=$1

# Set up
nRuns=20
let "iEcgRun=0" 1 # index of PD runs (add 1 to avoid premature exit)
let "iRespRun=0" 1 # index of PD runs (add 1 to avoid premature exit)
datadir=`pwd`

# FMRI DATA LOOP
for (( iRun=1; iRun<=$nRuns; iRun++ ))
do
	echo "=== Looking for run $iRun/$nRuns..."
	printf -v strRun4 "%04d" $iRun

	# LOOK FOR PHYSIO DATA IN REALTIME FOLDER
	# then copy and rename realtime files		
	for g in realtime/ECG*_scan_${strRun4}_*.1D # get ECG file
	do
		if [ -e ${g} ]
		then
			# update ecg file index
			let iEcgRun=iEcgRun+1
			printf -v strEcgRun2 "%02d" $iEcgRun
			echo "=== Copying ECG file to ${subject}_ECG_Run${strEcgRun2}.1D..."				
			# copy file
			cp ${g} ${subject}_ECG_Run${strEcgRun2}.1D
		else
			echo "=== ECG file ${iRun} not found!"
		fi
	done

	for g in realtime/Resp*_scan_${strRun4}_*.1D # get Resp file
	do
		if [ -e ${g} ]
		then								
			# update resp file index
			let iRespRun=iRespRun+1
			printf -v strRespRun2 "%02d" $iRespRun
			echo "=== Copying Respiration file to ${subject}_Resp_Run${strRespRun2}.1D..."
			# copy file
			cp ${g} ${subject}_Resp_Run${strRespRun2}.1D
		else
			echo "=== Resp file ${iRun} not found!"
		fi
	done

done

# clean up: mv
mv ${subject}* ../