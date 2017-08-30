#!/bin/bash
# ReconstructDimonFiles subject
#
# Should be called from inside the inner directory (the one containing mr_0001, realtime, etc.)
#
# Created 3/23/17 by DJ.

# stop if error
set -e

# Parse inputs
subject=$1

# assume we're in a subject's directory
datadir=`pwd`

# Set up
# nEchoes=3
# nRuns=20
# Detect nRuns
folders=`ls -d mr*`
# folders=`ls -d mr_0002 mr_0003-e02`
for folder in $folders
do
	echo "=== Folder ${folder}... ==="
	# Split folder name if it's an echo
  cd $folder
	# get name
	all_dcm_files=($(ls *.dcm))
	scan_name=${all_dcm_files[0]%-*}
	# move back to parent directory
	cd ..
	# check if it's a localizer
	if [[ $scan_name == *"localizer"* ]] || [[ $scan_name == *"scout"* ]]; then
	  echo "---Skipping localizer scan."
		continue
	fi
	# Reconstruct file
	Dimon -dicom_org -sort_method geme_index -num_chan 1 -quit -gert_create_dataset -infile_pattern "${datadir}/${folder}/*.dcm"

	# rename file and place in parent directory
	# get scan number
	head_file=`ls OutBrick_run_*.HEAD`
	foo=${head_file##*_}
	scan_num_in=${foo%+orig.HEAD}
	# check if it's a multi-echo
	if [[ $folder == *"-e"* ]]; then
	  echoNum=${folder#*-e}
		scan_name=${scan_name}_echo${echoNum} # append echo number
	else
		scan_num_out=${scan_num_in} # update scan number
	fi

	echo "=== Renaming output to ../${subject}_scan${scan_num_in}_${scan_name}..."
	3drename OutBrick_run_${scan_num_in}+orig. ${subject}_scan${scan_num_out}_${scan_name}

done

# clean up: mv
mv ${subject}* ../

# clean up: mv dimon files
mkdir ../dimon_files/
mv dimon.* ../dimon_files/
mv GERT* ../dimon_files/
