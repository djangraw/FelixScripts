#!/bin/bash

#while getopts  "abc:def:ghi" flag
#do
#  echo "$flag" $OPTIND $OPTARG
#done
#echo "Resetting"
#OPTIND=1
#while getopts  "abc:def:ghi" flag
#do
#  echo "$flag" $OPTIND $OPTARG
#done

mem="1g"
tmpdir="/scratch/$USER/igvtmp"

while getopts "m:t" flag
do
  if [ "$flag" == "m" ]; then
    mem=$OPTARG
  fi
  if [ "$flag" == "t" ]; then
    tmpdir=$OPTARG
  fi
done

echo mem = $mem
echo tmpdir = $tmpdir
