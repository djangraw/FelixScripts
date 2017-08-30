#!/bin/bash
module load R/2.14
BASE=gn.$RANDOM
for i in {1..22} X Y M ; do
  label=$i
  if [[ $i == [[:digit:]] ]]; then
    label=$(printf '%02d' $i)
  fi
  [[ -f $BASE/$label/trial.out ]] && break
  [[ -d $BASE/$label ]] || mkdir -p $BASE/$label
  pushd $BASE/$label 2>&1 > /dev/null
  echo Running chr${i}_out 
  # actually do something, not this
  touch trial_chr${i}.out
  popd >& /dev/null
done

