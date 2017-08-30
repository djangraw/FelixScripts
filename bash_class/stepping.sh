#!/bin/bash

# Extended expose on math and conditionals

# Run a command in a disowned shell every 2 seconds
iterations=5
iterations_remaining=$iterations
seconds_per_step=2

# stop when we've reached the limit
while (( $iterations_remaining > 0 ))
do

# test to see if the time matches the pattern
  if (( ($(date +%s) % $seconds_per_step) == 0 )) ; then

# be chatty
    echo -n "$iterations_remaining : "

# run the commands in a subshell that has been disowned
    ( date ; sleep 10 ) &

# keep track of how many iterations remain
    ((iterations_remaining--))
  fi 

# this sleep command is not necessary, but it keeps the load down
  sleep 1
done

