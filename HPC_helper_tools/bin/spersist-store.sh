#!/usr/bin/env bash

sp=~/.spersist

# check if you're in the right environment
if [[ ${SLURM_JOB_NAME} != "spersist" ]]
then
	echo
	echo "ERROR: `basename $0` must be run within an spersist session"
	echo "Please run 'spersist --vnc --tunnel' prior to running this script"
	echo
	exit 1
else

	# if the file exists, ask user if they want to overwrite
	if [[ -f "${sp}" ]]
	then
		echo
		echo "Overwrite .spersist?"
		read -p "(y/n): " -n 1
		echo
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			rm ${sp}
		else
			echo "~/.spersist already exists"
			echo
			exit 0
		fi
	fi

	# build the .spersist file
	# write slurm environment
	slenv=( `env | grep SLURM` )
	for ss in "${slenv[@]}"
	do
		echo "export ${ss}" >> ${sp}
	done

	# write PORT_VNC
	if [ ! -z "${PORT_VNC}" ]; then
		echo "export `env | grep PORT_VNC`" >> ${sp}
	fi

	# write the rest of the ports
	ports=( `env | egrep 'PORT[1-9].*=[0-9]{5}'` )
	for pp in "${ports[@]}"
	do
		echo "export ${pp}" >> ${sp}
	done

	echo "Environment variables written to ~/.spersist"
	echo
	exit 0
fi