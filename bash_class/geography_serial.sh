#!/bin/bash

# Pick a random number between 0 and 2^15 to label the output files.  This keeps multiple users/processes from
# clobbering each other.

tag=$RANDOM

# Uncompress the data file
zcat geography.txt.gz > $tag.input

# Define a function to do the reformatting
function reformat
{

# Notice the use of named pipes
  cat <(grep "^$1" $tag.input | sort -nk2) <(echo "--------") > $tag.file$2

# Just for fun, sleep for a random time between 0 and 8 seconds
  sleep $((RANDOM/4000))
  echo Done with $1!
}

reformat "Africa" 1
reformat "Asia" 2
reformat "Europe" 3
reformat "North America" 4
reformat "Oceania" 5
reformat "South America" 6

echo "
All done!
"
sleep 4
cat $tag.file*
rm $tag.*
