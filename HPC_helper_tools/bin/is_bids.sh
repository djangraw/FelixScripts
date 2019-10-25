#!/usr/bin/env bash
#https://github.com/bids-standard/bids-validator

# default to not use docker
docker="no"

# help file
usage() {
	echo
	echo "Usage: `basename $0` [options] directory"
	echo
	echo "[options]:"
	echo "  -h             display this help file and exit"
	echo "  -v             specify for '--verbose' option in the validator"
	echo "                   default is no verbosity"
	echo "  -docker        specify to use the latest docker image instead of singularity"
	echo "                   default is no docker (docker is not available on the HPC)"
	echo "  -simg image    specify path to singularity image"
	echo "                   default will look in the same directory as is_bids.sh"
	echo
	exit 1
}

# if no arguments are given
if [[ $# = 0 ]]; then
	usage
fi

# parse arguments and prepare
for i in $@; do :
	case "$i" in
		"-h")
			usage
		;;
		"-docker")
			docker="yes"
			shift
		;;
		"-v")
			verb="--verbose"
			shift
		;;
		"-simg")
			image=$2
			shift
		;;
		-*)
			echo
			echo "ERROR: Unknown option: $1"
			usage
			exit 1
	esac
done

# if singularity image is not assigned, look for it in is_bids.sh's directory
if [[ ! -n "$image" ]]; then
	script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	#fix: more elegant way to search for validator image
	image=`ls ${script_dir}/../bids-validator*`
	echo $image
	if [[ ${#image[@]} -gt 1 ]]; then
		echo
		echo "ERROR: more than one image found"
		echo "Please specify which you'd like with -simg"
		echo
		usage
	fi
fi

# grab the last argument and check that it's a directory
dir=`echo "$(cd "$(dirname "$i")" && pwd)/$(basename "$i")"`
if [[ ! -d "$dir" ]]; then
	echo
	echo "ERROR: $dir is not a directory..."
	echo
	usage
fi

# docker or singularity
if [[ "$docker" == "yes" ]]; then
	docker run -ti --rm -v "${dir}:/data:ro" bids/validator:latest ${verb} /data
else
	if [[ ! -f "${image}" ]]; then
		echo
		echo "ERROR: Singularity image not found"
		echo
		usage
	else
		if [[ ! `command -v singularity` ]]; then
			module load singularity
		fi
		singularity run -B ${dir}:/data ${image} ${verb} /data
	fi
fi