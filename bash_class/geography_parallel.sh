#!/bin/bash

# This script shows two ways to run a preliminary job, followed by several in parallel, and then a final consolidation step.

tag=$RANDOM
zcat geography.txt.gz > $tag.input

function reformat
{
  cat <(grep "^$1" $tag.input | sort -nk2) <(echo "--------") > $tag.file$2
  sleep $((RANDOM/4000))
  echo Done with $1!
}

{
  reformat "Africa" 1 &
  reformat "Asia" 2 &
  reformat "Europe" 3 &
  reformat "North America" 4 &
  reformat "Oceania" 5 &
  reformat "South America" 6 &
} 

wait

echo "
All done!
"
sleep 4
cat $tag.file*
rm $tag.*
