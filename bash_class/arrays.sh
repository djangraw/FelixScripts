#!/bin/bash

declare -a array
array=(apple pear fig)

echo There are ${#array[*]} elements in the array

echo Here are all the elements in one line: ${array[*]}

echo Here are the elements with their indices:

for (( i=0 ; i < ${#array[@]} ; i++ ))
do
  echo "  $i: ${array[$i]}"
done

