#!/bin/bash

start=$(date +%s)
for (( i=0; i<=10 ; i++ ))
do
  uptime
  sleep 4

  now=$(date +%s) 
#  if (( ( now-start ) > 10 )) ; then
#    break
#  fi
done
