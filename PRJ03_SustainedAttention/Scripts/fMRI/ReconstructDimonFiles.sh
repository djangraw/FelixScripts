#!/bin/bash
# ReconstructDimonFiles subject
# 
# Should be called from inside the inner directory (the one containing mr_0001, realtime, etc.)
# 
# Created 10/28/15 by DJ.

# stop if error
set -e

# Parse inputs
subject=$1

# Set up
nEchoes=3
nRuns=20
let "iTaskRun=0" 1 # index of task runs (add 1 to avoid premature exit)
let "iAnatRun=0" 1 # index of anat runs (add 1 to avoid premature exit)
let "iPDRun=0" 1 # index of PD runs (add 1 to avoid premature exit)
let "iEcgRun=0" 1 # index of PD runs (add 1 to avoid premature exit)
let "iRespRun=0" 1 # index of PD runs (add 1 to avoid premature exit)
datadir=`pwd`

# FMRI DATA LOOP
for (( iRun=1; iRun<=$nRuns; iRun++ ))
do
	echo "=== Looking for run $iRun/$nRuns..."
	printf -v strRun4 "%04d" $iRun
	# if directory exists
	if [ -d "mr_${strRun4}" ]
	then
		echo "=== mr_${strRun4} exists! Looking for files..."
		# look for MPRAGE file, PD file, or task EPI file
		# if found, reconstruct it, rename it, and place it in the parent directory.
		
		# look for anat file
		if [ -f mr_${strRun4}/sagittal_anat_mp_rage_1_mm-00001.dcm ]
		then
			echo "=== Anatomy files found. Reconstructing..."
			# reconstruct file
			Dimon -dicom_org -sort_method geme_index -num_chan 1 -quit -gert_create_dataset -infile_pattern "${datadir}/mr_${strRun4}/sagittal_anat_mp_rage_1_mm*.dcm"
			# rename file and place in parent dir			
			printf -v strRun3 "%03d" $iRun		
			let iAnatRun=iAnatRun+1
			printf -v strAnatRun2 "%02d" $iAnatRun
			echo "=== Renaming output to ../${subject}_Anat${strAnatRun2}..."	
			3drename OutBrick_run_${strRun3}+orig. ${subject}_Anat${strAnatRun2}
		fi
		
		# look for PD file
		if [ -f mr_${strRun4}/sagittal_anat_pd_1_mm-00001.dcm ]
		then
			echo "=== PD files found. Reconstructing..."
			# reconstruct file
			Dimon -dicom_org -sort_method geme_index -num_chan 1 -quit -gert_create_dataset -infile_pattern "${datadir}/mr_${strRun4}/sagittal_anat_pd_1_mm*.dcm"
			# rename file and place in parent dir
			printf -v strRun3 "%03d" $iRun
			let iPDRun=iPDRun+1
			printf -v strPDRun2 "%02d" $iPDRun
			echo "=== Renaming output to ${subject}_Anat${strPDRun2}..."
			3drename OutBrick_run_${strRun3}+orig. ${subject}_PD${strPDRun2}
		fi
		
		# look for task files
		for f in mr_${strRun4}/*_v002.dcm # multiecho
		do
			if [ -e ${f} ]
			then
				echo "=== Task files found. Reconstructing..."
				# reconstruct file
				Dimon -dicom_org -sort_method geme_index -num_chan ${nEchoes} -quit -gert_create_dataset -infile_pattern "${datadir}/mr_${strRun4}/*.dcm"
				
				# increment task file index
				let iTaskRun=iTaskRun+1
				printf -v strTaskRun2 "%02d" $iTaskRun
				# rename files and place in parent dir
				echo "=== Renaming output to ${subject}_Run${strTaskRun2}_e<1-${nEchoes}>..."
				printf -v strRun3 "%03d" $iRun				
				for (( iEcho=1; iEcho<=${nEchoes}; iEcho++ ))
				do					
					printf -v strEcho3 "%03d" $iEcho
					3drename OutBrick_run_${strRun3}_chan_${strEcho3}+orig. ${subject}_Run${strTaskRun2}_e${iEcho}
				done
				break
			fi
		done
	fi

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

# clean up: mv dimon files
mkdir ../dimon_files/
mv dimon.* ../dimon_files/
mv GERT* ../dimon_files/