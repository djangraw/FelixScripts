#!/usr/bin/env bash

# check if .spersist exists on remote server
ssh ${USER}@biowulf.nih.gov "test -e ~/.spersist"

# download remote .spersist and connect
if [ $? -eq 1 ]
then
	echo
	echo "ERROR: Session information not found in biowulf.nih.gov:~/.spersist"
	echo "Please run 'spersist-store.sh' within spersist session to record session information"
	echo
	exit 1
else
	echo
	echo "Updating .spersist..."
	echo
	scp -q ${USER}@biowulf.nih.gov:~/.spersist ~
	echo
	echo "Connecting to session..."
	echo
	source ~/.spersist

	# grab number of ports
	ports=( `env | egrep 'PORT[1-9].*=[0-9]{5}'` )

	# check for at least one port, otherwise why are you here?
	if [ "${#ports[@]}" == 0 ]
	then
		echo
		echo "ERROR: No tunnels found!"
		echo "Please include at least one --tunnel in your spersist command"
		echo
		exit 1
	fi

	# build ssh command
	cmd="ssh "

	# add all the ports
	START=1
	END=${#ports[@]}
	for (( p=$START; p<=$END; p++ ))
	do
		pvar="PORT${p}"
		cmd+="-Y -t -L ${!pvar}:localhost:${!pvar} "
	done

	# add VNC, if it exists
	if [ ! -z "${PORT_VNC}" ]; then
		cmd+="-L ${PORT_VNC}:localhost:${PORT_VNC} "
	fi

	# finish building
	cmd+="biowulf.nih.gov ssh -Y -t ${SLURMD_NODENAME}"

	# connect to node
	eval ${cmd}
fi